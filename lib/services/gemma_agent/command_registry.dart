/// Defines all available commands that Gemma can execute.
/// Each command has a name, description, parameters, and type.

enum CommandType {
  dataQuery,
  navigation,
  action,
}

class CommandDefinition {
  const CommandDefinition({
    required this.name,
    required this.description,
    required this.type,
    this.parameters = const [],
    this.examples = const [],
  });

  final String name;
  final String description;
  final CommandType type;
  final List<CommandParameter> parameters;
  final List<String> examples;
}

class CommandParameter {
  const CommandParameter({
    required this.name,
    required this.description,
    this.required = false,
    this.defaultValue,
  });

  final String name;
  final String description;
  final bool required;
  final String? defaultValue;
}

/// Registry of all available commands
class CommandRegistry {
  static const List<CommandDefinition> commands = [
    // ═══════════════════════════════════════════════════════════════
    // SELF (CURRENT MEMBER) COMMANDS - use these when user says "my", "I", etc.
    // ═══════════════════════════════════════════════════════════════
    CommandDefinition(
      name: 'GET_MY_SCANS',
      description: 'Get scan history for the current user (the person chatting)',
      type: CommandType.dataQuery,
      parameters: [
        CommandParameter(
          name: 'limit',
          description: 'Maximum number of scans to return',
          required: false,
          defaultValue: '5',
        ),
      ],
      examples: ['Show my scans', 'תראה לי את הסריקות שלי', 'My scan history', 'What are my reports?'],
    ),
    CommandDefinition(
      name: 'GET_MY_STATS',
      description: 'Get dental health stats for the current user',
      type: CommandType.dataQuery,
      examples: ['How am I doing?', 'מה המצב שלי?', 'My dental health', 'Am I healthy?'],
    ),
    CommandDefinition(
      name: 'COUNT_MY_SCANS',
      description: 'Count how many scans the current user has',
      type: CommandType.dataQuery,
      examples: ['How many scans do I have?', 'כמה סריקות יש לי?', 'Number of my reports'],
    ),
    CommandDefinition(
      name: 'EXPLAIN_MY_LAST_SCAN',
      description: 'Explain the most recent scan for the current user',
      type: CommandType.dataQuery,
      examples: ['Explain my last scan', 'תסביר את הסריקה האחרונה שלי', 'What did my last scan show?'],
    ),
    CommandDefinition(
      name: 'SEARCH_MY_DIAGNOSES',
      description: 'Search for specific conditions in the current user\'s scans',
      type: CommandType.dataQuery,
      parameters: [
        CommandParameter(
          name: 'keyword',
          description: 'Condition to search for (cavity, plaque, healthy, etc.)',
          required: true,
        ),
      ],
      examples: ['Do I have cavities?', 'יש לי חורים?', 'Search my scans for plaque'],
    ),

    // ═══════════════════════════════════════════════════════════════
    // DATA QUERY COMMANDS (for querying other family members)
    // ═══════════════════════════════════════════════════════════════
    CommandDefinition(
      name: 'GET_FAMILY_MEMBERS',
      description: 'List all family members',
      type: CommandType.dataQuery,
      examples: ['Who is in my family?', 'מי במשפחה שלי?', 'Show my family members'],
    ),
    CommandDefinition(
      name: 'GET_MEMBER_DETAILS',
      description: 'Get detailed info about a specific family member',
      type: CommandType.dataQuery,
      parameters: [
        CommandParameter(
          name: 'member_name',
          description: 'Name of the family member (supports Hebrew, English, family terms like Mom/אמא)',
          required: true,
        ),
      ],
      examples: ['Tell me about Sarah', 'מה המצב של אמא?', 'How is Dad doing?'],
    ),
    CommandDefinition(
      name: 'GET_MEMBER_SCANS',
      description: 'Get scan history for a family member',
      type: CommandType.dataQuery,
      parameters: [
        CommandParameter(
          name: 'member_name',
          description: 'Name of the family member',
          required: true,
        ),
        CommandParameter(
          name: 'limit',
          description: 'Maximum number of scans to return',
          required: false,
          defaultValue: '5',
        ),
      ],
      examples: ['Show me Mom\'s scans', 'תראה לי את הסריקות של אבא', 'Sarah\'s scan history'],
    ),
    CommandDefinition(
      name: 'GET_SCAN_DETAILS',
      description: 'Get details of a specific scan session including diagnoses',
      type: CommandType.dataQuery,
      parameters: [
        CommandParameter(
          name: 'session_id',
          description: 'ID of the scan session',
          required: true,
        ),
      ],
      examples: ['Show me that scan', 'What did the last scan find?'],
    ),
    CommandDefinition(
      name: 'SEARCH_DIAGNOSES',
      description: 'Search for specific dental conditions across all scans',
      type: CommandType.dataQuery,
      parameters: [
        CommandParameter(
          name: 'keyword',
          description: 'Condition to search for (cavity, plaque, healthy, etc.)',
          required: true,
        ),
        CommandParameter(
          name: 'member_name',
          description: 'Optionally filter by family member',
          required: false,
        ),
      ],
      examples: ['Has anyone had cavities?', 'יש למישהו חורים?', 'Search for plaque'],
    ),
    CommandDefinition(
      name: 'GET_FAMILY_STATS',
      description: 'Get overall family dental health statistics',
      type: CommandType.dataQuery,
      examples: ['How is my family doing?', 'מה המצב הכללי?', 'Family health overview'],
    ),

    // ═══════════════════════════════════════════════════════════════
    // NAVIGATION COMMANDS
    // ═══════════════════════════════════════════════════════════════
    CommandDefinition(
      name: 'NAV_HOME',
      description: 'Navigate to home page',
      type: CommandType.navigation,
      examples: ['Take me home', 'קח אותי הביתה', 'Go to home'],
    ),
    CommandDefinition(
      name: 'NAV_FAMILY',
      description: 'Navigate to family page',
      type: CommandType.navigation,
      examples: ['Show my family', 'תראה את המשפחה', 'Open family page'],
    ),
    CommandDefinition(
      name: 'NAV_MEMBER_DETAIL',
      description: 'Navigate to a specific family member\'s profile',
      type: CommandType.navigation,
      parameters: [
        CommandParameter(
          name: 'member_name',
          description: 'Name of the family member',
          required: true,
        ),
      ],
      examples: ['Open Sarah\'s profile', 'פתח את הפרופיל של אמא', 'Go to Dad\'s page'],
    ),
    CommandDefinition(
      name: 'NAV_SCAN_HISTORY',
      description: 'Navigate to scan history page',
      type: CommandType.navigation,
      examples: ['Show scan history', 'היסטוריית סריקות', 'My past scans'],
    ),
    CommandDefinition(
      name: 'NAV_SESSION_DETAIL',
      description: 'Navigate to a specific scan session',
      type: CommandType.navigation,
      parameters: [
        CommandParameter(
          name: 'session_id',
          description: 'ID of the scan session',
          required: true,
        ),
      ],
      examples: ['Open that scan', 'Show me the details'],
    ),
    CommandDefinition(
      name: 'NAV_SETTINGS',
      description: 'Navigate to settings/profile page',
      type: CommandType.navigation,
      examples: ['Open settings', 'הגדרות', 'Go to profile'],
    ),
    CommandDefinition(
      name: 'NAV_ACCESSIBILITY',
      description: 'Navigate to accessibility settings',
      type: CommandType.navigation,
      examples: ['Accessibility settings', 'הגדרות נגישות', 'Change theme'],
    ),

    // ═══════════════════════════════════════════════════════════════
    // ACTION COMMANDS
    // ═══════════════════════════════════════════════════════════════
    CommandDefinition(
      name: 'START_SCAN',
      description: 'Start a scan session for a specific family member',
      type: CommandType.action,
      parameters: [
        CommandParameter(
          name: 'member_name',
          description: 'Name of the family member to scan',
          required: true,
        ),
      ],
      examples: ['Scan Sarah\'s teeth', 'תתחיל סריקה לאבא', 'Start scan for Mom'],
    ),
    CommandDefinition(
      name: 'START_SCAN_SELECT',
      description: 'Open scan page with member selector',
      type: CommandType.action,
      examples: ['I want to do a scan', 'אני רוצה לסרוק', 'Start a new scan'],
    ),
    CommandDefinition(
      name: 'ADD_FAMILY_MEMBER',
      description: 'Open the add family member flow',
      type: CommandType.action,
      examples: ['Add a family member', 'הוסף בן משפחה', 'Add someone new'],
    ),
  ];

  /// Get a command definition by name
  static CommandDefinition? getCommand(String name) {
    try {
      return commands.firstWhere((c) => c.name == name);
    } catch (_) {
      return null;
    }
  }

  /// Get all commands of a specific type
  static List<CommandDefinition> getCommandsByType(CommandType type) {
    return commands.where((c) => c.type == type).toList();
  }

  /// Generate command documentation for the system prompt
  static String generatePromptDocumentation() {
    final buffer = StringBuffer();

    buffer.writeln('DATA QUERIES:');
    for (final cmd in getCommandsByType(CommandType.dataQuery)) {
      buffer.write('- ${cmd.name}');
      if (cmd.parameters.isNotEmpty) {
        buffer.write('|${cmd.parameters.map((p) => '${p.name}:X').join('|')}');
      }
      buffer.writeln(' - ${cmd.description}');
    }

    buffer.writeln('\nNAVIGATION:');
    for (final cmd in getCommandsByType(CommandType.navigation)) {
      buffer.write('- ${cmd.name}');
      if (cmd.parameters.isNotEmpty) {
        buffer.write('|${cmd.parameters.map((p) => '${p.name}:X').join('|')}');
      }
      buffer.writeln(' - ${cmd.description}');
    }

    buffer.writeln('\nACTIONS:');
    for (final cmd in getCommandsByType(CommandType.action)) {
      buffer.write('- ${cmd.name}');
      if (cmd.parameters.isNotEmpty) {
        buffer.write('|${cmd.parameters.map((p) => '${p.name}:X').join('|')}');
      }
      buffer.writeln(' - ${cmd.description}');
    }

    return buffer.toString();
  }
}
