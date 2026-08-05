import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../helpers/supabase_test_client.dart';

void main() {
  // Compute once at load time so we can gate `skip:` on it.
  final configured = SupabaseTestConfig.isConfigured;

  setUpAll(() async {
    if (!configured) return;
    await initTestSupabase();
  });

  group('sign-up / sign-in / sign-out', () {
    test('fresh sign-up returns a session with a matching uid', () async {
      await withCleanUser((user) async {
        expect(user.session.user.id, equals(user.userId));
        expect(user.email, contains('@bina-test.example.com'));
        expect(Supabase.instance.client.auth.currentUser?.id,
            equals(user.userId),
            reason: 'client should be signed in as the returned user');
      });
    }, skip: configured ? false : SupabaseTestConfig.skipReason);

    test('sign-out clears the current session', () async {
      await withCleanUser((user) async {
        await Supabase.instance.client.auth.signOut();
        expect(Supabase.instance.client.auth.currentUser, isNull);
        expect(Supabase.instance.client.auth.currentSession, isNull);
      });
    }, skip: configured ? false : SupabaseTestConfig.skipReason);

    test('sign-in with the same credentials restores the session',
        () async {
      await withCleanUser((user) async {
        await Supabase.instance.client.auth.signOut();
        expect(Supabase.instance.client.auth.currentUser, isNull);

        final res = await Supabase.instance.client.auth.signInWithPassword(
          email: user.email,
          password: user.password,
        );
        expect(res.session, isNotNull);
        expect(res.user?.id, equals(user.userId),
            reason: 're-signed session should match the original uid');
      });
    }, skip: configured ? false : SupabaseTestConfig.skipReason);

    test('wrong password fails with a typed AuthException', () async {
      await withCleanUser((user) async {
        await Supabase.instance.client.auth.signOut();

        await expectLater(
          () => Supabase.instance.client.auth.signInWithPassword(
            email: user.email,
            password: 'definitely-not-the-password',
          ),
          throwsA(isA<AuthException>()),
          reason: 'wrong-password path must surface a typed error, not '
              'return a null session silently',
        );
      });
    }, skip: configured ? false : SupabaseTestConfig.skipReason);

    test('signing in with an unknown email fails cleanly', () async {
      if (!configured) return;
      await expectLater(
        () => Supabase.instance.client.auth.signInWithPassword(
          email: 'nobody-here-at-all@bina-test.example.com',
          password: 'anything',
        ),
        throwsA(isA<AuthException>()),
      );
    }, skip: configured ? false : SupabaseTestConfig.skipReason);
  });

  group('session state', () {
    test('signed-in user can read their own row from users_info if present',
        () async {
      await withCleanUser((user) async {
        // users_info row is created by the client on first login; here we
        // just prove the RLS-guarded read works when a row does exist.
        try {
          await Supabase.instance.client.from('users_info').insert({
            'account_id': user.userId,
            'email': user.email,
          });
        } catch (_) {
          return;
        }
        final rows = await Supabase.instance.client
            .from('users_info')
            .select()
            .eq('account_id', user.userId);
        expect(rows, hasLength(1));
      });
    }, skip: configured ? false : SupabaseTestConfig.skipReason);

    test('signed-out reads on RLS-protected tables return empty', () async {
      await withCleanUser((user) async {
        await Supabase.instance.client.auth.signOut();
        final rows = await Supabase.instance.client
            .from('family_members')
            .select()
            .eq('account_id', user.userId);
        expect(rows, isEmpty,
            reason: 'anonymous session must not see any user rows');
      });
    }, skip: configured ? false : SupabaseTestConfig.skipReason);
  });

  group('user deletion (cascade)', () {
    test('deleting family_member cascades to its scan_session rows',
        () async {
      await withCleanUser((user) async {
        final fmId = await _insertFamilyMember(user);
        final sessionId = await _insertScanSession(fmId);

        await Supabase.instance.client
            .from('family_members')
            .delete()
            .eq('id', fmId);

        final remaining = await Supabase.instance.client
            .from('scan_session')
            .select('id')
            .eq('id', sessionId);
        expect(remaining, isEmpty,
            reason: 'FK cascade must scrub sessions when the member goes');
      });
    }, skip: configured ? false : SupabaseTestConfig.skipReason);
  });
}

Future<String> _insertFamilyMember(SupabaseTestUser user) async {
  final res = await Supabase.instance.client
      .from('family_members')
      .insert({
        'account_id': user.userId,
        'name': 'Integration Test Member',
      })
      .select('id')
      .single();
  return (res as Map)['id'] as String;
}

Future<String> _insertScanSession(String familyMemberId) async {
  final res = await Supabase.instance.client
      .from('scan_session')
      .insert({
        'family_member_id': familyMemberId,
        'status': 'pending',
      })
      .select('id')
      .single();
  return (res as Map)['id'] as String;
}
