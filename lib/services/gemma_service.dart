import 'package:flutter/foundation.dart';
import 'package:flutter_gemma/flutter_gemma.dart';

class GemmaService {
  GemmaService._();

  static final GemmaService _instance = GemmaService._();
  static GemmaService get instance => _instance;

  // static const _modelAsset = 'assets/gemma3-270m-it-q8.task';
  static const _modelAsset = 'assets/gemma3-1b-it-int4.task';

  bool _modelLoaded = false;
  InferenceModel? _model;

  bool get isModelLoaded => _modelLoaded;

  /// Initialize flutter_gemma, install from asset if needed, and load the model.
  /// Call once at app startup. Safe to call multiple times.
  Future<void> init() async {
    if (_modelLoaded) return;

    try {
      await FlutterGemma.initialize();

      await FlutterGemma.installModel(
        modelType: ModelType.gemmaIt,
        fileType: (_modelAsset.contains(".bin")) ? ModelFileType.binary : ModelFileType.task,
      ).fromAsset(_modelAsset).install();

      _model = await FlutterGemma.getActiveModel(
        maxTokens: 1024,
      );
      _modelLoaded = true;
      debugPrint('GemmaService: model loaded successfully');
    } catch (e) {
      debugPrint('GemmaService init error: $e');
      _modelLoaded = false;
    }
  }

  String _extractResponseText(ModelResponse response) {
    return switch (response) {
      TextResponse(:final token) => token,
      ThinkingResponse(:final content) => content,
      FunctionCallResponse(:final name) => 'Function call: $name',
    };
  }

  Future<String> generateResponse(String prompt) async {
    if (!_modelLoaded || _model == null) return '';

    try {
      final chat = await _model!.createChat(
        temperature: 0.7,
        topK: 40,
      );

      await chat.addQuery(Message.text(text: prompt, isUser: true));
      final response = await chat.generateChatResponse();

      return _extractResponseText(response);
    } catch (e) {
      debugPrint('GemmaService generateResponse error: $e');
      return '';
    }
  }

  Future<String> generateChatResponse(List<Message> messages) async {
    if (!_modelLoaded || _model == null) return '';

    try {
      final chat = await _model!.createChat(
        temperature: 0.7,
        topK: 40,
      );

      for (final message in messages) {
        await chat.addQuery(message);
      }

      final response = await chat.generateChatResponse();

      return _extractResponseText(response);
    } catch (e) {
      debugPrint('GemmaService generateChatResponse error: $e');
      return '';
    }
  }
}
