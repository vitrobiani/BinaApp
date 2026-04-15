import 'dart:io';

import 'package:flutter/services.dart';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

Future<Database> initializeDatabaseFromDbFile(
  String databaseName,
  String databaseAssetFilename,
) async {
  final databasesPath = await getDatabasesPath();
  final path = '$databaseName.db';
  final databasePath = join(databasesPath, path);
  // First, check if the database exists.
  final exists = await databaseExists(databasePath);
  if (!exists) {
    // Ensure parent directory exists.
    try {
      await Directory(dirname(databasePath)).create(recursive: true);
    } catch (_) {}
    // Copy the database file over to the working database directory.
    final databaseData = await rootBundle
        .load(join('assets', 'sqlite_db_files', databaseAssetFilename));
    final databaseBytes = databaseData.buffer.asUint8List(
      databaseData.offsetInBytes,
      databaseData.lengthInBytes,
    );
    await File(databasePath).writeAsBytes(databaseBytes, flush: true);
  }
  // Initialize the SQLite database.
  final database = await openDatabase(databasePath);

  // Run migrations for new tables
  await _runMigrations(database);

  return database;
}

Future<void> _runMigrations(Database database) async {
  // Create scan_session table if it doesn't exist
  await database.execute('''
    CREATE TABLE IF NOT EXISTS scan_session (
      id TEXT PRIMARY KEY,
      family_member_id TEXT NOT NULL,
      session_start INTEGER,
      session_end INTEGER,
      status TEXT NOT NULL DEFAULT 'pending',
      notes TEXT,
      total_images_captured INTEGER DEFAULT 0,
      FOREIGN KEY (family_member_id) REFERENCES family_member(id)
    )
  ''');

  // Create scan_image table if it doesn't exist
  await database.execute('''
    CREATE TABLE IF NOT EXISTS scan_image (
      id TEXT PRIMARY KEY,
      scan_session_id TEXT NOT NULL,
      image BLOB,
      diagnosed_image BLOB,
      captured_at INTEGER,
      raw_response TEXT,
      FOREIGN KEY (scan_session_id) REFERENCES scan_session(id)
    )
  ''');

  // Create dental_record table if it doesn't exist
  await database.execute('''
    CREATE TABLE IF NOT EXISTS dental_record (
      id TEXT PRIMARY KEY,
      family_member_id TEXT,
      scan_session_id TEXT,
      record_date INTEGER,
      findings_snapshot TEXT,
      overall_status TEXT DEFAULT 'unknown',
      FOREIGN KEY (family_member_id) REFERENCES family_member(id),
      FOREIGN KEY (scan_session_id) REFERENCES scan_session(id)
    )
  ''');
}
