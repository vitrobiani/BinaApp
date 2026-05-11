import '/app_core/app_icon_button.dart';
import '/app_core/app_theme.dart';
import '/app_core/app_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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

  // Language options with display names and flags
  static const List<LanguageOption> _languages = [
    LanguageOption(
      code: 'en',
      name: 'English',
      nativeName: 'English',
      flag: '🇺🇸',
    ),
    LanguageOption(
      code: 'he',
      name: 'Hebrew',
      nativeName: 'עברית',
      flag: '🇮🇱',
    ),
    LanguageOption(
      code: 'id',
      name: 'Indonesian',
      nativeName: 'Bahasa Indonesia',
      flag: '🇮🇩',
    ),
    LanguageOption(
      code: 'ms',
      name: 'Malay',
      nativeName: 'Bahasa Melayu',
      flag: '🇲🇾',
    ),
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
      // Trigger app rebuild by updating the locale
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
        backgroundColor: AppTheme.of(context).primaryBackground,
        appBar: AppBar(
          backgroundColor: AppTheme.of(context).secondaryBackground,
          automaticallyImplyLeading: false,
          leading: AppIconButton(
            borderColor: Colors.transparent,
            borderRadius: 30.0,
            borderWidth: 1.0,
            buttonSize: 60.0,
            icon: Icon(
              Icons.arrow_back_rounded,
              color: AppTheme.of(context).primaryText,
              size: 30.0,
            ),
            onPressed: () async {
              context.safePop();
            },
          ),
          title: Text(
            AppLocalizations.of(context).getText('lang001' /* Language */),
            style: AppTheme.of(context).headlineMedium.override(
                  font: GoogleFonts.readexPro(
                    fontWeight:
                        AppTheme.of(context).headlineMedium.fontWeight,
                  ),
                  letterSpacing: 0.0,
                ),
          ),
          centerTitle: false,
          elevation: 0.0,
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header description
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(24.0, 24.0, 24.0, 8.0),
                child: Text(
                  AppLocalizations.of(context).getText('lang002' /* Select your preferred language... */),
                  style: AppTheme.of(context).bodyMedium.override(
                        font: GoogleFonts.inter(),
                        color: AppTheme.of(context).secondaryText,
                      ),
                ),
              ),

              // Language options
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(16.0, 16.0, 16.0, 0.0),
                child: Column(
                  children: _languages.map((language) {
                    final isSelected = language.code == currentLanguage;
                    return _buildLanguageOption(
                      context,
                      language,
                      isSelected,
                    );
                  }).toList(),
                ),
              ),

              // Info section
              // Padding(
              //   padding: EdgeInsetsDirectional.fromSTEB(24.0, 32.0, 24.0, 24.0),
              //   child: Container(
              //     width: double.infinity,
              //     padding: EdgeInsets.all(16.0),
              //     decoration: BoxDecoration(
              //       color: AppTheme.of(context).primary.withValues(alpha: 0.1),
              //       borderRadius: BorderRadius.circular(12.0),
              //     ),
              //     child: Row(
              //       crossAxisAlignment: CrossAxisAlignment.start,
              //       children: [
              //         Icon(
              //           Icons.info_outline,
              //           color: AppTheme.of(context).primary,
              //           size: 20.0,
              //         ),
              //         SizedBox(width: 12.0),
              //         Expanded(
              //           child: Text(
              //             AppLocalizations.of(context).getText('lang003' /* More languages will be added... */),
              //             style: AppTheme.of(context).bodySmall.override(
              //                   font: GoogleFonts.inter(),
              //                   color: AppTheme.of(context).primary,
              //                 ),
              //           ),
              //         ),
              //       ],
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageOption(
    BuildContext context,
    LanguageOption language,
    bool isSelected,
  ) {
    final theme = AppTheme.of(context);

    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 12.0),
      child: InkWell(
        onTap: () async {
          if (!isSelected) {
            await _changeLanguage(language.code);
          }
        },
        borderRadius: BorderRadius.circular(12.0),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.primary.withValues(alpha: 0.1)
                : theme.secondaryBackground,
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(
              color: isSelected ? theme.primary : Colors.transparent,
              width: 2.0,
            ),
            boxShadow: isSelected
                ? null
                : [
                    BoxShadow(
                      blurRadius: 3.0,
                      color: Color(0x20000000),
                      offset: Offset(0.0, 1.0),
                    ),
                  ],
          ),
          child: Row(
            children: [
              // Flag
              Text(
                language.flag,
                style: TextStyle(fontSize: 32.0),
              ),
              SizedBox(width: 16.0),
              // Language names
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      language.name,
                      style: theme.titleMedium.override(
                        font: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                        ),
                        color: isSelected ? theme.primary : theme.primaryText,
                      ),
                    ),
                    SizedBox(height: 2.0),
                    Text(
                      language.nativeName,
                      style: theme.bodySmall.override(
                        font: GoogleFonts.inter(),
                        color: theme.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
              // Checkmark for selected
              if (isSelected)
                Container(
                  width: 28.0,
                  height: 28.0,
                  decoration: BoxDecoration(
                    color: theme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 18.0,
                  ),
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
