import '/app_core/app_util.dart';
import '/bina_design/bina_design.dart';
import 'package:flutter/material.dart';
import 'diagnosis_plack_model.dart';
export 'diagnosis_plack_model.dart';

class DiagnosisPlackWidget extends StatefulWidget {
  const DiagnosisPlackWidget({super.key});

  static String routeName = 'DiagnosisPlack';
  static String routePath = 'diagnosisPlack';

  @override
  State<DiagnosisPlackWidget> createState() => _DiagnosisPlackWidgetState();
}

class _DiagnosisPlackWidgetState extends State<DiagnosisPlackWidget> {
  late DiagnosisPlackModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DiagnosisPlackModel());

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
              'oo2y7ww0' /* Diagnosis */,
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

                        // Plaque result content
                        Container(
                          constraints: const BoxConstraints(maxWidth: 570.0),
                          padding: const EdgeInsets.symmetric(horizontal: BinaSpace.s4),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Status chip centered
                              Center(
                                child: const DxChip(kind: DxChipKind.plaque),
                              ),

                              const SizedBox(height: BinaSpace.s4),

                              // Problem detected message
                              Center(
                                child: Text(
                                  AppLocalizations.of(context).getText(
                                    'yrm43d77' /* Problem detected: Plack */,
                                  ),
                                  style: BinaType.headlineSm,
                                  textAlign: TextAlign.center,
                                ),
                              ),

                              const SizedBox(height: BinaSpace.s6),

                              // Advice section
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(BinaSpace.s4),
                                decoration: BoxDecoration(
                                  color: BinaColors.dxPlaque100,
                                  borderRadius: BorderRadius.circular(BinaRadius.md),
                                  border: Border.all(
                                    color: BinaColors.dxPlaque.withOpacity(0.3),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.lightbulb_outline_rounded,
                                          color: BinaColors.dxPlaque,
                                          size: 20,
                                        ),
                                        const SizedBox(width: BinaSpace.s2),
                                        Text(
                                          AppLocalizations.of(context).getText(
                                            'o44qkbc9' /* Advice: */,
                                          ),
                                          style: BinaType.titleSm.copyWith(
                                            color: BinaColors.dxPlaque,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: BinaSpace.s2),
                                    Text(
                                      AppLocalizations.of(context).getText(
                                        '3e2p6t0b' /* More thorough brushing, focus ... */,
                                      ),
                                      style: BinaType.bodyMd,
                                    ),
                                  ],
                                ),
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
