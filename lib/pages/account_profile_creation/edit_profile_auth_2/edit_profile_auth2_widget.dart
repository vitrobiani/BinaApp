import '/bina_design/bina_design.dart';
import '/app_core/app_util.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'edit_profile_auth2_model.dart';
export 'edit_profile_auth2_model.dart';

class EditProfileAuth2Widget extends StatefulWidget {
  const EditProfileAuth2Widget({
    super.key,
    String? title,
    String? confirmButtonText,
    required this.navigateAction,
  })  : title = title ?? 'Edit Profile',
        confirmButtonText = confirmButtonText ?? 'Save Changes';

  final String title;
  final String confirmButtonText;
  final Future Function()? navigateAction;

  @override
  State<EditProfileAuth2Widget> createState() => _EditProfileAuth2WidgetState();
}

class _EditProfileAuth2WidgetState extends State<EditProfileAuth2Widget> {
  late EditProfileAuth2Model _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => EditProfileAuth2Model());

    _model.yourNameTextController ??= TextEditingController();
    _model.yourNameFocusNode ??= FocusNode();

    _model.myBioTextController ??= TextEditingController();
    _model.myBioFocusNode ??= FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {
          _model.myBioTextController?.text =
              AppLocalizations.of(context).getText('xkqq8b0e');
        }));
  }

  @override
  void dispose() {
    _model.maybeDispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _model.formKey,
      autovalidateMode: AutovalidateMode.disabled,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Padding(
            padding: const EdgeInsets.only(left: 24),
            child: Text(widget.title, style: BinaType.displaySm),
          ),
          // Subtitle
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 0, 0),
            child: Text(
              AppLocalizations.of(context).getText('cfnr4q80'),
              style: BinaType.labelLg.copyWith(color: BinaColors.ink2),
            ),
          ),
          // Profile photo
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: BinaColors.primary100,
                  shape: BoxShape.circle,
                  border: Border.all(color: BinaColors.primary, width: 2),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(60),
                    child: CachedNetworkImage(
                      fadeInDuration: const Duration(milliseconds: 200),
                      fadeOutDuration: const Duration(milliseconds: 200),
                      imageUrl:
                          'https://images.unsplash.com/photo-1499887142886-791eca5918cd?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w0NTYyMDF8MHwxfHNlYXJjaHwxN3x8dXNlcnxlbnwwfHx8fDE2OTc4MjQ2MjZ8MA&ixlib=rb-4.0.3&q=80&w=400',
                      width: 300,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Change photo button
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 12, 0, 32),
              child: BinaButton(
                label: AppLocalizations.of(context).getText('u42j5t5x'),
                variant: BinaButtonVariant.secondary,
                onPressed: () {
                  // Change photo action
                },
              ),
            ),
          ),
          // Full Name field
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: _buildTextField(
              controller: _model.yourNameTextController!,
              focusNode: _model.yourNameFocusNode!,
              label: AppLocalizations.of(context).getText('hrubvu4m'),
              hint: AppLocalizations.of(context).getText('wdugkxi2'),
              autofillHints: const [AutofillHints.name],
              textCapitalization: TextCapitalization.words,
              validator: _model.yourNameTextControllerValidator.asValidator(context),
            ),
          ),
          // Role dropdown
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Container(
              decoration: BoxDecoration(
                color: BinaColors.surfaceSunken,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: BinaColors.line, width: 2),
              ),
              child: DropdownButtonFormField<String>(
                value: _model.dropDownValue,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context).getText('mzpep7jk'),
                  labelStyle: BinaType.labelMd.copyWith(color: BinaColors.ink2),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                style: BinaType.bodyMd,
                dropdownColor: BinaColors.surface,
                icon: Icon(Icons.keyboard_arrow_down_rounded, color: BinaColors.ink2),
                items: [
                  AppLocalizations.of(context).getText('bh82b223'),
                  AppLocalizations.of(context).getText('phu34612'),
                  AppLocalizations.of(context).getText('3u84r61z'),
                  AppLocalizations.of(context).getText('rrippote'),
                  AppLocalizations.of(context).getText('pj1vpx8r'),
                ].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (val) => safeSetState(() => _model.dropDownValue = val),
              ),
            ),
          ),
          // Bio field
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: _buildTextField(
              controller: _model.myBioTextController!,
              focusNode: _model.myBioFocusNode!,
              label: AppLocalizations.of(context).getText('evezo4gx'),
              hint: AppLocalizations.of(context).getText('15ubbgyg'),
              textCapitalization: TextCapitalization.sentences,
              maxLines: 3,
              validator: _model.myBioTextControllerValidator.asValidator(context),
            ),
          ),
          // Submit button
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
            child: SizedBox(
              width: double.infinity,
              child: BinaButton(
                label: widget.confirmButtonText,
                variant: BinaButtonVariant.primary,
                onPressed: () async {
                  if (widget.navigateAction != null) {
                    await widget.navigateAction!();
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required String hint,
    List<String>? autofillHints,
    TextCapitalization textCapitalization = TextCapitalization.none,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: BinaColors.surfaceSunken,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: BinaColors.line, width: 2),
      ),
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        autofillHints: autofillHints,
        textCapitalization: textCapitalization,
        maxLines: maxLines,
        style: BinaType.bodyMd,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: BinaType.labelMd.copyWith(color: BinaColors.ink2),
          hintText: hint,
          hintStyle: BinaType.bodyMd.copyWith(color: BinaColors.ink3),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        cursorColor: BinaColors.primary,
        validator: validator,
        inputFormatters: [
          if (!isAndroid && !isiOS && textCapitalization != TextCapitalization.none)
            TextInputFormatter.withFunction((oldValue, newValue) {
              return TextEditingValue(
                selection: newValue.selection,
                text: newValue.text.toCapitalization(textCapitalization),
              );
            }),
        ],
      ),
    );
  }
}
