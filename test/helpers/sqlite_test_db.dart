import 'package:bina_system/backend/sqlite/init.dart' as app_init;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void initFfiSqlite() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfiNoIsolate;
}

Future<Database> openBaseSqlite() async {
  final db = await databaseFactory.openDatabase(
    inMemoryDatabasePath,
    options: OpenDatabaseOptions(version: 1, singleInstance: false),
  );
  await _createBaseSchema(db);
  return db;
}

/// A "legacy install" seed: only the truly ancient tables (users and
/// family_member) exist. Migrations must build everything else on top.
/// Used by migration tests to prove that upgrading an old app is safe.
Future<Database> openLegacySqlite() async {
  final db = await databaseFactory.openDatabase(
    inMemoryDatabasePath,
    options: OpenDatabaseOptions(version: 1, singleInstance: false),
  );
  await db.execute('''
    CREATE TABLE users (
      id TEXT NOT NULL UNIQUE,
      email TEXT UNIQUE,
      phone_number TEXT UNIQUE,
      created_at INTEGER NOT NULL,
      last_active INTEGER,
      password_hash TEXT NOT NULL,
      PRIMARY KEY(id)
    )
  ''');
  await db.execute('''
    CREATE TABLE family_member (
      id TEXT PRIMARY KEY,
      account_id TEXT REFERENCES users(id),
      name TEXT,
      birthday INTEGER,
      gender TEXT,
      relationship TEXT,
      last_checked INTEGER
    )
  ''');
  return db;
}

/// Full modern schema after all migrations run — equivalent to what a
/// fresh install would end up with. Convenience for tests that want a
/// working DB without caring about migration paths. Also creates the chat
/// tables (`chat_conversation`, `chat_message`) which live in the bundled
/// AppData.db rather than in `runMigrations`.
Future<Database> openMigratedSqlite() async {
  final db = await openLegacySqlite();
  await app_init.runMigrations(db);
  await db.execute('''
    CREATE TABLE IF NOT EXISTS chat_conversation (
      id TEXT PRIMARY KEY,
      family_member_id TEXT NOT NULL,
      title TEXT NOT NULL,
      created_at INTEGER,
      last_updated_at INTEGER
    )
  ''');
  await db.execute('''
    CREATE TABLE IF NOT EXISTS chat_message (
      id TEXT PRIMARY KEY,
      conversation_id TEXT NOT NULL,
      role TEXT NOT NULL,
      content TEXT NOT NULL,
      timestamp INTEGER NOT NULL
    )
  ''');
  return db;
}

/// A "pre-gyro install" seed: the app before gyro capture was added. The
/// scan_image table exists but is missing pitch/roll/estimated_region.
/// Migrations must ALTER the table without losing data.
Future<Database> openPreGyroSqlite() async {
  final db = await openLegacySqlite();
  await db.execute('''
    CREATE TABLE scan_session (
      id TEXT PRIMARY KEY,
      family_member_id TEXT NOT NULL,
      session_start INTEGER,
      session_end INTEGER,
      status TEXT NOT NULL DEFAULT 'pending',
      notes TEXT,
      total_images_captured INTEGER DEFAULT 0
    )
  ''');
  await db.execute('''
    CREATE TABLE scan_image (
      id TEXT PRIMARY KEY,
      scan_session_id TEXT NOT NULL,
      image BLOB,
      diagnosed_image BLOB,
      captured_at INTEGER,
      raw_response TEXT
    )
  ''');
  return db;
}

Future<void> _createBaseSchema(Database db) async {
  // Just the minimum the migrations touch or reference. Not a full mirror
  // of AppData.db — tests that need chat_conversation etc. should CREATE
  // those tables themselves.
  await db.execute('''
    CREATE TABLE users (
      id TEXT NOT NULL UNIQUE,
      email TEXT UNIQUE,
      phone_number TEXT UNIQUE,
      created_at INTEGER NOT NULL,
      last_active INTEGER,
      password_hash TEXT NOT NULL,
      PRIMARY KEY(id)
    )
  ''');
  await db.execute('''
    CREATE TABLE family_member (
      id TEXT PRIMARY KEY,
      account_id TEXT REFERENCES users(id),
      name TEXT,
      birthday INTEGER,
      gender TEXT,
      relationship TEXT,
      last_checked INTEGER
    )
  ''');
}

/// Returns the names of every table in [db]. Handy for asserting migration
/// output.
Future<Set<String>> tableNames(Database db) async {
  final rows = await db.rawQuery(
    "SELECT name FROM sqlite_master WHERE type = 'table' AND name NOT LIKE 'sqlite_%'",
  );
  return rows.map((r) => r['name'] as String).toSet();
}

/// Returns the column names for [tableName].
Future<Set<String>> columnNames(Database db, String tableName) async {
  final rows = await db.rawQuery('PRAGMA table_info($tableName)');
  return rows.map((r) => r['name'] as String).toSet();
}
