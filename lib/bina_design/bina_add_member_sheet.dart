import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'bina_design_tokens.dart';
import 'bina_components.dart';

/// Bottom sheet for adding a new family member.
///
/// Shows a form with name, age, relationship, and avatar color selection.
///
/// Usage:
/// ```dart
/// showModalBottomSheet(
///   context: context,
///   isScrollControlled: true,
///   backgroundColor: Colors.transparent,
///   builder: (context) => BinaAddMemberSheet(
///     onAdd: (name, age, relationship, tone) {
///       // Handle adding the member
///     },
///   ),
/// );
/// ```
class BinaAddMemberSheet extends StatefulWidget {
  const BinaAddMemberSheet({
    super.key,
    required this.onAdd,
  });

  /// Called when the user submits the form.
  /// Parameters: name, age, relationship, tone color
  final void Function(String name, int? age, String relationship, String tone) onAdd;

  @override
  State<BinaAddMemberSheet> createState() => _BinaAddMemberSheetState();
}

class _BinaAddMemberSheetState extends State<BinaAddMemberSheet> {
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  String _relationship = 'child';
  BinaAvatarTone _tone = BinaAvatarTone.aqua;

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter a name'),
          backgroundColor: BinaColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    final age = int.tryParse(_ageController.text);
    widget.onAdd(name, age, _relationship, _tone.name);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: BoxDecoration(
        color: BinaColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: BinaElevation.sh4,
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.only(bottom: bottomPadding + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 6),
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: BinaColors.lineStrong,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Add family member',
                          style: BinaType.headlineMd,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Each member gets their own scan history.',
                          style: BinaType.bodyMd.copyWith(color: BinaColors.ink2),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: BinaColors.surfaceSunken,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close_rounded,
                        color: BinaColors.ink2,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Avatar preview + tone selector
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Column(
                children: [
                  BinaAvatar(
                    name: _nameController.text.isEmpty ? '??' : _nameController.text,
                    size: 72,
                    tone: _tone,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _ToneButton(
                        tone: BinaAvatarTone.blue,
                        color: BinaColors.primary,
                        isSelected: _tone == BinaAvatarTone.blue,
                        onTap: () => setState(() => _tone = BinaAvatarTone.blue),
                      ),
                      const SizedBox(width: 8),
                      _ToneButton(
                        tone: BinaAvatarTone.coral,
                        color: BinaColors.coral,
                        isSelected: _tone == BinaAvatarTone.coral,
                        onTap: () => setState(() => _tone = BinaAvatarTone.coral),
                      ),
                      const SizedBox(width: 8),
                      _ToneButton(
                        tone: BinaAvatarTone.aqua,
                        color: BinaColors.aqua,
                        isSelected: _tone == BinaAvatarTone.aqua,
                        onTap: () => setState(() => _tone = BinaAvatarTone.aqua),
                      ),
                      const SizedBox(width: 8),
                      _ToneButton(
                        tone: BinaAvatarTone.ink,
                        color: BinaColors.ink,
                        isSelected: _tone == BinaAvatarTone.ink,
                        onTap: () => setState(() => _tone = BinaAvatarTone.ink),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Form fields
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name field
                  _SheetField(
                    label: 'Name',
                    child: TextField(
                      controller: _nameController,
                      autofocus: true,
                      style: BinaType.bodyLg,
                      onChanged: (_) => setState(() {}),
                      decoration: _inputDecoration('e.g. Maya'),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Age field
                  _SheetField(
                    label: 'Age',
                    child: TextField(
                      controller: _ageController,
                      style: BinaType.bodyLg,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: _inputDecoration('11'),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Relationship selector
                  _SheetField(
                    label: 'Relationship',
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        _RelationshipChip(
                          label: 'Child',
                          value: 'child',
                          isSelected: _relationship == 'child',
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setState(() => _relationship = 'child');
                          },
                        ),
                        _RelationshipChip(
                          label: 'Partner',
                          value: 'partner',
                          isSelected: _relationship == 'partner',
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setState(() => _relationship = 'partner');
                          },
                        ),
                        _RelationshipChip(
                          label: 'Parent',
                          value: 'parent',
                          isSelected: _relationship == 'parent',
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setState(() => _relationship = 'parent');
                          },
                        ),
                        _RelationshipChip(
                          label: 'Other',
                          value: 'other',
                          isSelected: _relationship == 'other',
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setState(() => _relationship = 'other');
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(
                children: [
                  Expanded(
                    child: BinaButton(
                      label: 'Cancel',
                      variant: BinaButtonVariant.ghost,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: BinaButton(
                      label: 'Add member',
                      variant: BinaButtonVariant.primary,
                      icon: Icons.add_rounded,
                      onPressed: _submit,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String placeholder) {
    return InputDecoration(
      hintText: placeholder,
      hintStyle: BinaType.bodyLg.copyWith(color: BinaColors.ink3),
      filled: true,
      fillColor: BinaColors.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: BinaColors.lineStrong),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: BinaColors.lineStrong),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: BinaColors.primary, width: 2),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// HELPER WIDGETS
// ═══════════════════════════════════════════════════════════════

class _SheetField extends StatelessWidget {
  const _SheetField({
    required this.label,
    required this.child,
  });

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: BinaType.labelMd.copyWith(color: BinaColors.ink2),
          ),
        ),
        child,
      ],
    );
  }
}

class _ToneButton extends StatelessWidget {
  const _ToneButton({
    required this.tone,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  final BinaAvatarTone tone;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? BinaColors.ink : Colors.transparent,
            width: 3,
          ),
          boxShadow: BinaElevation.sh1,
        ),
      ),
    );
  }
}

class _RelationshipChip extends StatelessWidget {
  const _RelationshipChip({
    required this.label,
    required this.value,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final String value;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: isSelected ? BinaColors.primary : BinaColors.surface,
          borderRadius: BorderRadius.circular(999),
          border: isSelected
              ? null
              : Border.all(color: BinaColors.line),
        ),
        child: Text(
          label,
          style: BinaType.labelMd.copyWith(
            color: isSelected ? Colors.white : BinaColors.ink,
          ),
        ),
      ),
    );
  }
}
