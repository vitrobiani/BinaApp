import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/backend/schema/structs/index.dart';
import '/auth/base_auth_user_provider.dart';

import '/app_core/app_util.dart';

import '/index.dart';

export 'package:go_router/go_router.dart';
export 'serialization_util.dart';

const kTransitionInfoKey = '__transition_info__';

GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

class AppStateNotifier extends ChangeNotifier {
  AppStateNotifier._();

  static AppStateNotifier? _instance;
  static AppStateNotifier get instance => _instance ??= AppStateNotifier._();

  BaseAuthUser? initialUser;
  BaseAuthUser? user;
  bool showSplashImage = true;
  String? _redirectLocation;

  /// Determines whether the app will refresh and build again when a sign
  /// in or sign out happens. This is useful when the app is launched or
  /// on an unexpected logout. However, this must be turned off when we
  /// intend to sign in/out and then navigate or perform any actions after.
  /// Otherwise, this will trigger a refresh and interrupt the action(s).
  bool notifyOnAuthChange = true;

  bool get loading => user == null || showSplashImage;
  bool get loggedIn =>
      (user?.loggedIn ?? false) || AppState().UserSession.hasUserID();
  bool get initiallyLoggedIn => initialUser?.loggedIn ?? false;
  bool get shouldRedirect => loggedIn && _redirectLocation != null;

  String getRedirectLocation() => _redirectLocation!;
  bool hasRedirect() => _redirectLocation != null;
  void setRedirectLocationIfUnset(String loc) => _redirectLocation ??= loc;
  void clearRedirectLocation() => _redirectLocation = null;

  /// Mark as not needing to notify on a sign in / out when we intend
  /// to perform subsequent actions (such as navigation) afterwards.
  void updateNotifyOnAuthChange(bool notify) => notifyOnAuthChange = notify;

  void update(BaseAuthUser newUser) {
    final shouldUpdate =
        user?.uid == null || newUser.uid == null || user?.uid != newUser.uid;
    initialUser ??= newUser;
    user = newUser;
    // Refresh the app on auth change unless explicitly marked otherwise.
    // No need to update unless the user has changed.
    if (notifyOnAuthChange && shouldUpdate) {
      notifyListeners();
    }
    // Once again mark the notifier as needing to update on auth change
    // (in order to catch sign in / out events).
    updateNotifyOnAuthChange(true);
  }

  void stopShowingSplashImage() {
    showSplashImage = false;
    notifyListeners();
  }
}

GoRouter createRouter(AppStateNotifier appStateNotifier) => GoRouter(
      initialLocation: '/',
      debugLogDiagnostics: true,
      refreshListenable: appStateNotifier,
      navigatorKey: appNavigatorKey,
      errorBuilder: (context, state) =>
          appStateNotifier.loggedIn ? MainHomeWidget() : Auth2LoginWidget(),
      routes: [
        AppRoute(
          name: '_initialize',
          path: '/',
          builder: (context, _) =>
              appStateNotifier.loggedIn ? MainHomeWidget() : Auth2LoginWidget(),
          routes: [
            AppRoute(
              name: MainHomeWidget.routeName,
              path: MainHomeWidget.routePath,
              builder: (context, params) => MainHomeWidget(),
            ),
            AppRoute(
              name: MainDIagnosticsWidget.routeName,
              path: MainDIagnosticsWidget.routePath,
              builder: (context, params) => MainDIagnosticsWidget(),
            ),
            AppRoute(
              name: MainDiagnoseWidget.routeName,
              path: MainDiagnoseWidget.routePath,
              builder: (context, params) => MainDiagnoseWidget(),
            ),
            AppRoute(
              name: FamilyWidget.routeName,
              path: FamilyWidget.routePath,
              builder: (context, params) => FamilyWidget(),
            ),
            AppRoute(
              name: MainProfilePageWidget.routeName,
              path: MainProfilePageWidget.routePath,
              builder: (context, params) => MainProfilePageWidget(),
            ),
            AppRoute(
              name: CameraWidget.routeName,
              path: CameraWidget.routePath,
              builder: (context, params) => CameraWidget(
                memberId: params.getParam('memberId', ParamType.String),
                memberName: params.getParam('memberName', ParamType.String),
              ),
            ),
            AppRoute(
              name: DiagnosisGoodWidget.routeName,
              path: DiagnosisGoodWidget.routePath,
              builder: (context, params) => DiagnosisGoodWidget(),
            ),
            AppRoute(
              name: DiagnosisPlackWidget.routeName,
              path: DiagnosisPlackWidget.routePath,
              builder: (context, params) => DiagnosisPlackWidget(),
            ),
            AppRoute(
              name: DiagnosisPlackCavityWidget.routeName,
              path: DiagnosisPlackCavityWidget.routePath,
              builder: (context, params) => DiagnosisPlackCavityWidget(),
            ),
            AppRoute(
              name: DiagnosisCavityWidget.routeName,
              path: DiagnosisCavityWidget.routePath,
              builder: (context, params) => DiagnosisCavityWidget(),
            ),
            AppRoute(
              name: DiagnosisResultWidget.routeName,
              path: DiagnosisResultWidget.routePath,
              builder: (context, params) => DiagnosisResultWidget(
                imagePath: params.getParam('imagePath', ParamType.String),
                detections: params.getParam('detections', ParamType.JSON),
                memberName: params.getParam('memberName', ParamType.String),
              ),
            ),
            AppRoute(
              name: Auth2CreateWidget.routeName,
              path: Auth2CreateWidget.routePath,
              builder: (context, params) => Auth2CreateWidget(),
            ),
            AppRoute(
              name: Auth2LoginWidget.routeName,
              path: Auth2LoginWidget.routePath,
              builder: (context, params) => Auth2LoginWidget(),
            ),
            AppRoute(
              name: Auth2ForgotPasswordWidget.routeName,
              path: Auth2ForgotPasswordWidget.routePath,
              builder: (context, params) => Auth2ForgotPasswordWidget(),
            ),
            AppRoute(
              name: Auth2CreateProfileWidget.routeName,
              path: Auth2CreateProfileWidget.routePath,
              builder: (context, params) => Auth2CreateProfileWidget(),
            ),
            AppRoute(
              name: Auth2ProfileWidget.routeName,
              path: Auth2ProfileWidget.routePath,
              builder: (context, params) => Auth2ProfileWidget(),
            ),
            AppRoute(
              name: Auth2EditProfileWidget.routeName,
              path: Auth2EditProfileWidget.routePath,
              builder: (context, params) => Auth2EditProfileWidget(),
            ),
            AppRoute(
              name: PhotoSessionWidget.routeName,
              path: PhotoSessionWidget.routePath,
              builder: (context, params) => PhotoSessionWidget(
                memberId: params.getParam('memberId', ParamType.String),
                memberName: params.getParam('memberName', ParamType.String),
              ),
            ),
            AppRoute(
              name: SessionSummaryWidget.routeName,
              path: SessionSummaryWidget.routePath,
              builder: (context, params) => SessionSummaryWidget(
                sessionId: params.getParam('sessionId', ParamType.String),
                imageCount: params.getParam('imageCount', ParamType.int),
                memberName: params.getParam('memberName', ParamType.String),
                overallStatus: params.getParam('overallStatus', ParamType.String),
              ),
            ),
            AppRoute(
              name: SessionDetailsPageWidget.routeName,
              path: SessionDetailsPageWidget.routePath,
              builder: (context, params) => SessionDetailsPageWidget(
                sessionId: params.getParam('sessionId', ParamType.String),
              ),
            ),
            AppRoute(
              name: ChatHistoryWidget.routeName,
              path: ChatHistoryWidget.routePath,
              builder: (context, params) => ChatHistoryWidget(
                  params.getParam('familyMemberId', ParamType.String)),
            ),
            AppRoute(
              name: AccessibilityWidget.routeName,
              path: AccessibilityWidget.routePath,
              builder: (context, params) => AccessibilityWidget(),
            ),
            AppRoute(
              name: MemberDetailWidget.routeName,
              path: MemberDetailWidget.routePath,
              builder: (context, params) => MemberDetailWidget(
                member: params.getParam('member', ParamType.DataStruct,
                    structBuilder: FamilyMemberStruct.fromSerializableMap) ??
                    FamilyMemberStruct(),
              ),
            ),
            AppRoute(
              name: ChatRoomWidget.routeName,
              path: ChatRoomWidget.routePath,
              builder: (context, params) => ChatRoomWidget(
                conversationId: params.getParam('conversationId', ParamType.String),
              ),
            ),
            AppRoute(
              name: CameraConnectionWidget.routeName,
              path: CameraConnectionWidget.routePath,
              builder: (context, params) => CameraConnectionWidget(),
            ),
            AppRoute(
              name: TextSettingsWidget.routeName,
              path: TextSettingsWidget.routePath,
              builder: (context, params) => TextSettingsWidget(),
            ),
            AppRoute(
              name: ThemeSettingsWidget.routeName,
              path: ThemeSettingsWidget.routePath,
              builder: (context, params) => ThemeSettingsWidget(),
            ),
            AppRoute(
              name: HelpSupportWidget.routeName,
              path: HelpSupportWidget.routePath,
              builder: (context, params) => HelpSupportWidget(),
            ),
            AppRoute(
              name: LanguageSettingsWidget.routeName,
              path: LanguageSettingsWidget.routePath,
              builder: (context, params) => LanguageSettingsWidget(),
            ),
          ].map((r) => r.toRoute(appStateNotifier)).toList(),
        ),
      ].map((r) => r.toRoute(appStateNotifier)).toList(),
    );

extension NavParamExtensions on Map<String, String?> {
  Map<String, String> get withoutNulls => Map.fromEntries(
        entries
            .where((e) => e.value != null)
            .map((e) => MapEntry(e.key, e.value!)),
      );
}

extension NavigationExtensions on BuildContext {
  void goNamedAuth(
    String name,
    bool mounted, {
    Map<String, String> pathParameters = const <String, String>{},
    Map<String, String> queryParameters = const <String, String>{},
    Object? extra,
    bool ignoreRedirect = false,
  }) =>
      !mounted || GoRouter.of(this).shouldRedirect(ignoreRedirect)
          ? null
          : goNamed(
              name,
              pathParameters: pathParameters,
              queryParameters: queryParameters,
              extra: extra,
            );

  void pushNamedAuth(
    String name,
    bool mounted, {
    Map<String, String> pathParameters = const <String, String>{},
    Map<String, String> queryParameters = const <String, String>{},
    Object? extra,
    bool ignoreRedirect = false,
  }) =>
      !mounted || GoRouter.of(this).shouldRedirect(ignoreRedirect)
          ? null
          : pushNamed(
              name,
              pathParameters: pathParameters,
              queryParameters: queryParameters,
              extra: extra,
            );

  void safePop() {
    // If there is only one route on the stack, navigate to the initial
    // page instead of popping.
    if (canPop()) {
      pop();
    } else {
      go('/');
    }
  }
}

extension GoRouterExtensions on GoRouter {
  AppStateNotifier get appState => AppStateNotifier.instance;
  void prepareAuthEvent([bool ignoreRedirect = false]) =>
      appState.hasRedirect() && !ignoreRedirect
          ? null
          : appState.updateNotifyOnAuthChange(false);
  bool shouldRedirect(bool ignoreRedirect) =>
      !ignoreRedirect && appState.hasRedirect();
  void clearRedirectLocation() => appState.clearRedirectLocation();
  void setRedirectLocationIfUnset(String location) =>
      appState.updateNotifyOnAuthChange(false);
}

extension _GoRouterStateExtensions on GoRouterState {
  Map<String, dynamic> get extraMap =>
      extra != null ? extra as Map<String, dynamic> : {};
  Map<String, dynamic> get allParams => <String, dynamic>{}
    ..addAll(pathParameters)
    ..addAll(uri.queryParameters)
    ..addAll(extraMap);
  TransitionInfo get transitionInfo => extraMap.containsKey(kTransitionInfoKey)
      ? extraMap[kTransitionInfoKey] as TransitionInfo
      : TransitionInfo.appDefault();
}

class AppParameters {
  AppParameters(this.state, [this.asyncParams = const {}]);

  final GoRouterState state;
  final Map<String, Future<dynamic> Function(String)> asyncParams;

  Map<String, dynamic> futureParamValues = {};

  // Parameters are empty if the params map is empty or if the only parameter
  // present is the special extra parameter reserved for the transition info.
  bool get isEmpty =>
      state.allParams.isEmpty ||
      (state.allParams.length == 1 &&
          state.extraMap.containsKey(kTransitionInfoKey));
  bool isAsyncParam(MapEntry<String, dynamic> param) =>
      asyncParams.containsKey(param.key) && param.value is String;
  bool get hasFutures => state.allParams.entries.any(isAsyncParam);
  Future<bool> completeFutures() => Future.wait(
        state.allParams.entries.where(isAsyncParam).map(
          (param) async {
            final doc = await asyncParams[param.key]!(param.value)
                .onError((_, __) => null);
            if (doc != null) {
              futureParamValues[param.key] = doc;
              return true;
            }
            return false;
          },
        ),
      ).onError((_, __) => [false]).then((v) => v.every((e) => e));

  dynamic getParam<T>(
    String paramName,
    ParamType type, {
    bool isList = false,
    StructBuilder<T>? structBuilder,
  }) {
    if (futureParamValues.containsKey(paramName)) {
      return futureParamValues[paramName];
    }
    if (!state.allParams.containsKey(paramName)) {
      return null;
    }
    final param = state.allParams[paramName];
    // Got parameter from `extras`, so just directly return it.
    if (param is! String) {
      return param;
    }
    // Return serialized value.
    return deserializeParam<T>(
      param,
      type,
      isList,
      structBuilder: structBuilder,
    );
  }
}

class AppRoute {
  const AppRoute({
    required this.name,
    required this.path,
    required this.builder,
    this.requireAuth = false,
    this.asyncParams = const {},
    this.routes = const [],
  });

  final String name;
  final String path;
  final bool requireAuth;
  final Map<String, Future<dynamic> Function(String)> asyncParams;
  final Widget Function(BuildContext, AppParameters) builder;
  final List<GoRoute> routes;

  GoRoute toRoute(AppStateNotifier appStateNotifier) => GoRoute(
        name: name,
        path: path,
        redirect: (context, state) {
          if (appStateNotifier.shouldRedirect) {
            final redirectLocation = appStateNotifier.getRedirectLocation();
            appStateNotifier.clearRedirectLocation();
            return redirectLocation;
          }

          if (requireAuth && !appStateNotifier.loggedIn) {
            appStateNotifier.setRedirectLocationIfUnset(state.uri.toString());
            return '/auth2Login';
          }
          return null;
        },
        pageBuilder: (context, state) {
          fixStatusBarOniOS16AndBelow(context);
          final ffParams = AppParameters(state, asyncParams);
          final page = ffParams.hasFutures
              ? FutureBuilder(
                  future: ffParams.completeFutures(),
                  builder: (context, _) => builder(context, ffParams),
                )
              : builder(context, ffParams);
          final child = appStateNotifier.loading
              ? Container(
                  color: Colors.transparent,
                  child: Image.asset(
                    'assets/images/BinaSplash.png',
                    fit: BoxFit.cover,
                  ),
                )
              : page;

          final transitionInfo = state.transitionInfo;
          return transitionInfo.hasTransition
              ? CustomTransitionPage(
                  key: state.pageKey,
                  child: child,
                  transitionDuration: transitionInfo.duration,
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) =>
                          PageTransition(
                    type: transitionInfo.transitionType,
                    duration: transitionInfo.duration,
                    reverseDuration: transitionInfo.duration,
                    alignment: transitionInfo.alignment,
                    child: child,
                  ).buildTransitions(
                    context,
                    animation,
                    secondaryAnimation,
                    child,
                  ),
                )
              : MaterialPage(key: state.pageKey, child: child);
        },
        routes: routes,
      );
}

class TransitionInfo {
  const TransitionInfo({
    required this.hasTransition,
    this.transitionType = PageTransitionType.fade,
    this.duration = const Duration(milliseconds: 300),
    this.alignment,
  });

  final bool hasTransition;
  final PageTransitionType transitionType;
  final Duration duration;
  final Alignment? alignment;

  static TransitionInfo appDefault() => TransitionInfo(hasTransition: false);
}

class RootPageContext {
  const RootPageContext(this.isRootPage, [this.errorRoute]);
  final bool isRootPage;
  final String? errorRoute;

  static bool isInactiveRootPage(BuildContext context) {
    final rootPageContext = context.read<RootPageContext?>();
    final isRootPage = rootPageContext?.isRootPage ?? false;
    final location = GoRouterState.of(context).uri.toString();
    return isRootPage &&
        location != '/' &&
        location != rootPageContext?.errorRoute;
  }

  static Widget wrap(Widget child, {String? errorRoute}) => Provider.value(
        value: RootPageContext(true, errorRoute),
        child: child,
      );
}

extension GoRouterLocationExtension on GoRouter {
  String getCurrentLocation() {
    final RouteMatch lastMatch = routerDelegate.currentConfiguration.last;
    final RouteMatchList matchList = lastMatch is ImperativeRouteMatch
        ? lastMatch.matches
        : routerDelegate.currentConfiguration;
    return matchList.uri.toString();
  }
}
