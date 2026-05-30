import '/backend/schema/enums/enums.dart';
import '/backend/supabase/supabase.dart';
import '/backend/sqlite/sqlite_manager.dart';
import '/app_core/app_util.dart';
import '/bina_design/bina_design.dart';
import '/actions/actions.dart' as action_blocks;
import '/custom_code/actions/index.dart' as actions;
import '/app_core/custom_functions.dart' as functions;
import '/components/dialogs/loading_dialog.dart';
import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:provider/provider.dart';
import 'family_member_model.dart';
export 'family_member_model.dart';

class FamilyMemberWidget extends StatefulWidget {
  const FamilyMemberWidget({super.key});

  @override
  State<FamilyMemberWidget> createState() => _FamilyMemberWidgetState();
}

class _FamilyMemberWidgetState extends State<FamilyMemberWidget> {
  late FamilyMemberModel _model;
  String? _selectedGender;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => FamilyMemberModel());

    _model.nameTextController ??= TextEditingController();
    _model.nameFocusNode ??= FocusNode();

    _model.birthdayTextController ??= TextEditingController();
    _model.birthdayFocusNode ??= FocusNode();

    _model.birthdayMask = MaskTextInputFormatter(mask: '##/##/####');
    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();
    super.dispose();
  }

  Future<void> _pickBirthday() async {
    final datePickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 20)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: BinaColors.primary,
              onPrimary: Colors.white,
              surface: BinaColors.surface,
              onSurface: BinaColors.ink,
            ),
          ),
          child: child!,
        );
      },
    );

    if (datePickedDate != null) {
      safeSetState(() {
        _model.datePicked = DateTime(
          datePickedDate.year,
          datePickedDate.month,
          datePickedDate.day,
        );
        _model.birthdayTextController?.text = dateTimeFormat(
          "d/M/y",
          _model.datePicked,
          locale: AppLocalizations.of(context).languageCode,
        );
      });
    }
  }

  Future<void> _createMember() async {
    if (_model.nameTextController?.text.isEmpty ?? true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter a name'),
          backgroundColor: BinaColors.error,
        ),
      );
      return;
    }

    LoadingDialog.show(
      context: context,
      message: AppLocalizations.of(context).getText('dlg010'),
    );

    try {
      _model.uid = await actions.getUUID();

      if (AppState().UserSession.isLocalSession) {
        final birthdayTimestamp = functions.stringToUnixTimestamp(
            _model.birthdayTextController!.text);

        await SQLiteManager.instance.addFamilyMember(
          familyMemberID: _model.uid,
          accountID: AppState().UserSession.userID,
          name: _model.nameTextController!.text,
          birthday: birthdayTimestamp,
          gender: _selectedGender ?? _model.genderValue,
          relationship: 'OTHER',
          lastChecked: 0,
        );
      } else {
        _model.uInfo = await FamilyMembersTable().insert({
          'id': _model.uid,
          'account_id': AppState().UserSession.userID,
          'name': _model.nameTextController!.text,
          'birthday': supaSerialize<DateTime>(
              functions.stringToDateTime(_model.birthdayTextController!.text)),
          'gender': _selectedGender ?? _model.genderValue,
          'admin': false,
        });
      }

      await action_blocks.updateSessionFamily(context);

      if (context.mounted) {
        LoadingDialog.hide(context);
        Navigator.pop(context);
      }
    } catch (e) {
      if (context.mounted) {
        LoadingDialog.hide(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating member: $e'),
            backgroundColor: BinaColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    context.watch<AppState>();

    return Container(
      decoration: BoxDecoration(
        color: BinaColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 12, bottom: 8),
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: BinaColors.ink3.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Add Family Member',
                      style: BinaType.headlineSm,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Enter their details below',
                      style: BinaType.bodyMd.copyWith(color: BinaColors.ink2),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Name field
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _BinaTextField(
                  controller: _model.nameTextController!,
                  focusNode: _model.nameFocusNode!,
                  label: 'Name',
                  hint: 'Enter name',
                  icon: Icons.person_rounded,
                ),
              ),
              const SizedBox(height: 16),
              // Birthday field
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GestureDetector(
                  onTap: _pickBirthday,
                  child: AbsorbPointer(
                    child: _BinaTextField(
                      controller: _model.birthdayTextController!,
                      focusNode: _model.birthdayFocusNode!,
                      label: 'Birthday',
                      hint: 'DD/MM/YYYY',
                      icon: Icons.cake_rounded,
                      suffixIcon: Icons.calendar_today_rounded,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Gender selector
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Gender',
                      style: BinaType.labelMd.copyWith(color: BinaColors.ink2),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: Genders.values.map((gender) {
                        final isSelected = _selectedGender == gender.name;
                        return Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(
                              right: gender != Genders.values.last ? 10 : 0,
                            ),
                            child: GestureDetector(
                              onTap: () {
                                safeSetState(() {
                                  _selectedGender = gender.name;
                                  _model.genderValue = gender.name;
                                });
                              },
                              child: AnimatedContainer(
                                duration: BinaMotion.d1,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? BinaColors.primary100
                                      : BinaColors.surfaceSunken,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected
                                        ? BinaColors.primary
                                        : BinaColors.line,
                                    width: isSelected ? 2 : 1,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    _formatGender(gender.name),
                                    style: BinaType.labelMd.copyWith(
                                      color: isSelected
                                          ? BinaColors.primary
                                          : BinaColors.ink2,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Create button
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                child: SizedBox(
                  width: double.infinity,
                  child: BinaButton(
                    label: 'Create Member',
                    icon: Icons.add_rounded,
                    variant: BinaButtonVariant.primary,
                    onPressed: _createMember,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatGender(String gender) {
    return gender[0].toUpperCase() + gender.substring(1).toLowerCase();
  }
}

// ═══════════════════════════════════════════════════════════════
// BINA TEXT FIELD
// ═══════════════════════════════════════════════════════════════

class _BinaTextField extends StatelessWidget {
  const _BinaTextField({
    required this.controller,
    required this.focusNode,
    required this.label,
    required this.hint,
    required this.icon,
    this.suffixIcon,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String label;
  final String hint;
  final IconData icon;
  final IconData? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: BinaType.labelMd.copyWith(color: BinaColors.ink2),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: BinaColors.surfaceSunken,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: BinaColors.line),
          ),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            style: BinaType.bodyLg,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: BinaType.bodyLg.copyWith(color: BinaColors.ink3),
              prefixIcon: Icon(icon, color: BinaColors.ink2, size: 22),
              suffixIcon: suffixIcon != null
                  ? Icon(suffixIcon, color: BinaColors.ink2, size: 20)
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
