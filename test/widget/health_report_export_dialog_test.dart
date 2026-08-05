import 'package:bina_system/app_core/internationalization.dart';
import 'package:bina_system/app_state.dart';
import 'package:bina_system/backend/schema/structs/index.dart';
import 'package:bina_system/backend/sqlite/sqlite_manager.dart';
import 'package:bina_system/services/health_report_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
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

  Future<void> pumpFor(WidgetTester tester,
      [Duration budget = const Duration(seconds: 3)]) async {
    final end = tester.binding.clock.now().add(budget);
    while (tester.binding.clock.now().isBefore(end)) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  Widget triggerButton(FamilyMemberStruct member) => Builder(
        builder: (context) => Center(
          child: TextButton(
            key: const Key('trigger-export'),
            onPressed: () =>
                HealthReportService.exportAndShare(context, member),
            child: const Text('open export'),
          ),
        ),
      );

  testWidgets('opens with "Generating report…" copy', (tester) async {
    final member = FamilyMemberStruct(id: 'fm-empty', name: 'Alice');
    await pumpAppShellRaw(
      tester,
      triggerButton(member),
      size: const Size(500, 900),
    );
    await tester.tap(find.byKey(const Key('trigger-export')));
    await tester.pump();

    expect(find.text('Generating report…'), findsOneWidget);
  });

  testWidgets('transitions to "Report ready" once buildPayload + PDF finish',
      (tester) async {
    final member = FamilyMemberStruct(id: 'fm-empty', name: 'Alice');
    await pumpAppShellRaw(
      tester,
      triggerButton(member),
      size: const Size(500, 900),
    );
    await tester.tap(find.byKey(const Key('trigger-export')));
    await pumpFor(tester); // let buildPayload + PDF write complete

    expect(find.text('Report ready'), findsOneWidget,
        reason: 'dialog must reach the ready state on the empty-sessions '
            'happy path');
    expect(find.text('Share'), findsOneWidget);
    expect(find.text('Close'), findsOneWidget);
  });

  testWidgets('Close dismisses the dialog', (tester) async {
    final member = FamilyMemberStruct(id: 'fm-empty', name: 'Alice');
    await pumpAppShellRaw(
      tester,
      triggerButton(member),
      size: const Size(500, 900),
    );
    await tester.tap(find.byKey(const Key('trigger-export')));
    await pumpFor(tester);

    expect(find.text('Report ready'), findsOneWidget);
    await tester.tap(find.text('Close'));
    await pumpFor(tester);
    expect(find.text('Report ready'), findsNothing,
        reason: 'Close must actually pop the dialog off the navigator');
  });

  testWidgets('dialog is barrier-dismissible-blocked (must click Close)',
      (tester) async {
    final member = FamilyMemberStruct(id: 'fm-empty', name: 'Alice');
    await pumpAppShellRaw(
      tester,
      triggerButton(member),
      size: const Size(500, 900),
    );
    await tester.tap(find.byKey(const Key('trigger-export')));
    await pumpFor(tester);

    expect(find.text('Report ready'), findsOneWidget);
    await tester.tapAt(const Offset(10, 10));
    await pumpFor(tester);
    expect(find.text('Report ready'), findsOneWidget,
        reason: 'barrierDismissible=false — outside taps must NOT close');
  });
}
