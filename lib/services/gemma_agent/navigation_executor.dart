/// Executes navigation commands to take users to different pages.

import 'package:flutter/material.dart';
import '/app_core/app_util.dart';
import '/backend/schema/structs/index.dart';
import '/index.dart';
import 'command_parser.dart';
import 'member_name_resolver.dart';

/// Result of a navigation command
class NavigationResult {
  const NavigationResult({
    required this.success,
    this.destination,
    this.errorMessage,
  });

  final bool success;
  final String? destination;
  final String? errorMessage;

  factory NavigationResult.success(String destination) {
    return NavigationResult(
      success: true,
      destination: destination,
    );
  }

  factory NavigationResult.failure(String message) {
    return NavigationResult(
      success: false,
      errorMessage: message,
    );
  }
}

class NavigationExecutor {
  final MemberNameResolver _resolver = MemberNameResolver();

  /// Execute a navigation command
  /// Returns the result but doesn't actually navigate - that's done by the caller
  Future<NavigationIntent?> execute(
    ParsedCommand command,
    List<FamilyMemberStruct> familyMembers,
  ) async {
    switch (command.name) {
      case 'NAV_HOME':
        return NavigationIntent(
          routeName: MainHomeWidget.routeName,
          description: 'Home',
        );

      case 'NAV_FAMILY':
        return NavigationIntent(
          routeName: FamilyWidget.routeName,
          description: 'Family',
        );

      case 'NAV_MEMBER_DETAIL':
        final memberName = command.params['member_name'] ?? '';
        if (memberName.isEmpty) {
          return null;
        }

        final member = _resolver.resolve(memberName, familyMembers);
        if (member == null) {
          return null;
        }

        return NavigationIntent(
          routeName: MemberDetailWidget.routeName,
          description: "${member.name}'s Profile",
          extra: {'member': member},
        );

      case 'NAV_SCAN_HISTORY':
        return NavigationIntent(
          routeName: MainDiagnoseWidget.routeName,
          description: 'Scan History',
        );

      case 'NAV_SESSION_DETAIL':
        final sessionId = command.params['session_id'] ?? '';
        if (sessionId.isEmpty) {
          return null;
        }

        return NavigationIntent(
          routeName: SessionDetailsPageWidget.routeName,
          description: 'Scan Details',
          queryParameters: {'sessionId': sessionId},
        );

      case 'NAV_SETTINGS':
        return NavigationIntent(
          routeName: MainProfilePageWidget.routeName,
          description: 'Settings',
        );

      case 'NAV_ACCESSIBILITY':
        return NavigationIntent(
          routeName: AccessibilityWidget.routeName,
          description: 'Accessibility Settings',
        );

      default:
        return null;
    }
  }

  /// Perform the actual navigation
  static void navigate(BuildContext context, NavigationIntent intent) {
    if (intent.extra != null) {
      context.pushNamed(
        intent.routeName,
        extra: {
          ...intent.extra!,
          kTransitionInfoKey: const TransitionInfo(
            hasTransition: true,
            transitionType: PageTransitionType.fade,
            duration: Duration(milliseconds: 200),
          ),
        },
      );
    } else if (intent.queryParameters != null) {
      context.pushNamed(
        intent.routeName,
        queryParameters: intent.queryParameters!,
      );
    } else {
      context.pushNamed(intent.routeName);
    }
  }
}

/// Describes a navigation action
class NavigationIntent {
  const NavigationIntent({
    required this.routeName,
    required this.description,
    this.queryParameters,
    this.extra,
    this.replace = false,
  });

  final String routeName;
  final String description;
  final Map<String, String>? queryParameters;
  final Map<String, dynamic>? extra;
  final bool replace;
}
