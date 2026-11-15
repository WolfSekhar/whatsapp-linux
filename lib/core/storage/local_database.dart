import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Database provider managing local SQLite database lifecycle for Linux desktop.
class LocalDatabase {
  static Database? _database;

  /// Retrieves or opens the shared singleton SQLite database.
  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    sqfliteFfiInit();
    final dbFactory = databaseFactoryFfi;

    final xdgData = Platform.environment['XDG_DATA_HOME'];
    final home = Platform.environment['HOME'] ?? '.';
    final baseDir = (xdgData != null && xdgData.isNotEmpty)
        ? xdgData
        : p.join(home, '.local', 'share');
    final appDir = Directory(p.join(baseDir, 'whatsapp-linux'));

    if (!appDir.existsSync()) {
      appDir.createSync(recursive: true);
    }

    final dbPath = p.join(appDir.path, 'cache.db');
    return await dbFactory.openDatabase(
      dbPath,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS chats (
              jid TEXT PRIMARY KEY,
              name TEXT NOT NULL,
              last_message TEXT,
              last_message_timestamp INTEGER NOT NULL,
              unread_count INTEGER NOT NULL DEFAULT 0,
              avatar_url TEXT,
              is_group INTEGER NOT NULL DEFAULT 0
            )
          ''');

          await db.execute('''
            CREATE TABLE IF NOT EXISTS messages (
              id TEXT PRIMARY KEY,
              chat_jid TEXT NOT NULL,
              sender_jid TEXT NOT NULL,
              text TEXT NOT NULL,
              timestamp INTEGER NOT NULL,
              is_from_me INTEGER NOT NULL DEFAULT 0,
              status TEXT NOT NULL DEFAULT 'sent',
              media_type TEXT,
              media_url TEXT
            )
          ''');

          await db.execute(
            'CREATE INDEX IF NOT EXISTS idx_msg_chat ON messages(chat_jid, timestamp DESC)',
          );
        },
      ),
    );
  }

  /// Closes database connection.
  static Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
