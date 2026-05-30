import '/app_core/app_util.dart';
import '/bina_design/bina_design.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'family_success_model.dart';
export 'family_success_model.dart';

class FamilySuccessWidget extends StatefulWidget {
  const FamilySuccessWidget({super.key});

  @override
  State<FamilySuccessWidget> createState() => _FamilySuccessWidgetState();
}

class _FamilySuccessWidgetState extends State<FamilySuccessWidget> {
  late FamilySuccessModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => FamilySuccessModel());
    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 4, sigmaY: 6),
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: const Color(0x4D000000),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 400),
                decoration: BoxDecoration(
                  color: BinaColors.surface,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: BinaElevation.sh3,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Success icon
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: BinaColors.success100,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check_rounded,
                          color: BinaColors.success,
                          size: 40,
                        ),
                      ).animate()
                          .scale(
                            begin: const Offset(0.5, 0.5),
                            end: const Offset(1, 1),
                            duration: 500.ms,
                            curve: Curves.elasticOut,
                          )
                          .fadeIn(duration: 300.ms),
                      const SizedBox(height: 20),
                      // Title
                      Text(
                        'Success!',
                        style: BinaType.headlineSm,
                      ).animate()
                          .fadeIn(delay: 200.ms, duration: 400.ms)
                          .moveY(begin: 20, end: 0, delay: 200.ms, duration: 400.ms),
                      const SizedBox(height: 8),
                      // Description
                      Text(
                        'New family member added successfully',
                        style: BinaType.bodyMd.copyWith(color: BinaColors.ink2),
                        textAlign: TextAlign.center,
                      ).animate()
                          .fadeIn(delay: 400.ms, duration: 400.ms),
                      const SizedBox(height: 24),
                      // Button
                      SizedBox(
                        width: double.infinity,
                        child: BinaButton(
                          label: 'Done',
                          icon: Icons.check_rounded,
                          variant: BinaButtonVariant.primary,
                          onPressed: () => context.safePop(),
                        ),
                      ).animate()
                          .fadeIn(delay: 600.ms, duration: 400.ms)
                          .scale(
                            begin: const Offset(0.9, 0.9),
                            end: const Offset(1, 1),
                            delay: 600.ms,
                            duration: 300.ms,
                          ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
