import '/app_core/app_util.dart';
import '/bina_design/bina_design.dart';
import 'package:flutter/material.dart';
import 'diagnosis_good_model.dart';
export 'diagnosis_good_model.dart';

class DiagnosisGoodWidget extends StatefulWidget {
  const DiagnosisGoodWidget({super.key});

  static String routeName = 'DiagnosisGood';
  static String routePath = 'diagnosisGood';

  @override
  State<DiagnosisGoodWidget> createState() => _DiagnosisGoodWidgetState();
}

class _DiagnosisGoodWidgetState extends State<DiagnosisGoodWidget> {
  late DiagnosisGoodModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DiagnosisGoodModel());

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
              'oll2n2k5' /* Diagnosis */,
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

                        // Good result content
                        Container(
                          constraints: const BoxConstraints(maxWidth: 570.0),
                          padding: const EdgeInsets.symmetric(horizontal: BinaSpace.s4),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Status chip
                              const DxChip(kind: DxChipKind.good),

                              const SizedBox(height: BinaSpace.s4),

                              // Success message
                              Text(
                                AppLocalizations.of(context).getText(
                                  'e5ztajlj' /* No problems detected, good job... */,
                                ),
                                style: BinaType.headlineSm,
                                textAlign: TextAlign.center,
                              ),

                              const SizedBox(height: BinaSpace.s7),

                              // Congrats image
                              ClipRRect(
                                borderRadius: BorderRadius.circular(BinaRadius.md),
                                child: Image.asset(
                                  'assets/images/congrats@2x.png',
                                  width: 200.0,
                                  height: 200.0,
                                  fit: BoxFit.cover,
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
