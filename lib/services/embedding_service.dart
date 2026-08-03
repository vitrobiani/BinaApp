import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_onnxruntime/flutter_onnxruntime.dart';
import 'package:path_provider/path_provider.dart';

import 'embedding/gemma_tokenizer.dart';

/// On-device text embedding via Google's EmbeddingGemma-300M (int8 ONNX).
///
/// Model outputs `sentence_embedding` directly (768-dim), so we don't need
/// mean-pooling. Task prefixes matter for retrieval quality:
///   * documents (index-time): "title: none | text: <text>"
///   * queries    (query-time): "task: search result | query: <text>"
class EmbeddingService {
  EmbeddingService._();
  static final EmbeddingService _instance = EmbeddingService._();
  static EmbeddingService get instance => _instance;

  static const _assetDir = 'assets/model/embeddings';
  static const _modelAsset = '$_assetDir/model_quantized.onnx';
  static const _weightsAsset = '$_assetDir/model_quantized.onnx_data';
  static const _tokenizerAsset = '$_assetDir/tokenizer.json';

  // Gemma3 max_position_embeddings from config.json.
  static const int _maxSeqLen = 2048;
  static const int embeddingDim = 768;

  final OnnxRuntime _ort = OnnxRuntime();
  OrtSession? _session;
  GemmaTokenizer? _tokenizer;
  Future<void>? _initFuture;

  bool get isReady => _session != null && _tokenizer != null;

  Future<void> init() {
    _initFuture ??= _doInit();
    return _initFuture!;
  }

  Future<void> _smokeTest() async {
    try {
      final v1 = await embedDocument('hello world');
      final v2 = await embedQuery('greeting');
      if (v1 == null || v2 == null) return;
      double dot = 0;
      for (var i = 0; i < v1.length; i++) {
        dot += v1[i] * v2[i];
      }
      debugPrint('[Embedder] smoke test: dim=${v1.length} '
          'cosine(doc, query)=${dot.toStringAsFixed(3)} '
          'first5=[${v1.take(5).map((e) => e.toStringAsFixed(3)).join(', ')}]');
    } catch (e, st) {
      debugPrint('[Embedder] smoke test failed: $e\n$st');
    }
  }

  Future<void> _doInit() async {
    final sw = Stopwatch()..start();
    try {
      // Parallelise: file extraction is IO-bound, tokenizer parse is CPU-bound
      // (runs in an isolate). No reason to serialise them.
      final results = await Future.wait<Object>([
        _stageModelFiles(),
        GemmaTokenizer.loadFromAsset(_tokenizerAsset),
      ]);
      final modelPath = results[0] as String;
      _tokenizer = results[1] as GemmaTokenizer;

      debugPrint('[Embedder] loading ONNX session from $modelPath');
      _session = await _ort.createSession(modelPath);
      debugPrint('[Embedder] ready in ${sw.elapsedMilliseconds}ms '
          '(inputs=${_session!.inputNames}, outputs=${_session!.outputNames})');

      // Smoke test — confirm the whole pipeline (tokenize → run → pool) works.
      // Runs once at startup so any failure surfaces immediately in the log.
      unawaited(_smokeTest());
    } catch (e, st) {
      debugPrint('[Embedder] init failed: $e\n$st');
      _initFuture = null;
      rethrow;
    }
  }

  /// Embed a document chunk (index-time). Returns 768-dim L2-normalised vector,
  /// or null if the service isn't ready.
  Future<Float32List?> embedDocument(String text) =>
      _embed('title: none | text: $text');

  /// Embed a user query. Returns 768-dim L2-normalised vector, or null if the
  /// service isn't ready.
  Future<Float32List?> embedQuery(String text) =>
      _embed('task: search result | query: $text');

  Future<Float32List?> _embed(String promptedText) async {
    if (!isReady) {
      debugPrint('[Embedder] embed() called before ready');
      return null;
    }
    final sw = Stopwatch()..start();
    final ids = _tokenizer!.encode(promptedText, maxLength: _maxSeqLen);
    final seqLen = ids.length;

    final inputIds = Int64List(seqLen);
    final attentionMask = Int64List(seqLen);
    for (var i = 0; i < seqLen; i++) {
      inputIds[i] = ids[i];
      attentionMask[i] = 1;
    }

    OrtValue? inputIdsTensor;
    OrtValue? attentionMaskTensor;
    Map<String, OrtValue>? outputs;
    try {
      inputIdsTensor = await OrtValue.fromList(inputIds, [1, seqLen]);
      attentionMaskTensor = await OrtValue.fromList(attentionMask, [1, seqLen]);

      outputs = await _session!.run({
        'input_ids': inputIdsTensor,
        'attention_mask': attentionMaskTensor,
      });

      final sentenceEmbedding = outputs['sentence_embedding'];
      if (sentenceEmbedding == null) {
        debugPrint('[Embedder] sentence_embedding missing from outputs '
            '(got ${outputs.keys})');
        return null;
      }
      final flat = await sentenceEmbedding.asFlattenedList();
      final vec = Float32List(flat.length);
      for (var i = 0; i < flat.length; i++) {
        vec[i] = (flat[i] as num).toDouble();
      }
      _l2Normalize(vec);
      debugPrint('[Embedder] embedded ${promptedText.length} chars '
          '(seq=$seqLen) in ${sw.elapsedMilliseconds}ms → dim=${vec.length}');
      return vec;
    } finally {
      await inputIdsTensor?.dispose();
      await attentionMaskTensor?.dispose();
      if (outputs != null) {
        for (final v in outputs.values) {
          await v.dispose();
        }
      }
    }
  }

  static void _l2Normalize(Float32List v) {
    double sumSq = 0;
    for (final x in v) {
      sumSq += x * x;
    }
    if (sumSq <= 0) return;
    final inv = 1.0 / math.sqrt(sumSq);
    for (var i = 0; i < v.length; i++) {
      v[i] *= inv;
    }
  }

  // ---------------------------------------------------------------------------
  //  Model file staging
  // ---------------------------------------------------------------------------

  Future<String> _stageModelFiles() async {
    final baseDir = await getApplicationSupportDirectory();
    final targetDir = Directory('${baseDir.path}/embeddings');
    await targetDir.create(recursive: true);

    final modelFile = File('${targetDir.path}/model_quantized.onnx');
    final weightsFile = File('${targetDir.path}/model_quantized.onnx_data');

    await _copyAssetIfMissing(_modelAsset, modelFile);
    await _copyAssetIfMissing(_weightsAsset, weightsFile);

    return modelFile.path;
  }

  Future<void> _copyAssetIfMissing(String assetKey, File dest) async {
    if (await dest.exists()) return;
    final data = await rootBundle.load(assetKey);
    final bytes =
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    final tmp = File('${dest.path}.tmp');
    await tmp.writeAsBytes(bytes, flush: true);
    await tmp.rename(dest.path);
    debugPrint('[Embedder] staged ${assetKey.split('/').last} '
        '(${(bytes.lengthInBytes / (1024 * 1024)).toStringAsFixed(1)} MB)');
  }
}
