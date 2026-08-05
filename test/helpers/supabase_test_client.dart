import 'dart:io' show Platform;
import 'dart:math' show Random;

import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseTestConfig {
  SupabaseTestConfig._();

  static const String urlEnvKey = 'BINA_TEST_SUPABASE_URL';
  static const String anonEnvKey = 'BINA_TEST_SUPABASE_ANON_KEY';
  static const String serviceEnvKey = 'BINA_TEST_SUPABASE_SERVICE_KEY';

  static String? get url {
    final v = Platform.environment[urlEnvKey];
    return (v == null || v.isEmpty) ? null : v;
  }

  static String? get anonKey {
    final v = Platform.environment[anonEnvKey];
    return (v == null || v.isEmpty) ? null : v;
  }

  static String? get serviceKey {
    final v = Platform.environment[serviceEnvKey];
    return (v == null || v.isEmpty) ? null : v;
  }

  static bool get isConfigured => url != null && anonKey != null;

  static const String skipReason =
      'Integration test skipped: set $urlEnvKey + $anonEnvKey '
      '(see docs/testing/supabase_test_project.md)';
}

bool _supabaseInitialized = false;

Future<void> initTestSupabase() async {
  if (_supabaseInitialized) return;
  final url = SupabaseTestConfig.url;
  final anon = SupabaseTestConfig.anonKey;
  if (url == null || anon == null) {
    throw StateError(
      'Cannot initialize test Supabase — env vars missing. '
      'Check SupabaseTestConfig.isConfigured before calling.',
    );
  }
  TestWidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: url,
    anonKey: anon,
    debug: false,
  );
  _supabaseInitialized = true;
}

class SupabaseTestUser {
  final String email;
  final String password;
  final String userId;
  final Session session;

  const SupabaseTestUser({
    required this.email,
    required this.password,
    required this.userId,
    required this.session,
  });
}

Future<T> withCleanUser<T>(
  Future<T> Function(SupabaseTestUser user) body, {
  String? emailPrefix,
}) async {
  await initTestSupabase();
  final client = Supabase.instance.client;
  final prefix = emailPrefix ?? 'test';
  final randomId = _randomHex(12);
  final email = '$prefix-$randomId@bina-test.example.com';
  const password = 'Test-1234-throwaway-!';

  // Sign up. Email confirmation must be OFF in the test project.
  final signUp = await client.auth.signUp(email: email, password: password);
  final session = signUp.session ??
      (await client.auth
              .signInWithPassword(email: email, password: password))
          .session;
  if (session == null) {
    throw StateError(
      'withCleanUser: sign-up returned no session — is email confirmation '
      'still ON in the test project? See docs/testing/supabase_test_project.md',
    );
  }
  final userId = session.user.id;

  final user = SupabaseTestUser(
    email: email,
    password: password,
    userId: userId,
    session: session,
  );

  Object? bodyError;
  StackTrace? bodyStack;
  T? result;
  try {
    result = await body(user);
  } catch (e, st) {
    bodyError = e;
    bodyStack = st;
  }

  await _cleanupUser(client, userId);

  if (bodyError != null) {
    Error.throwWithStackTrace(bodyError, bodyStack!);
  }
  return result as T;
}

Future<void> _cleanupUser(SupabaseClient client, String userId) async {
  const orderedTables = [
    'member_document_chunk',
    'member_document',
    'scan_image',
    'dental_record',
    'scan_session',
    'family_member_calibration',
    'family_members',
    'users_info',
  ];

  final familyIds = await _familyIdsFor(client, userId);
  for (final table in orderedTables) {
    try {
      if (table == 'family_members' || table == 'users_info') {
        await client.from(table).delete().eq('account_id', userId);
      } else if (familyIds.isNotEmpty) {
        await client
            .from(table)
            .delete()
            .inFilter('family_member_id', familyIds);
      }
    } catch (_) {
      // Best effort - a missing table or an RLS refusal shouldn't leak.
    }
  }

  // Auth user delete requires the service_role key. Skip if unset.
  final serviceKey = SupabaseTestConfig.serviceKey;
  if (serviceKey == null) {
    // Silently sign out the current session; the auth user lingers in
    // the dashboard until a manual cleanup.
    try {
      await client.auth.signOut();
    } catch (_) {}
    return;
  }

  final adminClient = SupabaseClient(
    SupabaseTestConfig.url!,
    serviceKey,
  );
  try {
    await adminClient.auth.admin.deleteUser(userId);
  } catch (_) {
    // Ignore - worst case we leak an auth user, not test data.
  }
  try {
    await client.auth.signOut();
  } catch (_) {}
}

Future<List<String>> _familyIdsFor(
    SupabaseClient client, String userId) async {
  try {
    final rows = await client
        .from('family_members')
        .select('id')
        .eq('account_id', userId);
    return (rows as List)
        .map((r) => (r as Map)['id'] as String)
        .toList();
  } catch (_) {
    return const [];
  }
}

String _randomHex(int bytes) {
  final rand = Random.secure();
  final buf = StringBuffer();
  for (var i = 0; i < bytes; i++) {
    buf.write(rand.nextInt(256).toRadixString(16).padLeft(2, '0'));
  }
  return buf.toString();
}
