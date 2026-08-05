import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../helpers/supabase_test_client.dart';

void main() {
  final configured = SupabaseTestConfig.isConfigured;

  setUpAll(() async {
    if (!configured) return;
    await initTestSupabase();
  });

  test('per-member scan_session queries never see other members\' sessions',
      () async {
    await withCleanUser((user) async {
      // Create three siblings under the same account.
      final alice = await _insertFamilyMember(user.userId, name: 'Alice');
      final bob = await _insertFamilyMember(user.userId, name: 'Bob');
      final carol = await _insertFamilyMember(user.userId, name: 'Carol');

      // Each gets a scan session — tag notes so we can prove which is which.
      final aliceSession =
          await _insertScanSession(alice, notes: 'alice-only');
      final bobSession = await _insertScanSession(bob, notes: 'bob-only');
      final carolSession =
          await _insertScanSession(carol, notes: 'carol-only');

      // Query per member: each must see only its own session.
      final aliceRows = await Supabase.instance.client
          .from('scan_session')
          .select()
          .eq('family_member_id', alice);
      expect(aliceRows.map((r) => (r as Map)['id']),
          equals([aliceSession]));

      final bobRows = await Supabase.instance.client
          .from('scan_session')
          .select()
          .eq('family_member_id', bob);
      expect(bobRows.map((r) => (r as Map)['id']), equals([bobSession]));

      final carolRows = await Supabase.instance.client
          .from('scan_session')
          .select()
          .eq('family_member_id', carol);
      expect(carolRows.map((r) => (r as Map)['id']),
          equals([carolSession]));

      // Unscoped query returns all three.
      final all = await Supabase.instance.client
          .from('scan_session')
          .select()
          .inFilter('family_member_id', [alice, bob, carol]);
      expect(all, hasLength(3));
    });
  }, skip: configured ? false : SupabaseTestConfig.skipReason);

  test('per-member document queries never see other members\' documents',
      () async {
    await withCleanUser((user) async {
      final alice = await _insertFamilyMember(user.userId, name: 'Alice');
      final bob = await _insertFamilyMember(user.userId, name: 'Bob');

      final aliceDoc = await _insertMemberDocument(alice, 'alice-doc.pdf');
      final bobDoc = await _insertMemberDocument(bob, 'bob-doc.pdf');

      final aliceDocs = await Supabase.instance.client
          .from('member_document')
          .select()
          .eq('family_member_id', alice);
      expect(aliceDocs.map((r) => (r as Map)['id']), equals([aliceDoc]));

      final bobDocs = await Supabase.instance.client
          .from('member_document')
          .select()
          .eq('family_member_id', bob);
      expect(bobDocs.map((r) => (r as Map)['id']), equals([bobDoc]));
    });
  }, skip: configured ? false : SupabaseTestConfig.skipReason);

  test('deleting one member leaves siblings untouched', () async {
    await withCleanUser((user) async {
      final alice = await _insertFamilyMember(user.userId, name: 'Alice');
      final bob = await _insertFamilyMember(user.userId, name: 'Bob');
      final aliceSession = await _insertScanSession(alice, notes: 'a');
      final bobSession = await _insertScanSession(bob, notes: 'b');

      await Supabase.instance.client
          .from('family_members')
          .delete()
          .eq('id', alice);

      final remaining = await Supabase.instance.client
          .from('family_members')
          .select('id')
          .eq('account_id', user.userId);
      expect(remaining.map((r) => (r as Map)['id']), equals([bob]));

      final bobStill = await Supabase.instance.client
          .from('scan_session')
          .select('id')
          .eq('id', bobSession);
      expect(bobStill, hasLength(1),
          reason: 'sibling\'s session must survive Alice\'s delete');

      final aliceGone = await Supabase.instance.client
          .from('scan_session')
          .select('id')
          .eq('id', aliceSession);
      expect(aliceGone, isEmpty,
          reason: 'Alice\'s own session should have cascaded');
    });
  }, skip: configured ? false : SupabaseTestConfig.skipReason);
}

Future<String> _insertFamilyMember(String userId, {required String name}) async {
  final res = await Supabase.instance.client
      .from('family_members')
      .insert({
        'account_id': userId,
        'name': name,
      })
      .select('id')
      .single();
  return (res as Map)['id'] as String;
}

Future<String> _insertScanSession(String familyMemberId,
    {required String notes}) async {
  final res = await Supabase.instance.client
      .from('scan_session')
      .insert({
        'family_member_id': familyMemberId,
        'status': 'pending',
        'notes': notes,
      })
      .select('id')
      .single();
  return (res as Map)['id'] as String;
}

Future<String> _insertMemberDocument(
    String familyMemberId, String fileName) async {
  final res = await Supabase.instance.client
      .from('member_document')
      .insert({
        'family_member_id': familyMemberId,
        'file_name': fileName,
        'mime_type': 'application/pdf',
        'byte_size': 100,
        'extraction_status': 'ok',
        'extracted_text': 'stub',
        'storage_path': '$familyMemberId/$fileName',
      })
      .select('id')
      .single();
  return (res as Map)['id'] as String;
}
