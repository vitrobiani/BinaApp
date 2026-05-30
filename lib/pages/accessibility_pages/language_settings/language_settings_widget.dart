import '/app_core/app_util.dart';
import '/bina_design/bina_design.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'language_settings_model.dart';
export 'language_settings_model.dart';

class LanguageSettingsWidget extends StatefulWidget {
  const LanguageSettingsWidget({super.key});

  static String routeName = 'LanguageSettings';
  static String routePath = 'languageSettings';

  @override
  State<LanguageSettingsWidget> createState() => _LanguageSettingsWidgetState();
}

class _LanguageSettingsWidgetState extends State<LanguageSettingsWidget> {
  late LanguageSettingsModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  static const List<LanguageOption> _languages = [
    LanguageOption(code: 'en', name: 'English', nativeName: 'English', flag: '🇺🇸'),
    LanguageOption(code: 'he', name: 'Hebrew', nativeName: 'עברית', flag: '🇮🇱'),
    LanguageOption(code: 'id', name: 'Indonesian', nativeName: 'Bahasa Indonesia', flag: '🇮🇩'),
    LanguageOption(code: 'ms', name: 'Malay', nativeName: 'Bahasa Melayu', flag: '🇲🇾'),
  ];

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => LanguageSettingsModel());
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  String _getCurrentLanguageCode() {
    final storedLocale = AppLocalizations.getStoredLocale();
    if (storedLocale != null) {
      return storedLocale.languageCode;
    }
    return 'en';
  }

  Future<void> _changeLanguage(String languageCode) async {
    await AppLocalizations.storeLocale(languageCode);
    if (mounted) {
      setAppLanguage(context, languageCode);
    }
  }

  @override
  Widget build(BuildContext context) {
    context.watch<AppState>();
    final currentLanguage = _getCurrentLanguageCode();

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
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
                      onPressed: () => context.safePop(),
                    ),
                    const SizedBox(width: 8),
                    Text('Language', style: BinaType.titleLg),
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
                        'Select your preferred language for the app interface.',
                        style: BinaType.bodyMd.copyWith(color: BinaColors.ink2),
                      ),
                      const SizedBox(height: 24),
                      ..._languages.map((language) {
                        final isSelected = language.code == currentLanguage;
                        return _LanguageCard(
                          language: language,
                          isSelected: isSelected,
                          onTap: () async {
                            if (!isSelected) {
                              await _changeLanguage(language.code);
                            }
                          },
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguageCard extends StatelessWidget {
  const _LanguageCard({
    required this.language,
    required this.isSelected,
    required this.onTap,
  });

  final LanguageOption language;
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
            boxShadow: isSelected ? null : BinaElevation.sh1,
          ),
          child: Row(
            children: [
              Text(language.flag, style: const TextStyle(fontSize: 32)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      language.name,
                      style: BinaType.titleMd.copyWith(
                        color: isSelected ? BinaColors.primary : BinaColors.ink,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      language.nativeName,
                      style: BinaType.bodySm.copyWith(color: BinaColors.ink3),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: BinaColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_rounded, color: Colors.white, size: 18),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class LanguageOption {
  const LanguageOption({
    required this.code,
    required this.name,
    required this.nativeName,
    required this.flag,
  });

  final String code;
  final String name;
  final String nativeName;
  final String flag;
}
