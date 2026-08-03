/// Main orchestrator for the Gemma agent system.
/// Handles the full flow from user input to response with commands.

import 'package:flutter/material.dart';
import '/auth/supabase_auth/auth_util.dart';
import '/backend/schema/structs/index.dart';
import '/backend/sqlite/sqlite_manager.dart';
import '/backend/supabase/supabase.dart';
import '/app_core/app_util.dart';
import '/services/gemma_service.dart';
import '/services/embedding/chunk_retriever.dart';
import 'command_parser.dart';
import 'command_executor.dart';
import 'command_registry.dart';
import 'navigation_executor.dart';
import 'action_executor.dart';
import 'agent_prompts.dart';

/// Response from the agent
class AgentResponse {
  const AgentResponse({
    required this.textResponse,
    this.navigationIntent,
    this.actionIntent,
    this.executedCommands = const [],
    this.requiresFollowUp = false,
    this.error,
  });

  /// The text to display to the user
  final String textResponse;

  /// Navigation to perform (if any)
  final NavigationIntent? navigationIntent;

  /// Action to perform (if any)
  final ActionIntent? actionIntent;

  /// Commands that were executed
  final List<String> executedCommands;

  /// Whether we need another round with Gemma
  final bool requiresFollowUp;

  /// Error message if something went wrong
  final String? error;

  bool get hasNavigation => navigationIntent != null;
  bool get hasAction => actionIntent != null;
  bool get hasError => error != null;
}

/// Chat message for history
class AgentChatMessage {
  const AgentChatMessage({
    required this.role,
    required this.content,
    this.timestamp,
  });

  final String role; // 'user' or 'assistant'
  final String content;
  final DateTime? timestamp;
}

class GemmaAgentService {
  // Singleton instance
  static final GemmaAgentService instance = GemmaAgentService._();
  GemmaAgentService._();

  final CommandParser _parser = CommandParser();
  final CommandExecutor _executor = CommandExecutor();
  final NavigationExecutor _navigator = NavigationExecutor();
  final ActionExecutor _actionExecutor = ActionExecutor();

  // Conversation history (limited to last N messages)
  final List<AgentChatMessage> _history = [];
  static const int _maxHistoryLength = 10;

  // Cache for family members
  List<FamilyMemberStruct>? _familyMembersCache;
  DateTime? _cacheTime;
  static const Duration _cacheDuration = Duration(minutes: 5);

  /// Process a user message and return an agent response
  /// [currentMemberId] is the ID of the family member who is chatting
  /// [currentMemberName] is the name of the family member (for display)
  Future<AgentResponse> processMessage({
    required String userMessage,
    required BuildContext context,
    String? currentMemberId,
    String? currentMemberName,
  }) async {
    // Check if Gemma is loaded
    if (!GemmaService.instance.isModelLoaded) {
      return const AgentResponse(
        textResponse: "I'm not ready yet. Please wait for me to load.",
        error: 'Gemma model not loaded',
      );
    }

    // Add user message to history
    _addToHistory('user', userMessage);

    try {
      // Detect language hint from user message
      final languageHint = _detectLanguage(userMessage);

      // Load family members (cached)
      final familyMembers = await _getFamilyMembers();

      // RAG: embed the user's turn and pull the top-K most relevant chunks
      // from this member's uploaded documents. Empty list if the member has
      // no docs or the embedder is offline — the prompt just skips the
      // passages block in that case.
      List<RetrievedChunk> retrievedChunks = const [];
      if (currentMemberId != null && currentMemberId.isNotEmpty) {
        debugPrint('[Agent] RAG lookup for memberId=$currentMemberId '
            'query="${userMessage.length > 60 ? "${userMessage.substring(0, 60)}…" : userMessage}"');
        retrievedChunks = await ChunkRetriever.instance.retrieveTopK(
          familyMemberId: currentMemberId,
          userQuery: userMessage,
        );
        debugPrint('[Agent] RAG returned ${retrievedChunks.length} chunks');
      } else {
        debugPrint('[Agent] RAG skipped — currentMemberId is null/empty '
            '(chat not scoped to a member)');
      }

      // Build a minimal prompt for small models
      final systemPrompt = AgentPrompts.buildSystemPrompt(
        languageHint: languageHint,
        currentMemberName: currentMemberName,
        retrievedChunks: retrievedChunks,
      );

      // Keep prompt short - just system + last message
      final fullPrompt = '''$systemPrompt
User: $userMessage
Assistant:''';

      // Get response from Gemma
      final gemmaResponse = await GemmaService.instance.generateResponse(fullPrompt);
      debugPrint('Gemma raw response: $gemmaResponse');

      if (gemmaResponse.isEmpty) {
        return const AgentResponse(
          textResponse: "I couldn't think of a response. Please try again.",
          error: 'Empty response from Gemma model',
        );
      }

      // Check for model errors (LiteRT tensor buffer errors, etc.)
      if (gemmaResponse.startsWith('[ERROR:')) {
        debugPrint('Gemma returned an error - attempting recovery');
        // Try to reset the model state
        await GemmaService.instance.resetModel();
        return AgentResponse(
          textResponse: "I had a temporary issue. Please try asking again.",
          error: gemmaResponse,
        );
      }

      // Parse the response for commands
      final parseResult = _parser.parse(gemmaResponse);
      debugPrint('Parsed commands: ${parseResult.commands.map((c) => c.name).toList()}');
      debugPrint('Display text: ${parseResult.displayText}');

      // Check if the response is a question - if so, don't execute navigation/actions
      // Small models often include commands even when asking questions
      final isQuestion = _isResponseQuestion(parseResult.displayText);
      debugPrint('Is question: $isQuestion');

      // If no commands, just return the response
      if (!parseResult.hasCommands) {
        _addToHistory('assistant', parseResult.displayText);
        return AgentResponse(
          textResponse: parseResult.displayText,
        );
      }

      // Process commands
      NavigationIntent? navIntent;
      ActionIntent? actionIntent;
      final executedCommands = <String>[];
      final dataResults = <String>[];

      for (final command in parseResult.commands) {
        final commandDef = CommandRegistry.getCommand(command.name);
        if (commandDef == null) continue;

        switch (commandDef.type) {
          case CommandType.dataQuery:
            // Data queries are always executed
            executedCommands.add(command.name);
            final result = await _executor.execute(
              command,
              currentMemberId: currentMemberId,
            );
            if (result.success && result.formattedData != null) {
              dataResults.add(result.formattedData!);
            } else if (!result.success && result.errorMessage != null) {
              dataResults.add('Error: ${result.errorMessage}');
            }
            break;

          case CommandType.navigation:
            // DON'T navigate if Gemma is asking a question
            if (!isQuestion) {
              executedCommands.add(command.name);
              navIntent ??= await _navigator.execute(command, familyMembers);
            } else {
              debugPrint('Skipping navigation command because response is a question');
            }
            break;

          case CommandType.action:
            // DON'T perform actions if Gemma is asking a question
            if (!isQuestion) {
              executedCommands.add(command.name);
              final result = await _actionExecutor.execute(command, familyMembers);
              if (result.success && result.action != null) {
                actionIntent ??= result.action;
              } else if (!result.success && result.errorMessage != null) {
                dataResults.add('Error: ${result.errorMessage}');
              }
            } else {
              debugPrint('Skipping action command because response is a question');
            }
            break;
        }
      }

      // If we got data, send it back to Gemma for a natural response
      String finalResponse = parseResult.displayText;
      if (dataResults.isNotEmpty) {
        final dataContext = dataResults.join('\n\n');
        final followUpPrompt = AgentPrompts.buildDataResponsePrompt(
          dataContext,
          userMessage,
        );

        final followUpResponse = await GemmaService.instance.generateResponse(
          '$systemPrompt\n\n$followUpPrompt',
        );

        // Parse follow-up for any additional commands
        final followUpParse = _parser.parse(followUpResponse);

        // Process any navigation/action commands from follow-up
        for (final command in followUpParse.commands) {
          final commandDef = CommandRegistry.getCommand(command.name);
          if (commandDef == null) continue;

          if (commandDef.type == CommandType.navigation && navIntent == null) {
            navIntent = await _navigator.execute(command, familyMembers);
          } else if (commandDef.type == CommandType.action && actionIntent == null) {
            final result = await _actionExecutor.execute(command, familyMembers);
            if (result.success && result.action != null) {
              actionIntent = result.action;
            }
          }
        }

        finalResponse = followUpParse.displayText;
      }

      // Add assistant response to history
      _addToHistory('assistant', finalResponse);

      return AgentResponse(
        textResponse: finalResponse,
        navigationIntent: navIntent,
        actionIntent: actionIntent,
        executedCommands: executedCommands,
      );
    } catch (e) {
      debugPrint('Agent error: $e');
      return AgentResponse(
        textResponse: "I'm sorry, I encountered an error. Please try again.",
        error: e.toString(),
      );
    }
  }

  /// Clear conversation history
  void clearHistory() {
    _history.clear();
  }

  /// Clear cache
  void clearCache() {
    _familyMembersCache = null;
    _cacheTime = null;
  }

  // ═══════════════════════════════════════════════════════════════
  // PRIVATE HELPERS
  // ═══════════════════════════════════════════════════════════════

  /// Check if the response is a question - used to prevent auto-navigation
  /// when Gemma asks "Would you like to...?" type questions
  bool _isResponseQuestion(String text) {
    final trimmed = text.trim();

    // Check if ends with question mark (handles multiple languages)
    if (trimmed.endsWith('?')) return true;

    // Hebrew question mark
    if (trimmed.endsWith('׃')) return true;

    // Check for common question phrases (case insensitive)
    final lower = trimmed.toLowerCase();
    final questionPhrases = [
      'would you like',
      'do you want',
      'shall i',
      'should i',
      'can i help',
      'may i',
      'האם תרצה',  // Hebrew: would you like
      'האם אתה רוצה',  // Hebrew: do you want
      'רוצה ש',  // Hebrew: want me to
    ];

    for (final phrase in questionPhrases) {
      if (lower.contains(phrase)) return true;
    }

    return false;
  }

  void _addToHistory(String role, String content) {
    _history.add(AgentChatMessage(
      role: role,
      content: content,
      timestamp: DateTime.now(),
    ));

    // Trim history if too long
    while (_history.length > _maxHistoryLength) {
      _history.removeAt(0);
    }
  }

  String _buildConversationContext() {
    if (_history.isEmpty) return '(No previous messages)';

    return _history
        .map((m) => '${m.role.toUpperCase()}: ${m.content}')
        .join('\n');
  }

  String? _detectLanguage(String text) {
    // Simple language detection based on character ranges
    final hebrewPattern = RegExp(r'[\u0590-\u05FF]');

    if (hebrewPattern.hasMatch(text)) return 'he';

    // Check for Indonesian/Malay keywords
    final idKeywords = ['saya', 'anda', 'bagaimana', 'tolong', 'terima kasih'];
    final msKeywords = ['saya', 'awak', 'macam mana', 'tolong', 'terima kasih'];

    final lowerText = text.toLowerCase();
    for (final keyword in idKeywords) {
      if (lowerText.contains(keyword)) return 'id';
    }
    for (final keyword in msKeywords) {
      if (lowerText.contains(keyword)) return 'ms';
    }

    return 'en'; // Default to English
  }

  Future<List<FamilyMemberStruct>> _getFamilyMembers() async {
    // Check cache
    if (_familyMembersCache != null &&
        _cacheTime != null &&
        DateTime.now().difference(_cacheTime!) < _cacheDuration) {
      return _familyMembersCache!;
    }

    // Use cached family members from AppState if available
    final cachedMembers = AppState().UserSession.family;
    if (cachedMembers.isNotEmpty) {
      _familyMembersCache = cachedMembers;
      _cacheTime = DateTime.now();
      return _familyMembersCache!;
    }

    // Load from database
    final isLocal = AppState().UserSession.isLocalSession;

    if (isLocal) {
      final accountId = AppState().UserSession.userID;
      final rows = await SQLiteManager.instance.getFamilyMembersByAccountId(
        accountId: accountId,
      );

      _familyMembersCache = rows.map((r) => FamilyMemberStruct(
        id: r.id,
        name: r.name ?? '',
        score: 0, // Score not stored in SQLite
        lastChecked: r.lastChecked != null
            ? DateTime.fromMillisecondsSinceEpoch(r.lastChecked!)
            : null,
        birthday: r.birthday != null
            ? DateTime.fromMillisecondsSinceEpoch(r.birthday!)
            : null,
        admin: r.relationship == 'ME',
      )).toList();
    } else {
      final rows = await FamilyMembersTable().queryRows(
        queryFn: (q) => q.eq('account_id', currentUserUid).order('name'),
      );

      _familyMembersCache = rows.map((r) => FamilyMemberStruct(
        id: r.id,
        name: r.name ?? '',
        score: r.score?.toDouble() ?? 0,
        lastChecked: r.lastChecked,
        birthday: r.birthday,
        admin: r.admin ?? false,
      )).toList();
    }

    _cacheTime = DateTime.now();
    return _familyMembersCache!;
  }
}
