/// Executes action commands like starting scans, adding members, etc.

import 'package:flutter/material.dart';
import '/app_core/app_util.dart';
import '/backend/schema/structs/index.dart';
import '/index.dart';
import 'command_parser.dart';
import 'member_name_resolver.dart';

/// Result of an action command
class ActionResult {
  const ActionResult({
    required this.success,
    this.message,
    this.action,
    this.errorMessage,
  });

  final bool success;
  final String? message;
  final ActionIntent? action;
  final String? errorMessage;

  factory ActionResult.success({
    required String message,
    ActionIntent? action,
  }) {
    return ActionResult(
      success: true,
      message: message,
      action: action,
    );
  }

  factory ActionResult.failure(String message) {
    return ActionResult(
      success: false,
      errorMessage: message,
    );
  }

  factory ActionResult.memberNotFound(String memberName, List<String> available) {
    return ActionResult(
      success: false,
      errorMessage: 'Could not find family member "$memberName". Available members: ${available.join(', ')}',
    );
  }
}

/// Types of actions that can be executed
enum ActionType {
  startScan,
  startScanSelect,
  addFamilyMember,
  shareScan,
}

/// Describes an action to be performed
class ActionIntent {
  const ActionIntent({
    required this.type,
    this.member,
    this.sessionId,
  });

  final ActionType type;
  final FamilyMemberStruct? member;
  final String? sessionId;
}

class ActionExecutor {
  final MemberNameResolver _resolver = MemberNameResolver();

  /// Execute an action command
  Future<ActionResult> execute(
    ParsedCommand command,
    List<FamilyMemberStruct> familyMembers,
  ) async {
    switch (command.name) {
      case 'START_SCAN':
        return await _startScan(command.params['member_name'] ?? '', familyMembers);

      case 'START_SCAN_SELECT':
        return ActionResult.success(
          message: 'Opening scan page',
          action: const ActionIntent(type: ActionType.startScanSelect),
        );

      case 'ADD_FAMILY_MEMBER':
        return ActionResult.success(
          message: 'Opening add family member',
          action: const ActionIntent(type: ActionType.addFamilyMember),
        );

      default:
        return ActionResult.failure('Unknown action: ${command.name}');
    }
  }

  Future<ActionResult> _startScan(
    String memberName,
    List<FamilyMemberStruct> familyMembers,
  ) async {
    if (memberName.isEmpty) {
      return ActionResult.failure('Please specify which family member to scan');
    }

    final member = _resolver.resolve(memberName, familyMembers);

    if (member == null) {
      return ActionResult.memberNotFound(
        memberName,
        familyMembers.map((m) => m.name).toList(),
      );
    }

    return ActionResult.success(
      message: 'Starting scan for ${member.name}',
      action: ActionIntent(
        type: ActionType.startScan,
        member: member,
      ),
    );
  }

  /// Perform the action (navigate to appropriate page)
  static void performAction(BuildContext context, ActionIntent action) {
    switch (action.type) {
      case ActionType.startScan:
        if (action.member != null) {
          context.pushNamed(
            MainDIagnosticsWidget.routeName,
            queryParameters: {
              'preselectedMemberId': action.member!.id,
              'preselectedMemberName': action.member!.name,
            },
          );
        }
        break;

      case ActionType.startScanSelect:
        context.pushNamed(MainDIagnosticsWidget.routeName);
        break;

      case ActionType.addFamilyMember:
        // Navigate to family page which has add member functionality
        context.pushNamed(FamilyWidget.routeName);
        break;

      case ActionType.shareScan:
        // TODO: Implement share functionality
        break;
    }
  }
}
