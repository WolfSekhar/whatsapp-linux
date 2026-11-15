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
        version: 4,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS chats (
              jid TEXT PRIMARY KEY,
              name TEXT NOT NULL,
              last_message TEXT,
              last_message_timestamp INTEGER NOT NULL,
              unread_count INTEGER NOT NULL DEFAULT 0,
              avatar_url TEXT,
              is_group INTEGER NOT NULL DEFAULT 0,
              is_pinned INTEGER NOT NULL DEFAULT 0,
              is_archived INTEGER NOT NULL DEFAULT 0,
              mute_until INTEGER NOT NULL DEFAULT 0
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
              quoted_id TEXT,
              quoted_sender TEXT,
              quoted_text TEXT,
              is_starred INTEGER NOT NULL DEFAULT 0,
              is_revoked INTEGER NOT NULL DEFAULT 0,
              media_type TEXT,
              media_url TEXT,
              file_name TEXT,
              file_size INTEGER,
              mime_type TEXT,
              local_path TEXT,
              thumbnail TEXT,
              duration INTEGER
            )
          ''');

          await db.execute('''
            CREATE TABLE IF NOT EXISTS message_reactions (
              msg_id TEXT NOT NULL,
              sender_jid TEXT NOT NULL,
              emoji TEXT NOT NULL,
              timestamp INTEGER NOT NULL,
              PRIMARY KEY (msg_id, sender_jid)
            )
          ''');

          await db.execute(
            'CREATE INDEX IF NOT EXISTS idx_msg_chat ON messages(chat_jid, timestamp DESC)',
          );
          await db.execute(
            'CREATE INDEX IF NOT EXISTS idx_reaction_msg ON message_reactions(msg_id)',
          );
        },
        onUpgrade: (db, oldVersion, newVersion) async {
          if (oldVersion < 2) {
            await _runSafe(db, 'ALTER TABLE messages ADD COLUMN file_name TEXT');
            await _runSafe(db, 'ALTER TABLE messages ADD COLUMN file_size INTEGER');
            await _runSafe(db, 'ALTER TABLE messages ADD COLUMN mime_type TEXT');
            await _runSafe(db, 'ALTER TABLE messages ADD COLUMN local_path TEXT');
            await _runSafe(db, 'ALTER TABLE messages ADD COLUMN thumbnail TEXT');
            await _runSafe(db, 'ALTER TABLE messages ADD COLUMN duration INTEGER');
          }
          if (oldVersion < 3) {
            await _runSafe(db, 'ALTER TABLE messages ADD COLUMN quoted_id TEXT');
            await _runSafe(db, 'ALTER TABLE messages ADD COLUMN quoted_sender TEXT');
            await _runSafe(db, 'ALTER TABLE messages ADD COLUMN quoted_text TEXT');
            await _runSafe(db, 'ALTER TABLE messages ADD COLUMN is_starred INTEGER NOT NULL DEFAULT 0');
            await _runSafe(db, 'ALTER TABLE messages ADD COLUMN is_revoked INTEGER NOT NULL DEFAULT 0');
            await db.execute('''
              CREATE TABLE IF NOT EXISTS message_reactions (
                msg_id TEXT NOT NULL,
                sender_jid TEXT NOT NULL,
                emoji TEXT NOT NULL,
                timestamp INTEGER NOT NULL,
                PRIMARY KEY (msg_id, sender_jid)
              )
            ''');
            await db.execute('CREATE INDEX IF NOT EXISTS idx_reaction_msg ON message_reactions(msg_id)');
          }
          if (oldVersion < 4) {
            await _runSafe(db, 'ALTER TABLE chats ADD COLUMN is_pinned INTEGER NOT NULL DEFAULT 0');
            await _runSafe(db, 'ALTER TABLE chats ADD COLUMN is_archived INTEGER NOT NULL DEFAULT 0');
            await _runSafe(db, 'ALTER TABLE chats ADD COLUMN mute_until INTEGER NOT NULL DEFAULT 0');
          }
        },
      ),
    );
  }

  static Future<void> _runSafe(Database db, String sql) async {
    try {
      await db.execute(sql);
    } catch (_) {}
  }

  /// Closes database connection.
  static Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
