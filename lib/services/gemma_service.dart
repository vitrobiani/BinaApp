import 'package:flutter/foundation.dart';
import 'package:flutter_gemma/flutter_gemma.dart';

/// Model source - bundled in app or downloaded at runtime
enum ModelSource {
  bundled,  // Included in APK (small models only)
  network,  // Download from URL (HuggingFace, etc.)
}

/// Available model configurations
enum GemmaModel {
  gemma3_1b(
    name: 'Gemma 3 1B',
    source: ModelSource.bundled,
    mobileAsset: 'assets/gemma3-1b-it-int4.task',
    webAsset: 'assets/gemma3-1b-it-int4.task',
    downloadUrl: null,
    modelType: ModelType.gemmaIt,
    maxTokens: 1024,
    sizeDescription: '~555 MB (bundled)',
  ),
  gemma4_e2b(
    name: 'Gemma 4 E2B',
    source: ModelSource.network,
    mobileAsset: null,
    webAsset: 'assets/gemma-4-E2B-it-web.task',
    // Direct download URL from HuggingFace
    downloadUrl: 'https://huggingface.co/litert-community/gemma-4-E2B-it-litert-lm/resolve/main/gemma-4-E2B-it.litertlm',
    modelType: ModelType.gemma4,  // Use gemma4 for Gemma 4 models
    maxTokens: 2048,
    sizeDescription: '~2.6 GB (downloads on first use)',
  );

  const GemmaModel({
    required this.name,
    required this.source,
    required this.mobileAsset,
    required this.webAsset,
    required this.downloadUrl,
    required this.modelType,
    required this.maxTokens,
    required this.sizeDescription,
  });

  final String name;
  final ModelSource source;
  final String? mobileAsset;
  final String? webAsset;
  final String? downloadUrl;
  final ModelType modelType;
  final int maxTokens;
  final String sizeDescription;

  /// Whether this model needs to be downloaded
  bool get requiresDownload => source == ModelSource.network && !kIsWeb;

  /// Get the correct asset path for bundled models
  String? get assetPath {
    if (kIsWeb) return webAsset;
    if (source == ModelSource.bundled) return mobileAsset;
    return null;
  }

  /// Determine file type from extension
  ModelFileType get fileType {
    final path = (assetPath ?? downloadUrl ?? '').toLowerCase();
    if (path.endsWith('.litertlm')) {
      return ModelFileType.litertlm;  // LiteRT-LM SDK handles these via FFI
    }
    if (path.endsWith('.bin') || path.endsWith('.tflite')) {
      return ModelFileType.binary;
    }
    return ModelFileType.task;
  }
}

/// Callback for download progress
typedef DownloadProgressCallback = void Function(int progress, String status);

class GemmaService {
  GemmaService._();

  static final GemmaService _instance = GemmaService._();
  static GemmaService get instance => _instance;

  // ============================================================
  // CHANGE THIS LINE TO SWITCH MODELS
  // ============================================================
  static const GemmaModel _selectedModel = GemmaModel.gemma4_e2b;
  // Options: GemmaModel.gemma3_1b (bundled), GemmaModel.gemma4_e2b (downloads)
  // ============================================================

  bool _modelLoaded = false;
  bool _isDownloading = false;
  int _downloadProgress = 0;
  String _downloadStatus = '';
  InferenceModel? _model;

  bool get isModelLoaded => _modelLoaded;
  bool get isDownloading => _isDownloading;
  double get downloadProgress => _downloadProgress / 100.0;
  String get downloadStatus => _downloadStatus;
  String get modelName => _selectedModel.name;
  String get modelSizeDescription => _selectedModel.sizeDescription;
  bool get requiresDownload => _selectedModel.requiresDownload;
  GemmaModel get currentModel => _selectedModel;

  /// Initialize flutter_gemma, install/download model, and load it.
  /// Call once at app startup. Safe to call multiple times.
  ///
  /// [onProgress] - Optional callback for download progress updates
  Future<void> init({DownloadProgressCallback? onProgress}) async {
    if (_modelLoaded) return;
    if (_isDownloading) return;

    try {
      debugPrint('GemmaService: initializing ${_selectedModel.name}...');
      debugPrint('GemmaService: platform=${kIsWeb ? "web" : "mobile"}');
      debugPrint('GemmaService: source=${_selectedModel.source}');
      debugPrint('GemmaService: requiresDownload=${_selectedModel.requiresDownload}');

      await FlutterGemma.initialize();

      // Install/download the model based on source
      if (_selectedModel.requiresDownload) {
        await _installFromNetwork(onProgress);
      } else {
        await _installFromAsset(onProgress);
      }

      _model = await FlutterGemma.getActiveModel(
        maxTokens: _selectedModel.maxTokens,
      );
      _modelLoaded = true;
      _isDownloading = false;
      debugPrint('GemmaService: ${_selectedModel.name} loaded successfully');
    } catch (e) {
      debugPrint('GemmaService init error: $e');
      _modelLoaded = false;
      _isDownloading = false;
      _downloadStatus = 'Error: $e';
      rethrow;
    }
  }

  Future<void> _installFromAsset(DownloadProgressCallback? onProgress) async {
    final assetPath = _selectedModel.assetPath;
    if (assetPath == null) {
      throw Exception('No asset path configured for ${_selectedModel.name}');
    }

    debugPrint('GemmaService: installing from asset: $assetPath');
    _updateProgress(onProgress, 50, 'Loading from app bundle...');

    await FlutterGemma.installModel(
      modelType: _selectedModel.modelType,
      fileType: _selectedModel.fileType,
    ).fromAsset(assetPath).install();

    _updateProgress(onProgress, 100, 'Model loaded');
  }

  Future<void> _installFromNetwork(DownloadProgressCallback? onProgress) async {
    final url = _selectedModel.downloadUrl;
    if (url == null) {
      throw Exception('No download URL configured for ${_selectedModel.name}');
    }

    debugPrint('GemmaService: downloading from: $url');
    _isDownloading = true;
    _updateProgress(onProgress, 0, 'Connecting...');

    await FlutterGemma.installModel(
      modelType: _selectedModel.modelType,
      fileType: _selectedModel.fileType,
    )
        .fromNetwork(url, foreground: true) // Use foreground service for large downloads
        .withProgress((progress) {
          _updateProgress(onProgress, progress, 'Downloading: $progress%');
        })
        .install();

    _updateProgress(onProgress, 100, 'Download complete');
  }

  void _updateProgress(DownloadProgressCallback? callback, int progress, String status) {
    _downloadProgress = progress;
    _downloadStatus = status;
    callback?.call(progress, status);
    debugPrint('GemmaService: $status');
  }

  String _extractResponseText(ModelResponse response) {
    return switch (response) {
      TextResponse(:final token) => token,
      ThinkingResponse(:final content) => content,
      FunctionCallResponse(:final name) => 'Function call: $name',
      ParallelFunctionCallResponse(:final calls) =>
        'Function calls: ${calls.map((c) => c.name).join(", ")}',
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
