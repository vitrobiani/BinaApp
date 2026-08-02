import 'dart:async';

import 'package:provider/provider.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

import 'auth/supabase_auth/supabase_user_provider.dart';
import 'auth/supabase_auth/auth_util.dart';

import '/backend/supabase/supabase.dart';
import '/services/gemma_service.dart';
import '/services/accessibility_settings_service.dart';
import '/backend/sqlite/sqlite_manager.dart';
import '/app_core/app_theme.dart';
import '/bina_design/bina_design_tokens.dart';
import 'app_core/app_util.dart';
import 'app_core/internationalization.dart';
import 'index.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GoRouter.optionURLReflectsImperativeAPIs = true;
  usePathUrlStrategy();

  // Configure status bar to be transparent with dark icons (for light theme)
  // This ensures status bar icons are visible on all devices including tablets
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark, // Dark icons for light background
    statusBarBrightness: Brightness.light, // iOS: light status bar
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.dark,
  ));

  // Enable edge-to-edge mode for modern UI
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  await SupaFlow.initialize();

  await SQLiteManager.initialize();
  await AppTheme.initialize();
  await AppLocalizations.initialize();
  await AccessibilitySettingsService.instance.init();

  // Sync contrast level from settings to design tokens
  BinaColors.setContrastLevel(AccessibilitySettingsService.instance.contrastLevel);

  // Start loading Gemma model in background (don't block app startup)
  // For large models like Gemma 4, this downloads from HuggingFace
  // Users can use the app while it downloads
  GemmaService.instance.init().catchError((e) {
    debugPrint('GemmaService background init error: $e');
  });

  final appState = AppState(); // Initialize AppState
  await appState.initializePersistedState();

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => appState),
      ChangeNotifierProvider.value(value: AccessibilitySettingsService.instance),
    ],
    child: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  State<MyApp> createState() => _MyAppState();

  static _MyAppState of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>()!;
}

class MyAppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  Locale? _locale = AppLocalizations.getStoredLocale();

  ThemeMode _themeMode = AppTheme.themeMode;

  late AppStateNotifier _appStateNotifier;
  late GoRouter _router;

  // Auto-disconnect from the Bina camera after the app has been backgrounded
  // for this long. Prevents the camera from staying paired to a phone that's
  // no longer using it. Note: Android/iOS may suspend Dart timers when the
  // app is fully backgrounded, so this is best-effort — on `detached` we
  // also disconnect immediately as a hard fallback.
  static const Duration _cameraIdleDisconnectAfter = Duration(seconds: 60);
  Timer? _cameraDisconnectTimer;
  String getRoute([RouteMatch? routeMatch]) {
    final RouteMatch lastMatch =
        routeMatch ?? _router.routerDelegate.currentConfiguration.last;
    final RouteMatchList matchList = lastMatch is ImperativeRouteMatch
        ? lastMatch.matches
        : _router.routerDelegate.currentConfiguration;
    return matchList.uri.toString();
  }

  List<String> getRouteStack() =>
      _router.routerDelegate.currentConfiguration.matches
          .map((e) => getRoute(e))
          .toList();
  late Stream<BaseAuthUser> userStream;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _appStateNotifier = AppStateNotifier.instance;
    _router = createRouter(_appStateNotifier);
    userStream = binaSystemSupabaseUserStream()
      ..listen((user) {
        _appStateNotifier.update(user);
      });
    jwtTokenStream.listen((_) {});
    Future.delayed(
      Duration(milliseconds: 1000),
      () => _appStateNotifier.stopShowingSplashImage(),
    );
  }

  @override
  void dispose() {
    _cameraDisconnectTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.paused:
        _armCameraDisconnectTimer();
        break;
      case AppLifecycleState.resumed:
        _cameraDisconnectTimer?.cancel();
        _cameraDisconnectTimer = null;
        break;
      case AppLifecycleState.detached:
        _cameraDisconnectTimer?.cancel();
        _cameraDisconnectTimer = null;
        // Fire-and-forget: the app is dying, we just want to release the
        // Wi-Fi Direct group on the way out.
        unawaited(AppState().disconnectCamera());
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
        // Transient (control center, incoming call preview) — don't act.
        break;
    }
  }

  void _armCameraDisconnectTimer() {
    if (!AppState().cameraConnection.isCameraConnected()) return;
    _cameraDisconnectTimer?.cancel();
    _cameraDisconnectTimer = Timer(_cameraIdleDisconnectAfter, () async {
      if (AppState().cameraConnection.isCameraConnected()) {
        debugPrint(
            '[Lifecycle] auto-disconnecting camera after ${_cameraIdleDisconnectAfter.inSeconds}s in background');
        await AppState().disconnectCamera();
      }
    });
  }

  void setLocale(String language) {
    safeSetState(() => _locale = createLocale(language));
  }

  void setThemeMode(ThemeMode mode) => safeSetState(() {
        _themeMode = mode;
        AppTheme.saveThemeMode(mode);
      });

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'BinaSystem',
      scrollBehavior: MyAppScrollBehavior(),
      localizationsDelegates: [
        AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        FallbackMaterialLocalizationDelegate(),
        FallbackCupertinoLocalizationDelegate(),
      ],
      locale: _locale,
      supportedLocales: const [
        Locale('en'),
        Locale('he'),
        Locale('id'),
        Locale('ms'),
      ],
      theme: ThemeData(
        brightness: Brightness.light,
        useMaterial3: false,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: false,
      ),
      themeMode: _themeMode,
      routerConfig: _router,
    );
  }
}

class NavBarPage extends StatefulWidget {
  NavBarPage({
    Key? key,
    this.initialPage,
    this.page,
    this.disableResizeToAvoidBottomInset = false,
  }) : super(key: key);

  final String? initialPage;
  final Widget? page;
  final bool disableResizeToAvoidBottomInset;

  @override
  _NavBarPageState createState() => _NavBarPageState();
}

/// This is the private State class that goes with NavBarPage.
class _NavBarPageState extends State<NavBarPage> {
  String _currentPageName = 'Main_Home';
  late Widget? _currentPage;

  @override
  void initState() {
    super.initState();
    _currentPageName = widget.initialPage ?? _currentPageName;
    _currentPage = widget.page;
  }

  @override
  Widget build(BuildContext context) {
    final tabs = {
      'Main_Home': MainHomeWidget(),
      'Main_DIagnostics': MainDIagnosticsWidget(),
      'Main_Diagnose': MainDiagnoseWidget(),
      'Main_profilePage': MainProfilePageWidget(),
    };
    final currentIndex = tabs.keys.toList().indexOf(_currentPageName);

    return Scaffold(
      resizeToAvoidBottomInset: !widget.disableResizeToAvoidBottomInset,
      body: _currentPage ?? tabs[_currentPageName],
      bottomNavigationBar: Visibility(
        visible: responsiveVisibility(
          context: context,
          tabletLandscape: false,
          desktop: false,
        ),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (i) => safeSetState(() {
            _currentPage = null;
            _currentPageName = tabs.keys.toList()[i];
          }),
          backgroundColor: AppTheme.of(context).secondaryBackground,
          selectedItemColor: AppTheme.of(context).primary,
          unselectedItemColor: AppTheme.of(context).secondaryText,
          showSelectedLabels: true,
          showUnselectedLabels: false,
          type: BottomNavigationBarType.fixed,
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(
                Icons.home_outlined,
                size: 24.0,
              ),
              activeIcon: Icon(
                Icons.home,
                size: 32.0,
              ),
              label: AppLocalizations.of(context).getText(
                'xdxbdj20' /* __ */,
              ),
              tooltip: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.remove_red_eye_outlined,
                size: 24.0,
              ),
              activeIcon: Icon(
                Icons.remove_red_eye,
                size: 32.0,
              ),
              label: AppLocalizations.of(context).getText(
                '3ourv2w9' /* __ */,
              ),
              tooltip: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.camera_alt_outlined,
                size: 24.0,
              ),
              activeIcon: Icon(
                Icons.camera_alt,
                size: 32.0,
              ),
              label: AppLocalizations.of(context).getText(
                'j08eiorc' /* __ */,
              ),
              tooltip: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.account_circle_outlined,
                size: 24.0,
              ),
              activeIcon: Icon(
                Icons.account_circle,
                size: 32.0,
              ),
              label: AppLocalizations.of(context).getText(
                'o3dp9tss' /* __ */,
              ),
              tooltip: '',
            )
          ],
        ),
      ),
    );
  }
}
