/// Static prompt templates for Gemma LLM interactions.
class LlmPrompts {
  LlmPrompts._();

  static const String chatbotSystemPrompt =
      'You are a dental health assistant. Answer dental questions concisely. '
      'You are not a dentist — recommend professional consultation when needed.';

  /// Build a prompt to interpret YOLO detections for a single image.
  static String buildImageInterpretationPrompt(String detectionsJson) {
    return 'You are a dental AI assistant. Analyze the following dental image '
        'detection results from a YOLO model and provide a brief, '
        'patient-friendly interpretation.\n\n'
        'Detection results (JSON):\n$detectionsJson\n\n'
        'For each issue found (non-tooth detections), explain what it means '
        'in simple terms. For teeth detected, summarize which teeth are visible. '
        'If no issues are found, reassure the user. '
        'Keep the response under 100 words.';
  }

  /// Build a prompt to generate a session summary.
  static String buildSessionSummaryPrompt({
    required String findingsJson,
    required int imageCount,
    required String memberName,
    required String overallStatus,
  }) {
    return 'You are a dental AI assistant. Generate a brief summary of a '
        'dental check-up session.\n\n'
        'Patient: $memberName\n'
        'Images analyzed: $imageCount\n'
        'Overall status: $overallStatus\n'
        'Aggregated findings:\n$findingsJson\n\n'
        'Provide a 2-3 sentence summary that:\n'
        '1. States the overall dental health status\n'
        '2. Highlights any issues found (if any)\n'
        '3. Gives a brief recommendation\n'
        'Keep it patient-friendly and concise.';
  }

  /// Build a context injection prompt for the chatbot when the user has
  /// recent diagnosis data.
  static String buildChatContextPrompt(String recentDiagnosisSummary) {
    return '$chatbotSystemPrompt\n\n'
        'The user recently completed a dental check-up. Here is their '
        'diagnosis summary for context:\n$recentDiagnosisSummary\n\n'
        'Use this context to provide more relevant answers if the user asks '
        'about their dental health.';
  }
}
