/// Parses Gemma's output to extract commands and display text.
/// Commands follow the format: [CMD:COMMAND_NAME|param1:value1|param2:value2]

class ParsedCommand {
  const ParsedCommand({
    required this.name,
    required this.params,
    required this.rawMatch,
  });

  final String name;
  final Map<String, String> params;
  final String rawMatch;

  @override
  String toString() => 'ParsedCommand($name, $params)';
}

class ParseResult {
  const ParseResult({
    required this.displayText,
    required this.commands,
  });

  final String displayText;
  final List<ParsedCommand> commands;

  bool get hasCommands => commands.isNotEmpty;

  @override
  String toString() => 'ParseResult(commands: ${commands.length}, text: "${displayText.substring(0, displayText.length.clamp(0, 50))}...")';
}

class CommandParser {
  // Regex patterns for commands - support multiple formats:
  // Format 1: [CMD:COMMAND_NAME|param1:value1]
  // Format 2: [COMMAND_NAME|param1:value1]
  // Format 3: [COMMAND_NAME]
  static final _commandPatternWithPrefix = RegExp(
    r'\[CMD:([A-Z_]+)(?:\|([^\]]+))?\]',
    multiLine: true,
  );

  static final _commandPatternSimple = RegExp(
    r'\[([A-Z][A-Z_]+)(?:\|([^\]]+))?\]',
    multiLine: true,
  );

  // Valid command names to avoid matching random bracketed text
  static final Set<String> _validCommands = {
    // Self (current member) commands
    'GET_MY_SCANS', 'GET_MY_STATS', 'COUNT_MY_SCANS',
    'EXPLAIN_MY_LAST_SCAN', 'SEARCH_MY_DIAGNOSES',
    // Family member commands
    'GET_FAMILY_MEMBERS', 'GET_MEMBER_DETAILS', 'GET_MEMBER_SCANS',
    'GET_SCAN_DETAILS', 'SEARCH_DIAGNOSES', 'GET_FAMILY_STATS',
    // Navigation
    'NAV_HOME', 'NAV_FAMILY', 'NAV_MEMBER_DETAIL', 'NAV_SCAN_HISTORY',
    'NAV_SESSION_DETAIL', 'NAV_SETTINGS', 'NAV_ACCESSIBILITY',
    // Actions
    'START_SCAN', 'START_SCAN_SELECT', 'ADD_FAMILY_MEMBER',
  };

  /// Parse Gemma's output to extract commands and clean display text
  ParseResult parse(String gemmaOutput) {
    final commands = <ParsedCommand>[];
    String cleanText = gemmaOutput;
    final processedMatches = <String>{};

    // First try the format with CMD: prefix
    for (final match in _commandPatternWithPrefix.allMatches(gemmaOutput)) {
      final commandName = match.group(1)!;
      if (!_validCommands.contains(commandName)) continue;

      final paramsString = match.group(2);
      final params = _parseParams(paramsString);
      final rawMatch = match.group(0)!;

      if (!processedMatches.contains(rawMatch)) {
        processedMatches.add(rawMatch);
        commands.add(ParsedCommand(
          name: commandName,
          params: params,
          rawMatch: rawMatch,
        ));
        cleanText = cleanText.replaceAll(rawMatch, '');
      }
    }

    // Then try the simple format without CMD: prefix
    for (final match in _commandPatternSimple.allMatches(gemmaOutput)) {
      final commandName = match.group(1)!;
      if (!_validCommands.contains(commandName)) continue;

      final paramsString = match.group(2);
      final params = _parseParams(paramsString);
      final rawMatch = match.group(0)!;

      if (!processedMatches.contains(rawMatch)) {
        processedMatches.add(rawMatch);
        commands.add(ParsedCommand(
          name: commandName,
          params: params,
          rawMatch: rawMatch,
        ));
        cleanText = cleanText.replaceAll(rawMatch, '');
      }
    }

    // Clean up extra whitespace and newlines
    cleanText = cleanText
        .replaceAll(RegExp(r'\n{3,}'), '\n\n')
        .trim();

    return ParseResult(
      displayText: cleanText,
      commands: commands,
    );
  }

  /// Parse parameter string into a map
  /// Format: "param1:value1|param2:value2"
  Map<String, String> _parseParams(String? paramsString) {
    if (paramsString == null || paramsString.isEmpty) {
      return {};
    }

    final params = <String, String>{};
    for (final param in paramsString.split('|')) {
      final colonIndex = param.indexOf(':');
      if (colonIndex > 0) {
        final key = param.substring(0, colonIndex).trim();
        final value = param.substring(colonIndex + 1).trim();
        params[key] = value;
      }
    }
    return params;
  }

  /// Check if text contains any commands
  bool containsCommands(String text) {
    // Check both patterns
    for (final match in _commandPatternWithPrefix.allMatches(text)) {
      if (_validCommands.contains(match.group(1))) return true;
    }
    for (final match in _commandPatternSimple.allMatches(text)) {
      if (_validCommands.contains(match.group(1))) return true;
    }
    return false;
  }

  /// Extract just the command names from text (for quick checking)
  List<String> extractCommandNames(String text) {
    final names = <String>[];
    for (final match in _commandPatternWithPrefix.allMatches(text)) {
      final name = match.group(1)!;
      if (_validCommands.contains(name)) names.add(name);
    }
    for (final match in _commandPatternSimple.allMatches(text)) {
      final name = match.group(1)!;
      if (_validCommands.contains(name) && !names.contains(name)) {
        names.add(name);
      }
    }
    return names;
  }
}
