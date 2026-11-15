import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../../domain/models/chat_item.dart';
import 'local_database.dart';

/// Data Access Object for local chats persistence in SQLite.
class ChatDao {
  Future<Database> get _db => LocalDatabase.database;

  Map<String, dynamic> _toMap(ChatItem chat) => {
        'jid': chat.jid,
        'name': chat.name,
        'last_message': chat.lastMessage,
        'last_message_timestamp': chat.lastMessageTimestamp.millisecondsSinceEpoch,
        'unread_count': chat.unreadCount,
        'avatar_url': chat.avatarUrl,
        'is_group': chat.isGroup ? 1 : 0,
        'is_pinned': chat.isPinned ? 1 : 0,
        'is_archived': chat.isArchived ? 1 : 0,
        'mute_until': chat.muteUntil,
      };

  ChatItem _fromMap(Map<String, Object?> m) => ChatItem(
        jid: m['jid'] as String,
        name: m['name'] as String?,
        lastMessage: m['last_message'] as String?,
        lastMessageTimestamp: DateTime.fromMillisecondsSinceEpoch(m['last_message_timestamp'] as int? ?? 0),
        unreadCount: m['unread_count'] as int? ?? 0,
        avatarUrl: m['avatar_url'] as String?,
        isGroup: (m['is_group'] as int? ?? 0) == 1,
        isPinned: (m['is_pinned'] as int? ?? 0) == 1,
        isArchived: (m['is_archived'] as int? ?? 0) == 1,
        muteUntil: m['mute_until'] as int? ?? 0,
      );

  /// Saves or updates multiple chat summaries in a single transaction.
  Future<void> saveChats(List<ChatItem> chats) async {
    final db = await _db;
    final batch = db.batch();
    for (final chat in chats) {
      batch.insert('chats', _toMap(chat), conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  /// Inserts or replaces a single chat summary.
  Future<void> saveChat(ChatItem chat) async {
    final db = await _db;
    await db.insert('chats', _toMap(chat), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// Retrieves cached chats sorted by pin status and timestamp with contact resolution.
  Future<List<ChatItem>> getChats() async {
    final db = await _db;
    try {
      final sessionFile = File(p.join(p.dirname(db.path), 'session.db'));
      if (sessionFile.existsSync()) {
        await db.execute("ATTACH DATABASE '${sessionFile.path}' AS sdb");
      }
    } catch (_) {}

    List<Map<String, Object?>> maps;
    try {
      maps = await db.rawQuery('''
        SELECT 
          c.jid,
          COALESCE(
            NULLIF(cnt.full_name, ''), NULLIF(cnt.push_name, ''), NULLIF(cnt.first_name, ''),
            NULLIF(cnt_direct.full_name, ''), NULLIF(cnt_direct.push_name, ''), NULLIF(c.name, ''),
            CASE 
              WHEN lm.pn IS NOT NULL THEN '+' || lm.pn 
              WHEN c.jid LIKE '%@lid' THEN 'Contact (' || SUBSTR(c.jid, 1, 6) || '...)'
              ELSE c.jid 
            END
          ) as name,
          c.last_message, c.last_message_timestamp, c.unread_count, c.avatar_url,
          c.is_group, c.is_pinned, c.is_archived, c.mute_until
        FROM chats c
        LEFT JOIN sdb.whatsmeow_lid_map lm ON lm.lid = SUBSTR(c.jid, 1, INSTR(c.jid, '@') - 1)
        LEFT JOIN sdb.whatsmeow_contacts cnt ON cnt.their_jid = lm.pn || '@s.whatsapp.net'
        LEFT JOIN sdb.whatsmeow_contacts cnt_direct ON cnt_direct.their_jid = c.jid
        ORDER BY c.is_pinned DESC, c.last_message_timestamp DESC
      ''');
    } catch (_) {
      maps = await db.query('chats', orderBy: 'is_pinned DESC, last_message_timestamp DESC');
    }
    return maps.map(_fromMap).toList();
  }

  /// Updates pin status for a chat.
  Future<void> setPinned(String jid, bool isPinned) async {
    final db = await _db;
    await db.update('chats', {'is_pinned': isPinned ? 1 : 0}, where: 'jid = ?', whereArgs: [jid]);
  }

  /// Updates archive status for a chat.
  Future<void> setArchived(String jid, bool isArchived) async {
    final db = await _db;
    await db.update('chats', {'is_archived': isArchived ? 1 : 0}, where: 'jid = ?', whereArgs: [jid]);
  }

  /// Updates mute timestamp for a chat.
  Future<void> setMute(String jid, int muteUntil) async {
    final db = await _db;
    await db.update('chats', {'mute_until': muteUntil}, where: 'jid = ?', whereArgs: [jid]);
  }

  /// Marks unread count as zero for a specific chat.
  Future<void> clearUnread(String jid) async {
    final db = await _db;
    await db.update('chats', {'unread_count': 0}, where: 'jid = ?', whereArgs: [jid]);
  }

  /// Deletes a chat entry from local cache.
  Future<void> deleteChat(String jid) async {
    final db = await _db;
    await db.delete('chats', where: 'jid = ?', whereArgs: [jid]);
  }
}
