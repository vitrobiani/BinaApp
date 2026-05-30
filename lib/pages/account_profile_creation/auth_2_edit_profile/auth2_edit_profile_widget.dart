import '/bina_design/bina_design.dart';
import '/app_core/app_util.dart';
import '/pages/account_profile_creation/edit_profile_auth_2/edit_profile_auth2_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'auth2_edit_profile_model.dart';
export 'auth2_edit_profile_model.dart';

class Auth2EditProfileWidget extends StatefulWidget {
  const Auth2EditProfileWidget({super.key});

  static String routeName = 'auth_2_EditProfile';
  static String routePath = 'auth2EditProfile';

  @override
  State<Auth2EditProfileWidget> createState() => _Auth2EditProfileWidgetState();
}

class _Auth2EditProfileWidgetState extends State<Auth2EditProfileWidget> {
  late Auth2EditProfileModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => Auth2EditProfileModel());
    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
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
        backgroundColor: BinaColors.surface,
        body: Column(
          children: [
            // Header with gradient
            Container(
              width: double.infinity,
              height: 130,
              decoration: BoxDecoration(
                gradient: BinaColors.gradHero,
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      BinaColors.surface,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16, bottom: 24),
                    child: BinaIconButton(
                      icon: Icons.arrow_back_rounded,
                      onPressed: () => context.safePop(),
                    ),
                  ),
                ),
              ),
            ).animate()
                .fadeIn(duration: 400.ms)
                .scale(
                  begin: const Offset(3, 3),
                  end: const Offset(1, 1),
                  duration: 400.ms,
                ),
            // Content
            Expanded(
              child: SingleChildScrollView(
                child: Center(
                  child: Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(maxWidth: 770),
                    child: wrapWithModel(
                      model: _model.editProfileAuth2Model,
                      updateCallback: () => safeSetState(() {}),
                      child: EditProfileAuth2Widget(
                        title: 'Edit Profile',
                        confirmButtonText: 'Save Changes',
                        navigateAction: () async {
                          context.safePop();
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
