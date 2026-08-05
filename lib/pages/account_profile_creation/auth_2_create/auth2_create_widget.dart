import '/auth/supabase_auth/auth_util.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/schema/structs/index.dart';
import '/backend/sqlite/sqlite_manager.dart';
import '/backend/supabase/supabase.dart';
import '/app_core/app_drop_down.dart';
import '/app_core/app_util.dart';
import '/app_core/form_field_controller.dart';
import '/bina_design/bina_design.dart';
import '/custom_code/actions/index.dart' as actions;
import '/app_core/custom_functions.dart' as functions;
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'auth2_create_model.dart';
export 'auth2_create_model.dart';

class Auth2CreateWidget extends StatefulWidget {
  const Auth2CreateWidget({super.key});

  static String routeName = 'auth_2_Create';
  static String routePath = 'auth2Create';

  @override
  State<Auth2CreateWidget> createState() => _Auth2CreateWidgetState();
}

class _Auth2CreateWidgetState extends State<Auth2CreateWidget> {
  late Auth2CreateModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => Auth2CreateModel());

    _model.switchValue = true;
    _model.nameTextController ??= TextEditingController();
    _model.nameFocusNode ??= FocusNode();

    _model.emailAddressTextController ??= TextEditingController();
    _model.emailAddressFocusNode ??= FocusNode();

    _model.passwordTextController ??= TextEditingController();
    _model.passwordFocusNode ??= FocusNode();

    _model.ageTextController ??= TextEditingController();
    _model.ageFocusNode ??= FocusNode();
    _model.ageFocusNode!.addListener(() => safeSetState(() {}));
    _model.ageMask = MaskTextInputFormatter(mask: '##/##/####');

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Future<void> _handleCreateAccount() async {
    if (_model.switchValue!) {
      // Cloud signup via Supabase
      GoRouter.of(context).prepareAuthEvent();

      final user = await authManager.createAccountWithEmail(
        context,
        _model.emailAddressTextController.text,
        _model.passwordTextController.text,
      );
      if (user == null) return;

      await UsersInfoTable().update(
        data: {'name': _model.nameTextController.text},
        matchingRows: (rows) => rows.eqOrNull('id', currentUserUid),
      );
      await FamilyMembersTable().update(
        data: {
          'name': _model.nameTextController.text,
          'birthday': supaSerialize<DateTime>(
              functions.stringToDateTime(_model.ageTextController.text)),
          'gender': _model.genderValue,
          'relationship': 'ME',
          'admin': true,
        },
        matchingRows: (rows) => rows.eqOrNull('account_id', currentUserUid),
      );

      context.pushNamedAuth(MainHomeWidget.routeName, context.mounted);
    } else {
      // Local SQLite signup
      _model.userID = await actions.getUUID();
      _model.familyMemberID = await actions.getUUID();
      _model.hashedPW = await actions.hashPassword(
        _model.passwordTextController.text,
      );

      final birthdayTimestamp = functions.stringToUnixTimestamp(
          _model.ageTextController.text);

      try {
        await SQLiteManager.instance.registerNewUser(
          id: _model.userID!,
          email: _model.emailAddressTextController.text,
          phoneNumber: null,
          createdAt: getCurrentTimestamp.secondsSinceEpoch,
          passwordHash: _model.hashedPW!,
          familyMemberID: _model.familyMemberID!,
          name: _model.nameTextController.text,
          birthday: birthdayTimestamp,
          gender: _model.genderValue!,
          relationship: 'ME',
          lastChecked: 0,
          lastActive: 0,
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error creating account: ${e.toString().contains('UNIQUE') ? 'Email already exists' : e.toString()}',
            ),
            backgroundColor: BinaColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        return;
      }

      // Create the initial family member struct
      final familyMember = FamilyMemberStruct(
        id: _model.familyMemberID!,
        name: _model.nameTextController.text,
        birthday: birthdayTimestamp > 0
            ? DateTime.fromMillisecondsSinceEpoch(birthdayTimestamp * 1000)
            : null,
        relationship: Relationships.ME,
        admin: true,
      );

      // Populate the UserSession
      AppState().UserSession = UserSessionStruct(
        userID: _model.userID!,
        email: _model.emailAddressTextController.text,
        name: _model.nameTextController.text,
        sessionId: _model.userID!,
        family: [familyMember],
        familyAmount: 1,
        sumChecked: 0,
        isLocalSession: true,
        isMock: true,
      );

      context.goNamedAuth(MainHomeWidget.routeName, context.mounted);
    }

    safeSetState(() {});
  }

  Future<void> _selectBirthday() async {
    final datePickedDate = await showDatePicker(
      context: context,
      initialDate: getCurrentTimestamp,
      firstDate: DateTime(1900),
      lastDate: getCurrentTimestamp,
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
      });
    }

    safeSetState(() {
      _model.ageTextController?.text = dateTimeFormat(
        "d/M/y",
        _model.datePicked,
        locale: AppLocalizations.of(context).languageCode,
      );
      _model.ageMask.updateMask(
        newValue: TextEditingValue(text: _model.ageTextController!.text),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: BinaColors.surfaceAlt,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),

                  // Back button
                  BinaIconButton(
                    icon: Icons.chevron_left_rounded,
                    onPressed: () => Navigator.of(context).pop(),
                  ).animate()
                      .fadeIn(duration: 300.ms),

                  const SizedBox(height: 24),

                  // Title
                  Text(
                    'Get started',
                    style: BinaType.displaySm,
                  ).animate()
                      .fadeIn(delay: 100.ms, duration: 400.ms)
                      .moveY(begin: 20, end: 0, delay: 100.ms, duration: 400.ms),

                  const SizedBox(height: 6),

                  Text(
                    'Create a Bina account. Takes about 30 seconds.',
                    style: BinaType.bodyLg.copyWith(color: BinaColors.ink2),
                  ).animate()
                      .fadeIn(delay: 150.ms, duration: 400.ms)
                      .moveY(begin: 20, end: 0, delay: 150.ms, duration: 400.ms),

                  const SizedBox(height: 24),

                  // Storage mode switch (only on mobile)
                  if (!isWeb)
                    Container(
                      decoration: BoxDecoration(
                        color: BinaColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: BinaColors.line),
                        boxShadow: BinaElevation.sh1,
                      ),
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: _model.switchValue!
                                  ? BinaColors.primary100
                                  : BinaColors.surfaceSunken,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              _model.switchValue!
                                  ? Icons.cloud_outlined
                                  : Icons.smartphone_rounded,
                              color: _model.switchValue!
                                  ? BinaColors.primary700
                                  : BinaColors.ink2,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _model.switchValue! ? 'Cloud' : 'Local',
                                  style: BinaType.titleSm,
                                ),
                                Text(
                                  _model.switchValue!
                                      ? 'Sync across devices'
                                      : 'Data stays on device',
                                  style: BinaType.bodySm.copyWith(color: BinaColors.ink3),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: _model.switchValue!,
                            onChanged: (value) => safeSetState(() => _model.switchValue = value),
                            activeThumbColor: BinaColors.primary,
                            activeTrackColor: BinaColors.primary100,
                            inactiveThumbColor: BinaColors.ink3,
                            inactiveTrackColor: BinaColors.line,
                          ),
                        ],
                      ),
                    ).animate()
                        .fadeIn(delay: 200.ms, duration: 400.ms)
                        .moveY(begin: 20, end: 0, delay: 200.ms, duration: 400.ms),

                  if (!isWeb) const SizedBox(height: 20),

                  // Name field
                  _AuthField(
                    label: 'Full name',
                    controller: _model.nameTextController!,
                    focusNode: _model.nameFocusNode!,
                    keyboardType: TextInputType.name,
                    autofillHints: const [AutofillHints.name],
                    placeholder: 'Sarah Levin',
                  ).animate()
                      .fadeIn(delay: 250.ms, duration: 400.ms)
                      .moveY(begin: 20, end: 0, delay: 250.ms, duration: 400.ms),

                  const SizedBox(height: 16),

                  // Email field
                  _AuthField(
                    label: 'Email',
                    hint: 'Used to sign in and recover your account.',
                    controller: _model.emailAddressTextController!,
                    focusNode: _model.emailAddressFocusNode!,
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email],
                    placeholder: 'sarah@example.com',
                  ).animate()
                      .fadeIn(delay: 300.ms, duration: 400.ms)
                      .moveY(begin: 20, end: 0, delay: 300.ms, duration: 400.ms),

                  const SizedBox(height: 16),

                  // Birthday and Gender row
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 4, bottom: 8),
                              child: Text(
                                'Date of birth',
                                style: BinaType.labelMd.copyWith(color: BinaColors.ink2),
                              ),
                            ),
                            GestureDetector(
                              onTap: _selectBirthday,
                              child: Container(
                                height: 52,
                                decoration: BoxDecoration(
                                  color: BinaColors.surface,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: BinaColors.lineStrong),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 14),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        _model.ageTextController?.text.isEmpty ?? true
                                            ? 'DD/MM/YYYY'
                                            : _model.ageTextController!.text,
                                        style: BinaType.bodyLg.copyWith(
                                          color: _model.ageTextController?.text.isEmpty ?? true
                                              ? BinaColors.ink3
                                              : BinaColors.ink,
                                        ),
                                      ),
                                    ),
                                    Icon(
                                      Icons.calendar_today_rounded,
                                      color: BinaColors.ink3,
                                      size: 20,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 4, bottom: 8),
                              child: Text(
                                'Gender',
                                style: BinaType.labelMd.copyWith(color: BinaColors.ink2),
                              ),
                            ),
                            AppDropDown<String>(
                              controller: _model.genderValueController ??=
                                  FormFieldController<String>(null),
                              options: Genders.values.map((e) => e.name).toList(),
                              onChanged: (val) => safeSetState(() => _model.genderValue = val),
                              width: double.infinity,
                              height: 52,
                              textStyle: BinaType.bodyLg,
                              hintText: 'Select',
                              icon: Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: BinaColors.ink3,
                                size: 24,
                              ),
                              fillColor: BinaColors.surface,
                              elevation: 0,
                              borderColor: BinaColors.lineStrong,
                              borderWidth: 1,
                              borderRadius: 12,
                              margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                              hidesUnderline: true,
                              isOverButton: true,
                              isSearchable: false,
                              isMultiSelect: false,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ).animate()
                      .fadeIn(delay: 350.ms, duration: 400.ms)
                      .moveY(begin: 20, end: 0, delay: 350.ms, duration: 400.ms),

                  const SizedBox(height: 16),

                  // Password field
                  _AuthField(
                    label: 'Password',
                    controller: _model.passwordTextController!,
                    focusNode: _model.passwordFocusNode!,
                    obscureText: !_model.passwordVisibility,
                    autofillHints: const [AutofillHints.newPassword],
                    placeholder: 'At least 8 characters',
                    suffixIcon: IconButton(
                      icon: Icon(
                        _model.passwordVisibility
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: BinaColors.ink3,
                        size: 22,
                      ),
                      onPressed: () => safeSetState(
                        () => _model.passwordVisibility = !_model.passwordVisibility,
                      ),
                    ),
                  ).animate()
                      .fadeIn(delay: 400.ms, duration: 400.ms)
                      .moveY(begin: 20, end: 0, delay: 400.ms, duration: 400.ms),

                  const SizedBox(height: 24),

                  // Create account button
                  BinaButton(
                    label: 'Create account',
                    variant: BinaButtonVariant.primary,
                    fullWidth: true,
                    icon: Icons.arrow_forward_rounded,
                    onPressed: _handleCreateAccount,
                  ).animate()
                      .fadeIn(delay: 450.ms, duration: 400.ms)
                      .moveY(begin: 20, end: 0, delay: 450.ms, duration: 400.ms),

                  const SizedBox(height: 24),

                  // Sign in link
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Already have an account? ',
                          style: BinaType.bodyMd.copyWith(color: BinaColors.ink2),
                        ),
                        GestureDetector(
                          onTap: () => context.pushNamed(
                            Auth2LoginWidget.routeName,
                            extra: <String, dynamic>{
                              kTransitionInfoKey: const TransitionInfo(
                                hasTransition: true,
                                transitionType: PageTransitionType.fade,
                                duration: Duration(milliseconds: 200),
                              ),
                            },
                          ),
                          child: Text(
                            'Sign in',
                            style: BinaType.bodyMd.copyWith(
                              color: BinaColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ).animate()
                      .fadeIn(delay: 500.ms, duration: 400.ms),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// AUTH FIELD
// ═══════════════════════════════════════════════════════════════

class _AuthField extends StatelessWidget {
  const _AuthField({
    required this.label,
    required this.controller,
    required this.focusNode,
    this.hint,
    this.obscureText = false,
    this.keyboardType,
    this.autofillHints,
    this.placeholder,
    this.suffixIcon,
  });

  final String label;
  final String? hint;
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Iterable<String>? autofillHints;
  final String? placeholder;
  final Widget? suffixIcon;

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
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          obscureText: obscureText,
          keyboardType: keyboardType,
          autofillHints: autofillHints,
          style: BinaType.bodyLg,
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: BinaType.bodyLg.copyWith(color: BinaColors.ink3),
            filled: true,
            fillColor: BinaColors.surface,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: BinaColors.error, width: 2),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: BinaColors.error, width: 2),
            ),
            suffixIcon: suffixIcon,
          ),
          cursorColor: BinaColors.primary,
        ),
        if (hint != null)
          Padding(
            padding: const EdgeInsets.only(left: 4, top: 6),
            child: Text(
              hint!,
              style: BinaType.bodySm.copyWith(color: BinaColors.ink3),
            ),
          ),
      ],
    );
  }
}
