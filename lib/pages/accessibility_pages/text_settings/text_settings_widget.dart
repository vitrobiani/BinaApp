import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/app_core/app_util.dart';
import '/app_core/text_scale.dart';
import '/bina_design/bina_design.dart';
import '/services/accessibility_settings_service.dart';
import 'text_settings_model.dart';

export 'text_settings_model.dart';

class TextSettingsWidget extends StatefulWidget {
  const TextSettingsWidget({super.key});

  static String routeName = 'TextSettings';
  static String routePath = 'textSettings';

  @override
  State<TextSettingsWidget> createState() => _TextSettingsWidgetState();
}

class _TextSettingsWidgetState extends State<TextSettingsWidget> {
  late TextSettingsModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => TextSettingsModel());
  }

  @override
  void dispose() {
    _model.maybeDispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<AccessibilitySettingsService>();
    final currentScale = AccessibilitySettingsService.instance.textScale;

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: BinaColors.surfaceAlt,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
              decoration: BoxDecoration(
                color: BinaColors.surface,
                border: Border(bottom: BorderSide(color: BinaColors.line)),
              ),
              child: Row(
                children: [
                  BinaIconButton(
                    icon: Icons.chevron_left_rounded,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 8),
                  Text('Text Size', style: BinaType.titleLg),
                ],
              ),
            ),
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Choose your preferred text size for better readability.',
                      style: BinaType.bodyMd.copyWith(color: BinaColors.ink2),
                    ),
                    const SizedBox(height: 24),

                    // Text scale options
                    ...TextScale.values.map((scale) {
                      final isSelected = scale == currentScale;
                      return _TextScaleCard(
                        scale: scale,
                        isSelected: isSelected,
                        onTap: () async {
                          await AccessibilitySettingsService.instance.setTextScale(scale);
                          safeSetState(() {});
                        },
                      );
                    }),

                    const SizedBox(height: 24),

                    // Preview section
                    Text('Preview', style: BinaType.titleMd),
                    const SizedBox(height: 12),
                    BinaCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Sample Heading',
                            style: BinaType.titleLg,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'This is how text will appear throughout the app with your current text size setting.',
                            style: BinaType.bodyMd,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Smaller caption text appears like this.',
                            style: BinaType.bodySm.copyWith(color: BinaColors.ink2),
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
    );
  }
}

class _TextScaleCard extends StatelessWidget {
  const _TextScaleCard({
    required this.scale,
    required this.isSelected,
    required this.onTap,
  });

  final TextScale scale;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: BinaMotion.d2,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected ? BinaColors.primary100 : BinaColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? BinaColors.primary : BinaColors.line,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected ? BinaElevation.sh2 : BinaElevation.sh1,
          ),
          child: Row(
            children: [
              // Radio indicator
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? BinaColors.primary : BinaColors.ink3,
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? Center(
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: BinaColors.primary,
                          ),
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 16),
              // Scale name and info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      scale.displayName,
                      style: BinaType.titleMd.copyWith(
                        color: isSelected ? BinaColors.primary : BinaColors.ink,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Scale: ${(scale.scaleFactor * 100).toInt()}%',
                      style: BinaType.bodySm.copyWith(color: BinaColors.ink3),
                    ),
                  ],
                ),
              ),
              // Preview text
              Text(
                'Aa',
                style: BinaType.headlineMd.copyWith(
                  fontSize: 16 * scale.scaleFactor,
                  color: isSelected ? BinaColors.primary : BinaColors.ink2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
