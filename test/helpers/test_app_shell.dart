import 'package:bina_system/app_core/internationalization.dart';
import 'package:bina_system/app_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fake_secure_storage.dart';

Future<void> pumpAppShell(
  WidgetTester tester,
  Widget child, {
  Locale locale = const Locale('en'),
  bool seedSecureStorage = false,
  Size size = const Size(400, 800),
}) async {
  await tester.binding.setSurfaceSize(size);

  if (seedSecureStorage) {
    SharedPreferences.setMockInitialValues({});
    await AppLocalizations.initialize();
    AppState.reset();
    installFakeSecureStorage();
    await AppState().initializePersistedState();
  }

  await tester.pumpWidget(
    ChangeNotifierProvider<AppState>.value(
      value: AppState(),
      child: MaterialApp(
        locale: locale,
        supportedLocales: const [
          Locale('en'),
          Locale('he'),
          Locale('id'),
          Locale('ms'),
        ],
        localizationsDelegates: [
          AppLocalizationsDelegate(),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: Scaffold(body: child),
      ),
    ),
  );

  await tester.pump();
}

Future<void> pumpAppShellRaw(
  WidgetTester tester,
  Widget child, {
  Locale locale = const Locale('en'),
  bool seedSecureStorage = false,
  Size size = const Size(400, 800),
}) async {
  await tester.binding.setSurfaceSize(size);

  if (seedSecureStorage) {
    SharedPreferences.setMockInitialValues({});
    await AppLocalizations.initialize();
    AppState.reset();
    installFakeSecureStorage();
    await AppState().initializePersistedState();
  }

  await tester.pumpWidget(
    ChangeNotifierProvider<AppState>.value(
      value: AppState(),
      child: MaterialApp(
        locale: locale,
        supportedLocales: const [
          Locale('en'),
          Locale('he'),
          Locale('id'),
          Locale('ms'),
        ],
        localizationsDelegates: [
          AppLocalizationsDelegate(),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: child,
      ),
    ),
  );

  await tester.pump();
}

void teardownAppShell() {
  uninstallFakeSecureStorage();
  AppState.reset();
}
