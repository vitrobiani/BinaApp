import 'dart:ui' show Locale;

import 'package:bina_system/app_core/internationalization.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const supportedLocales = ['en', 'he', 'id', 'ms'];

  const kTotalKeysAtLeast = 625;
  const kMissingEnLimit = 0; // no key should have `en` completely absent
  const kEmptyEnLimit = 4;
  const kEmptyIdLimit = 112;
  const kEmptyMsLimit = 112;
  const kEmptyHeLimit = 4;

  test('supported locales are exactly the four we ship', () {
    expect(
      AppLocalizations.languages().toSet(),
      equals(supportedLocales.toSet()),
    );
  });

  test('every entry only uses supported locale codes', () {
    final unknown = <String>{};
    kTranslationsMap.forEach((key, translations) {
      for (final locale in translations.keys) {
        if (!supportedLocales.contains(locale)) {
          unknown.add('$key → $locale');
        }
      }
    });
    expect(unknown, isEmpty, reason: 'Unsupported locale codes: $unknown');
  });

  test('kTranslationsMap contains at least the current key count', () {
    expect(
      kTranslationsMap.length,
      greaterThanOrEqualTo(kTotalKeysAtLeast),
      reason: 'kTranslationsMap shrank unexpectedly — probable merge '
          'collision or an accidental delete.',
    );
  });

  test('no key is completely missing an `en` entry (strict)', () {
    final missing = <String>[];
    kTranslationsMap.forEach((key, translations) {
      if (!translations.containsKey('en')) missing.add(key);
    });
    expect(
      missing.length,
      lessThanOrEqualTo(kMissingEnLimit),
      reason: 'Keys without any `en` entry: $missing',
    );
  });

  test('empty-string count per locale stays within watermark', () {
    final emptyByLocale = <String, List<String>>{};
    kTranslationsMap.forEach((key, translations) {
      translations.forEach((locale, value) {
        if (value.isEmpty) {
          emptyByLocale.putIfAbsent(locale, () => <String>[]).add(key);
        }
      });
    });

    expect(
      emptyByLocale['en']?.length ?? 0,
      lessThanOrEqualTo(kEmptyEnLimit),
      reason: 'Empty English strings grew — new blank labels appeared: '
          '${emptyByLocale['en']}',
    );
    expect(
      emptyByLocale['he']?.length ?? 0,
      lessThanOrEqualTo(kEmptyHeLimit),
      reason: 'Empty Hebrew strings grew: ${emptyByLocale['he']}',
    );
    expect(
      emptyByLocale['id']?.length ?? 0,
      lessThanOrEqualTo(kEmptyIdLimit),
      reason: 'Empty Indonesian strings grew — untranslated widget shipped?',
    );
    expect(
      emptyByLocale['ms']?.length ?? 0,
      lessThanOrEqualTo(kEmptyMsLimit),
      reason: 'Empty Malay strings grew — untranslated widget shipped?',
    );
  });

  group('AppLocalizations getters honour the merged map', () {
    test('AppLocalizations returns the English text for a known key', () {
      final loc = AppLocalizations(const Locale('en'));
      expect(loc.getText('home_hello'), equals('Hello'));
    });

    test('unknown key returns empty string (documented fallback behaviour)',
        () {
      final loc = AppLocalizations(const Locale('en'));
      expect(loc.getText('this_key_definitely_does_not_exist'), equals(''));
    });

    test('Hebrew value returned when Hebrew locale is active', () {
      final loc = AppLocalizations(const Locale('he'));
      expect(loc.getText('home_hello'), equals('שלום'));
    });

    test('missing-locale-entry falls back to English silently', () {
      final loc = AppLocalizations(const Locale('id'));
      expect(loc.getText('home_hello'), isNotEmpty);
    });
  });
}
