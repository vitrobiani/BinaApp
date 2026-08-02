import 'dart:typed_data';

import '../database.dart';

class ScanImagesTable extends SupabaseTable<ScanImagesRow> {
  @override
  String get tableName => 'scan_image';

  @override
  ScanImagesRow createRow(Map<String, dynamic> data) => ScanImagesRow(data);
}

class ScanImagesRow extends SupabaseDataRow {
  ScanImagesRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => ScanImagesTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get scanSessionId => getField<String>('scan_session_id')!;
  set scanSessionId(String value) => setField<String>('scan_session_id', value);

  // image and diagnosed_image are BYTEA - stored as Uint8List
  Uint8List? get image => getField<Uint8List>('image');
  set image(Uint8List? value) => setField<Uint8List>('image', value);

  Uint8List? get diagnosedImage => getField<Uint8List>('diagnosed_image');
  set diagnosedImage(Uint8List? value) => setField<Uint8List>('diagnosed_image', value);

  DateTime? get capturedAt => getField<DateTime>('captured_at');
  set capturedAt(DateTime? value) => setField<DateTime>('captured_at', value);

  String? get rawResponse => getField<String>('raw_response');
  set rawResponse(String? value) => setField<String>('raw_response', value);

  // Gyro orientation captured with the image, degrees in [-180, 180].
  int? get pitch => getField<int>('pitch');
  set pitch(int? value) => setField<int>('pitch', value);

  int? get roll => getField<int>('roll');
  set roll(int? value) => setField<int>('roll', value);

  // Estimated mouth region at capture time (e.g. "URI" or "URI/ULO").
  String? get estimatedRegion => getField<String>('estimated_region');
  set estimatedRegion(String? value) =>
      setField<String>('estimated_region', value);
}
