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

  static List<String> languages() => ['en', 'id', 'ms'];

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

  String getText(String key) =>
      (kTranslationsMap[key] ?? {})[locale.toString()] ?? '';

  String getVariableText({
    String? enText = '',
    String? idText = '',
    String? msText = '',
  }) =>
      [enText, idText, msText][languageIndex] ?? '';

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
      'id': 'Di bawah ini adalah ringkasan aktivitas tim Anda.',
      'ms': 'Di bawah ialah ringkasan aktiviti pasukan anda.',
    },
    'kphqz3hi': {
      'en': 'Updates',
      'id': 'Proyek',
      'ms': 'Projek',
    },
    'xlzf8qqx': {
      'en': 'Undiagnosed members this week:',
      'id': 'Tim Desain UI',
      'ms': 'Pasukan Reka Bentuk UI',
    },
    'puy8obok': {
      'en': 'Contract Activity',
      'id': 'Aktivitas Kontrak',
      'ms': 'Aktiviti Kontrak',
    },
    'zlovh0zt': {
      'en': 'Below is an a summary of activity.',
      'id': 'Di bawah ini adalah ringkasan kegiatan.',
      'ms': 'Di bawah ialah ringkasan aktiviti.',
    },
    'g1uaaovn': {
      'en': 'Customer Activity',
      'id': 'Aktivitas Pelanggan',
      'ms': 'Aktiviti Pelanggan',
    },
    'e5q3ows1': {
      'en': 'Below is an a summary of activity.',
      'id': 'Di bawah ini adalah ringkasan kegiatan.',
      'ms': 'Di bawah ialah ringkasan aktiviti.',
    },
    'uj7jsxmo': {
      'en': 'Sigal (You): Cavity',
      'id': 'Aktivitas Kontrak',
      'ms': 'Aktiviti Kontrak',
    },
    'hkk2zmjw': {
      'en': 'Severity: Severe\nAdvice: Visit doctor ASAP',
      'id': 'Di bawah ini adalah ringkasan kegiatan.',
      'ms': 'Di bawah ialah ringkasan aktiviti.',
    },
    'jkgae0vc': {
      'en': 'Idan: Plaque',
      'id': 'Aktivitas Pelanggan',
      'ms': 'Aktiviti Pelanggan',
    },
    'g4os7kcp': {
      'en':
          'Severity: Light\nAdvice: More Thorough brishing, use a\nsoft fiber toothbrush',
      'id': 'Di bawah ini adalah ringkasan kegiatan.',
      'ms': 'Di bawah ialah ringkasan aktiviti.',
    },
    'xdxbdj20': {
      'en': '__',
      'id': '__',
      'ms': '__',
    },
  },
  // Main_DIagnostics
  {
    'n99lg1qh': {
      'en': 'Diagnostics',
      'id': 'Pelanggan',
      'ms': 'Pelanggan',
    },
    'lvnskphp': {
      'en': 'Sigal (You)',
      'id': 'Semua',
      'ms': 'Semua',
    },
    'f5d3fvff': {
      'en': 'Major problem found!',
      'id': 'Randy Alcorn',
      'ms': 'Randy Alcorn',
    },
    'jwrrbd37': {
      'en': '14/06/2025',
      'id': 'Kepala Pengadaan',
      'ms': 'Ketua Perolehan',
    },
    '4vyvrsvp': {
      'en': 'Cavity (severe)',
      'id': 'Kepala Pengadaan',
      'ms': 'Ketua Perolehan',
    },
    'xbmye3r1': {
      'en': 'Problem found!',
      'id': 'Randy Alcorn',
      'ms': 'Randy Alcorn',
    },
    'sot8njss': {
      'en': '01/06/2025',
      'id': 'Kepala Pengadaan',
      'ms': 'Ketua Perolehan',
    },
    'ko2o59js': {
      'en': 'Cavity (minor), Plack',
      'id': 'Kepala Pengadaan',
      'ms': 'Ketua Perolehan',
    },
    'lbnt26st': {
      'en': 'No problems found',
      'id': 'Randy Alcorn',
      'ms': 'Randy Alcorn',
    },
    'io7qmr33': {
      'en': '26/05/2025',
      'id': 'Kepala Pengadaan',
      'ms': 'Ketua Perolehan',
    },
    '35o5woky': {
      'en': 'Problem found!',
      'id': 'Randy Alcorn',
      'ms': 'Randy Alcorn',
    },
    '8ieto4rf': {
      'en': '13/05/2025',
      'id': 'Kepala Pengadaan',
      'ms': 'Ketua Perolehan',
    },
    '2719y4vf': {
      'en': 'Plack',
      'id': 'Kepala Pengadaan',
      'ms': 'Ketua Perolehan',
    },
    'a258xeav': {
      'en': 'No problems found',
      'id': 'Randy Alcorn',
      'ms': 'Randy Alcorn',
    },
    'wduyui67': {
      'en': '05/05/2025',
      'id': 'Kepala Pengadaan',
      'ms': 'Ketua Perolehan',
    },
    'u0su8kte': {
      'en': 'No problems found',
      'id': 'James Wiseman',
      'ms': 'James Wiseman',
    },
    'nyfsg4hw': {
      'en': '26/04/2025',
      'id': 'Manajer Akuntansi',
      'ms': 'Pengurus akaun',
    },
    'qh2ock0d': {
      'en': 'Idan',
      'id': 'Aktif',
      'ms': 'Aktif',
    },
    'yj40ezzo': {
      'en': 'Problem found!',
      'id': 'Randy Alcorn',
      'ms': 'Randy Alcorn',
    },
    '25dp2kkr': {
      'en': '14/06/2025',
      'id': 'Kepala Pengadaan',
      'ms': 'Ketua Perolehan',
    },
    'qpaeeh6n': {
      'en': 'Plack',
      'id': 'Manajer Akuntansi',
      'ms': 'Pengurus akaun',
    },
    'hx6auuvz': {
      'en': 'No problems found',
      'id': 'Randy Alcorn',
      'ms': 'Randy Alcorn',
    },
    'p7egakgn': {
      'en': '01/06/2025',
      'id': 'Kepala Pengadaan',
      'ms': 'Ketua Perolehan',
    },
    'g9xzjmh4': {
      'en': 'Problem found!',
      'id': 'Randy Alcorn',
      'ms': 'Randy Alcorn',
    },
    'zj5j9aqi': {
      'en': '15/05/2025',
      'id': 'Kepala Pengadaan',
      'ms': 'Ketua Perolehan',
    },
    '82sehtrs': {
      'en': 'Plack',
      'id': 'Manajer Akuntansi',
      'ms': 'Pengurus akaun',
    },
    '7mw5a1fj': {
      'en': 'Problem found!',
      'id': 'Randy Alcorn',
      'ms': 'Randy Alcorn',
    },
    '0wu7ys98': {
      'en': '06/05/2025',
      'id': 'Kepala Pengadaan',
      'ms': 'Ketua Perolehan',
    },
    '1k5z65cm': {
      'en': 'Plack',
      'id': 'Manajer Akuntansi',
      'ms': 'Pengurus akaun',
    },
    'xlgk615j': {
      'en': 'Problem found!',
      'id': 'James Wiseman',
      'ms': 'James Wiseman',
    },
    'uhbzwcb6': {
      'en': '26/04/2025',
      'id': 'Manajer Akuntansi',
      'ms': 'Pengurus akaun',
    },
    '0ovyr17x': {
      'en': 'Plack',
      'id': 'Manajer Akuntansi',
      'ms': 'Pengurus akaun',
    },
    's7xebw09': {
      'en': 'Nadav',
      'id': 'Panggilan Dingin',
      'ms': 'Panggilan Dingin',
    },
    '7s0fouho': {
      'en': 'REMINDER!!!',
      'id': 'Randy Alcorn',
      'ms': 'Randy Alcorn',
    },
    'rsn6tjee': {
      'en': 'Nadav hasn\'t been diagnosed in 17 days!',
      'id': 'Kepala Pengadaan',
      'ms': 'Ketua Perolehan',
    },
    'a0y9ee8v': {
      'en': 'No problems found',
      'id': 'Randy Alcorn',
      'ms': 'Randy Alcorn',
    },
    'cacq37iq': {
      'en': '01/06/2025',
      'id': 'Kepala Pengadaan',
      'ms': 'Ketua Perolehan',
    },
    'whotijlg': {
      'en': 'No problems found',
      'id': 'Randy Alcorn',
      'ms': 'Randy Alcorn',
    },
    '2tmpc136': {
      'en': '15/05/2025',
      'id': 'Kepala Pengadaan',
      'ms': 'Ketua Perolehan',
    },
    'c7mlpdai': {
      'en': 'No problems found',
      'id': 'Randy Alcorn',
      'ms': 'Randy Alcorn',
    },
    'r0f1wtdf': {
      'en': '06/05/2025',
      'id': 'Kepala Pengadaan',
      'ms': 'Ketua Perolehan',
    },
    'mk55qtlt': {
      'en': 'No problems found',
      'id': 'James Wiseman',
      'ms': 'James Wiseman',
    },
    'vkerup2g': {
      'en': '26/04/2025',
      'id': 'Manajer Akuntansi',
      'ms': 'Pengurus akaun',
    },
    '15e6aiew': {
      'en': 'Mika',
      'id': '',
      'ms': '',
    },
    '3gdogcuj': {
      'en': 'No problems found',
      'id': 'Randy Alcorn',
      'ms': 'Randy Alcorn',
    },
    'm1skw7zq': {
      'en': '12/06/2025',
      'id': 'Kepala Pengadaan',
      'ms': 'Ketua Perolehan',
    },
    'd6yaafds': {
      'en': 'No problems found',
      'id': 'Randy Alcorn',
      'ms': 'Randy Alcorn',
    },
    'ravf9evv': {
      'en': '01/06/2025',
      'id': 'Kepala Pengadaan',
      'ms': 'Ketua Perolehan',
    },
    'jayfnk4b': {
      'en': 'Problem found!',
      'id': 'Randy Alcorn',
      'ms': 'Randy Alcorn',
    },
    '4d75exqp': {
      'en': '15/05/2025',
      'id': 'Kepala Pengadaan',
      'ms': 'Ketua Perolehan',
    },
    'hkjqhfr5': {
      'en': 'Plack',
      'id': 'Kepala Pengadaan',
      'ms': 'Ketua Perolehan',
    },
    'zszyq3qo': {
      'en': 'No problems found',
      'id': 'Randy Alcorn',
      'ms': 'Randy Alcorn',
    },
    '17tbb4ca': {
      'en': '06/05/2025',
      'id': 'Kepala Pengadaan',
      'ms': 'Ketua Perolehan',
    },
    'iu055ept': {
      'en': 'No problems found',
      'id': 'James Wiseman',
      'ms': 'James Wiseman',
    },
    '4hp0xkx2': {
      'en': '26/04/2025',
      'id': 'Manajer Akuntansi',
      'ms': 'Pengurus akaun',
    },
    '3ourv2w9': {
      'en': '__',
      'id': '__',
      'ms': '__',
    },
  },
  // Main_Diagnose
  {
    'smh1o93d': {
      'en': 'Diagnose',
      'id': 'Kontrak',
      'ms': 'Kontrak',
    },
    'dlt46loo': {
      'en': 'Choose a member:',
      'id': 'Kontrak',
      'ms': 'Kontrak',
    },
    'j08eiorc': {
      'en': '__',
      'id': '__',
      'ms': '__',
    },
  },
  // Family
  {
    '609lph0v': {
      'en': 'My Family',
      'id': '',
      'ms': '',
    },
    'umoqnnb1': {
      'en': '',
      'id': '',
      'ms': '',
    },
    'ww48hqky': {
      'en': '+',
      'id': '',
      'ms': '',
    },
    'smtxdnbn': {
      'en': '__',
      'id': '__',
      'ms': '__',
    },
  },
  // Main_profilePage
  {
    'qrxn5crt': {
      'en': 'My Profile',
      'id': 'Profil saya',
      'ms': 'Profil saya',
    },
    'v1hh7jlp': {
      'en': 'Switch to Dark Mode',
      'id': 'Beralih ke Mode Gelap',
      'ms': 'Tukar kepada Mod Gelap',
    },
    'sh7q15l6': {
      'en': 'Switch to Light Mode',
      'id': 'Beralih ke Mode Cahaya',
      'ms': 'Tukar kepada Mod Cahaya',
    },
    'fyxsf6vn': {
      'en': 'Account Settings',
      'id': 'Pengaturan akun',
      'ms': 'Tetapan Akaun',
    },
    'h43llaan': {
      'en': 'Manage Family',
      'id': 'Ganti kata sandi',
      'ms': 'Tukar kata laluan',
    },
    'b1lw0hfu': {
      'en': 'Prefrences and Accessability',
      'id': 'Sunting profil',
      'ms': 'Sunting profil',
    },
    'abqf147c': {
      'en': 'Log Out',
      'id': 'Keluar',
      'ms': 'Log keluar',
    },
    'o3dp9tss': {
      'en': '__',
      'id': '__',
      'ms': '__',
    },
  },
  // Camera
  {
    'w972eae7': {
      'en': 'Light balance',
      'id': '',
      'ms': '',
    },
    'eaietejr': {
      'en': 'Brightness',
      'id': '',
      'ms': '',
    },
    'u1lkhmsh': {
      'en': 'Exposure',
      'id': '',
      'ms': '',
    },
    '3z1637ww': {
      'en': 'Contrast',
      'id': '',
      'ms': '',
    },
    'phrtb6wf': {
      'en': 'Highlights',
      'id': '',
      'ms': '',
    },
    '7hd0gmek': {
      'en': 'Shadows',
      'id': '',
      'ms': '',
    },
    'abvzrcko': {
      'en': 'Take photo!',
      'id': '',
      'ms': '',
    },
    'o9yv9tqq': {
      'en': 'Preview',
      'id': '',
      'ms': '',
    },
    'hrli547k': {
      'en': 'Please make sure camera is seated properly',
      'id': '',
      'ms': '',
    },
    '2jil0fv1': {
      'en': 'Home',
      'id': '',
      'ms': '',
    },
  },
  // DiagnosisGood
  {
    'e5ztajlj': {
      'en': 'No problems detected, good job!',
      'id': '',
      'ms': '',
    },
    'oll2n2k5': {
      'en': 'Diagnosis',
      'id': '',
      'ms': '',
    },
    '0pos3zta': {
      'en': 'Home',
      'id': '',
      'ms': '',
    },
  },
  // DiagnosisPlack
  {
    'yrm43d77': {
      'en': 'Problem detected: Plack',
      'id': '',
      'ms': '',
    },
    'o44qkbc9': {
      'en': 'Advice:',
      'id': '',
      'ms': '',
    },
    '3e2p6t0b': {
      'en':
          'More thorough brushing, focus more on the inner left side of the mouth.\nUse a soft-fiber toothbrush',
      'id': '',
      'ms': '',
    },
    'oo2y7ww0': {
      'en': 'Diagnosis',
      'id': '',
      'ms': '',
    },
    'irumc86j': {
      'en': 'Home',
      'id': '',
      'ms': '',
    },
  },
  // DiagnosisPlackCavity
  {
    'jlylby4g': {
      'en': 'Problem detected: Plack',
      'id': '',
      'ms': '',
    },
    '1r9dts97': {
      'en': 'Advice:',
      'id': '',
      'ms': '',
    },
    'g3onei9w': {
      'en':
          'More thorough brushing, focus more on the inner left side of the mouth.\nUse a soft-fiber toothbrush',
      'id': '',
      'ms': '',
    },
    'o537478g': {
      'en': 'Problem detected: Cavity',
      'id': '',
      'ms': '',
    },
    'yyd8epn5': {
      'en': 'Advice:',
      'id': '',
      'ms': '',
    },
    'c33xlo8j': {
      'en':
          'Indications of a cavity are appearing on the base of the cuspid on the right side.\nThe use of mouthwash after brushing is recommanded.\nIf you feel any pain, schedule a doctor appointment.',
      'id': '',
      'ms': '',
    },
    'cw83ljf7': {
      'en': 'Diagnosis',
      'id': '',
      'ms': '',
    },
    'covqeaa4': {
      'en': 'Home',
      'id': '',
      'ms': '',
    },
  },
  // DiagnosisCavity
  {
    '5ck7mnyd': {
      'en': 'Upload',
      'id': '',
      'ms': '',
    },
    'w0eizveb': {
      'en': 'Detect',
      'id': '',
      'ms': '',
    },
    't6s40hur': {
      'en': 'Home',
      'id': '',
      'ms': '',
    },
  },
  // auth_2_Create
  {
    '7x498wvw': {
      'en': 'Bina ',
      'id': '',
      'ms': '',
    },
    'pwekpcwd': {
      'en': 'Get Started',
      'id': '',
      'ms': '',
    },
    'gu5o6pdk': {
      'en': 'Create an account by using the form below.',
      'id': '',
      'ms': '',
    },
    'c71pv0m4': {
      'en': 'name',
      'id': '',
      'ms': '',
    },
    'x8m48y2p': {
      'en': 'Email',
      'id': '',
      'ms': '',
    },
    'd69sdrms': {
      'en': 'Password',
      'id': '',
      'ms': '',
    },
    'llees51u': {
      'en': 'birthday',
      'id': '',
      'ms': '',
    },
    'i1jbvk65': {
      'en': 'Gender',
      'id': '',
      'ms': '',
    },
    'tgz3ru1h': {
      'en': 'Search for an item...',
      'id': '',
      'ms': '',
    },
    'kpngnsd5': {
      'en': 'Male',
      'id': '',
      'ms': '',
    },
    'm4fwgt1i': {
      'en': 'Female',
      'id': '',
      'ms': '',
    },
    'p26kr74a': {
      'en': 'Rather Not Disclouse',
      'id': '',
      'ms': '',
    },
    'z4fzwb7k': {
      'en': 'Create Account',
      'id': '',
      'ms': '',
    },
    'wi5b68oy': {
      'en': 'Already have an account? ',
      'id': '',
      'ms': '',
    },
    'meimul7j': {
      'en': 'Sign in here',
      'id': '',
      'ms': '',
    },
    'vc2sjby7': {
      'en': 'Home',
      'id': '',
      'ms': '',
    },
  },
  // auth_2_Login
  {
    'bphmg5zj': {
      'en': 'Bina ',
      'id': '',
      'ms': '',
    },
    'jsow1zkm': {
      'en': 'Welcome Back',
      'id': '',
      'ms': '',
    },
    '0g7rc7ho': {
      'en': 'Fill out the information below in order to access your account.',
      'id': '',
      'ms': '',
    },
    'qzd05hym': {
      'en': 'Email',
      'id': '',
      'ms': '',
    },
    '2em4alc6': {
      'en': 'Password',
      'id': '',
      'ms': '',
    },
    'e3i91khq': {
      'en': 'Sign In',
      'id': '',
      'ms': '',
    },
    'rlv6ildk': {
      'en': 'Don\'t have an account?  ',
      'id': '',
      'ms': '',
    },
    'mtsguguk': {
      'en': 'Create Account',
      'id': '',
      'ms': '',
    },
    'vifhe4r6': {
      'en': 'Forgot password?',
      'id': '',
      'ms': '',
    },
    '8mt2zjs0': {
      'en': 'Home',
      'id': '',
      'ms': '',
    },
  },
  // auth_2_ForgotPassword
  {
    'n1wihh9r': {
      'en': 'Bina ',
      'id': '',
      'ms': '',
    },
    'm2oi1dus': {
      'en': 'Forgot Password',
      'id': '',
      'ms': '',
    },
    '0i9qpt6b': {
      'en':
          'Please fill out your email belo in order to recieve a reset password link.',
      'id': '',
      'ms': '',
    },
    'h7ggbaau': {
      'en': 'Email',
      'id': '',
      'ms': '',
    },
    'oxefc8xl': {
      'en': 'Send Reset Link',
      'id': '',
      'ms': '',
    },
    '3jn4q2g5': {
      'en': 'Home',
      'id': '',
      'ms': '',
    },
  },
  // auth_2_createProfile
  {
    '7g2ljvog': {
      'en': 'Bina ',
      'id': '',
      'ms': '',
    },
    'deytzh8h': {
      'en': 'Home',
      'id': '',
      'ms': '',
    },
  },
  // auth_2_Profile
  {
    'mv3aa31t': {
      'en': '',
      'id': '',
      'ms': '',
    },
    '0ytdwza8': {
      'en': '',
      'id': '',
      'ms': '',
    },
    'coygd922': {
      'en': 'Your Account',
      'id': '',
      'ms': '',
    },
    '8ctbqg92': {
      'en': 'Edit Profile',
      'id': '',
      'ms': '',
    },
    'ue4tdodf': {
      'en': 'App Settings',
      'id': '',
      'ms': '',
    },
    'ljm3zuye': {
      'en': 'Support',
      'id': '',
      'ms': '',
    },
    'sl7qwp3g': {
      'en': 'Terms of Service',
      'id': '',
      'ms': '',
    },
    'ud37xux6': {
      'en': 'Log Out',
      'id': '',
      'ms': '',
    },
    '5utl5cz5': {
      'en': 'Home',
      'id': '',
      'ms': '',
    },
  },
  // auth_2_EditProfile
  {
    'b15mqbg3': {
      'en': 'Home',
      'id': '',
      'ms': '',
    },
  },
  // CameraCheck
  {
    'kred63vb': {
      'en': 'Device status: Connected!',
      'id': 'Kirim Konfirmasi Kontrak',
      'ms': 'Hantar Pengesahan Kontrak',
    },
    'e408bhw6': {
      'en': 'OK',
      'id': 'Kirim Informasi',
      'ms': 'Hantar Maklumat',
    },
  },
  // FamilySuccess
  {
    'wa4vkne2': {
      'en': 'Congratulations!',
      'id': 'Selamat!',
      'ms': 'tahniah!',
    },
    '3hf2ocig': {
      'en': 'New member added successfully',
      'id':
          'Sekarang kontrak telah dibuat untuk pelanggan ini, silakan hubungi mereka dengan tanggal Anda akan mengirim perjanjian yang ditandatangani.',
      'ms':
          'Memandangkan kontrak telah dijana untuk pelanggan ini, sila hubungi mereka dengan tarikh anda akan menghantar perjanjian yang ditandatangani.',
    },
    'q0jvi1lp': {
      'en': 'Okay',
      'id': 'Oke',
      'ms': 'baik',
    },
  },
  // Success
  {
    '00flvi93': {
      'en': 'Operation success!',
      'id': 'Selamat!',
      'ms': 'tahniah!',
    },
    'fmzceh74': {
      'en': 'New diagnosis will be generated soon!',
      'id': 'Kontrak baru telah dibuat untuk:',
      'ms': 'Kontrak baru telah dijana untuk:',
    },
    'g8q2u55w': {
      'en': 'Continue',
      'id': 'Melanjutkan',
      'ms': 'teruskan',
    },
  },
  // createComment
  {
    'l2jlnhye': {
      'en': 'Create Note',
      'id': 'Buat Catatan',
      'ms': 'Cipta Nota',
    },
    'd6yfe8tj': {
      'en': 'Find members by searching below',
      'id': 'Temukan anggota dengan mencari di bawah',
      'ms': 'Cari ahli dengan mencari di bawah',
    },
    '9gf6o5ss': {
      'en': 'Enter your note here...',
      'id': 'Masukkan catatan Anda di sini...',
      'ms': 'Masukkan nota anda di sini...',
    },
    'farrki57': {
      'en': 'Create Note',
      'id': 'Buat Catatan',
      'ms': 'Cipta Nota',
    },
  },
  // mobileNav
  {
    'sy0pxvma': {
      'en': 'Dashboard',
      'id': 'Dasbor',
      'ms': 'Papan pemuka',
    },
    't5c3aiuy': {
      'en': 'My Team',
      'id': 'Kelompok ku',
      'ms': 'Pasukan saya',
    },
    'nkz3c58a': {
      'en': 'Customers',
      'id': 'Pelanggan',
      'ms': 'Pelanggan',
    },
    '1mkyyjwj': {
      'en': 'Contracts',
      'id': 'Kontrak',
      'ms': 'Kontrak',
    },
    'eg79coc6': {
      'en': 'Profile',
      'id': 'Profil',
      'ms': 'Profil',
    },
  },
  // webNav
  {
    'c9o7o7xh': {
      'en': 'Bina ',
      'id': '',
      'ms': '',
    },
    'yg07zi4c': {
      'en': 'Home',
      'id': 'Dasbor',
      'ms': 'Papan pemuka',
    },
    'lbojdpxg': {
      'en': 'Diagnostics',
      'id': 'Pelanggan',
      'ms': 'Pelanggan',
    },
    '9pjba90p': {
      'en': 'Camera',
      'id': 'Kontrak',
      'ms': 'Kontrak',
    },
    '01nu9cy0': {
      'en': 'Profile',
      'id': 'Profil',
      'ms': 'Profil',
    },
  },
  // Accessability
  {
    'pw6kvl1f': {
      'en': 'Prefrences and Accessabiliry',
      'id': 'tautan langsung',
      'ms': 'Pautan Pantas',
    },
    'gckukxjv': {
      'en': 'Text Settings',
      'id': 'Temukan Kontrak',
      'ms': 'Cari Kontrak',
    },
    'zsq8vj02': {
      'en': 'Color and Theme',
      'id': 'Temukan Pelanggan',
      'ms': 'Cari Pelanggan',
    },
    'iqxwv326': {
      'en': 'Language and Region',
      'id': 'Kontrak baru',
      'ms': 'Kontrak Baru',
    },
    's60yfg0g': {
      'en': 'Help and Support',
      'id': 'Pelanggan baru',
      'ms': 'Pelanggan baru',
    },
  },
  // editProfilePhoto
  {
    '6bnefz1c': {
      'en': 'Change Photo',
      'id': '',
      'ms': '',
    },
    'yaxe7q8v': {
      'en':
          'Upload a new photo below in order to change your avatar seen by others.',
      'id': '',
      'ms': '',
    },
    're4x0sz7': {
      'en': 'Upload Image',
      'id': '',
      'ms': '',
    },
    'sr54fsk6': {
      'en': 'Save Changes',
      'id': '',
      'ms': '',
    },
  },
  // FamilyMember
  {
    'e3gk5os7': {
      'en': 'Create Member',
      'id': 'Buat Catatan',
      'ms': 'Cipta Nota',
    },
    'nwy3vye6': {
      'en': 'Enter member info below',
      'id': 'Temukan anggota dengan mencari di bawah',
      'ms': 'Cari ahli dengan mencari di bawah',
    },
    '2rkmiqyr': {
      'en': 'name',
      'id': '',
      'ms': '',
    },
    '7zhjhvr8': {
      'en': 'Birthday',
      'id': '',
      'ms': '',
    },
    '7syz836y': {
      'en': 'Gender',
      'id': '',
      'ms': '',
    },
    'sekelp0m': {
      'en': 'Search for an item...',
      'id': '',
      'ms': '',
    },
    '1pcjocor': {
      'en': 'Male',
      'id': '',
      'ms': '',
    },
    'rcwbqs7l': {
      'en': 'Female',
      'id': '',
      'ms': '',
    },
    '660v8p3t': {
      'en': 'Rather Not Disclouse',
      'id': '',
      'ms': '',
    },
    '3syylynq': {
      'en': 'Create Member',
      'id': 'Buat Catatan',
      'ms': 'Cipta Nota',
    },
  },
  // editProfile_auth_2
  {
    'cfnr4q80': {
      'en': 'Adjust the content below to update your profile.',
      'id': '',
      'ms': '',
    },
    'u42j5t5x': {
      'en': 'Change Photo',
      'id': '',
      'ms': '',
    },
    'hrubvu4m': {
      'en': 'Full Name',
      'id': '',
      'ms': '',
    },
    'wdugkxi2': {
      'en': 'Your full name...',
      'id': '',
      'ms': '',
    },
    '4ype6kkg': {
      'en': '',
      'id': '',
      'ms': '',
    },
    'mzpep7jk': {
      'en': 'Your Role',
      'id': '',
      'ms': '',
    },
    'dmpx82h0': {
      'en': 'Search for an item...',
      'id': '',
      'ms': '',
    },
    'bh82b223': {
      'en': 'Owner/Founder',
      'id': '',
      'ms': '',
    },
    'phu34612': {
      'en': 'Director',
      'id': '',
      'ms': '',
    },
    '3u84r61z': {
      'en': 'Manager',
      'id': '',
      'ms': '',
    },
    'rrippote': {
      'en': 'Mid-Manager',
      'id': '',
      'ms': '',
    },
    'pj1vpx8r': {
      'en': 'Employee',
      'id': '',
      'ms': '',
    },
    'evezo4gx': {
      'en': 'Short Description',
      'id': '',
      'ms': '',
    },
    '15ubbgyg': {
      'en': 'A little about you...',
      'id': '',
      'ms': '',
    },
    'xkqq8b0e': {
      'en': '[bio]',
      'id': '',
      'ms': '',
    },
  },
  // profile_pic
  {
    'muz1mh5f': {
      'en': 'Change Photo',
      'id': '',
      'ms': '',
    },
  },
  // FamilyRowDetail
  {
    'yhtoc3s4': {
      'en': 'Diagnostics',
      'id': '',
      'ms': '',
    },
  },
  // Miscellaneous
  {
    'mi3brblw': {
      'en': '',
      'id': '',
      'ms': '',
    },
    'loyo8vh1': {
      'en': '',
      'id': '',
      'ms': '',
    },
    '65e2tfs2': {
      'en': '',
      'id': '',
      'ms': '',
    },
    'ddazihx4': {
      'en': '',
      'id': '',
      'ms': '',
    },
    'db03cpjj': {
      'en': '',
      'id': '',
      'ms': '',
    },
    'fdb9078p': {
      'en': '',
      'id': '',
      'ms': '',
    },
    '80ouzj9q': {
      'en': '',
      'id': '',
      'ms': '',
    },
    '6rzhptp9': {
      'en': '',
      'id': '',
      'ms': '',
    },
    'ce8c4ty0': {
      'en': '',
      'id': '',
      'ms': '',
    },
    'l87829sp': {
      'en': '',
      'id': '',
      'ms': '',
    },
    '7a27z0ia': {
      'en': '',
      'id': '',
      'ms': '',
    },
    'k9j181ct': {
      'en': '',
      'id': '',
      'ms': '',
    },
    'py4f22s7': {
      'en': '',
      'id': '',
      'ms': '',
    },
    'kcvqa08x': {
      'en': '',
      'id': '',
      'ms': '',
    },
    'dqrzd6sq': {
      'en': '',
      'id': '',
      'ms': '',
    },
    'dpqtohyf': {
      'en': '',
      'id': '',
      'ms': '',
    },
    'v01vf71s': {
      'en': '',
      'id': '',
      'ms': '',
    },
    'gcv6def1': {
      'en': '',
      'id': '',
      'ms': '',
    },
    'um9es99m': {
      'en': '',
      'id': '',
      'ms': '',
    },
    'o4enbz4j': {
      'en': '',
      'id': '',
      'ms': '',
    },
    '8z4tvfh7': {
      'en': '',
      'id': '',
      'ms': '',
    },
    '2ybzla8x': {
      'en': '',
      'id': '',
      'ms': '',
    },
    'd1wdf5i1': {
      'en': '',
      'id': '',
      'ms': '',
    },
    'frqnmevo': {
      'en': '',
      'id': '',
      'ms': '',
    },
    '2py80kgi': {
      'en': '',
      'id': '',
      'ms': '',
    },
    'p6lsrh2a': {
      'en': '',
      'id': '',
      'ms': '',
    },
    'ne8cclp9': {
      'en': '',
      'id': '',
      'ms': '',
    },
  },
].reduce((a, b) => a..addAll(b));
