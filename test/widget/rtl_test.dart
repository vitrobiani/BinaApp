import 'package:bina_system/app_core/internationalization.dart';
import 'package:bina_system/app_state.dart';
import 'package:bina_system/backend/sqlite/sqlite_manager.dart';
import 'package:bina_system/pages/family/member_documents/member_documents_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/fake_secure_storage.dart';
import '../helpers/sqlite_test_db.dart';
import '../helpers/test_app_shell.dart';

void main() {
  setUpAll(initFfiSqlite);

  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    AppState.reset();
    SharedPreferences.setMockInitialValues({});
    await AppLocalizations.initialize();
    installFakeSecureStorage();
    await AppState().initializePersistedState();
    AppState().updateUserSessionStruct((u) => u.isLocalSession = true);
    final db = await openMigratedSqlite();
    SQLiteManager.setDatabaseForTesting(db);
  });

  tearDown(teardownAppShell);

  Future<void> pumpRtl(WidgetTester tester, Widget child) async {
    await tester.binding.setSurfaceSize(const Size(400, 800));
    await tester.pumpWidget(
      ChangeNotifierProvider<AppState>.value(
        value: AppState(),
        child: MaterialApp(
          locale: const Locale('he'),
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
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: child,
          ),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('MemberDocumentsWidget renders under RTL without overflow',
      (tester) async {
    await pumpRtl(
      tester,
      const MemberDocumentsWidget(
        familyMemberId: 'fm-1',
        familyMemberName: 'אליס',
      ),
    );
    await tester.pump();

    final ex = tester.takeException();
    expect(ex, isNull,
        reason: 'RTL layout must not throw overflow assertions');

    final BuildContext ctx = tester.element(find.byType(MemberDocumentsWidget));
    expect(Directionality.of(ctx), equals(TextDirection.rtl));
  });

  testWidgets('MemberDocumentsWidget empty-state copy has non-empty Hebrew',
      (tester) async {
    await pumpRtl(
      tester,
      const MemberDocumentsWidget(familyMemberId: 'fm-1'),
    );
    await tester.pump();

    expect(find.text('No documents yet'), findsOneWidget,
        reason: 'Empty state currently hard-codes English — flip the '
            'expectation when the string moves to kTranslationsMap');
  });
}
