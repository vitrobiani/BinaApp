import '/app_core/app_util.dart';
import '/bina_design/bina_design.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'web_nav_model.dart';
export 'web_nav_model.dart';

/// Desktop/tablet sidebar navigation matching the Claude design.
/// Features: Logo, nav items, gradient "Scan now" button, help, theme dots.
class WebNavWidget extends StatefulWidget {
  const WebNavWidget({
    super.key,
    this.currentTab,
    // Legacy parameters (ignored - kept for compatibility)
    this.iconOne,
    this.iconTwo,
    this.iconThree,
    this.iconFour,
    this.colorBgOne,
    this.colorBgTwo,
    this.colorBgThree,
    this.colorBgFour,
    this.textOne,
    this.textTwo,
    this.textThree,
    this.textFour,
    this.iconFive,
    this.colorBgFive,
    this.textFive,
  });

  final BinaNavTab? currentTab;

  // Legacy parameters
  final Widget? iconOne;
  final Widget? iconTwo;
  final Widget? iconThree;
  final Widget? iconFour;
  final Color? colorBgOne;
  final Color? colorBgTwo;
  final Color? colorBgThree;
  final Color? colorBgFour;
  final Color? textOne;
  final Color? textTwo;
  final Color? textThree;
  final Color? textFour;
  final Widget? iconFive;
  final Color? colorBgFive;
  final Color? textFive;

  @override
  State<WebNavWidget> createState() => _WebNavWidgetState();
}

class _WebNavWidgetState extends State<WebNavWidget> {
  late WebNavModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => WebNavModel());
    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();
    super.dispose();
  }

  BinaSidebarTab get _currentSidebarTab {
    switch (widget.currentTab) {
      case BinaNavTab.home:
        return BinaSidebarTab.home;
      case BinaNavTab.family:
        return BinaSidebarTab.family;
      case BinaNavTab.scan:
        return BinaSidebarTab.scan;
      case BinaNavTab.chat:
        return BinaSidebarTab.chat;
      case BinaNavTab.profile:
        return BinaSidebarTab.profile;
      case BinaNavTab.none:
      case null:
        return BinaSidebarTab.none;
    }
  }

  void _handleTabChanged(BinaSidebarTab tab) {
    switch (tab) {
      case BinaSidebarTab.none:
        return; // Don't navigate for none tab
      case BinaSidebarTab.home:
        context.pushNamed(
          MainHomeWidget.routeName,
          extra: <String, dynamic>{
            kTransitionInfoKey: const TransitionInfo(
              hasTransition: true,
              transitionType: PageTransitionType.fade,
              duration: Duration.zero,
            ),
          },
        );
        break;
      case BinaSidebarTab.family:
        context.pushNamed(
          FamilyWidget.routeName,
          extra: <String, dynamic>{
            kTransitionInfoKey: const TransitionInfo(
              hasTransition: true,
              transitionType: PageTransitionType.fade,
              duration: Duration.zero,
            ),
          },
        );
        break;
      case BinaSidebarTab.scan:
        // Skip the diagnose page and go directly to the scan session flow
        context.pushNamed(
          MainDIagnosticsWidget.routeName,
          extra: <String, dynamic>{
            kTransitionInfoKey: const TransitionInfo(
              hasTransition: true,
              transitionType: PageTransitionType.fade,
              duration: Duration.zero,
            ),
          },
        );
        break;
      case BinaSidebarTab.chat:
        context.pushNamed(
          ChatHistoryWidget.routeName,
          extra: <String, dynamic>{
            kTransitionInfoKey: const TransitionInfo(
              hasTransition: true,
              transitionType: PageTransitionType.fade,
              duration: Duration.zero,
            ),
          },
        );
        break;
      case BinaSidebarTab.profile:
        context.pushNamed(
          MainProfilePageWidget.routeName,
          extra: <String, dynamic>{
            kTransitionInfoKey: const TransitionInfo(
              hasTransition: true,
              transitionType: PageTransitionType.fade,
              duration: Duration.zero,
            ),
          },
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BinaSidebar(
      currentTab: _currentSidebarTab,
      onTabChanged: _handleTabChanged,
      onHelpTap: () {
        context.pushNamed(HelpSupportWidget.routeName);
      },
    );
  }
}
