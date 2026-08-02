// ignore_for_file: unnecessary_getters_setters

import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/app_core/app_util.dart';

/// One document attached to a family member (typically a PDF report or
/// referral letter). Text is extracted at upload time and stored so Gemma
/// can inject it into the system prompt without re-parsing.
///
/// The raw bytes are stored in the DB row itself (SQLite `blob` column) or
/// in Supabase Storage (`storage_path`) — not on this struct. Fetch them
/// on demand when previewing / re-extracting.
class MemberDocumentStruct extends BaseStruct {
  MemberDocumentStruct({
    String? id,
    String? familyMemberId,
    String? fileName,
    String? mimeType,
    int? byteSize,
    String? storagePath,
    String? extractedText,
    String? extractionStatus,
    DateTime? uploadedAt,
  })  : _id = id,
        _familyMemberId = familyMemberId,
        _fileName = fileName,
        _mimeType = mimeType,
        _byteSize = byteSize,
        _storagePath = storagePath,
        _extractedText = extractedText,
        _extractionStatus = extractionStatus,
        _uploadedAt = uploadedAt;

  String? _id;
  String get id => _id ?? '';
  set id(String? val) => _id = val;
  bool hasId() => _id != null;

  String? _familyMemberId;
  String get familyMemberId => _familyMemberId ?? '';
  set familyMemberId(String? val) => _familyMemberId = val;
  bool hasFamilyMemberId() => _familyMemberId != null;

  String? _fileName;
  String get fileName => _fileName ?? '';
  set fileName(String? val) => _fileName = val;
  bool hasFileName() => _fileName != null;

  String? _mimeType;
  String? get mimeType => _mimeType;
  set mimeType(String? val) => _mimeType = val;
  bool hasMimeType() => _mimeType != null;

  int? _byteSize;
  int? get byteSize => _byteSize;
  set byteSize(int? val) => _byteSize = val;
  bool hasByteSize() => _byteSize != null;

  String? _storagePath;
  String? get storagePath => _storagePath;
  set storagePath(String? val) => _storagePath = val;
  bool hasStoragePath() => _storagePath != null;

  String? _extractedText;
  String? get extractedText => _extractedText;
  set extractedText(String? val) => _extractedText = val;
  bool hasExtractedText() => _extractedText != null;

  /// 'ok' when extraction yielded usable text, 'empty' for scanned-image PDFs
  /// or otherwise text-less documents, 'error' if extraction threw.
  String? _extractionStatus;
  String? get extractionStatus => _extractionStatus;
  set extractionStatus(String? val) => _extractionStatus = val;
  bool hasExtractionStatus() => _extractionStatus != null;

  DateTime? _uploadedAt;
  DateTime? get uploadedAt => _uploadedAt;
  set uploadedAt(DateTime? val) => _uploadedAt = val;
  bool hasUploadedAt() => _uploadedAt != null;

  static MemberDocumentStruct fromMap(Map<String, dynamic> data) =>
      MemberDocumentStruct(
        id: data['id'] as String?,
        familyMemberId: data['family_member_id'] as String?,
        fileName: data['file_name'] as String?,
        mimeType: data['mime_type'] as String?,
        byteSize: (data['byte_size'] as num?)?.toInt(),
        storagePath: data['storage_path'] as String?,
        extractedText: data['extracted_text'] as String?,
        extractionStatus: data['extraction_status'] as String?,
        uploadedAt: data['uploaded_at'] as DateTime?,
      );

  static MemberDocumentStruct? maybeFromMap(dynamic data) => data is Map
      ? MemberDocumentStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'id': _id,
        'family_member_id': _familyMemberId,
        'file_name': _fileName,
        'mime_type': _mimeType,
        'byte_size': _byteSize,
        'storage_path': _storagePath,
        'extracted_text': _extractedText,
        'extraction_status': _extractionStatus,
        'uploaded_at': _uploadedAt,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'id': serializeParam(_id, ParamType.String),
        'family_member_id':
            serializeParam(_familyMemberId, ParamType.String),
        'file_name': serializeParam(_fileName, ParamType.String),
        'mime_type': serializeParam(_mimeType, ParamType.String),
        'byte_size': serializeParam(_byteSize, ParamType.int),
        'storage_path': serializeParam(_storagePath, ParamType.String),
        'extracted_text': serializeParam(_extractedText, ParamType.String),
        'extraction_status':
            serializeParam(_extractionStatus, ParamType.String),
        'uploaded_at': serializeParam(_uploadedAt, ParamType.DateTime),
      }.withoutNulls;

  static MemberDocumentStruct fromSerializableMap(Map<String, dynamic> data) =>
      MemberDocumentStruct(
        id: deserializeParam(data['id'], ParamType.String, false),
        familyMemberId:
            deserializeParam(data['family_member_id'], ParamType.String, false),
        fileName: deserializeParam(data['file_name'], ParamType.String, false),
        mimeType: deserializeParam(data['mime_type'], ParamType.String, false),
        byteSize: deserializeParam(data['byte_size'], ParamType.int, false),
        storagePath:
            deserializeParam(data['storage_path'], ParamType.String, false),
        extractedText: deserializeParam(
            data['extracted_text'], ParamType.String, false),
        extractionStatus: deserializeParam(
            data['extraction_status'], ParamType.String, false),
        uploadedAt: deserializeParam(
            data['uploaded_at'], ParamType.DateTime, false),
      );

  @override
  String toString() => 'MemberDocumentStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is MemberDocumentStruct &&
        id == other.id &&
        familyMemberId == other.familyMemberId &&
        fileName == other.fileName &&
        mimeType == other.mimeType &&
        byteSize == other.byteSize &&
        storagePath == other.storagePath &&
        extractedText == other.extractedText &&
        extractionStatus == other.extractionStatus &&
        uploadedAt == other.uploadedAt;
  }

  @override
  int get hashCode => const ListEquality().hash([
        id,
        familyMemberId,
        fileName,
        mimeType,
        byteSize,
        storagePath,
        extractedText,
        extractionStatus,
        uploadedAt,
      ]);
}
