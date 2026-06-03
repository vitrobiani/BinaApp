import '/app_core/app_util.dart';
import '/bina_design/bina_design.dart';
import 'package:flutter/material.dart';
import 'diagnosis_plack_cavity_model.dart';
export 'diagnosis_plack_cavity_model.dart';

class DiagnosisPlackCavityWidget extends StatefulWidget {
  const DiagnosisPlackCavityWidget({super.key});

  static String routeName = 'DiagnosisPlackCavity';
  static String routePath = 'diagnosisPlackCavity';

  @override
  State<DiagnosisPlackCavityWidget> createState() =>
      _DiagnosisPlackCavityWidgetState();
}

class _DiagnosisPlackCavityWidgetState
    extends State<DiagnosisPlackCavityWidget> {
  late DiagnosisPlackCavityModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DiagnosisPlackCavityModel());

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
        appBar: AppBar(
          backgroundColor: BinaColors.surface,
          automaticallyImplyLeading: false,
          title: Text(
            AppLocalizations.of(context).getText(
              'cw83ljf7' /* Diagnosis */,
            ),
            style: BinaType.headlineMd,
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: BinaSpace.s3),
              child: BinaIconButton(
                icon: Icons.close_rounded,
                onPressed: () {
                  context.safePop();
                },
              ),
            ),
          ],
          centerTitle: false,
          elevation: 0.0,
        ),
        body: SafeArea(
          top: true,
          child: Form(
            key: _model.formKey,
            autovalidateMode: AutovalidateMode.disabled,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        // Image section
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            BinaSpace.s4, BinaSpace.s3, BinaSpace.s4, 0,
                          ),
                          child: BinaCard(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(
                                maxWidth: 570.0,
                              ),
                              child: SizedBox(
                                width: double.infinity,
                                height: 330.0,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(BinaRadius.sm),
                                  child: Image.network(
                                    'https://i.pinimg.com/736x/96/7d/c7/967dc78b80cd745b1ba0e6377048d692.jpg',
                                    width: 300.0,
                                    height: 200.0,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: BinaSpace.s4),

                        // Divider
                        Container(
                          height: 1,
                          color: BinaColors.line,
                        ),

                        const SizedBox(height: BinaSpace.s5),

                        // Mixed result content (Plaque + Cavity)
                        Container(
                          constraints: const BoxConstraints(maxWidth: 570.0),
                          padding: const EdgeInsets.symmetric(horizontal: BinaSpace.s4),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Status chip centered
                              Center(
                                child: const DxChip(kind: DxChipKind.mixed),
                              ),

                              const SizedBox(height: BinaSpace.s5),

                              // === Plaque Section ===
                              _IssueSection(
                                title: AppLocalizations.of(context).getText(
                                  'jlylby4g' /* Problem detected: Plack */,
                                ),
                                advice: AppLocalizations.of(context).getText(
                                  'g3onei9w' /* More thorough brushing, focus ... */,
                                ),
                                color: BinaColors.dxPlaque,
                                colorBg: BinaColors.dxPlaque100,
                              ),

                              const SizedBox(height: BinaSpace.s4),

                              // === Cavity Section ===
                              _IssueSection(
                                title: AppLocalizations.of(context).getText(
                                  'o537478g' /* Problem detected: Cavity */,
                                ),
                                advice: AppLocalizations.of(context).getText(
                                  'c33xlo8j' /* Indications of a cavity are ap... */,
                                ),
                                color: BinaColors.dxCavity,
                                colorBg: BinaColors.dxCavity100,
                              ),

                              const SizedBox(height: BinaSpace.s7),

                              // Back button
                              BinaButton(
                                label: 'Done',
                                fullWidth: true,
                                size: BinaButtonSize.lg,
                                onPressed: () {
                                  context.safePop();
                                },
                              ),

                              const SizedBox(height: BinaSpace.s4),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Reusable issue section widget
class _IssueSection extends StatelessWidget {
  const _IssueSection({
    required this.title,
    required this.advice,
    required this.color,
    required this.colorBg,
  });

  final String title;
  final String advice;
  final Color color;
  final Color colorBg;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(BinaSpace.s4),
      decoration: BoxDecoration(
        color: colorBg,
        borderRadius: BorderRadius.circular(BinaRadius.md),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Issue title with icon
          Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: color,
                size: 20,
              ),
              const SizedBox(width: BinaSpace.s2),
              Expanded(
                child: Text(
                  title,
                  style: BinaType.titleSm.copyWith(color: color),
                ),
              ),
            ],
          ),

          const SizedBox(height: BinaSpace.s3),

          // Advice section
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.lightbulb_outline_rounded,
                color: color.withOpacity(0.7),
                size: 18,
              ),
              const SizedBox(width: BinaSpace.s2),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Advice:',
                      style: BinaType.labelMd.copyWith(
                        color: color.withOpacity(0.8),
                      ),
                    ),
                    const SizedBox(height: BinaSpace.s1),
                    Text(
                      advice,
                      style: BinaType.bodyMd,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
