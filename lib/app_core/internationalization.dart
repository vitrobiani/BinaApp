import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kLocaleStorageKey = '__locale_key__';

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static AppLocalizations of(BuildContext context) =>
      Localizations.of<AppLocalizations>(context, AppLocalizations)!;

  static List<String> languages() => ['en', 'he', 'id', 'ms'];

  static late SharedPreferences _prefs;
  static Future initialize() async =>
      _prefs = await SharedPreferences.getInstance();
  static Future storeLocale(String locale) =>
      _prefs.setString(_kLocaleStorageKey, locale);
  static Locale? getStoredLocale() {
    final locale = _prefs.getString(_kLocaleStorageKey);
    return locale != null && locale.isNotEmpty ? createLocale(locale) : null;
  }

  String get languageCode => locale.toString();
  String? get languageShortCode =>
      _languagesWithShortCode.contains(locale.toString())
          ? '${locale.toString()}_short'
          : null;
  int get languageIndex => languages().contains(languageCode)
      ? languages().indexOf(languageCode)
      : 0;

  String getText(String key) {
    final translations = kTranslationsMap[key] ?? {};
    // Try current locale first, fallback to English if not found
    return translations[locale.toString()] ?? translations['en'] ?? '';
  }

  String getVariableText({
    String? enText = '',
    String? heText = '',
    String? idText = '',
    String? msText = '',
  }) =>
      [enText, heText, idText, msText][languageIndex] ?? '';

  static const Set<String> _languagesWithShortCode = {
    'ar',
    'az',
    'ca',
    'cs',
    'da',
    'de',
    'dv',
    'en',
    'es',
    'et',
    'fi',
    'fr',
    'gr',
    'he',
    'hi',
    'hu',
    'it',
    'km',
    'ku',
    'mn',
    'ms',
    'no',
    'pt',
    'ro',
    'ru',
    'rw',
    'sv',
    'th',
    'uk',
    'vi',
  };
}

/// Used if the locale is not supported by GlobalMaterialLocalizations.
class FallbackMaterialLocalizationDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const FallbackMaterialLocalizationDelegate();

  @override
  bool isSupported(Locale locale) => _isSupportedLocale(locale);

  @override
  Future<MaterialLocalizations> load(Locale locale) async =>
      SynchronousFuture<MaterialLocalizations>(
        const DefaultMaterialLocalizations(),
      );

  @override
  bool shouldReload(FallbackMaterialLocalizationDelegate old) => false;
}

/// Used if the locale is not supported by GlobalCupertinoLocalizations.
class FallbackCupertinoLocalizationDelegate
    extends LocalizationsDelegate<CupertinoLocalizations> {
  const FallbackCupertinoLocalizationDelegate();

  @override
  bool isSupported(Locale locale) => _isSupportedLocale(locale);

  @override
  Future<CupertinoLocalizations> load(Locale locale) =>
      SynchronousFuture<CupertinoLocalizations>(
        const DefaultCupertinoLocalizations(),
      );

  @override
  bool shouldReload(FallbackCupertinoLocalizationDelegate old) => false;
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => _isSupportedLocale(locale);

  @override
  Future<AppLocalizations> load(Locale locale) =>
      SynchronousFuture<AppLocalizations>(AppLocalizations(locale));

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}

Locale createLocale(String language) => language.contains('_')
    ? Locale.fromSubtags(
        languageCode: language.split('_').first,
        scriptCode: language.split('_').last,
      )
    : Locale(language);

bool _isSupportedLocale(Locale locale) {
  final language = locale.toString();
  return AppLocalizations.languages().contains(
    language.endsWith('_')
        ? language.substring(0, language.length - 1)
        : language,
  );
}
final kTranslationsMap = <Map<String, Map<String, String>>>[
  // Main_Home
  {
    'nnv46x35': {
      'en': 'Weekly Summary',
      'he': 'סיכום שבועי',
      'id': 'Di bawah ini adalah ringkasan aktivitas tim Anda.',
      'ms': 'Di bawah ialah ringkasan aktiviti pasukan anda.',
    },
    'kphqz3hi': {
      'en': 'Updates',
      'he': 'עדכונים',
      'id': 'Proyek',
      'ms': 'Projek',
    },
    'xlzf8qqx': {
      'en': 'Undiagnosed members this week:',
      'he': 'חברי צוות ללא אבחון השבוע:',
      'id': 'Tim Desain UI',
      'ms': 'Pasukan Reka Bentuk UI',
    },
    'puy8obok': {
      'en': 'Contract Activity',
      'he': 'פעילות חוזים',
      'id': 'Aktivitas Kontrak',
      'ms': 'Aktiviti Kontrak',
    },
    'zlovh0zt': {
      'en': 'Below is an a summary of activity.',
      'he': 'להלן סיכום הפעילות.',
      'id': 'Di bawah ini adalah ringkasan kegiatan.',
      'ms': 'Di bawah ialah ringkasan aktiviti.',
    },
    'g1uaaovn': {
      'en': 'Customer Activity',
      'he': 'פעילות לקוחות',
      'id': 'Aktivitas Pelanggan',
      'ms': 'Aktiviti Pelanggan',
    },
    'e5q3ows1': {
      'en': 'Below is an a summary of activity.',
      'he': 'להלן סיכום הפעילות.',
      'id': 'Di bawah ini adalah ringkasan kegiatan.',
      'ms': 'Di bawah ialah ringkasan aktiviti.',
    },
    'uj7jsxmo': {
      'en': 'Sigal (You): Cavity',
      'he': 'סיגל (את/ה): חור בשן',
      'id': 'Aktivitas Kontrak',
      'ms': 'Aktiviti Kontrak',
    },
    'hkk2zmjw': {
      'en': 'Severity: Severe\nAdvice: Visit doctor ASAP',
      'he': 'חומרה: חמורה\nהמלצה: פנה לרופא בהקדם',
      'id': 'Di bawah ini adalah ringkasan kegiatan.',
      'ms': 'Di bawah ialah ringkasan aktiviti.',
    },
    'jkgae0vc': {
      'en': 'Idan: Plaque',
      'he': 'עידן: פלאק',
      'id': 'Aktivitas Pelanggan',
      'ms': 'Aktiviti Pelanggan',
    },
    'g4os7kcp': {
      'en':
      'Severity: Light\nAdvice: More Thorough brishing, use a\nsoft fiber toothbrush',
      'he': 'חומרה: קלה\nהמלצה: צחצוח יסודי יותר, השתמש במברשת רכה',
      'id': 'Di bawah ini adalah ringkasan kegiatan.',
      'ms': 'Di bawah ialah ringkasan aktiviti.',
    },
    'xdxbdj20': {
      'en': '__',
      'he': '__',
      'id': '__',
      'ms': '__',
    },
  },
  // Main_DIagnostics
  {
    'n99lg1qh': {
      'en': 'Diagnostics',
      'he': 'אבחונים',
      'id': 'Pelanggan',
      'ms': 'Pelanggan',
    },
    'lvnskphp': {
      'en': 'Sigal (You)',
      'he': 'סיגל (את/ה)',
      'id': 'Semua',
      'ms': 'Semua',
    },
    'f5d3fvff': {
      'en': 'Major problem found!',
      'he': 'נמצאה בעיה משמעותית!',
      'id': 'Randy Alcorn',
      'ms': 'Randy Alcorn',
    },
    'jwrrbd37': {
      'en': '14/06/2025',
      'he': '14/06/2025',
      'id': 'Kepala Pengadaan',
      'ms': 'Ketua Perolehan',
    },
    '4vyvrsvp': {
      'en': 'Cavity (severe)',
      'he': 'חור בשן (חמור)',
      'id': 'Kepala Pengadaan',
      'ms': 'Ketua Perolehan',
    },
    'xbmye3r1': {
      'en': 'Problem found!',
      'he': 'נמצאה בעיה!',
      'id': 'Randy Alcorn',
      'ms': 'Randy Alcorn',
    },
    'sot8njss': {
      'en': '01/06/2025',
      'he': '01/06/2025',
      'id': 'Kepala Pengadaan',
      'ms': 'Ketua Perolehan',
    },
    'ko2o59js': {
      'en': 'Cavity (minor), Plack',
      'he': 'חור (קל), פלאק',
      'id': 'Kepala Pengadaan',
      'ms': 'Ketua Perolehan',
    },
    'lbnt26st': {
      'en': 'No problems found',
      'he': 'לא נמצאו בעיות',
      'id': 'Randy Alcorn',
      'ms': 'Randy Alcorn',
    },
    'io7qmr33': {
      'en': '26/05/2025',
      'he': '26/05/2025',
      'id': 'Kepala Pengadaan',
      'ms': 'Ketua Perolehan',
    },
    '35o5woky': {
      'en': 'Problem found!',
      'he': 'נמצאה בעיה!',
      'id': 'Randy Alcorn',
      'ms': 'Randy Alcorn',
    },
    '8ieto4rf': {
      'en': '13/05/2025',
      'he': '13/05/2025',
      'id': 'Kepala Pengadaan',
      'ms': 'Ketua Perolehan',
    },
    '2719y4vf': {
      'en': 'Plack',
      'he': 'פלאק',
      'id': 'Kepala Pengadaan',
      'ms': 'Ketua Perolehan',
    },
    'a258xeav': {
      'en': 'No problems found',
      'he': 'לא נמצאו בעיות',
      'id': 'Randy Alcorn',
      'ms': 'Randy Alcorn',
    },
    'wduyui67': {
      'en': '05/05/2025',
      'he': '05/05/2025',
      'id': 'Kepala Pengadaan',
      'ms': 'Ketua Perolehan',
    },
    'u0su8kte': {
      'en': 'No problems found',
      'he': 'לא נמצאו בעיות',
      'id': 'James Wiseman',
      'ms': 'James Wiseman',
    },
    'nyfsg4hw': {
      'en': '26/04/2025',
      'he': '26/04/2025',
      'id': 'Manajer Akuntansi',
      'ms': 'Pengurus akaun',
    },
    'qh2ock0d': {
      'en': 'Idan',
      'he': 'עידן',
      'id': 'Aktif',
      'ms': 'Aktif',
    },
    'yj40ezzo': {
      'en': 'Problem found!',
      'he': 'נמצאה בעיה!',
      'id': 'Randy Alcorn',
      'ms': 'Randy Alcorn',
    },
    '25dp2kkr': {
      'en': '14/06/2025',
      'he': '14/06/2025',
      'id': 'Kepala Pengadaan',
      'ms': 'Ketua Perolehan',
    },
    'qpaeeh6n': {
      'en': 'Plack',
      'he': 'פלאק',
      'id': 'Manajer Akuntansi',
      'ms': 'Pengurus akaun',
    },
    'hx6auuvz': {
      'en': 'No problems found',
      'he': 'לא נמצאו בעיות',
      'id': 'Randy Alcorn',
      'ms': 'Randy Alcorn',
    },
    'p7egakgn': {
      'en': '01/06/2025',
      'he': '01/06/2025',
      'id': 'Kepala Pengadaan',
      'ms': 'Ketua Perolehan',
    },
    'g9xzjmh4': {
      'en': 'Problem found!',
      'he': 'נמצאה בעיה!',
      'id': 'Randy Alcorn',
      'ms': 'Randy Alcorn',
    },
    'zj5j9aqi': {
      'en': '15/05/2025',
      'he': '15/05/2025',
      'id': 'Kepala Pengadaan',
      'ms': 'Ketua Perolehan',
    },
    '82sehtrs': {
      'en': 'Plack',
      'he': 'פלאק',
      'id': 'Manajer Akuntansi',
      'ms': 'Pengurus akaun',
    },
    '7mw5a1fj': {
      'en': 'Problem found!',
      'he': 'נמצאה בעיה!',
      'id': 'Randy Alcorn',
      'ms': 'Randy Alcorn',
    },
    '0wu7ys98': {
      'en': '06/05/2025',
      'he': '06/05/2025',
      'id': 'Kepala Pengadaan',
      'ms': 'Ketua Perolehan',
    },
    '1k5z65cm': {
      'en': 'Plack',
      'he': 'פלאק',
      'id': 'Manajer Akuntansi',
      'ms': 'Pengurus akaun',
    },
    'xlgk615j': {
      'en': 'Problem found!',
      'he': 'נמצאה בעיה!',
      'id': 'James Wiseman',
      'ms': 'James Wiseman',
    },
    'uhbzwcb6': {
      'en': '26/04/2025',
      'he': '26/04/2025',
      'id': 'Manajer Akuntansi',
      'ms': 'Pengurus akaun',
    },
    '0ovyr17x': {
      'en': 'Plack',
      'he': 'פלאק',
      'id': 'Manajer Akuntansi',
      'ms': 'Pengurus akaun',
    },
    's7xebw09': {
      'en': 'Nadav',
      'he': 'נדב',
      'id': 'Panggilan Dingin',
      'ms': 'Panggilan Dingin',
    },
    '7s0fouho': {
      'en': 'REMINDER!!!',
      'he': 'תזכורת!!!',
      'id': 'Randy Alcorn',
      'ms': 'Randy Alcorn',
    },
    'rsn6tjee': {
      'en': 'Nadav hasn\'t been diagnosed in 17 days!',
      'he': 'נדב לא אובחן כבר 17 ימים!',
      'id': 'Kepala Pengadaan',
      'ms': 'Ketua Perolehan',
    },
    'a0y9ee8v': {
      'en': 'No problems found',
      'he': 'לא נמצאו בעיות',
      'id': 'Randy Alcorn',
      'ms': 'Randy Alcorn',
    },
    'cacq37iq': {
      'en': '01/06/2025',
      'he': '01/06/2025',
      'id': 'Kepala Pengadaan',
      'ms': 'Ketua Perolehan',
    },
    'whotijlg': {
      'en': 'No problems found',
      'he': 'לא נמצאו בעיות',
      'id': 'Randy Alcorn',
      'ms': 'Randy Alcorn',
    },
    '2tmpc136': {
      'en': '15/05/2025',
      'he': '15/05/2025',
      'id': 'Kepala Pengadaan',
      'ms': 'Ketua Perolehan',
    },
    'c7mlpdai': {
      'en': 'No problems found',
      'he': 'לא נמצאו בעיות',
      'id': 'Randy Alcorn',
      'ms': 'Randy Alcorn',
    },
    'r0f1wtdf': {
      'en': '06/05/2025',
      'he': '06/05/2025',
      'id': 'Kepala Pengadaan',
      'ms': 'Ketua Perolehan',
    },
    'mk55qtlt': {
      'en': 'No problems found',
      'he': 'לא נמצאו בעיות',
      'id': 'James Wiseman',
      'ms': 'James Wiseman',
    },
    'vkerup2g': {
      'en': '26/04/2025',
      'he': '26/04/2025',
      'id': 'Manajer Akuntansi',
      'ms': 'Pengurus akaun',
    },
    '15e6aiew': {
      'en': 'Mika',
      'he': 'מיקה',
      'id': '',
      'ms': '',
    },
    '3gdogcuj': {
      'en': 'No problems found',
      'he': 'לא נמצאו בעיות',
      'id': 'Randy Alcorn',
      'ms': 'Randy Alcorn',
    },
    'm1skw7zq': {
      'en': '12/06/2025',
      'he': '12/06/2025',
      'id': 'Kepala Pengadaan',
      'ms': 'Ketua Perolehan',
    },
    'd6yaafds': {
      'en': 'No problems found',
      'he': 'לא נמצאו בעיות',
      'id': 'Randy Alcorn',
      'ms': 'Randy Alcorn',
    },
    'ravf9evv': {
      'en': '01/06/2025',
      'he': '01/06/2025',
      'id': 'Kepala Pengadaan',
      'ms': 'Ketua Perolehan',
    },
    'jayfnk4b': {
      'en': 'Problem found!',
      'he': 'נמצאה בעיה!',
      'id': 'Randy Alcorn',
      'ms': 'Randy Alcorn',
    },
    '4d75exqp': {
      'en': '15/05/2025',
      'he': '15/05/2025',
      'id': 'Kepala Pengadaan',
      'ms': 'Ketua Perolehan',
    },
    'hkjqhfr5': {
      'en': 'Plack',
      'he': 'פלאק',
      'id': 'Kepala Pengadaan',
      'ms': 'Ketua Perolehan',
    },
    'zszyq3qo': {
      'en': 'No problems found',
      'he': 'לא נמצאו בעיות',
      'id': 'Randy Alcorn',
      'ms': 'Randy Alcorn',
    },
    '17tbb4ca': {
      'en': '06/05/2025',
      'he': '06/05/2025',
      'id': 'Kepala Pengadaan',
      'ms': 'Ketua Perolehan',
    },
    'iu055ept': {
      'en': 'No problems found',
      'he': 'לא נמצאו בעיות',
      'id': 'James Wiseman',
      'ms': 'James Wiseman',
    },
    '4hp0xkx2': {
      'en': '26/04/2025',
      'he': '26/04/2025',
      'id': 'Manajer Akuntansi',
      'ms': 'Pengurus akaun',
    },
    '3ourv2w9': {
      'en': '__',
      'he': '__',
      'id': '__',
      'ms': '__',
    },
  },
  // Main_Diagnose
  {
    'smh1o93d': {
      'en': 'Diagnose',
      'he': 'אבחון',
      'id': 'Kontrak',
      'ms': 'Kontrak',
    },
    'dlt46loo': {
      'en': 'Choose a member:',
      'he': 'בחר/י חבר צוות:',
      'id': 'Kontrak',
      'ms': 'Kontrak',
    },
    'j08eiorc': {
      'en': '__',
      'he': '__',
      'id': '__',
      'ms': '__',
    },
  },
  // Family
  {
    '609lph0v': {
      'en': 'My Family',
      'he': 'המשפחה שלי',
      'id': '',
      'ms': '',
    },
    'umoqnnb1': {
      'en': '',
      'he': '',
      'id': '',
      'ms': '',
    },
    'ww48hqky': {
      'en': '+',
      'he': '+',
      'id': '',
      'ms': '',
    },
    'smtxdnbn': {
      'en': '__',
      'he': '__',
      'id': '__',
      'ms': '__',
    },
  },
  // Main_profilePage
  {
    'qrxn5crt': {
      'en': 'My Profile',
      'he': 'הפרופיל שלי',
      'id': 'Profil saya',
      'ms': 'Profil saya',
    },
    'v1hh7jlp': {
      'en': 'Switch to Dark Mode',
      'he': 'עבור למצב כהה',
      'id': 'Beralih ke Mode Gelap',
      'ms': 'Tukar kepada Mod Gelap',
    },
    'sh7q15l6': {
      'en': 'Switch to Light Mode',
      'he': 'עבור למצב בהיר',
      'id': 'Beralih ke Mode Cahaya',
      'ms': 'Tukar kepada Mod Cahaya',
    },
    'fyxsf6vn': {
      'en': 'Account Settings',
      'he': 'הגדרות חשבון',
      'id': 'Pengaturan akun',
      'ms': 'Tetapan Akaun',
    },
    'h43llaan': {
      'en': 'Manage Family',
      'he': 'ניהול משפחה',
      'id': 'Ganti kata sandi',
      'ms': 'Tukar kata laluan',
    },
    'b1lw0hfu': {
      'en': 'Preferences and Accessibility',
      'he': 'העדפות ונגישות',
      'id': 'Sunting profil',
      'ms': 'Sunting profil',
    },
    'abqf147c': {
      'en': 'Log Out',
      'he': 'התנתק',
      'id': 'Keluar',
      'ms': 'Log keluar',
    },
    'o3dp9tss': {
      'en': '__',
      'he': '__',
      'id': '__',
      'ms': '__',
    },
  },
  // Camera
  {
    'w972eae7': {
      'en': 'Light balance',
      'he': 'איזון תאורה',
      'id': '',
      'ms': '',
    },
    'eaietejr': {
      'en': 'Brightness',
      'he': 'בהירות',
      'id': '',
      'ms': '',
    },
    'u1lkhmsh': {
      'en': 'Exposure',
      'he': 'חשיפה',
      'id': '',
      'ms': '',
    },
    '3z1637ww': {
      'en': 'Contrast',
      'he': 'ניגודיות',
      'id': '',
      'ms': '',
    },
    'phrtb6wf': {
      'en': 'Highlights',
      'he': 'הדגשות',
      'id': '',
      'ms': '',
    },
    '7hd0gmek': {
      'en': 'Shadows',
      'he': 'צללים',
      'id': '',
      'ms': '',
    },
    'abvzrcko': {
      'en': 'Take photo!',
      'he': 'צלם/י תמונה!',
      'id': '',
      'ms': '',
    },
    'o9yv9tqq': {
      'en': 'Preview',
      'he': 'תצוגה מקדימה',
      'id': '',
      'ms': '',
    },
    'hrli547k': {
      'en': 'Please make sure camera is seated properly',
      'he': 'אנא ודא/י שהמצלמה ממוקמת כראוי',
      'id': '',
      'ms': '',
    },
    '2jil0fv1': {
      'en': 'Home',
      'he': 'בית',
      'id': '',
      'ms': '',
    },
  },
  // DiagnosisGood
  {
    'e5ztajlj': {
      'en': 'No problems detected, good job!',
      'he': 'לא זוהו בעיות, עבודה טובה!',
      'id': '',
      'ms': '',
    },
    'oll2n2k5': {
      'en': 'Diagnosis',
      'he': 'אבחון',
      'id': '',
      'ms': '',
    },
    '0pos3zta': {
      'en': 'Home',
      'he': 'בית',
      'id': '',
      'ms': '',
    },
  },
  // DiagnosisPlack
  {
    'yrm43d77': {
      'en': 'Problem detected: Plack',
      'he': 'זוהתה בעיה: פלאק',
      'id': '',
      'ms': '',
    },
    'o44qkbc9': {
      'en': 'Advice:',
      'he': 'המלצה:',
      'id': '',
      'ms': '',
    },
    '3e2p6t0b': {
      'en':
      'More thorough brushing, focus more on the inner left side of the mouth.\nUse a soft-fiber toothbrush',
      'he': 'צחצוח יסודי יותר, התמקד/י יותר בצד השמאלי הפנימי של הפה.\nהשתמש/י במברשת שיניים עם סיבים רכים.',
      'id': '',
      'ms': '',
    },
    'oo2y7ww0': {
      'en': 'Diagnosis',
      'he': 'אבחון',
      'id': '',
      'ms': '',
    },
    'irumc86j': {
      'en': 'Home',
      'he': 'בית',
      'id': '',
      'ms': '',
    },
  },
  // DiagnosisPlackCavity
  {
    'jlylby4g': {
      'en': 'Problem detected: Plack',
      'he': 'זוהתה בעיה: פלאק',
      'id': '',
      'ms': '',
    },
    '1r9dts97': {
      'en': 'Advice:',
      'he': 'המלצה:',
      'id': '',
      'ms': '',
    },
    'g3onei9w': {
      'en':
      'More thorough brushing, focus more on the inner left side of the mouth.\nUse a soft-fiber toothbrush',
      'he': 'צחצוח יסודי יותר, התמקד/י יותר בצד השמאלי הפנימי של הפה.\nהשתמש/י במברשת שיניים עם סיבים רכים.',
      'id': '',
      'ms': '',
    },
    'o537478g': {
      'en': 'Problem detected: Cavity',
      'he': 'זוהתה בעיה: חור בשן',
      'id': '',
      'ms': '',
    },
    'yyd8epn5': {
      'en': 'Advice:',
      'he': 'המלצה:',
      'id': '',
      'ms': '',
    },
    'c33xlo8j': {
      'en':
      'Indications of a cavity are appearing on the base of the cuspid on the right side.\nThe use of mouthwash after brushing is recommanded.\nIf you feel any pain, schedule a doctor appointment.',
      'he': 'סימנים לחור מופיעים בבסיס הניב בצד ימין.\nמומלץ להשתמש במי פה לאחר הצחצוח.\nבמידה ויש כאב, קבע/י תור לרופא.',
      'id': '',
      'ms': '',
    },
    'cw83ljf7': {
      'en': 'Diagnosis',
      'he': 'אבחון',
      'id': '',
      'ms': '',
    },
    'covqeaa4': {
      'en': 'Home',
      'he': 'בית',
      'id': '',
      'ms': '',
    },
  },
  // DiagnosisCavity
  {
    '5ck7mnyd': {
      'en': 'Upload',
      'he': 'העלה',
      'id': '',
      'ms': '',
    },
    'w0eizveb': {
      'en': 'Detect',
      'he': 'זהה',
      'id': '',
      'ms': '',
    },
    't6s40hur': {
      'en': 'Home',
      'he': 'בית',
      'id': '',
      'ms': '',
    },
  },
  // auth_2_Create
  {
    '7x498wvw': {
      'en': 'Bina ',
      'he': 'בינה ',
      'id': '',
      'ms': '',
    },
    'pwekpcwd': {
      'en': 'Get Started',
      'he': 'מתחילים',
      'id': '',
      'ms': '',
    },
    'gu5o6pdk': {
      'en': 'Create an account by using the form below.',
      'he': 'צור/י חשבון באמצעות הטופס למטה.',
      'id': '',
      'ms': '',
    },
    'c71pv0m4': {
      'en': 'name',
      'he': 'שם',
      'id': '',
      'ms': '',
    },
    'x8m48y2p': {
      'en': 'Email',
      'he': 'אימייל',
      'id': '',
      'ms': '',
    },
    'd69sdrms': {
      'en': 'Password',
      'he': 'סיסמה',
      'id': '',
      'ms': '',
    },
    'llees51u': {
      'en': 'birthday',
      'he': 'תאריך לידה',
      'id': '',
      'ms': '',
    },
    'i1jbvk65': {
      'en': 'Gender',
      'he': 'מגדר',
      'id': '',
      'ms': '',
    },
    'tgz3ru1h': {
      'en': 'Search for an item...',
      'he': 'חפש/י פריט...',
      'id': '',
      'ms': '',
    },
    'kpngnsd5': {
      'en': 'Male',
      'he': 'זכר',
      'id': '',
      'ms': '',
    },
    'm4fwgt1i': {
      'en': 'Female',
      'he': 'נקבה',
      'id': '',
      'ms': '',
    },
    'p26kr74a': {
      'en': 'Rather Not Disclouse',
      'he': 'מעדיף/ה לא לציין',
      'id': '',
      'ms': '',
    },
    'z4fzwb7k': {
      'en': 'Create Account',
      'he': 'צור חשבון',
      'id': '',
      'ms': '',
    },
    'wi5b68oy': {
      'en': 'Already have an account? ',
      'he': 'כבר יש לך חשבון? ',
      'id': '',
      'ms': '',
    },
    'meimul7j': {
      'en': 'Sign in here',
      'he': 'התחבר כאן',
      'id': '',
      'ms': '',
    },
    'vc2sjby7': {
      'en': 'Home',
      'he': 'בית',
      'id': '',
      'ms': '',
    },
  },
  // auth_2_Login
  {
    'bphmg5zj': {
      'en': 'Bina ',
      'he': 'בינה ',
      'id': '',
      'ms': '',
    },
    'jsow1zkm': {
      'en': 'Welcome Back',
      'he': 'ברוך השב',
      'id': '',
      'ms': '',
    },
    '0g7rc7ho': {
      'en': 'Fill out the information below in order to access your account.',
      'he': 'מלא/י את הפרטים למטה כדי לגשת לחשבונך.',
      'id': '',
      'ms': '',
    },
    'qzd05hym': {
      'en': 'Email',
      'he': 'אימייל',
      'id': '',
      'ms': '',
    },
    '2em4alc6': {
      'en': 'Password',
      'he': 'סיסמה',
      'id': '',
      'ms': '',
    },
    'e3i91khq': {
      'en': 'Sign In',
      'he': 'התחברות',
      'id': '',
      'ms': '',
    },
    'rlv6ildk': {
      'en': 'Don\'t have an account?  ',
      'he': 'אין לך חשבון? ',
      'id': '',
      'ms': '',
    },
    'mtsguguk': {
      'en': 'Create Account',
      'he': 'צור חשבון',
      'id': '',
      'ms': '',
    },
    'vifhe4r6': {
      'en': 'Forgot password?',
      'he': 'שכחת סיסמה?',
      'id': '',
      'ms': '',
    },
    '8mt2zjs0': {
      'en': 'Home',
      'he': 'בית',
      'id': '',
      'ms': '',
    },
  },
  // auth_2_ForgotPassword
  {
    'n1wihh9r': {
      'en': 'Bina ',
      'he': 'בינה ',
      'id': '',
      'ms': '',
    },
    'm2oi1dus': {
      'en': 'Forgot Password',
      'he': 'שכחתי סיסמה',
      'id': '',
      'ms': '',
    },
    '0i9qpt6b': {
      'en':
      'Please fill out your email belo in order to recieve a reset password link.',
      'he': 'אנא מלא/י את כתובת האימייל כדי לקבל קישור לאיפוס סיסמה.',
      'id': '',
      'ms': '',
    },
    'h7ggbaau': {
      'en': 'Email',
      'he': 'אימייל',
      'id': '',
      'ms': '',
    },
    'oxefc8xl': {
      'en': 'Send Reset Link',
      'he': 'שלח קישור לאיפוס',
      'id': '',
      'ms': '',
    },
    '3jn4q2g5': {
      'en': 'Home',
      'he': 'בית',
      'id': '',
      'ms': '',
    },
  },
  // auth_2_createProfile
  {
    '7g2ljvog': {
      'en': 'Bina ',
      'he': 'בינה ',
      'id': '',
      'ms': '',
    },
    'deytzh8h': {
      'en': 'Home',
      'he': 'בית',
      'id': '',
      'ms': '',
    },
  },
  // auth_2_Profile
  {
    'mv3aa31t': {
      'en': '',
      'he': '',
      'id': '',
      'ms': '',
    },
    '0ytdwza8': {
      'en': '',
      'he': '',
      'id': '',
      'ms': '',
    },
    'coygd922': {
      'en': 'Your Account',
      'he': 'החשבון שלך',
      'id': '',
      'ms': '',
    },
    '8ctbqg92': {
      'en': 'Edit Profile',
      'he': 'ערוך פרופיל',
      'id': '',
      'ms': '',
    },
    'ue4tdodf': {
      'en': 'App Settings',
      'he': 'הגדרות אפליקציה',
      'id': '',
      'ms': '',
    },
    'ljm3zuye': {
      'en': 'Support',
      'he': 'תמיכה',
      'id': '',
      'ms': '',
    },
    'sl7qwp3g': {
      'en': 'Terms of Service',
      'he': 'תנאי שימוש',
      'id': '',
      'ms': '',
    },
    'ud37xux6': {
      'en': 'Log Out',
      'he': 'התנתקות',
      'id': '',
      'ms': '',
    },
    '5utl5cz5': {
      'en': 'Home',
      'he': 'בית',
      'id': '',
      'ms': '',
    },
  },
  // auth_2_EditProfile
  {
    'b15mqbg3': {
      'en': 'Home',
      'he': 'בית',
      'id': '',
      'ms': '',
    },
  },
  // CameraCheck
  {
    'kred63vb': {
      'en': 'Device status: Connected!',
      'he': 'מצב מכשיר: מחובר!',
      'id': 'Kirim Konfirmasi Kontrak',
      'ms': 'Hantar Pengesahan Kontrak',
    },
    'e408bhw6': {
      'en': 'OK',
      'he': 'אישור',
      'id': 'Kirim Informasi',
      'ms': 'Hantar Maklumat',
    },
  },
  // FamilySuccess
  {
    'wa4vkne2': {
      'en': 'Congratulations!',
      'he': 'מזל טוב!',
      'id': 'Selamat!',
      'ms': 'tahniah!',
    },
    '3hf2ocig': {
      'en': 'New member added successfully',
      'he': 'חבר חדש נוסף בהצלחה',
      'id':
      'Sekarang kontrak telah dibuat untuk pelanggan ini, silakan hubungi mereka dengan tanggal Anda akan mengirim perjanjian yang ditandatangani.',
      'ms':
      'Memandangkan kontrak telah dijana untuk pelanggan ini, sila hubungi mereka dengan tarikh anda akan menghantar perjanjian yang ditandatangani.',
    },
    'q0jvi1lp': {
      'en': 'Okay',
      'he': 'אוקיי',
      'id': 'Oke',
      'ms': 'baik',
    },
  },
  // Success
  {
    '00flvi93': {
      'en': 'Operation success!',
      'he': 'הפעולה הצליחה!',
      'id': 'Selamat!',
      'ms': 'tahniah!',
    },
    'fmzceh74': {
      'en': 'New diagnosis will be generated soon!',
      'he': 'אבחון חדש יופק בקרוב!',
      'id': 'Kontrak baru telah dibuat untuk:',
      'ms': 'Kontrak baru telah dijana untuk:',
    },
    'g8q2u55w': {
      'en': 'Continue',
      'he': 'המשך',
      'id': 'Melanjutkan',
      'ms': 'teruskan',
    },
  },
  // createNote
  {
    'l2jlnhye': {
      'en': 'Create Note',
      'he': 'צור הערה',
      'id': 'Buat Catatan',
      'ms': 'Cipta Nota',
    },
    'd6yfe8tj': {
      'en': 'Find members by searching below',
      'he': 'מצא/י חברים על ידי חיפוש למטה',
      'id': 'Temukan anggota dengan mencari di bawah',
      'ms': 'Cari ahli dengan mencari di bawah',
    },
    '9gf6o5ss': {
      'en': 'Enter your note here...',
      'he': 'הזן/י את ההערה כאן...',
      'id': 'Masukkan catatan Anda di sini...',
      'ms': 'Masukkan nota anda di sini...',
    },
    'farrki57': {
      'en': 'Create Note',
      'he': 'צור הערה',
      'id': 'Buat Catatan',
      'ms': 'Cipta Nota',
    },
  },
  // mobileNav
  {
    'sy0pxvma': {
      'en': 'Dashboard',
      'he': 'לוח בקרה',
      'id': 'Dasbor',
      'ms': 'Papan pemuka',
    },
    't5c3aiuy': {
      'en': 'My Team',
      'he': 'הצוות שלי',
      'id': 'Kelompok ku',
      'ms': 'Pasukan saya',
    },
    'nkz3c58a': {
      'en': 'Customers',
      'he': 'לקוחות',
      'id': 'Pelanggan',
      'ms': 'Pelanggan',
    },
    '1mkyyjwj': {
      'en': 'Contracts',
      'he': 'חוזים',
      'id': 'Kontrak',
      'ms': 'Kontrak',
    },
    'eg79coc6': {
      'en': 'Profile',
      'he': 'פרופיל',
      'id': 'Profil',
      'ms': 'Profil',
    },
  },
  // webNav
  {
    'c9o7o7xh': {
      'en': 'Bina ',
      'he': 'בינה ',
      'id': '',
      'ms': '',
    },
    'yg07zi4c': {
      'en': 'Home',
      'he': 'בית',
      'id': 'Dasbor',
      'ms': 'Papan pemuka',
    },
    'lbojdpxg': {
      'en': 'Diagnostics',
      'he': 'אבחונים',
      'id': 'Pelanggan',
      'ms': 'Pelanggan',
    },
    '9pjba90p': {
      'en': 'Camera',
      'he': 'מצלמה',
      'id': 'Kontrak',
      'ms': 'Kontrak',
    },
    '01nu9cy0': {
      'en': 'Profile',
      'he': 'פרופיל',
      'id': 'Profil',
      'ms': 'Profil',
    },
  },
  // Accessibility
  {
    'pw6kvl1f': {
      'en': 'Preferences and Accessibility',
      'he': 'העדפות ונגישות',
      'id': 'tautan langsung',
      'ms': 'Pautan Pantas',
    },
    'gckukxjv': {
      'en': 'Text Settings',
      'he': 'הגדרות טקסט',
      'id': 'Temukan Kontrak',
      'ms': 'Cari Kontrak',
    },
    'zsq8vj02': {
      'en': 'Color and Theme',
      'he': 'צבע וערכת נושא',
      'id': 'Temukan Pelanggan',
      'ms': 'Cari Pelanggan',
    },
    'iqxwv326': {
      'en': 'Language and Region',
      'he': 'שפה ואזור',
      'id': 'Kontrak baru',
      'ms': 'Kontrak Baru',
    },
    's60yfg0g': {
      'en': 'Help and Support',
      'he': 'עזרה ותמיכה',
      'id': 'Pelanggan baru',
      'ms': 'Pelanggan baru',
    },
  },
  // editProfilePhoto
  {
    '6bnefz1c': {
      'en': 'Change Photo',
      'he': 'שנה תמונה',
      'id': '',
      'ms': '',
    },
    'yaxe7q8v': {
      'en':
      'Upload a new photo below in order to change your avatar seen by others.',
      'he': 'העלה/י תמונה חדשה למטה כדי לשנות את האווטאר שלך.',
      'id': '',
      'ms': '',
    },
    're4x0sz7': {
      'en': 'Upload Image',
      'he': 'העלה תמונה',
      'id': '',
      'ms': '',
    },
    'sr54fsk6': {
      'en': 'Save Changes',
      'he': 'שמור שינויים',
      'id': '',
      'ms': '',
    },
  },
  // FamilyMember
  {
    'e3gk5os7': {
      'en': 'Create Member',
      'he': 'צור חבר צוות',
      'id': 'Buat Catatan',
      'ms': 'Cipta Nota',
    },
    'nwy3vye6': {
      'en': 'Enter member info below',
      'he': 'הזן/י פרטי חבר למטה',
      'id': 'Temukan anggota dengan mencari di bawah',
      'ms': 'Cari ahli dengan mencari di bawah',
    },
    '2rkmiqyr': {
      'en': 'name',
      'he': 'שם',
      'id': '',
      'ms': '',
    },
    '7zhjhvr8': {
      'en': 'Birthday',
      'he': 'תאריך לידה',
      'id': '',
      'ms': '',
    },
    '7syz836y': {
      'en': 'Gender',
      'he': 'מגדר',
      'id': '',
      'ms': '',
    },
    'sekelp0m': {
      'en': 'Search for an item...',
      'he': 'חפש/י פריט...',
      'id': '',
      'ms': '',
    },
    '1pcjocor': {
      'en': 'Male',
      'he': 'זכר',
      'id': '',
      'ms': '',
    },
    'rcwbqs7l': {
      'en': 'Female',
      'he': 'נקבה',
      'id': '',
      'ms': '',
    },
    '660v8p3t': {
      'en': 'Rather Not Disclouse',
      'he': 'מעדיף/ה לא לציין',
      'id': '',
      'ms': '',
    },
    '3syylynq': {
      'en': 'Create Member',
      'he': 'צור חבר',
      'id': 'Buat Catatan',
      'ms': 'Cipta Nota',
    },
  },
  // editProfile_auth_2
  {
    'cfnr4q80': {
      'en': 'Adjust the content below to update your profile.',
      'he': 'עדכן/י את התוכן למטה כדי לעדכן את הפרופיל.',
      'id': '',
      'ms': '',
    },
    'u42j5t5x': {
      'en': 'Change Photo',
      'he': 'שנה תמונה',
      'id': '',
      'ms': '',
    },
    'hrubvu4m': {
      'en': 'Full Name',
      'he': 'שם מלא',
      'id': '',
      'ms': '',
    },
    'wdugkxi2': {
      'en': 'Your full name...',
      'he': 'השם המלא שלך...',
      'id': '',
      'ms': '',
    },
    '4ype6kkg': {
      'en': '',
      'he': '',
      'id': '',
      'ms': '',
    },
    'mzpep7jk': {
      'en': 'Your Role',
      'he': 'התפקיד שלך',
      'id': '',
      'ms': '',
    },
    'dmpx82h0': {
      'en': 'Search for an item...',
      'he': 'חפש/י פריט...',
      'id': '',
      'ms': '',
    },
    'bh82b223': {
      'en': 'Owner/Founder',
      'he': 'בעלים/מייסד',
      'id': '',
      'ms': '',
    },
    'phu34612': {
      'en': 'Director',
      'he': 'מנהל',
      'id': '',
      'ms': '',
    },
    '3u84r61z': {
      'en': 'Manager',
      'he': 'מנהל צוות',
      'id': '',
      'ms': '',
    },
    'rrippote': {
      'en': 'Mid-Manager',
      'he': 'מנהל ביניים',
      'id': '',
      'ms': '',
    },
    'pj1vpx8r': {
      'en': 'Employee',
      'he': 'עובד',
      'id': '',
      'ms': '',
    },
    'evezo4gx': {
      'en': 'Short Description',
      'he': 'תיאור קצר',
      'id': '',
      'ms': '',
    },
    '15ubbgyg': {
      'en': 'A little about you...',
      'he': 'קצת עליך...',
      'id': '',
      'ms': '',
    },
    'xkqq8b0e': {
      'en': '[bio]',
      'he': '[ביוגרפיה]',
      'id': '',
      'ms': '',
    },
  },
  // profile_pic
  {
    'muz1mh5f': {
      'en': 'Change Photo',
      'he': 'שנה תמונה',
      'id': '',
      'ms': '',
    },
  },
  // FamilyRowDetail
  {
    'yhtoc3s4': {
      'en': 'Diagnostics',
      'he': 'אבחונים',
      'id': '',
      'ms': '',
    },
  },
  // Miscellaneous
  {
    'txts001': {
      'en': 'Text Size',
      'he': 'גודל טקסט',
      'id': 'Ukuran Teks',
      'ms': 'Saiz Teks',
    },
    'txts002': {
      'en': 'Choose your preferred text size. Changes apply throughout the app.',
      'he': 'בחר/י את גודל הטקסט המועדף. השינויים יחולו בכל האפליקציה.',
      'id': 'Pilih ukuran teks yang Anda inginkan. Perubahan berlaku di seluruh aplikasi.',
      'ms': 'Pilih saiz teks pilihan anda. Perubahan akan digunakan di seluruh aplikasi.',
    },
    'txts003': {
      'en': 'Preview',
      'he': 'תצוגה מקדימה',
      'id': 'Pratinjau',
      'ms': 'Pratonton',
    },
    'txts004': {
      'en': 'This is how text will appear throughout the app with your selected size.',
      'he': 'כך ייראה הטקסט ברחבי האפליקציה בגודל שבחרת.',
      'id': 'Ini adalah tampilan teks di seluruh aplikasi dengan ukuran yang Anda pilih.',
      'ms': 'Beginilah teks akan kelihatan di seluruh aplikasi dengan saiz yang anda pilih.',
    },
  },
  // ThemeSettings
  {
    'thms001': {
      'en': 'Theme',
      'he': 'ערכת נושא',
      'id': 'Tema',
      'ms': 'Tema',
    },
    'thms002': {
      'en': 'Choose a color theme that works best for you.',
      'he': 'בחר/י ערכת נושא שמתאימה לך ביותר.',
      'id': 'Pilih tema warna yang paling sesuai untuk Anda.',
      'ms': 'Pilih tema warna yang paling sesuai untuk anda.',
    },
    'thms003': {
      'en': 'Contrast',
      'he': 'ניגודיות',
      'id': 'Kontras',
      'ms': 'Kontras',
    },
    'thms004': {
      'en': 'Adjust contrast level for better visibility.',
      'he': 'כוונן/י את רמת הניגודיות לנראות טובה יותר.',
      'id': 'Sesuaikan tingkat kontras untuk visibilitas yang lebih baik.',
      'ms': 'Laraskan tahap kontras untuk penglihatan yang lebih baik.',
    },
    'thms005': {
      'en': 'Preview',
      'he': 'תצוגה מקדימה',
      'id': 'Pratinjau',
      'ms': 'Pratonton',
    },
    'thms006': {
      'en': 'Primary',
      'he': 'ראשי',
      'id': 'Utama',
      'ms': 'Utama',
    },
    'thms007': {
      'en': 'Secondary',
      'he': 'משני',
      'id': 'Sekunder',
      'ms': 'Sekunder',
    },
    'thms008': {
      'en': 'Background',
      'he': 'רקע',
      'id': 'Latar Belakang',
      'ms': 'Latar Belakang',
    },
  },
  // HelpSupport
  {
    'help001': {
      'en': 'Help & Support',
      'he': 'עזרה ותמיכה',
      'id': 'Bantuan & Dukungan',
      'ms': 'Bantuan & Sokongan',
    },
    'help002': {
      'en': 'Contact Us',
      'he': 'צור קשר',
      'id': 'Hubungi Kami',
      'ms': 'Hubungi Kami',
    },
    'help003': {
      'en': 'Email',
      'he': 'אימייל',
      'id': 'Email',
      'ms': 'E-mel',
    },
    'help004': {
      'en': 'support@binaapp.com',
      'he': 'support@binaapp.com',
      'id': 'support@binaapp.com',
      'ms': 'support@binaapp.com',
    },
    'help005': {
      'en': 'Phone',
      'he': 'טלפון',
      'id': 'Telepon',
      'ms': 'Telefon',
    },
    'help006': {
      'en': '+1 (555) 123-4567',
      'he': '+1 (555) 123-4567',
      'id': '+1 (555) 123-4567',
      'ms': '+1 (555) 123-4567',
    },
    'help007': {
      'en': 'Send Feedback',
      'he': 'שלח משוב',
      'id': 'Kirim Umpan Balik',
      'ms': 'Hantar Maklum Balas',
    },
    'help008': {
      'en': 'We\'d love to hear from you!',
      'he': 'נשמח לשמוע ממך!',
      'id': 'Kami ingin mendengar dari Anda!',
      'ms': 'Kami ingin mendengar daripada anda!',
    },
    'help009': {
      'en': 'Category',
      'he': 'קטגוריה',
      'id': 'Kategori',
      'ms': 'Kategori',
    },
    'help010': {
      'en': 'Bug Report',
      'he': 'דיווח על באג',
      'id': 'Laporan Bug',
      'ms': 'Laporan Pepijat',
    },
    'help011': {
      'en': 'Feature Request',
      'he': 'בקשת פיצ\'ר',
      'id': 'Permintaan Fitur',
      'ms': 'Permintaan Ciri',
    },
    'help012': {
      'en': 'General Feedback',
      'he': 'משוב כללי',
      'id': 'Umpan Balik Umum',
      'ms': 'Maklum Balas Umum',
    },
    'help013': {
      'en': 'Your feedback...',
      'he': 'המשוב שלך...',
      'id': 'Umpan balik Anda...',
      'ms': 'Maklum balas anda...',
    },
    'help014': {
      'en': 'Submit',
      'he': 'שלח',
      'id': 'Kirim',
      'ms': 'Hantar',
    },
    'help015': {
      'en': 'FAQ',
      'he': 'שאלות נפוצות',
      'id': 'FAQ',
      'ms': 'Soalan Lazim',
    },
    'help016': {
      'en': 'How do I add a family member?',
      'he': 'איך מוסיפים בן משפחה?',
      'id': 'Bagaimana cara menambahkan anggota keluarga?',
      'ms': 'Bagaimana untuk menambah ahli keluarga?',
    },
    'help017': {
      'en': 'Go to Profile > Manage Family and tap the + button to add a new family member.',
      'he': 'עבור לפרופיל > ניהול משפחה והקש על כפתור ה-+ כדי להוסיף בן משפחה חדש.',
      'id': 'Buka Profil > Kelola Keluarga dan ketuk tombol + untuk menambahkan anggota keluarga baru.',
      'ms': 'Pergi ke Profil > Urus Keluarga dan ketik butang + untuk menambah ahli keluarga baru.',
    },
    'help018': {
      'en': 'How do I take a scan?',
      'he': 'איך מבצעים סריקה?',
      'id': 'Bagaimana cara melakukan pemindaian?',
      'ms': 'Bagaimana untuk mengambil imbasan?',
    },
    'help019': {
      'en': 'Navigate to the Camera tab, select a family member, and follow the on-screen instructions to capture images.',
      'he': 'עבור ללשונית המצלמה, בחר/י בן משפחה, ועקוב/י אחר ההוראות על המסך לצילום תמונות.',
      'id': 'Navigasi ke tab Kamera, pilih anggota keluarga, dan ikuti petunjuk di layar untuk mengambil gambar.',
      'ms': 'Navigasi ke tab Kamera, pilih ahli keluarga, dan ikuti arahan di skrin untuk mengambil gambar.',
    },
    'help020': {
      'en': 'Is my data secure?',
      'he': 'האם הנתונים שלי מאובטחים?',
      'id': 'Apakah data saya aman?',
      'ms': 'Adakah data saya selamat?',
    },
    'help021': {
      'en': 'Yes, all data is encrypted and stored securely. We never share your personal information with third parties.',
      'he': 'כן, כל הנתונים מוצפנים ונשמרים בצורה מאובטחת. לעולם לא נשתף את המידע האישי שלך עם צדדים שלישיים.',
      'id': 'Ya, semua data dienkripsi dan disimpan dengan aman. Kami tidak pernah membagikan informasi pribadi Anda kepada pihak ketiga.',
      'ms': 'Ya, semua data disulitkan dan disimpan dengan selamat. Kami tidak pernah berkongsi maklumat peribadi anda dengan pihak ketiga.',
    },
    'help022': {
      'en': 'How do I change the app language?',
      'he': 'איך משנים את שפת האפליקציה?',
      'id': 'Bagaimana cara mengubah bahasa aplikasi?',
      'ms': 'Bagaimana untuk menukar bahasa aplikasi?',
    },
    'help023': {
      'en': 'Go to Profile > Preferences and Accessibility > Language and Region to select your preferred language.',
      'he': 'עבור לפרופיל > העדפות ונגישות > שפה ואזור כדי לבחור את השפה המועדפת.',
      'id': 'Buka Profil > Preferensi dan Aksesibilitas > Bahasa dan Wilayah untuk memilih bahasa pilihan Anda.',
      'ms': 'Pergi ke Profil > Keutamaan dan Kebolehcapaian > Bahasa dan Wilayah untuk memilih bahasa pilihan anda.',
    },
    'help024': {
      'en': 'Tutorials',
      'he': 'מדריכים',
      'id': 'Tutorial',
      'ms': 'Tutorial',
    },
    'help025': {
      'en': 'Getting Started',
      'he': 'איך מתחילים',
      'id': 'Memulai',
      'ms': 'Bermula',
    },
    'help026': {
      'en': 'Learn the basics',
      'he': 'למד/י את היסודות',
      'id': 'Pelajari dasar-dasarnya',
      'ms': 'Pelajari asas-asasnya',
    },
    'help027': {
      'en': 'Taking Scans',
      'he': 'ביצוע סריקות',
      'id': 'Mengambil Pemindaian',
      'ms': 'Mengambil Imbasan',
    },
    'help028': {
      'en': 'How to capture images',
      'he': 'איך מצלמים תמונות',
      'id': 'Cara mengambil gambar',
      'ms': 'Cara mengambil gambar',
    },
    'help029': {
      'en': 'Understanding Results',
      'he': 'הבנת תוצאות',
      'id': 'Memahami Hasil',
      'ms': 'Memahami Keputusan',
    },
    'help030': {
      'en': 'Reading your diagnosis',
      'he': 'קריאת האבחון שלך',
      'id': 'Membaca diagnosis Anda',
      'ms': 'Membaca diagnosis anda',
    },
    'help031': {
      'en': 'Family Management',
      'he': 'ניהול משפחה',
      'id': 'Manajemen Keluarga',
      'ms': 'Pengurusan Keluarga',
    },
    'help032': {
      'en': 'Managing family members',
      'he': 'ניהול בני משפחה',
      'id': 'Mengelola anggota keluarga',
      'ms': 'Mengurus ahli keluarga',
    },
    'help033': {
      'en': 'Thank you for your feedback!',
      'he': 'תודה על המשוב שלך!',
      'id': 'Terima kasih atas umpan balik Anda!',
      'ms': 'Terima kasih atas maklum balas anda!',
    },
  },
  // LanguageSettings
  {
    'lang001': {
      'en': 'Language',
      'he': 'שפה',
      'id': 'Bahasa',
      'ms': 'Bahasa',
    },
    'lang002': {
      'en': 'Select your preferred language. The app will restart with the new language.',
      'he': 'בחר/י את השפה המועדפת. האפליקציה תופעל מחדש עם השפה החדשה.',
      'id': 'Pilih bahasa pilihan Anda. Aplikasi akan dimulai ulang dengan bahasa baru.',
      'ms': 'Pilih bahasa pilihan anda. Aplikasi akan dimulakan semula dengan bahasa baru.',
    },
    'lang003': {
      'en': 'More languages will be added in future updates. Contact us if you would like to help translate the app.',
      'he': 'שפות נוספות יתווספו בעדכונים עתידיים. צור קשר אם תרצה/י לעזור בתרגום.',
      'id': 'Lebih banyak bahasa akan ditambahkan dalam pembaruan mendatang. Hubungi kami jika Anda ingin membantu menerjemahkan aplikasi.',
      'ms': 'Lebih banyak bahasa akan ditambah dalam kemas kini akan datang. Hubungi kami jika anda ingin membantu menterjemah aplikasi.',
    },
  },
  // AccessibilityToggles
  {
    'accs001': {
      'en': 'Hints Mode',
      'he': 'מצב רמזים',
      'id': 'Mode Petunjuk',
      'ms': 'Mod Petunjuk',
    },
    'accs002': {
      'en': 'Show tooltips on long-press',
      'he': 'הצג טיפים בלחיצה ארוכה',
      'id': 'Tampilkan tooltip saat tekan lama',
      'ms': 'Tunjukkan petua alat pada tekan lama',
    },
    'accs003': {
      'en': 'Auto-Adjust Settings',
      'he': 'התאמה אוטומטית',
      'id': 'Pengaturan Penyesuaian Otomatis',
      'ms': 'Tetapan Pelarasan Automatik',
    },
    'accs004': {
      'en': 'Adjust text size based on age (65+)',
      'he': 'התאם גודל טקסט לפי גיל (65+)',
      'id': 'Sesuaikan ukuran teks berdasarkan usia (65+)',
      'ms': 'Laraskan saiz teks berdasarkan umur (65+)',
    },
  },
  // CameraConnection
  {
    'camc001': {
      'en': 'Camera Connection',
      'he': 'חיבור מצלמה',
      'id': 'Koneksi Kamera',
      'ms': 'Sambungan Kamera',
    },
    'camc002': {
      'en': 'IP Address',
      'he': 'כתובת IP',
      'id': 'Alamat IP',
      'ms': 'Alamat IP',
    },
    'camc003': {
      'en': 'e.g., 192.168.1.100',
      'he': 'לדוגמה, 192.168.1.100',
      'id': 'contoh, 192.168.1.100',
      'ms': 'cth., 192.168.1.100',
    },
    'camc004': {
      'en': 'Port',
      'he': 'פורט (Port)',
      'id': 'Port',
      'ms': 'Port',
    },
    'camc005': {
      'en': 'e.g., 8080',
      'he': 'לדוגמה, 8080',
      'id': 'contoh, 8080',
      'ms': 'cth., 8080',
    },
    'camc006': {
      'en': 'Connect',
      'he': 'התחבר',
      'id': 'Hubungkan',
      'ms': 'Sambung',
    },
    'camc007': {
      'en': 'Disconnect',
      'he': 'נתק',
      'id': 'Putuskan',
      'ms': 'Putuskan',
    },
    'camc008': {
      'en': 'Connected',
      'he': 'מחובר',
      'id': 'Terhubung',
      'ms': 'Disambung',
    },
    'camc009': {
      'en': 'Disconnected',
      'he': 'מנותק',
      'id': 'Terputus',
      'ms': 'Terputus',
    },
    'camc010': {
      'en': 'Camera Preview',
      'he': 'תצוגת מצלמה',
      'id': 'Pratinjau Kamera',
      'ms': 'Pratonton Kamera',
    },
    'camc011': {
      'en': 'Connection failed. Check IP and port.',
      'he': 'החיבור נכשל. בדוק/י IP ופורט.',
      'id': 'Koneksi gagal. Periksa IP dan port.',
      'ms': 'Sambungan gagal. Semak IP dan port.',
    },
    'camc012': {
      'en': 'Not Connected',
      'he': 'לא מחובר',
      'id': 'Tidak Terhubung',
      'ms': 'Tidak Disambung',
    },
    'camc013': {
      'en': 'No camera connected',
      'he': 'אין מצלמה מחוברת',
      'id': 'Tidak ada kamera yang terhubung',
      'ms': 'Tiada kamera disambung',
    },
    'camc014': {
      'en': 'Nearby Devices',
      'he': 'התקנים בקרבת מקום',
      'id': 'Perangkat Terdekat',
      'ms': 'Peranti Berdekatan',
    },
    'camc015': {
      'en': 'Scanning...',
      'he': 'סורק...',
      'id': 'Memindai...',
      'ms': 'Mengimbas...',
    },
    'camc016': {
      'en': 'No devices found',
      'he': 'לא נמצאו התקנים',
      'id': 'Tidak ada perangkat ditemukan',
      'ms': 'Tiada peranti dijumpai',
    },
    'camc017': {
      'en': 'Tap "Scan" to search for nearby cameras',
      'he': 'הקש "סרוק" לחיפוש מצלמות בקרבת מקום',
      'id': 'Ketuk "Pindai" untuk mencari kamera terdekat',
      'ms': 'Ketik "Imbas" untuk mencari kamera berdekatan',
    },
    'camc018': {
      'en': 'Scan for Devices',
      'he': 'סרוק התקנים',
      'id': 'Pindai Perangkat',
      'ms': 'Imbas Peranti',
    },
    'camc019': {
      'en': 'Stop Scan',
      'he': 'עצור סריקה',
      'id': 'Hentikan Pemindaian',
      'ms': 'Hentikan Imbasan',
    },
    'camc020': {
      'en': 'OR',
      'he': 'או',
      'id': 'ATAU',
      'ms': 'ATAU',
    },
    'camc021': {
      'en': 'Enter IP Manually',
      'he': 'הזן IP ידנית',
      'id': 'Masukkan IP Secara Manual',
      'ms': 'Masukkan IP Secara Manual',
    },
    'camc022': {
      'en': 'Enter Camera IP Address',
      'he': 'הזן כתובת IP של מצלמה',
      'id': 'Masukkan Alamat IP Kamera',
      'ms': 'Masukkan Alamat IP Kamera',
    },
    'camc023': {
      'en': 'Failed to start discovery. Check permissions.',
      'he': 'הסריקה נכשלה. בדוק הרשאות.',
      'id': 'Gagal memulai penemuan. Periksa izin.',
      'ms': 'Gagal memulakan penemuan. Semak kebenaran.',
    },
    'camc024': {
      'en': 'Failed to connect to',
      'he': 'נכשל בחיבור אל',
      'id': 'Gagal terhubung ke',
      'ms': 'Gagal menyambung ke',
    },
    'camc025': {
      'en': 'WiFi Direct is not available on this device. Use manual IP entry to connect.',
      'he': 'WiFi Direct אינו זמין במכשיר זה. השתמש בהזנת IP ידנית להתחברות.',
      'id': 'WiFi Direct tidak tersedia di perangkat ini. Gunakan entri IP manual untuk menghubungkan.',
      'ms': 'WiFi Direct tidak tersedia pada peranti ini. Gunakan kemasukan IP manual untuk menyambung.',
    },
    'camc026': {
      'en': 'Cancel',
      'he': 'ביטול',
      'id': 'Batal',
      'ms': 'Batal',
    },
  },
  // PhotoSession
  {
    'phts001': {
      'en': 'Photo Session',
      'he': 'סשן צילום',
      'id': 'Sesi Foto',
      'ms': 'Sesi Foto',
    },
    'phts002': {
      'en': 'Capture photos for diagnosis',
      'he': 'צלם/י תמונות לאבחון',
      'id': 'Ambil foto untuk diagnosis',
      'ms': 'Ambil foto untuk diagnosis',
    },
    'phts003': {
      'en': 'Front View',
      'he': 'מבט חזיתי',
      'id': 'Tampilan Depan',
      'ms': 'Paparan Hadapan',
    },
    'phts004': {
      'en': 'Left Side',
      'he': 'צד שמאל',
      'id': 'Sisi Kiri',
      'ms': 'Sebelah Kiri',
    },
    'phts005': {
      'en': 'Right Side',
      'he': 'צד ימין',
      'id': 'Sisi Kanan',
      'ms': 'Sebelah Kanan',
    },
    'phts006': {
      'en': 'Top View',
      'he': 'מבט מלמעלה',
      'id': 'Tampilan Atas',
      'ms': 'Paparan Atas',
    },
    'phts007': {
      'en': 'Bottom View',
      'he': 'מבט מלמטה',
      'id': 'Tampilan Bawah',
      'ms': 'Paparan Bawah',
    },
    'phts008': {
      'en': 'Tap to capture',
      'he': 'הקש לצילום',
      'id': 'Ketuk untuk mengambil',
      'ms': 'Ketik untuk tangkap',
    },
    'phts009': {
      'en': 'Retake',
      'he': 'צילום חוזר',
      'id': 'Ambil Ulang',
      'ms': 'Ambil Semula',
    },
    'phts010': {
      'en': 'Submit All',
      'he': 'שלח הכל',
      'id': 'Kirim Semua',
      'ms': 'Hantar Semua',
    },
    'phts011': {
      'en': 'Processing...',
      'he': 'מעבד...',
      'id': 'Memproses...',
      'ms': 'Memproses...',
    },
    'phts012': {
      'en': 'Gallery',
      'he': 'גלריה',
      'id': 'Galeri',
      'ms': 'Galeri',
    },
    'phts013': {
      'en': 'Camera',
      'he': 'מצלמה',
      'id': 'Kamera',
      'ms': 'Kamera',
    },
    'phts014': {
      'en': 'Patient:',
      'he': 'מטופל:',
      'id': 'Pasien:',
      'ms': 'Pesakit:',
    },
    'phts015': {
      'en': 'images',
      'he': 'תמונות',
      'id': 'gambar',
      'ms': 'imej',
    },
    'phts016': {
      'en': 'No images yet',
      'he': 'אין תמונות עדיין',
      'id': 'Belum ada gambar',
      'ms': 'Tiada imej lagi',
    },
    'phts017': {
      'en': 'Capture dental images using the buttons below',
      'he': 'צלם/י תמונות שיניים באמצעות הכפתורים למטה',
      'id': 'Ambil gambar gigi menggunakan tombol di bawah',
      'ms': 'Tangkap imej gigi menggunakan butang di bawah',
    },
    'phts018': {
      'en': 'Processing image...',
      'he': 'מעבד תמונה...',
      'id': 'Memproses gambar...',
      'ms': 'Memproses imej...',
    },
    'phts019': {
      'en': 'Finish Session',
      'he': 'סיים סשן',
      'id': 'Selesaikan Sesi',
      'ms': 'Selesaikan Sesi',
    },
    'phts020': {
      'en': 'Camera is not available on web.',
      'he': 'המצלמה אינה זמינה ברשת.',
      'id': 'Kamera tidak tersedia di web.',
      'ms': 'Kamera tidak tersedia di web.',
    },
    'phts021': {
      'en': 'Bina Camera is not connected.',
      'he': 'מצלמת בינה אינה מחוברת.',
      'id': 'Kamera Bina tidak terhubung.',
      'ms': 'Kamera Bina tidak disambung.',
    },
    'phts022': {
      'en': 'Diagnosis is not available on web.',
      'he': 'האבחון אינו זמין ברשת.',
      'id': 'Diagnosis tidak tersedia di web.',
      'ms': 'Diagnosis tidak tersedia di web.',
    },
    'phts023': {
      'en': 'Please capture at least one image before finishing.',
      'he': 'יש לצלם לפחות תמונה אחת לפני הסיום.',
      'id': 'Silakan ambil setidaknya satu gambar sebelum selesai.',
      'ms': 'Sila tangkap sekurang-kurangnya satu imej sebelum selesai.',
    },
    'phts024': {
      'en': 'Error initializing session:',
      'he': 'שגיאה באתחול סשן:',
      'id': 'Kesalahan inisialisasi sesi:',
      'ms': 'Ralat memulakan sesi:',
    },
    'phts025': {
      'en': 'Error processing image:',
      'he': 'שגיאה בעיבוד תמונה:',
      'id': 'Kesalahan memproses gambar:',
      'ms': 'Ralat memproses imej:',
    },
    'phts026': {
      'en': 'Error finishing session:',
      'he': 'שגיאה בסיום סשן:',
      'id': 'Kesalahan menyelesaikan sesi:',
      'ms': 'Ralat menyelesaikan sesi:',
    },
  },
  // ChatPages
  {
    'chat001': {
      'en': 'Chats',
      'he': 'צ\'אטים',
      'id': 'Obrolan',
      'ms': 'Sembang',
    },
    'chat002': {
      'en': 'No conversations yet',
      'he': 'אין שיחות עדיין',
      'id': 'Belum ada percakapan',
      'ms': 'Tiada perbualan lagi',
    },
    'chat003': {
      'en': 'Tap + to start a new chat',
      'he': 'הקש על + להתחלת צ\'אט חדש',
      'id': 'Ketuk + untuk memulai obrolan baru',
      'ms': 'Ketik + untuk memulakan sembang baru',
    },
    'chat004': {
      'en': 'Delete conversation?',
      'he': 'למחוק שיחה?',
      'id': 'Hapus percakapan?',
      'ms': 'Padam perbualan?',
    },
    'chat005': {
      'en': 'Cancel',
      'he': 'ביטול',
      'id': 'Batal',
      'ms': 'Batal',
    },
    'chat006': {
      'en': 'Delete',
      'he': 'מחק',
      'id': 'Hapus',
      'ms': 'Padam',
    },
    'chat007': {
      'en': 'No messages yet',
      'he': 'אין הודעות עדיין',
      'id': 'Belum ada pesan',
      'ms': 'Tiada mesej lagi',
    },
    'chat008': {
      'en': 'Type a message...',
      'he': 'הקלד הודעה...',
      'id': 'Ketik pesan...',
      'ms': 'Taip mesej...',
    },
    'chat009': {
      'en': 'New Chat',
      'he': 'צ\'אט חדש',
      'id': 'Obrolan Baru',
      'ms': 'Sembang Baru',
    },
  },
  // Dialogs
  {
    'dlg001': {
      'en': 'Loading...',
      'he': 'טוען...',
      'id': 'Memuat...',
      'ms': 'Memuatkan...',
    },
    'dlg002': {
      'en': 'Confirm',
      'he': 'אישור',
      'id': 'Konfirmasi',
      'ms': 'Sahkan',
    },
    'dlg003': {
      'en': 'Cancel',
      'he': 'ביטול',
      'id': 'Batal',
      'ms': 'Batal',
    },
    'dlg004': {
      'en': 'An error occurred',
      'he': 'אירעה שגיאה',
      'id': 'Terjadi kesalahan',
      'ms': 'Ralat berlaku',
    },
    'dlg005': {
      'en': 'Log Out?',
      'he': 'להתנתק?',
      'id': 'Keluar?',
      'ms': 'Log Keluar?',
    },
    'dlg006': {
      'en': 'Are you sure you want to log out of your account?',
      'he': 'האם את/ה בטוח/ה שברצונך להתנתק מהחשבון?',
      'id': 'Apakah Anda yakin ingin keluar dari akun Anda?',
      'ms': 'Adakah anda pasti mahu log keluar daripada akaun anda?',
    },
    'dlg007': {
      'en': 'Log Out',
      'he': 'התנתקות',
      'id': 'Keluar',
      'ms': 'Log Keluar',
    },
    'dlg008': {
      'en': 'Logging out...',
      'he': 'מתנתק...',
      'id': 'Sedang keluar...',
      'ms': 'Sedang log keluar...',
    },
    'dlg009': {
      'en': 'Deleting...',
      'he': 'מוחק...',
      'id': 'Menghapus...',
      'ms': 'Memadam...',
    },
    'dlg010': {
      'en': 'Creating family member...',
      'he': 'יוצר בן משפחה...',
      'id': 'Membuat anggota keluarga...',
      'ms': 'Mencipta ahli keluarga...',
    },
    'dlg011': {
      'en': 'Error creating member',
      'he': 'שגיאה ביצירת חבר',
      'id': 'Kesalahan membuat anggota',
      'ms': 'Ralat mencipta ahli',
    },
  },
  // Tooltips
  {
    'tip001': {
      'en': 'Add or edit family members',
      'he': 'הוסף או ערוך בני משפחה',
      'id': 'Tambah atau edit anggota keluarga',
      'ms': 'Tambah atau edit ahli keluarga',
    },
    'tip002': {
      'en': 'Change text size, themes, and more',
      'he': 'שנה גודל טקסט, ערכות נושא ועוד',
      'id': 'Ubah ukuran teks, tema, dan lainnya',
      'ms': 'Tukar saiz teks, tema, dan lain-lain',
    },
    'tip003': {
      'en': 'Add a new family member',
      'he': 'הוסף בן משפחה חדש',
      'id': 'Tambah anggota keluarga baru',
      'ms': 'Tambah ahli keluarga baru',
    },
    'tip004': {
      'en': 'Connect to external camera',
      'he': 'התחבר למצלמה חיצונית',
      'id': 'Hubungkan ke kamera eksternal',
      'ms': 'Sambung ke kamera luaran',
    },
  },
  // SessionDetails
  {
    'sesd001': {
      'en': 'Session Details',
      'he': 'פרטי סשן',
      'id': 'Detail Sesi',
      'ms': 'Butiran Sesi',
    },
    'sesd002': {
      'en': 'Diagnosis',
      'he': 'אבחון',
      'id': 'Diagnosis',
      'ms': 'Diagnosis',
    },
    'sesd003': {
      'en': 'Images',
      'he': 'תמונות',
      'id': 'Gambar',
      'ms': 'Imej',
    },
    'sesd004': {
      'en': 'No issues found',
      'he': 'לא נמצאו בעיות',
      'id': 'Tidak ditemukan masalah',
      'ms': 'Tiada isu dijumpai',
    },
    'sesd005': {
      'en': 'Issues found',
      'he': 'נמצאו בעיות',
      'id': 'Masalah ditemukan',
      'ms': 'Isu dijumpai',
    },
    'sesd006': {
      'en': 'Severity',
      'he': 'חומרה',
      'id': 'Tingkat Keparahan',
      'ms': 'Keterukan',
    },
    'sesd007': {
      'en': 'Advice',
      'he': 'המלצה',
      'id': 'Saran',
      'ms': 'Nasihat',
    },
    'sesd008': {
      'en': 'Date',
      'he': 'תאריך',
      'id': 'Tanggal',
      'ms': 'Tarikh',
    },
    'sesd009': {
      'en': 'Error loading images',
      'he': 'שגיאה בטעינת תמונות',
      'id': 'Kesalahan memuat gambar',
      'ms': 'Ralat memuatkan imej',
    },
    'sesd010': {
      'en': 'Invalid session ID',
      'he': 'מזהה סשן לא חוקי',
      'id': 'ID sesi tidak valid',
      'ms': 'ID sesi tidak sah',
    },
    'sesd011': {
      'en': 'No images found',
      'he': 'לא נמצאו תמונות',
      'id': 'Tidak ditemukan gambar',
      'ms': 'Tiada imej dijumpai',
    },
    'sesd012': {
      'en': 'This session has no images',
      'he': 'סשן זה אינו מכיל תמונות',
      'id': 'Sesi ini tidak memiliki gambar',
      'ms': 'Sesi ini tidak mempunyai imej',
    },
    'sesd013': {
      'en': 'Original Image',
      'he': 'תמונה מקורית',
      'id': 'Gambar Asli',
      'ms': 'Imej Asal',
    },
    'sesd014': {
      'en': 'Diagnosed Image',
      'he': 'תמונה מאובחנת',
      'id': 'Gambar Diagnosis',
      'ms': 'Imej Diagnosis',
    },
    'sesd015': {
      'en': 'Detection Summary',
      'he': 'סיכום זיהוי',
      'id': 'Ringkasan Deteksi',
      'ms': 'Ringkasan Pengesanan',
    },
    'sesd016': {
      'en': 'Issues Found',
      'he': 'בעיות שנמצאו',
      'id': 'Masalah Ditemukan',
      'ms': 'Isu Dijumpai',
    },
    'sesd017': {
      'en': 'No issues detected',
      'he': 'לא זוהו בעיות',
      'id': 'Tidak ada masalah terdeteksi',
      'ms': 'Tiada isu dikesan',
    },
    'sesd018': {
      'en': 'Teeth Detected',
      'he': 'שיניים שזוהו',
      'id': 'Gigi Terdeteksi',
      'ms': 'Gigi Dikesan',
    },
    'sesd019': {
      'en': 'Original image not available',
      'he': 'התמונה המקורית אינה זמינה',
      'id': 'Gambar asli tidak tersedia',
      'ms': 'Imej asal tidak tersedia',
    },
    'sesd020': {
      'en': 'Diagnosed image not available',
      'he': 'התמונה המאובחנת אינה זמינה',
      'id': 'Gambar diagnosis tidak tersedia',
      'ms': 'Imej diagnosis tidak tersedia',
    },
  },


].reduce((a, b) => a..addAll(b));


// final kTranslationsMap = <Map<String, Map<String, String>>>[
//   // Main_Home
//   {
//     'nnv46x35': {
//       'en': 'Weekly Summary',
//       'id': 'Di bawah ini adalah ringkasan aktivitas tim Anda.',
//       'ms': 'Di bawah ialah ringkasan aktiviti pasukan anda.',
//     },
//     'kphqz3hi': {
//       'en': 'Updates',
//       'id': 'Proyek',
//       'ms': 'Projek',
//     },
//     'xlzf8qqx': {
//       'en': 'Undiagnosed members this week:',
//       'id': 'Tim Desain UI',
//       'ms': 'Pasukan Reka Bentuk UI',
//     },
//     'puy8obok': {
//       'en': 'Contract Activity',
//       'id': 'Aktivitas Kontrak',
//       'ms': 'Aktiviti Kontrak',
//     },
//     'zlovh0zt': {
//       'en': 'Below is an a summary of activity.',
//       'id': 'Di bawah ini adalah ringkasan kegiatan.',
//       'ms': 'Di bawah ialah ringkasan aktiviti.',
//     },
//     'g1uaaovn': {
//       'en': 'Customer Activity',
//       'id': 'Aktivitas Pelanggan',
//       'ms': 'Aktiviti Pelanggan',
//     },
//     'e5q3ows1': {
//       'en': 'Below is an a summary of activity.',
//       'id': 'Di bawah ini adalah ringkasan kegiatan.',
//       'ms': 'Di bawah ialah ringkasan aktiviti.',
//     },
//     'uj7jsxmo': {
//       'en': 'Sigal (You): Cavity',
//       'id': 'Aktivitas Kontrak',
//       'ms': 'Aktiviti Kontrak',
//     },
//     'hkk2zmjw': {
//       'en': 'Severity: Severe\nAdvice: Visit doctor ASAP',
//       'id': 'Di bawah ini adalah ringkasan kegiatan.',
//       'ms': 'Di bawah ialah ringkasan aktiviti.',
//     },
//     'jkgae0vc': {
//       'en': 'Idan: Plaque',
//       'id': 'Aktivitas Pelanggan',
//       'ms': 'Aktiviti Pelanggan',
//     },
//     'g4os7kcp': {
//       'en':
//           'Severity: Light\nAdvice: More Thorough brishing, use a\nsoft fiber toothbrush',
//       'id': 'Di bawah ini adalah ringkasan kegiatan.',
//       'ms': 'Di bawah ialah ringkasan aktiviti.',
//     },
//     'xdxbdj20': {
//       'en': '__',
//       'id': '__',
//       'ms': '__',
//     },
//   },
//   // Main_DIagnostics
//   {
//     'n99lg1qh': {
//       'en': 'Diagnostics',
//       'id': 'Pelanggan',
//       'ms': 'Pelanggan',
//     },
//     'lvnskphp': {
//       'en': 'Sigal (You)',
//       'id': 'Semua',
//       'ms': 'Semua',
//     },
//     'f5d3fvff': {
//       'en': 'Major problem found!',
//       'id': 'Randy Alcorn',
//       'ms': 'Randy Alcorn',
//     },
//     'jwrrbd37': {
//       'en': '14/06/2025',
//       'id': 'Kepala Pengadaan',
//       'ms': 'Ketua Perolehan',
//     },
//     '4vyvrsvp': {
//       'en': 'Cavity (severe)',
//       'id': 'Kepala Pengadaan',
//       'ms': 'Ketua Perolehan',
//     },
//     'xbmye3r1': {
//       'en': 'Problem found!',
//       'id': 'Randy Alcorn',
//       'ms': 'Randy Alcorn',
//     },
//     'sot8njss': {
//       'en': '01/06/2025',
//       'id': 'Kepala Pengadaan',
//       'ms': 'Ketua Perolehan',
//     },
//     'ko2o59js': {
//       'en': 'Cavity (minor), Plack',
//       'id': 'Kepala Pengadaan',
//       'ms': 'Ketua Perolehan',
//     },
//     'lbnt26st': {
//       'en': 'No problems found',
//       'id': 'Randy Alcorn',
//       'ms': 'Randy Alcorn',
//     },
//     'io7qmr33': {
//       'en': '26/05/2025',
//       'id': 'Kepala Pengadaan',
//       'ms': 'Ketua Perolehan',
//     },
//     '35o5woky': {
//       'en': 'Problem found!',
//       'id': 'Randy Alcorn',
//       'ms': 'Randy Alcorn',
//     },
//     '8ieto4rf': {
//       'en': '13/05/2025',
//       'id': 'Kepala Pengadaan',
//       'ms': 'Ketua Perolehan',
//     },
//     '2719y4vf': {
//       'en': 'Plack',
//       'id': 'Kepala Pengadaan',
//       'ms': 'Ketua Perolehan',
//     },
//     'a258xeav': {
//       'en': 'No problems found',
//       'id': 'Randy Alcorn',
//       'ms': 'Randy Alcorn',
//     },
//     'wduyui67': {
//       'en': '05/05/2025',
//       'id': 'Kepala Pengadaan',
//       'ms': 'Ketua Perolehan',
//     },
//     'u0su8kte': {
//       'en': 'No problems found',
//       'id': 'James Wiseman',
//       'ms': 'James Wiseman',
//     },
//     'nyfsg4hw': {
//       'en': '26/04/2025',
//       'id': 'Manajer Akuntansi',
//       'ms': 'Pengurus akaun',
//     },
//     'qh2ock0d': {
//       'en': 'Idan',
//       'id': 'Aktif',
//       'ms': 'Aktif',
//     },
//     'yj40ezzo': {
//       'en': 'Problem found!',
//       'id': 'Randy Alcorn',
//       'ms': 'Randy Alcorn',
//     },
//     '25dp2kkr': {
//       'en': '14/06/2025',
//       'id': 'Kepala Pengadaan',
//       'ms': 'Ketua Perolehan',
//     },
//     'qpaeeh6n': {
//       'en': 'Plack',
//       'id': 'Manajer Akuntansi',
//       'ms': 'Pengurus akaun',
//     },
//     'hx6auuvz': {
//       'en': 'No problems found',
//       'id': 'Randy Alcorn',
//       'ms': 'Randy Alcorn',
//     },
//     'p7egakgn': {
//       'en': '01/06/2025',
//       'id': 'Kepala Pengadaan',
//       'ms': 'Ketua Perolehan',
//     },
//     'g9xzjmh4': {
//       'en': 'Problem found!',
//       'id': 'Randy Alcorn',
//       'ms': 'Randy Alcorn',
//     },
//     'zj5j9aqi': {
//       'en': '15/05/2025',
//       'id': 'Kepala Pengadaan',
//       'ms': 'Ketua Perolehan',
//     },
//     '82sehtrs': {
//       'en': 'Plack',
//       'id': 'Manajer Akuntansi',
//       'ms': 'Pengurus akaun',
//     },
//     '7mw5a1fj': {
//       'en': 'Problem found!',
//       'id': 'Randy Alcorn',
//       'ms': 'Randy Alcorn',
//     },
//     '0wu7ys98': {
//       'en': '06/05/2025',
//       'id': 'Kepala Pengadaan',
//       'ms': 'Ketua Perolehan',
//     },
//     '1k5z65cm': {
//       'en': 'Plack',
//       'id': 'Manajer Akuntansi',
//       'ms': 'Pengurus akaun',
//     },
//     'xlgk615j': {
//       'en': 'Problem found!',
//       'id': 'James Wiseman',
//       'ms': 'James Wiseman',
//     },
//     'uhbzwcb6': {
//       'en': '26/04/2025',
//       'id': 'Manajer Akuntansi',
//       'ms': 'Pengurus akaun',
//     },
//     '0ovyr17x': {
//       'en': 'Plack',
//       'id': 'Manajer Akuntansi',
//       'ms': 'Pengurus akaun',
//     },
//     's7xebw09': {
//       'en': 'Nadav',
//       'id': 'Panggilan Dingin',
//       'ms': 'Panggilan Dingin',
//     },
//     '7s0fouho': {
//       'en': 'REMINDER!!!',
//       'id': 'Randy Alcorn',
//       'ms': 'Randy Alcorn',
//     },
//     'rsn6tjee': {
//       'en': 'Nadav hasn\'t been diagnosed in 17 days!',
//       'id': 'Kepala Pengadaan',
//       'ms': 'Ketua Perolehan',
//     },
//     'a0y9ee8v': {
//       'en': 'No problems found',
//       'id': 'Randy Alcorn',
//       'ms': 'Randy Alcorn',
//     },
//     'cacq37iq': {
//       'en': '01/06/2025',
//       'id': 'Kepala Pengadaan',
//       'ms': 'Ketua Perolehan',
//     },
//     'whotijlg': {
//       'en': 'No problems found',
//       'id': 'Randy Alcorn',
//       'ms': 'Randy Alcorn',
//     },
//     '2tmpc136': {
//       'en': '15/05/2025',
//       'id': 'Kepala Pengadaan',
//       'ms': 'Ketua Perolehan',
//     },
//     'c7mlpdai': {
//       'en': 'No problems found',
//       'id': 'Randy Alcorn',
//       'ms': 'Randy Alcorn',
//     },
//     'r0f1wtdf': {
//       'en': '06/05/2025',
//       'id': 'Kepala Pengadaan',
//       'ms': 'Ketua Perolehan',
//     },
//     'mk55qtlt': {
//       'en': 'No problems found',
//       'id': 'James Wiseman',
//       'ms': 'James Wiseman',
//     },
//     'vkerup2g': {
//       'en': '26/04/2025',
//       'id': 'Manajer Akuntansi',
//       'ms': 'Pengurus akaun',
//     },
//     '15e6aiew': {
//       'en': 'Mika',
//       'id': '',
//       'ms': '',
//     },
//     '3gdogcuj': {
//       'en': 'No problems found',
//       'id': 'Randy Alcorn',
//       'ms': 'Randy Alcorn',
//     },
//     'm1skw7zq': {
//       'en': '12/06/2025',
//       'id': 'Kepala Pengadaan',
//       'ms': 'Ketua Perolehan',
//     },
//     'd6yaafds': {
//       'en': 'No problems found',
//       'id': 'Randy Alcorn',
//       'ms': 'Randy Alcorn',
//     },
//     'ravf9evv': {
//       'en': '01/06/2025',
//       'id': 'Kepala Pengadaan',
//       'ms': 'Ketua Perolehan',
//     },
//     'jayfnk4b': {
//       'en': 'Problem found!',
//       'id': 'Randy Alcorn',
//       'ms': 'Randy Alcorn',
//     },
//     '4d75exqp': {
//       'en': '15/05/2025',
//       'id': 'Kepala Pengadaan',
//       'ms': 'Ketua Perolehan',
//     },
//     'hkjqhfr5': {
//       'en': 'Plack',
//       'id': 'Kepala Pengadaan',
//       'ms': 'Ketua Perolehan',
//     },
//     'zszyq3qo': {
//       'en': 'No problems found',
//       'id': 'Randy Alcorn',
//       'ms': 'Randy Alcorn',
//     },
//     '17tbb4ca': {
//       'en': '06/05/2025',
//       'id': 'Kepala Pengadaan',
//       'ms': 'Ketua Perolehan',
//     },
//     'iu055ept': {
//       'en': 'No problems found',
//       'id': 'James Wiseman',
//       'ms': 'James Wiseman',
//     },
//     '4hp0xkx2': {
//       'en': '26/04/2025',
//       'id': 'Manajer Akuntansi',
//       'ms': 'Pengurus akaun',
//     },
//     '3ourv2w9': {
//       'en': '__',
//       'id': '__',
//       'ms': '__',
//     },
//   },
//   // Main_Diagnose
//   {
//     'smh1o93d': {
//       'en': 'Diagnose',
//       'id': 'Kontrak',
//       'ms': 'Kontrak',
//     },
//     'dlt46loo': {
//       'en': 'Choose a member:',
//       'id': 'Kontrak',
//       'ms': 'Kontrak',
//     },
//     'j08eiorc': {
//       'en': '__',
//       'id': '__',
//       'ms': '__',
//     },
//   },
//   // Family
//   {
//     '609lph0v': {
//       'en': 'My Family',
//       'id': '',
//       'ms': '',
//     },
//     'umoqnnb1': {
//       'en': '',
//       'id': '',
//       'ms': '',
//     },
//     'ww48hqky': {
//       'en': '+',
//       'id': '',
//       'ms': '',
//     },
//     'smtxdnbn': {
//       'en': '__',
//       'id': '__',
//       'ms': '__',
//     },
//   },
//   // Main_profilePage
//   {
//     'qrxn5crt': {
//       'en': 'My Profile',
//       'id': 'Profil saya',
//       'ms': 'Profil saya',
//     },
//     'v1hh7jlp': {
//       'en': 'Switch to Dark Mode',
//       'id': 'Beralih ke Mode Gelap',
//       'ms': 'Tukar kepada Mod Gelap',
//     },
//     'sh7q15l6': {
//       'en': 'Switch to Light Mode',
//       'id': 'Beralih ke Mode Cahaya',
//       'ms': 'Tukar kepada Mod Cahaya',
//     },
//     'fyxsf6vn': {
//       'en': 'Account Settings',
//       'id': 'Pengaturan akun',
//       'ms': 'Tetapan Akaun',
//     },
//     'h43llaan': {
//       'en': 'Manage Family',
//       'id': 'Ganti kata sandi',
//       'ms': 'Tukar kata laluan',
//     },
//     'b1lw0hfu': {
//       'en': 'Preferences and Accessibility',
//       'id': 'Sunting profil',
//       'ms': 'Sunting profil',
//     },
//     'abqf147c': {
//       'en': 'Log Out',
//       'id': 'Keluar',
//       'ms': 'Log keluar',
//     },
//     'o3dp9tss': {
//       'en': '__',
//       'id': '__',
//       'ms': '__',
//     },
//   },
//   // Camera
//   {
//     'w972eae7': {
//       'en': 'Light balance',
//       'id': '',
//       'ms': '',
//     },
//     'eaietejr': {
//       'en': 'Brightness',
//       'id': '',
//       'ms': '',
//     },
//     'u1lkhmsh': {
//       'en': 'Exposure',
//       'id': '',
//       'ms': '',
//     },
//     '3z1637ww': {
//       'en': 'Contrast',
//       'id': '',
//       'ms': '',
//     },
//     'phrtb6wf': {
//       'en': 'Highlights',
//       'id': '',
//       'ms': '',
//     },
//     '7hd0gmek': {
//       'en': 'Shadows',
//       'id': '',
//       'ms': '',
//     },
//     'abvzrcko': {
//       'en': 'Take photo!',
//       'id': '',
//       'ms': '',
//     },
//     'o9yv9tqq': {
//       'en': 'Preview',
//       'id': '',
//       'ms': '',
//     },
//     'hrli547k': {
//       'en': 'Please make sure camera is seated properly',
//       'id': '',
//       'ms': '',
//     },
//     '2jil0fv1': {
//       'en': 'Home',
//       'id': '',
//       'ms': '',
//     },
//   },
//   // DiagnosisGood
//   {
//     'e5ztajlj': {
//       'en': 'No problems detected, good job!',
//       'id': '',
//       'ms': '',
//     },
//     'oll2n2k5': {
//       'en': 'Diagnosis',
//       'id': '',
//       'ms': '',
//     },
//     '0pos3zta': {
//       'en': 'Home',
//       'id': '',
//       'ms': '',
//     },
//   },
//   // DiagnosisPlack
//   {
//     'yrm43d77': {
//       'en': 'Problem detected: Plack',
//       'id': '',
//       'ms': '',
//     },
//     'o44qkbc9': {
//       'en': 'Advice:',
//       'id': '',
//       'ms': '',
//     },
//     '3e2p6t0b': {
//       'en':
//           'More thorough brushing, focus more on the inner left side of the mouth.\nUse a soft-fiber toothbrush',
//       'id': '',
//       'ms': '',
//     },
//     'oo2y7ww0': {
//       'en': 'Diagnosis',
//       'id': '',
//       'ms': '',
//     },
//     'irumc86j': {
//       'en': 'Home',
//       'id': '',
//       'ms': '',
//     },
//   },
//   // DiagnosisPlackCavity
//   {
//     'jlylby4g': {
//       'en': 'Problem detected: Plack',
//       'id': '',
//       'ms': '',
//     },
//     '1r9dts97': {
//       'en': 'Advice:',
//       'id': '',
//       'ms': '',
//     },
//     'g3onei9w': {
//       'en':
//           'More thorough brushing, focus more on the inner left side of the mouth.\nUse a soft-fiber toothbrush',
//       'id': '',
//       'ms': '',
//     },
//     'o537478g': {
//       'en': 'Problem detected: Cavity',
//       'id': '',
//       'ms': '',
//     },
//     'yyd8epn5': {
//       'en': 'Advice:',
//       'id': '',
//       'ms': '',
//     },
//     'c33xlo8j': {
//       'en':
//           'Indications of a cavity are appearing on the base of the cuspid on the right side.\nThe use of mouthwash after brushing is recommanded.\nIf you feel any pain, schedule a doctor appointment.',
//       'id': '',
//       'ms': '',
//     },
//     'cw83ljf7': {
//       'en': 'Diagnosis',
//       'id': '',
//       'ms': '',
//     },
//     'covqeaa4': {
//       'en': 'Home',
//       'id': '',
//       'ms': '',
//     },
//   },
//   // DiagnosisCavity
//   {
//     '5ck7mnyd': {
//       'en': 'Upload',
//       'id': '',
//       'ms': '',
//     },
//     'w0eizveb': {
//       'en': 'Detect',
//       'id': '',
//       'ms': '',
//     },
//     't6s40hur': {
//       'en': 'Home',
//       'id': '',
//       'ms': '',
//     },
//   },
//   // auth_2_Create
//   {
//     '7x498wvw': {
//       'en': 'Bina ',
//       'id': '',
//       'ms': '',
//     },
//     'pwekpcwd': {
//       'en': 'Get Started',
//       'id': '',
//       'ms': '',
//     },
//     'gu5o6pdk': {
//       'en': 'Create an account by using the form below.',
//       'id': '',
//       'ms': '',
//     },
//     'c71pv0m4': {
//       'en': 'name',
//       'id': '',
//       'ms': '',
//     },
//     'x8m48y2p': {
//       'en': 'Email',
//       'id': '',
//       'ms': '',
//     },
//     'd69sdrms': {
//       'en': 'Password',
//       'id': '',
//       'ms': '',
//     },
//     'llees51u': {
//       'en': 'birthday',
//       'id': '',
//       'ms': '',
//     },
//     'i1jbvk65': {
//       'en': 'Gender',
//       'id': '',
//       'ms': '',
//     },
//     'tgz3ru1h': {
//       'en': 'Search for an item...',
//       'id': '',
//       'ms': '',
//     },
//     'kpngnsd5': {
//       'en': 'Male',
//       'id': '',
//       'ms': '',
//     },
//     'm4fwgt1i': {
//       'en': 'Female',
//       'id': '',
//       'ms': '',
//     },
//     'p26kr74a': {
//       'en': 'Rather Not Disclouse',
//       'id': '',
//       'ms': '',
//     },
//     'z4fzwb7k': {
//       'en': 'Create Account',
//       'id': '',
//       'ms': '',
//     },
//     'wi5b68oy': {
//       'en': 'Already have an account? ',
//       'id': '',
//       'ms': '',
//     },
//     'meimul7j': {
//       'en': 'Sign in here',
//       'id': '',
//       'ms': '',
//     },
//     'vc2sjby7': {
//       'en': 'Home',
//       'id': '',
//       'ms': '',
//     },
//   },
//   // auth_2_Login
//   {
//     'bphmg5zj': {
//       'en': 'Bina ',
//       'id': '',
//       'ms': '',
//     },
//     'jsow1zkm': {
//       'en': 'Welcome Back',
//       'id': '',
//       'ms': '',
//     },
//     '0g7rc7ho': {
//       'en': 'Fill out the information below in order to access your account.',
//       'id': '',
//       'ms': '',
//     },
//     'qzd05hym': {
//       'en': 'Email',
//       'id': '',
//       'ms': '',
//     },
//     '2em4alc6': {
//       'en': 'Password',
//       'id': '',
//       'ms': '',
//     },
//     'e3i91khq': {
//       'en': 'Sign In',
//       'id': '',
//       'ms': '',
//     },
//     'rlv6ildk': {
//       'en': 'Don\'t have an account?  ',
//       'id': '',
//       'ms': '',
//     },
//     'mtsguguk': {
//       'en': 'Create Account',
//       'id': '',
//       'ms': '',
//     },
//     'vifhe4r6': {
//       'en': 'Forgot password?',
//       'id': '',
//       'ms': '',
//     },
//     '8mt2zjs0': {
//       'en': 'Home',
//       'id': '',
//       'ms': '',
//     },
//   },
//   // auth_2_ForgotPassword
//   {
//     'n1wihh9r': {
//       'en': 'Bina ',
//       'id': '',
//       'ms': '',
//     },
//     'm2oi1dus': {
//       'en': 'Forgot Password',
//       'id': '',
//       'ms': '',
//     },
//     '0i9qpt6b': {
//       'en':
//           'Please fill out your email belo in order to recieve a reset password link.',
//       'id': '',
//       'ms': '',
//     },
//     'h7ggbaau': {
//       'en': 'Email',
//       'id': '',
//       'ms': '',
//     },
//     'oxefc8xl': {
//       'en': 'Send Reset Link',
//       'id': '',
//       'ms': '',
//     },
//     '3jn4q2g5': {
//       'en': 'Home',
//       'id': '',
//       'ms': '',
//     },
//   },
//   // auth_2_createProfile
//   {
//     '7g2ljvog': {
//       'en': 'Bina ',
//       'id': '',
//       'ms': '',
//     },
//     'deytzh8h': {
//       'en': 'Home',
//       'id': '',
//       'ms': '',
//     },
//   },
//   // auth_2_Profile
//   {
//     'mv3aa31t': {
//       'en': '',
//       'id': '',
//       'ms': '',
//     },
//     '0ytdwza8': {
//       'en': '',
//       'id': '',
//       'ms': '',
//     },
//     'coygd922': {
//       'en': 'Your Account',
//       'id': '',
//       'ms': '',
//     },
//     '8ctbqg92': {
//       'en': 'Edit Profile',
//       'id': '',
//       'ms': '',
//     },
//     'ue4tdodf': {
//       'en': 'App Settings',
//       'id': '',
//       'ms': '',
//     },
//     'ljm3zuye': {
//       'en': 'Support',
//       'id': '',
//       'ms': '',
//     },
//     'sl7qwp3g': {
//       'en': 'Terms of Service',
//       'id': '',
//       'ms': '',
//     },
//     'ud37xux6': {
//       'en': 'Log Out',
//       'id': '',
//       'ms': '',
//     },
//     '5utl5cz5': {
//       'en': 'Home',
//       'id': '',
//       'ms': '',
//     },
//   },
//   // auth_2_EditProfile
//   {
//     'b15mqbg3': {
//       'en': 'Home',
//       'id': '',
//       'ms': '',
//     },
//   },
//   // CameraCheck
//   {
//     'kred63vb': {
//       'en': 'Device status: Connected!',
//       'id': 'Kirim Konfirmasi Kontrak',
//       'ms': 'Hantar Pengesahan Kontrak',
//     },
//     'e408bhw6': {
//       'en': 'OK',
//       'id': 'Kirim Informasi',
//       'ms': 'Hantar Maklumat',
//     },
//   },
//   // FamilySuccess
//   {
//     'wa4vkne2': {
//       'en': 'Congratulations!',
//       'id': 'Selamat!',
//       'ms': 'tahniah!',
//     },
//     '3hf2ocig': {
//       'en': 'New member added successfully',
//       'id':
//           'Sekarang kontrak telah dibuat untuk pelanggan ini, silakan hubungi mereka dengan tanggal Anda akan mengirim perjanjian yang ditandatangani.',
//       'ms':
//           'Memandangkan kontrak telah dijana untuk pelanggan ini, sila hubungi mereka dengan tarikh anda akan menghantar perjanjian yang ditandatangani.',
//     },
//     'q0jvi1lp': {
//       'en': 'Okay',
//       'id': 'Oke',
//       'ms': 'baik',
//     },
//   },
//   // Success
//   {
//     '00flvi93': {
//       'en': 'Operation success!',
//       'id': 'Selamat!',
//       'ms': 'tahniah!',
//     },
//     'fmzceh74': {
//       'en': 'New diagnosis will be generated soon!',
//       'id': 'Kontrak baru telah dibuat untuk:',
//       'ms': 'Kontrak baru telah dijana untuk:',
//     },
//     'g8q2u55w': {
//       'en': 'Continue',
//       'id': 'Melanjutkan',
//       'ms': 'teruskan',
//     },
//   },
//   // createComment
//   {
//     'l2jlnhye': {
//       'en': 'Create Note',
//       'id': 'Buat Catatan',
//       'ms': 'Cipta Nota',
//     },
//     'd6yfe8tj': {
//       'en': 'Find members by searching below',
//       'id': 'Temukan anggota dengan mencari di bawah',
//       'ms': 'Cari ahli dengan mencari di bawah',
//     },
//     '9gf6o5ss': {
//       'en': 'Enter your note here...',
//       'id': 'Masukkan catatan Anda di sini...',
//       'ms': 'Masukkan nota anda di sini...',
//     },
//     'farrki57': {
//       'en': 'Create Note',
//       'id': 'Buat Catatan',
//       'ms': 'Cipta Nota',
//     },
//   },
//   // mobileNav
//   {
//     'sy0pxvma': {
//       'en': 'Dashboard',
//       'id': 'Dasbor',
//       'ms': 'Papan pemuka',
//     },
//     't5c3aiuy': {
//       'en': 'My Team',
//       'id': 'Kelompok ku',
//       'ms': 'Pasukan saya',
//     },
//     'nkz3c58a': {
//       'en': 'Customers',
//       'id': 'Pelanggan',
//       'ms': 'Pelanggan',
//     },
//     '1mkyyjwj': {
//       'en': 'Contracts',
//       'id': 'Kontrak',
//       'ms': 'Kontrak',
//     },
//     'eg79coc6': {
//       'en': 'Profile',
//       'id': 'Profil',
//       'ms': 'Profil',
//     },
//   },
//   // webNav
//   {
//     'c9o7o7xh': {
//       'en': 'Bina ',
//       'id': '',
//       'ms': '',
//     },
//     'yg07zi4c': {
//       'en': 'Home',
//       'id': 'Dasbor',
//       'ms': 'Papan pemuka',
//     },
//     'lbojdpxg': {
//       'en': 'Diagnostics',
//       'id': 'Pelanggan',
//       'ms': 'Pelanggan',
//     },
//     '9pjba90p': {
//       'en': 'Camera',
//       'id': 'Kontrak',
//       'ms': 'Kontrak',
//     },
//     '01nu9cy0': {
//       'en': 'Profile',
//       'id': 'Profil',
//       'ms': 'Profil',
//     },
//   },
//   // Accessibility
//   {
//     'pw6kvl1f': {
//       'en': 'Preferences and Accessibility',
//       'id': 'tautan langsung',
//       'ms': 'Pautan Pantas',
//     },
//     'gckukxjv': {
//       'en': 'Text Settings',
//       'id': 'Temukan Kontrak',
//       'ms': 'Cari Kontrak',
//     },
//     'zsq8vj02': {
//       'en': 'Color and Theme',
//       'id': 'Temukan Pelanggan',
//       'ms': 'Cari Pelanggan',
//     },
//     'iqxwv326': {
//       'en': 'Language and Region',
//       'id': 'Kontrak baru',
//       'ms': 'Kontrak Baru',
//     },
//     's60yfg0g': {
//       'en': 'Help and Support',
//       'id': 'Pelanggan baru',
//       'ms': 'Pelanggan baru',
//     },
//   },
//   // editProfilePhoto
//   {
//     '6bnefz1c': {
//       'en': 'Change Photo',
//       'id': '',
//       'ms': '',
//     },
//     'yaxe7q8v': {
//       'en':
//           'Upload a new photo below in order to change your avatar seen by others.',
//       'id': '',
//       'ms': '',
//     },
//     're4x0sz7': {
//       'en': 'Upload Image',
//       'id': '',
//       'ms': '',
//     },
//     'sr54fsk6': {
//       'en': 'Save Changes',
//       'id': '',
//       'ms': '',
//     },
//   },
//   // FamilyMember
//   {
//     'e3gk5os7': {
//       'en': 'Create Member',
//       'id': 'Buat Catatan',
//       'ms': 'Cipta Nota',
//     },
//     'nwy3vye6': {
//       'en': 'Enter member info below',
//       'id': 'Temukan anggota dengan mencari di bawah',
//       'ms': 'Cari ahli dengan mencari di bawah',
//     },
//     '2rkmiqyr': {
//       'en': 'name',
//       'id': '',
//       'ms': '',
//     },
//     '7zhjhvr8': {
//       'en': 'Birthday',
//       'id': '',
//       'ms': '',
//     },
//     '7syz836y': {
//       'en': 'Gender',
//       'id': '',
//       'ms': '',
//     },
//     'sekelp0m': {
//       'en': 'Search for an item...',
//       'id': '',
//       'ms': '',
//     },
//     '1pcjocor': {
//       'en': 'Male',
//       'id': '',
//       'ms': '',
//     },
//     'rcwbqs7l': {
//       'en': 'Female',
//       'id': '',
//       'ms': '',
//     },
//     '660v8p3t': {
//       'en': 'Rather Not Disclouse',
//       'id': '',
//       'ms': '',
//     },
//     '3syylynq': {
//       'en': 'Create Member',
//       'id': 'Buat Catatan',
//       'ms': 'Cipta Nota',
//     },
//   },
//   // editProfile_auth_2
//   {
//     'cfnr4q80': {
//       'en': 'Adjust the content below to update your profile.',
//       'id': '',
//       'ms': '',
//     },
//     'u42j5t5x': {
//       'en': 'Change Photo',
//       'id': '',
//       'ms': '',
//     },
//     'hrubvu4m': {
//       'en': 'Full Name',
//       'id': '',
//       'ms': '',
//     },
//     'wdugkxi2': {
//       'en': 'Your full name...',
//       'id': '',
//       'ms': '',
//     },
//     '4ype6kkg': {
//       'en': '',
//       'id': '',
//       'ms': '',
//     },
//     'mzpep7jk': {
//       'en': 'Your Role',
//       'id': '',
//       'ms': '',
//     },
//     'dmpx82h0': {
//       'en': 'Search for an item...',
//       'id': '',
//       'ms': '',
//     },
//     'bh82b223': {
//       'en': 'Owner/Founder',
//       'id': '',
//       'ms': '',
//     },
//     'phu34612': {
//       'en': 'Director',
//       'id': '',
//       'ms': '',
//     },
//     '3u84r61z': {
//       'en': 'Manager',
//       'id': '',
//       'ms': '',
//     },
//     'rrippote': {
//       'en': 'Mid-Manager',
//       'id': '',
//       'ms': '',
//     },
//     'pj1vpx8r': {
//       'en': 'Employee',
//       'id': '',
//       'ms': '',
//     },
//     'evezo4gx': {
//       'en': 'Short Description',
//       'id': '',
//       'ms': '',
//     },
//     '15ubbgyg': {
//       'en': 'A little about you...',
//       'id': '',
//       'ms': '',
//     },
//     'xkqq8b0e': {
//       'en': '[bio]',
//       'id': '',
//       'ms': '',
//     },
//   },
//   // profile_pic
//   {
//     'muz1mh5f': {
//       'en': 'Change Photo',
//       'id': '',
//       'ms': '',
//     },
//   },
//   // FamilyRowDetail
//   {
//     'yhtoc3s4': {
//       'en': 'Diagnostics',
//       'id': '',
//       'ms': '',
//     },
//   },
//   // Miscellaneous
//   {
//     'mi3brblw': {
//       'en': '',
//       'id': '',
//       'ms': '',
//     },
//     'loyo8vh1': {
//       'en': '',
//       'id': '',
//       'ms': '',
//     },
//     '65e2tfs2': {
//       'en': '',
//       'id': '',
//       'ms': '',
//     },
//     'ddazihx4': {
//       'en': '',
//       'id': '',
//       'ms': '',
//     },
//     'db03cpjj': {
//       'en': '',
//       'id': '',
//       'ms': '',
//     },
//     'fdb9078p': {
//       'en': '',
//       'id': '',
//       'ms': '',
//     },
//     '80ouzj9q': {
//       'en': '',
//       'id': '',
//       'ms': '',
//     },
//     '6rzhptp9': {
//       'en': '',
//       'id': '',
//       'ms': '',
//     },
//     'ce8c4ty0': {
//       'en': '',
//       'id': '',
//       'ms': '',
//     },
//     'l87829sp': {
//       'en': '',
//       'id': '',
//       'ms': '',
//     },
//     '7a27z0ia': {
//       'en': '',
//       'id': '',
//       'ms': '',
//     },
//     'k9j181ct': {
//       'en': '',
//       'id': '',
//       'ms': '',
//     },
//     'py4f22s7': {
//       'en': '',
//       'id': '',
//       'ms': '',
//     },
//     'kcvqa08x': {
//       'en': '',
//       'id': '',
//       'ms': '',
//     },
//     'dqrzd6sq': {
//       'en': '',
//       'id': '',
//       'ms': '',
//     },
//     'dpqtohyf': {
//       'en': '',
//       'id': '',
//       'ms': '',
//     },
//     'v01vf71s': {
//       'en': '',
//       'id': '',
//       'ms': '',
//     },
//     'gcv6def1': {
//       'en': '',
//       'id': '',
//       'ms': '',
//     },
//     'um9es99m': {
//       'en': '',
//       'id': '',
//       'ms': '',
//     },
//     'o4enbz4j': {
//       'en': '',
//       'id': '',
//       'ms': '',
//     },
//     '8z4tvfh7': {
//       'en': '',
//       'id': '',
//       'ms': '',
//     },
//     '2ybzla8x': {
//       'en': '',
//       'id': '',
//       'ms': '',
//     },
//     'd1wdf5i1': {
//       'en': '',
//       'id': '',
//       'ms': '',
//     },
//     'frqnmevo': {
//       'en': '',
//       'id': '',
//       'ms': '',
//     },
//     '2py80kgi': {
//       'en': '',
//       'id': '',
//       'ms': '',
//     },
//     'p6lsrh2a': {
//       'en': '',
//       'id': '',
//       'ms': '',
//     },
//     'ne8cclp9': {
//       'en': '',
//       'id': '',
//       'ms': '',
//     },
//   },
//   // TextSettings
//   {
//     'txts001': {
//       'en': 'Text Size',
//       'id': 'Ukuran Teks',
//       'ms': 'Saiz Teks',
//     },
//     'txts002': {
//       'en': 'Choose your preferred text size. Changes apply throughout the app.',
//       'id': 'Pilih ukuran teks yang Anda inginkan. Perubahan berlaku di seluruh aplikasi.',
//       'ms': 'Pilih saiz teks pilihan anda. Perubahan akan digunakan di seluruh aplikasi.',
//     },
//     'txts003': {
//       'en': 'Preview',
//       'id': 'Pratinjau',
//       'ms': 'Pratonton',
//     },
//     'txts004': {
//       'en': 'This is how text will appear throughout the app with your selected size.',
//       'id': 'Ini adalah tampilan teks di seluruh aplikasi dengan ukuran yang Anda pilih.',
//       'ms': 'Beginilah teks akan kelihatan di seluruh aplikasi dengan saiz yang anda pilih.',
//     },
//   },
//   // ThemeSettings
//   {
//     'thms001': {
//       'en': 'Theme',
//       'id': 'Tema',
//       'ms': 'Tema',
//     },
//     'thms002': {
//       'en': 'Choose a color theme that works best for you.',
//       'id': 'Pilih tema warna yang paling sesuai untuk Anda.',
//       'ms': 'Pilih tema warna yang paling sesuai untuk anda.',
//     },
//     'thms003': {
//       'en': 'Contrast',
//       'id': 'Kontras',
//       'ms': 'Kontras',
//     },
//     'thms004': {
//       'en': 'Adjust contrast level for better visibility.',
//       'id': 'Sesuaikan tingkat kontras untuk visibilitas yang lebih baik.',
//       'ms': 'Laraskan tahap kontras untuk penglihatan yang lebih baik.',
//     },
//     'thms005': {
//       'en': 'Preview',
//       'id': 'Pratinjau',
//       'ms': 'Pratonton',
//     },
//     'thms006': {
//       'en': 'Primary',
//       'id': 'Utama',
//       'ms': 'Utama',
//     },
//     'thms007': {
//       'en': 'Secondary',
//       'id': 'Sekunder',
//       'ms': 'Sekunder',
//     },
//     'thms008': {
//       'en': 'Background',
//       'id': 'Latar Belakang',
//       'ms': 'Latar Belakang',
//     },
//   },
//   // HelpSupport
//   {
//     'help001': {
//       'en': 'Help & Support',
//       'id': 'Bantuan & Dukungan',
//       'ms': 'Bantuan & Sokongan',
//     },
//     'help002': {
//       'en': 'Contact Us',
//       'id': 'Hubungi Kami',
//       'ms': 'Hubungi Kami',
//     },
//     'help003': {
//       'en': 'Email',
//       'id': 'Email',
//       'ms': 'E-mel',
//     },
//     'help004': {
//       'en': 'support@binaapp.com',
//       'id': 'support@binaapp.com',
//       'ms': 'support@binaapp.com',
//     },
//     'help005': {
//       'en': 'Phone',
//       'id': 'Telepon',
//       'ms': 'Telefon',
//     },
//     'help006': {
//       'en': '+1 (555) 123-4567',
//       'id': '+1 (555) 123-4567',
//       'ms': '+1 (555) 123-4567',
//     },
//     'help007': {
//       'en': 'Send Feedback',
//       'id': 'Kirim Umpan Balik',
//       'ms': 'Hantar Maklum Balas',
//     },
//     'help008': {
//       'en': 'We\'d love to hear from you!',
//       'id': 'Kami ingin mendengar dari Anda!',
//       'ms': 'Kami ingin mendengar daripada anda!',
//     },
//     'help009': {
//       'en': 'Category',
//       'id': 'Kategori',
//       'ms': 'Kategori',
//     },
//     'help010': {
//       'en': 'Bug Report',
//       'id': 'Laporan Bug',
//       'ms': 'Laporan Pepijat',
//     },
//     'help011': {
//       'en': 'Feature Request',
//       'id': 'Permintaan Fitur',
//       'ms': 'Permintaan Ciri',
//     },
//     'help012': {
//       'en': 'General Feedback',
//       'id': 'Umpan Balik Umum',
//       'ms': 'Maklum Balas Umum',
//     },
//     'help013': {
//       'en': 'Your feedback...',
//       'id': 'Umpan balik Anda...',
//       'ms': 'Maklum balas anda...',
//     },
//     'help014': {
//       'en': 'Submit',
//       'id': 'Kirim',
//       'ms': 'Hantar',
//     },
//     'help015': {
//       'en': 'FAQ',
//       'id': 'FAQ',
//       'ms': 'Soalan Lazim',
//     },
//     'help016': {
//       'en': 'How do I add a family member?',
//       'id': 'Bagaimana cara menambahkan anggota keluarga?',
//       'ms': 'Bagaimana untuk menambah ahli keluarga?',
//     },
//     'help017': {
//       'en': 'Go to Profile > Manage Family and tap the + button to add a new family member.',
//       'id': 'Buka Profil > Kelola Keluarga dan ketuk tombol + untuk menambahkan anggota keluarga baru.',
//       'ms': 'Pergi ke Profil > Urus Keluarga dan ketik butang + untuk menambah ahli keluarga baru.',
//     },
//     'help018': {
//       'en': 'How do I take a scan?',
//       'id': 'Bagaimana cara melakukan pemindaian?',
//       'ms': 'Bagaimana untuk mengambil imbasan?',
//     },
//     'help019': {
//       'en': 'Navigate to the Camera tab, select a family member, and follow the on-screen instructions to capture images.',
//       'id': 'Navigasi ke tab Kamera, pilih anggota keluarga, dan ikuti petunjuk di layar untuk mengambil gambar.',
//       'ms': 'Navigasi ke tab Kamera, pilih ahli keluarga, dan ikuti arahan di skrin untuk mengambil gambar.',
//     },
//     'help020': {
//       'en': 'Is my data secure?',
//       'id': 'Apakah data saya aman?',
//       'ms': 'Adakah data saya selamat?',
//     },
//     'help021': {
//       'en': 'Yes, all data is encrypted and stored securely. We never share your personal information with third parties.',
//       'id': 'Ya, semua data dienkripsi dan disimpan dengan aman. Kami tidak pernah membagikan informasi pribadi Anda kepada pihak ketiga.',
//       'ms': 'Ya, semua data disulitkan dan disimpan dengan selamat. Kami tidak pernah berkongsi maklumat peribadi anda dengan pihak ketiga.',
//     },
//     'help022': {
//       'en': 'How do I change the app language?',
//       'id': 'Bagaimana cara mengubah bahasa aplikasi?',
//       'ms': 'Bagaimana untuk menukar bahasa aplikasi?',
//     },
//     'help023': {
//       'en': 'Go to Profile > Preferences and Accessibility > Language and Region to select your preferred language.',
//       'id': 'Buka Profil > Preferensi dan Aksesibilitas > Bahasa dan Wilayah untuk memilih bahasa pilihan Anda.',
//       'ms': 'Pergi ke Profil > Keutamaan dan Kebolehcapaian > Bahasa dan Wilayah untuk memilih bahasa pilihan anda.',
//     },
//     'help024': {
//       'en': 'Tutorials',
//       'id': 'Tutorial',
//       'ms': 'Tutorial',
//     },
//     'help025': {
//       'en': 'Getting Started',
//       'id': 'Memulai',
//       'ms': 'Bermula',
//     },
//     'help026': {
//       'en': 'Learn the basics',
//       'id': 'Pelajari dasar-dasarnya',
//       'ms': 'Pelajari asas-asasnya',
//     },
//     'help027': {
//       'en': 'Taking Scans',
//       'id': 'Mengambil Pemindaian',
//       'ms': 'Mengambil Imbasan',
//     },
//     'help028': {
//       'en': 'How to capture images',
//       'id': 'Cara mengambil gambar',
//       'ms': 'Cara mengambil gambar',
//     },
//     'help029': {
//       'en': 'Understanding Results',
//       'id': 'Memahami Hasil',
//       'ms': 'Memahami Keputusan',
//     },
//     'help030': {
//       'en': 'Reading your diagnosis',
//       'id': 'Membaca diagnosis Anda',
//       'ms': 'Membaca diagnosis anda',
//     },
//     'help031': {
//       'en': 'Family Management',
//       'id': 'Manajemen Keluarga',
//       'ms': 'Pengurusan Keluarga',
//     },
//     'help032': {
//       'en': 'Managing family members',
//       'id': 'Mengelola anggota keluarga',
//       'ms': 'Mengurus ahli keluarga',
//     },
//     'help033': {
//       'en': 'Thank you for your feedback!',
//       'id': 'Terima kasih atas umpan balik Anda!',
//       'ms': 'Terima kasih atas maklum balas anda!',
//     },
//   },
//   // LanguageSettings
//   {
//     'lang001': {
//       'en': 'Language',
//       'id': 'Bahasa',
//       'ms': 'Bahasa',
//     },
//     'lang002': {
//       'en': 'Select your preferred language. The app will restart with the new language.',
//       'id': 'Pilih bahasa pilihan Anda. Aplikasi akan dimulai ulang dengan bahasa baru.',
//       'ms': 'Pilih bahasa pilihan anda. Aplikasi akan dimulakan semula dengan bahasa baru.',
//     },
//     'lang003': {
//       'en': 'More languages will be added in future updates. Contact us if you would like to help translate the app.',
//       'id': 'Lebih banyak bahasa akan ditambahkan dalam pembaruan mendatang. Hubungi kami jika Anda ingin membantu menerjemahkan aplikasi.',
//       'ms': 'Lebih banyak bahasa akan ditambah dalam kemas kini akan datang. Hubungi kami jika anda ingin membantu menterjemah aplikasi.',
//     },
//   },
//   // AccessibilityToggles
//   {
//     'accs001': {
//       'en': 'Hints Mode',
//       'id': 'Mode Petunjuk',
//       'ms': 'Mod Petunjuk',
//     },
//     'accs002': {
//       'en': 'Show tooltips on long-press',
//       'id': 'Tampilkan tooltip saat tekan lama',
//       'ms': 'Tunjukkan petua alat pada tekan lama',
//     },
//     'accs003': {
//       'en': 'Auto-Adjust Settings',
//       'id': 'Pengaturan Penyesuaian Otomatis',
//       'ms': 'Tetapan Pelarasan Automatik',
//     },
//     'accs004': {
//       'en': 'Adjust text size based on age (65+)',
//       'id': 'Sesuaikan ukuran teks berdasarkan usia (65+)',
//       'ms': 'Laraskan saiz teks berdasarkan umur (65+)',
//     },
//   },
//   // CameraConnection
//   {
//     'camc001': {
//       'en': 'Camera Connection',
//       'id': 'Koneksi Kamera',
//       'ms': 'Sambungan Kamera',
//     },
//     'camc002': {
//       'en': 'IP Address',
//       'id': 'Alamat IP',
//       'ms': 'Alamat IP',
//     },
//     'camc003': {
//       'en': 'e.g., 192.168.1.100',
//       'id': 'contoh, 192.168.1.100',
//       'ms': 'cth., 192.168.1.100',
//     },
//     'camc004': {
//       'en': 'Port',
//       'id': 'Port',
//       'ms': 'Port',
//     },
//     'camc005': {
//       'en': 'e.g., 8080',
//       'id': 'contoh, 8080',
//       'ms': 'cth., 8080',
//     },
//     'camc006': {
//       'en': 'Connect',
//       'id': 'Hubungkan',
//       'ms': 'Sambung',
//     },
//     'camc007': {
//       'en': 'Disconnect',
//       'id': 'Putuskan',
//       'ms': 'Putuskan',
//     },
//     'camc008': {
//       'en': 'Connected',
//       'id': 'Terhubung',
//       'ms': 'Disambung',
//     },
//     'camc009': {
//       'en': 'Disconnected',
//       'id': 'Terputus',
//       'ms': 'Terputus',
//     },
//     'camc010': {
//       'en': 'Camera Preview',
//       'id': 'Pratinjau Kamera',
//       'ms': 'Pratonton Kamera',
//     },
//     'camc011': {
//       'en': 'Connection failed. Check IP and port.',
//       'id': 'Koneksi gagal. Periksa IP dan port.',
//       'ms': 'Sambungan gagal. Semak IP dan port.',
//     },
//   },
//   // PhotoSession
//   {
//     'phts001': {
//       'en': 'Photo Session',
//       'id': 'Sesi Foto',
//       'ms': 'Sesi Foto',
//     },
//     'phts002': {
//       'en': 'Capture photos for diagnosis',
//       'id': 'Ambil foto untuk diagnosis',
//       'ms': 'Ambil foto untuk diagnosis',
//     },
//     'phts003': {
//       'en': 'Front View',
//       'id': 'Tampilan Depan',
//       'ms': 'Paparan Hadapan',
//     },
//     'phts004': {
//       'en': 'Left Side',
//       'id': 'Sisi Kiri',
//       'ms': 'Sebelah Kiri',
//     },
//     'phts005': {
//       'en': 'Right Side',
//       'id': 'Sisi Kanan',
//       'ms': 'Sebelah Kanan',
//     },
//     'phts006': {
//       'en': 'Top View',
//       'id': 'Tampilan Atas',
//       'ms': 'Paparan Atas',
//     },
//     'phts007': {
//       'en': 'Bottom View',
//       'id': 'Tampilan Bawah',
//       'ms': 'Paparan Bawah',
//     },
//     'phts008': {
//       'en': 'Tap to capture',
//       'id': 'Ketuk untuk mengambil',
//       'ms': 'Ketik untuk tangkap',
//     },
//     'phts009': {
//       'en': 'Retake',
//       'id': 'Ambil Ulang',
//       'ms': 'Ambil Semula',
//     },
//     'phts010': {
//       'en': 'Submit All',
//       'id': 'Kirim Semua',
//       'ms': 'Hantar Semua',
//     },
//     'phts011': {
//       'en': 'Processing...',
//       'id': 'Memproses...',
//       'ms': 'Memproses...',
//     },
//     'phts012': {
//       'en': 'Gallery',
//       'id': 'Galeri',
//       'ms': 'Galeri',
//     },
//     'phts013': {
//       'en': 'Camera',
//       'id': 'Kamera',
//       'ms': 'Kamera',
//     },
//   },
//   // ChatPages
//   {
//     'chat001': {
//       'en': 'Chats',
//       'id': 'Obrolan',
//       'ms': 'Sembang',
//     },
//     'chat002': {
//       'en': 'No conversations yet',
//       'id': 'Belum ada percakapan',
//       'ms': 'Tiada perbualan lagi',
//     },
//     'chat003': {
//       'en': 'Tap + to start a new chat',
//       'id': 'Ketuk + untuk memulai obrolan baru',
//       'ms': 'Ketik + untuk memulakan sembang baru',
//     },
//     'chat004': {
//       'en': 'Delete conversation?',
//       'id': 'Hapus percakapan?',
//       'ms': 'Padam perbualan?',
//     },
//     'chat005': {
//       'en': 'Cancel',
//       'id': 'Batal',
//       'ms': 'Batal',
//     },
//     'chat006': {
//       'en': 'Delete',
//       'id': 'Hapus',
//       'ms': 'Padam',
//     },
//     'chat007': {
//       'en': 'No messages yet',
//       'id': 'Belum ada pesan',
//       'ms': 'Tiada mesej lagi',
//     },
//     'chat008': {
//       'en': 'Type a message...',
//       'id': 'Ketik pesan...',
//       'ms': 'Taip mesej...',
//     },
//     'chat009': {
//       'en': 'New Chat',
//       'id': 'Obrolan Baru',
//       'ms': 'Sembang Baru',
//     },
//   },
//   // Dialogs
//   {
//     'dlg001': {
//       'en': 'Loading...',
//       'id': 'Memuat...',
//       'ms': 'Memuatkan...',
//     },
//     'dlg002': {
//       'en': 'Confirm',
//       'id': 'Konfirmasi',
//       'ms': 'Sahkan',
//     },
//     'dlg003': {
//       'en': 'Cancel',
//       'id': 'Batal',
//       'ms': 'Batal',
//     },
//     'dlg004': {
//       'en': 'An error occurred',
//       'id': 'Terjadi kesalahan',
//       'ms': 'Ralat berlaku',
//     },
//     'dlg005': {
//       'en': 'Log Out?',
//       'id': 'Keluar?',
//       'ms': 'Log Keluar?',
//     },
//     'dlg006': {
//       'en': 'Are you sure you want to log out of your account?',
//       'id': 'Apakah Anda yakin ingin keluar dari akun Anda?',
//       'ms': 'Adakah anda pasti mahu log keluar daripada akaun anda?',
//     },
//     'dlg007': {
//       'en': 'Log Out',
//       'id': 'Keluar',
//       'ms': 'Log Keluar',
//     },
//     'dlg008': {
//       'en': 'Logging out...',
//       'id': 'Sedang keluar...',
//       'ms': 'Sedang log keluar...',
//     },
//     'dlg009': {
//       'en': 'Deleting...',
//       'id': 'Menghapus...',
//       'ms': 'Memadam...',
//     },
//     'dlg010': {
//       'en': 'Creating family member...',
//       'id': 'Membuat anggota keluarga...',
//       'ms': 'Mencipta ahli keluarga...',
//     },
//     'dlg011': {
//       'en': 'Error creating member',
//       'id': 'Kesalahan membuat anggota',
//       'ms': 'Ralat mencipta ahli',
//     },
//   },
//   // Tooltips
//   {
//     'tip001': {
//       'en': 'Add or edit family members',
//       'id': 'Tambah atau edit anggota keluarga',
//       'ms': 'Tambah atau edit ahli keluarga',
//     },
//     'tip002': {
//       'en': 'Change text size, themes, and more',
//       'id': 'Ubah ukuran teks, tema, dan lainnya',
//       'ms': 'Tukar saiz teks, tema, dan lain-lain',
//     },
//     'tip003': {
//       'en': 'Add a new family member',
//       'id': 'Tambah anggota keluarga baru',
//       'ms': 'Tambah ahli keluarga baru',
//     },
//     'tip004': {
//       'en': 'Connect to external camera',
//       'id': 'Hubungkan ke kamera eksternal',
//       'ms': 'Sambung ke kamera luaran',
//     },
//   },
//   // SessionDetails
//   {
//     'sesd001': {
//       'en': 'Session Details',
//       'id': 'Detail Sesi',
//       'ms': 'Butiran Sesi',
//     },
//     'sesd002': {
//       'en': 'Diagnosis',
//       'id': 'Diagnosis',
//       'ms': 'Diagnosis',
//     },
//     'sesd003': {
//       'en': 'Images',
//       'id': 'Gambar',
//       'ms': 'Imej',
//     },
//     'sesd004': {
//       'en': 'No issues found',
//       'id': 'Tidak ditemukan masalah',
//       'ms': 'Tiada isu dijumpai',
//     },
//     'sesd005': {
//       'en': 'Issues found',
//       'id': 'Masalah ditemukan',
//       'ms': 'Isu dijumpai',
//     },
//     'sesd006': {
//       'en': 'Severity',
//       'id': 'Tingkat Keparahan',
//       'ms': 'Keterukan',
//     },
//     'sesd007': {
//       'en': 'Advice',
//       'id': 'Saran',
//       'ms': 'Nasihat',
//     },
//     'sesd008': {
//       'en': 'Date',
//       'id': 'Tanggal',
//       'ms': 'Tarikh',
//     },
//   },
// ].reduce((a, b) => a..addAll(b));
