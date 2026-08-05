import 'dart:ui' show Size;

import 'package:bina_system/app_core/internationalization.dart';
import 'package:bina_system/app_state.dart';
import 'package:bina_system/backend/schema/structs/index.dart';
import 'package:bina_system/backend/sqlite/sqlite_manager.dart';
import 'package:bina_system/pages/family/member_detail/member_detail_widget.dart';
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

  FamilyMemberStruct fm({
    String id = 'fm-detail',
    String name = 'Alice',
  }) =>
      FamilyMemberStruct(id: id, name: name);

  Future<void> insertSession(String memberId, {int? end}) =>
      SQLiteManager.instance.createScanSession(
        id: '$memberId-s-${DateTime.now().microsecondsSinceEpoch}',
        familyMemberId: memberId,
        sessionStart: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        status: 'completed',
        notes: 'test session',
        totalImagesCaptured: 0,
      );

  Future<void> pumpFor(WidgetTester tester,
      [Duration budget = const Duration(seconds: 2)]) async {
    final end = tester.binding.clock.now().add(budget);
    while (tester.binding.clock.now().isBefore(end)) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  testWidgets('with 0 sessions → Export action is hidden', (tester) async {
    await pumpAppShellRaw(
      tester,
      MemberDetailWidget(member: fm(id: 'fm-empty')),
      size: const Size(500, 900),
    );
    await pumpFor(tester);

    expect(find.text('Export'), findsNothing,
        reason: 'Export must not appear for members with zero sessions '
            '(W2 rule).');
  });

  testWidgets('with ≥ 1 session → Export action is visible', (tester) async {
    const memberId = 'fm-populated';
    await insertSession(memberId);

    await pumpAppShellRaw(
      tester,
      MemberDetailWidget(member: fm(id: memberId)),
      size: const Size(500, 900),
    );
    await pumpFor(tester);

    expect(find.text('Export'), findsOneWidget,
        reason: 'Export must appear once the member has at least one '
            'saved session.');
  });

  testWidgets('member name renders in the header', (tester) async {
    await pumpAppShellRaw(
      tester,
      MemberDetailWidget(member: fm(id: 'fm-1', name: 'Bob')),
      size: const Size(500, 900),
    );
    await pumpFor(tester);

    expect(find.text('Bob'), findsWidgets,
        reason: 'the header should display the member name somewhere');
  });
}
