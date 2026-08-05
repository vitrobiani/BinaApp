import 'dart:typed_data';

import 'package:bina_system/app_core/internationalization.dart';
import 'package:bina_system/app_state.dart';
import 'package:bina_system/backend/sqlite/sqlite_manager.dart';
import 'package:bina_system/pages/family/member_documents/member_documents_widget.dart';
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

  Future<void> insertDoc({
    required String id,
    String memberId = 'fm-1',
    String fileName = 'referral.pdf',
    String mimeType = 'application/pdf',
    int byteSize = 12345,
    String extractedText = 'Some readable text.',
    String extractionStatus = 'ok',
  }) =>
      SQLiteManager.instance.insertMemberDocument(
        id: id,
        familyMemberId: memberId,
        fileName: fileName,
        mimeType: mimeType,
        byteSize: byteSize,
        blob: Uint8List.fromList([0x25, 0x50, 0x44, 0x46]),
        extractedText: extractedText,
        extractionStatus: extractionStatus,
        uploadedAt: DateTime(2025, 6, 15).millisecondsSinceEpoch ~/ 1000,
      );

  group('empty state', () {
    testWidgets('renders the empty-state card when no docs exist',
        (tester) async {
      await pumpAppShellRaw(
        tester,
        const MemberDocumentsWidget(familyMemberId: 'fm-1'),
      );
      await tester.pump();
      await tester.pump();

      expect(find.text('No documents yet'), findsOneWidget);
      expect(find.byIcon(Icons.folder_open_rounded), findsOneWidget);
    });

    testWidgets('shows the "Upload PDF" FAB in both states', (tester) async {
      await pumpAppShellRaw(
        tester,
        const MemberDocumentsWidget(familyMemberId: 'fm-1'),
      );
      await tester.pump();

      expect(find.text('Upload PDF'), findsOneWidget);
      expect(find.byIcon(Icons.upload_file_rounded), findsOneWidget);
    });
  });

  group('populated state', () {
    testWidgets('renders one tile per document with name + size + date',
        (tester) async {
      await pumpAppShellRaw(
        tester,
        const MemberDocumentsWidget(familyMemberId: 'fm-1'),
      );
      await insertDoc(id: 'd-1', fileName: 'referral.pdf', byteSize: 2048);
      await insertDoc(id: 'd-2', fileName: 'xray_notes.pdf', byteSize: 5 * 1024 * 1024);
      await AppState().loadMemberDocuments('fm-1');
      await tester.pump();

      expect(find.text('referral.pdf'), findsOneWidget);
      expect(find.text('xray_notes.pdf'), findsOneWidget);
      expect(find.textContaining('2.0 KB'), findsOneWidget);
      expect(find.textContaining('5.0 MB'), findsOneWidget);
      expect(find.textContaining('15 Jun 2025'), findsNWidgets(2));
    });

    testWidgets(
        'ok extraction → green "Ready" badge; empty → amber "No text" badge',
        (tester) async {
      await pumpAppShellRaw(
        tester,
        const MemberDocumentsWidget(familyMemberId: 'fm-1'),
      );
      await insertDoc(id: 'd-ok', fileName: 'r.pdf', extractionStatus: 'ok');
      await insertDoc(
          id: 'd-empty', fileName: 's.pdf', extractionStatus: 'empty');
      await AppState().loadMemberDocuments('fm-1');
      await tester.pump();

      expect(find.text('Ready'), findsOneWidget);
      expect(find.text('No text'), findsOneWidget);
    });

    testWidgets('tile is dismissible (Delete confirmation flow)',
        (tester) async {
      await pumpAppShellRaw(
        tester,
        const MemberDocumentsWidget(familyMemberId: 'fm-1'),
      );
      await insertDoc(id: 'd-1', fileName: 'referral.pdf');
      await AppState().loadMemberDocuments('fm-1');
      await tester.pump();

      final tile = find.byType(Dismissible);
      expect(tile, findsOneWidget,
          reason: 'each tile is wrapped in Dismissible for swipe-to-delete');
    });
  });

  group('header', () {
    testWidgets('renders member name when provided', (tester) async {
      await pumpAppShellRaw(
        tester,
        const MemberDocumentsWidget(
          familyMemberId: 'fm-1',
          familyMemberName: 'Alice',
        ),
      );
      await tester.pump();

      expect(find.textContaining('Alice'), findsOneWidget);
    });

    testWidgets('falls back to generic title when name is null',
        (tester) async {
      await pumpAppShellRaw(
        tester,
        const MemberDocumentsWidget(familyMemberId: 'fm-1'),
      );
      await tester.pump();

      expect(find.text('Member documents'), findsOneWidget);
    });
  });

  group('_DocumentTile size formatter (via public rendering)', () {
    testWidgets('bytes < 1024 render as "N B"', (tester) async {
      await pumpAppShellRaw(
        tester,
        const MemberDocumentsWidget(familyMemberId: 'fm-1'),
      );
      await insertDoc(id: 'd-tiny', byteSize: 512);
      await AppState().loadMemberDocuments('fm-1');
      await tester.pump();

      expect(find.textContaining('512 B'), findsOneWidget);
    });

    testWidgets('bytes < 1 MB render as "N KB" one decimal', (tester) async {
      await pumpAppShellRaw(
        tester,
        const MemberDocumentsWidget(familyMemberId: 'fm-1'),
      );
      await insertDoc(id: 'd-kb', byteSize: 3584); // 3.5 KB
      await AppState().loadMemberDocuments('fm-1');
      await tester.pump();

      expect(find.textContaining('3.5 KB'), findsOneWidget);
    });
  });
}
