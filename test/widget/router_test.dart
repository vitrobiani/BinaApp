import 'package:bina_system/app_core/nav/nav.dart';
import 'package:bina_system/auth/base_auth_user_provider.dart';
import 'package:bina_system/index.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final expectedRouteNames = <String>{
    MainHomeWidget.routeName,
    MainDIagnosticsWidget.routeName,
    MainDiagnoseWidget.routeName,
    FamilyWidget.routeName,
    MainProfilePageWidget.routeName,
    CameraWidget.routeName,
    DiagnosisGoodWidget.routeName,
    DiagnosisPlackWidget.routeName,
    DiagnosisPlackCavityWidget.routeName,
    DiagnosisCavityWidget.routeName,
    DiagnosisResultWidget.routeName,
    Auth2CreateWidget.routeName,
    Auth2LoginWidget.routeName,
    Auth2ForgotPasswordWidget.routeName,
    Auth2CreateProfileWidget.routeName,
    Auth2ProfileWidget.routeName,
    Auth2EditProfileWidget.routeName,
    PhotoSessionWidget.routeName,
    SessionSummaryWidget.routeName,
    SessionDetailsPageWidget.routeName,
    ChatHistoryWidget.routeName,
    AccessibilityWidget.routeName,
    MemberDetailWidget.routeName,
    CalibrationWidget.routeName,
    MemberDocumentsWidget.routeName,
    ChatRoomWidget.routeName,
    CameraConnectionWidget.routeName,
    TextSettingsWidget.routeName,
    ThemeSettingsWidget.routeName,
    HelpSupportWidget.routeName,
    LanguageSettingsWidget.routeName,
    AccountSettingsWidget.routeName,
  };

  final expectedRoutePaths = <String>{
    MainHomeWidget.routePath,
    MainDIagnosticsWidget.routePath,
    MainDiagnoseWidget.routePath,
    FamilyWidget.routePath,
    MainProfilePageWidget.routePath,
    CameraWidget.routePath,
    DiagnosisGoodWidget.routePath,
    DiagnosisPlackWidget.routePath,
    DiagnosisPlackCavityWidget.routePath,
    DiagnosisCavityWidget.routePath,
    DiagnosisResultWidget.routePath,
    Auth2CreateWidget.routePath,
    Auth2LoginWidget.routePath,
    Auth2ForgotPasswordWidget.routePath,
    Auth2CreateProfileWidget.routePath,
    Auth2ProfileWidget.routePath,
    Auth2EditProfileWidget.routePath,
    PhotoSessionWidget.routePath,
    SessionSummaryWidget.routePath,
    SessionDetailsPageWidget.routePath,
    ChatHistoryWidget.routePath,
    AccessibilityWidget.routePath,
    MemberDetailWidget.routePath,
    CalibrationWidget.routePath,
    MemberDocumentsWidget.routePath,
    ChatRoomWidget.routePath,
    CameraConnectionWidget.routePath,
    TextSettingsWidget.routePath,
    ThemeSettingsWidget.routePath,
    HelpSupportWidget.routePath,
    LanguageSettingsWidget.routePath,
    AccountSettingsWidget.routePath,
  };

  GoRouter buildRouter() {
    final notifier = AppStateNotifier.instance;
    notifier.user = _FakeAuthUser(loggedIn: true);
    notifier.initialUser = notifier.user;
    notifier.showSplashImage = false;
    return createRouter(notifier);
  }

  Iterable<GoRoute> walk(List<RouteBase> routes) sync* {
    for (final r in routes) {
      if (r is GoRoute) {
        yield r;
        yield* walk(r.routes);
      }
    }
  }

  test('every widget class in the manifest has a matching route', () {
    final router = buildRouter();
    final names = walk(router.configuration.routes).map((r) => r.name).toSet();
    final missing = expectedRouteNames.difference(names);
    expect(missing, isEmpty,
        reason: 'Widget classes without a route in nav.dart: $missing');
  });

  test('every widget class has a matching route PATH', () {
    final router = buildRouter();
    final paths = walk(router.configuration.routes).map((r) => r.path).toSet();
    final missing = expectedRoutePaths.difference(paths);
    expect(missing, isEmpty,
        reason: 'Widget classes without a path in nav.dart: $missing');
  });

  test('all route names are non-empty', () {
    final router = buildRouter();
    for (final r in walk(router.configuration.routes)) {
      expect(r.name ?? '', isNotEmpty,
          reason: 'Route at path "${r.path}" is missing a name');
    }
  });

  test('all route paths are non-empty', () {
    final router = buildRouter();
    for (final r in walk(router.configuration.routes)) {
      expect(r.path, isNotEmpty,
          reason: 'Route "${r.name}" is missing a path');
    }
  });

  test('route names are unique across the tree', () {
    final router = buildRouter();
    final names = walk(router.configuration.routes)
        .map((r) => r.name)
        .whereType<String>()
        .toList();
    final seen = <String>{};
    final duplicates = <String>[];
    for (final n in names) {
      if (!seen.add(n)) duplicates.add(n);
    }
    expect(duplicates, isEmpty,
        reason: 'Duplicate route names silently shadow each other: '
            '$duplicates');
  });

  test('route paths are unique across the tree', () {
    final router = buildRouter();
    final paths =
        walk(router.configuration.routes).map((r) => r.path).toList();
    final seen = <String>{};
    final duplicates = <String>[];
    for (final p in paths) {
      if (!seen.add(p)) duplicates.add(p);
    }
    expect(duplicates, isEmpty,
        reason: 'Duplicate paths make one page unreachable: $duplicates');
  });

  test('router builds without throwing under a logged-in fake user', () {
    expect(buildRouter, returnsNormally);
  });

  test('root route is named "_initialize"', () {
    final router = buildRouter();
    final rootRoute = router.configuration.routes
        .whereType<GoRoute>()
        .firstWhere((r) => r.path == '/');
    expect(rootRoute.name, equals('_initialize'));
  });
}

class _FakeAuthUser extends BaseAuthUser {
  _FakeAuthUser({required this.loggedIn});
  @override
  final bool loggedIn;
  @override
  String? get uid => 'test-uid';
  @override
  AuthUserInfo get authUserInfo =>
      AuthUserInfo(uid: uid, email: 'test@example.com');
  @override
  Future? delete() async {}
  @override
  Future? sendEmailVerification() async {}
  @override
  Future? updateEmail(String email) async {}
  @override
  Future? updatePassword(String password) async {}
  @override
  bool get emailVerified => true;
}
