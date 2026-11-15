import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../../domain/models/message_item.dart';
import 'local_database.dart';

/// Data Access Object for local message history in SQLite.
class MessageDao {
  Future<Database> get _db => LocalDatabase.database;

  /// Saves a message item to the local database cache.
  Future<void> saveMessage(MessageItem message) async {
    final db = await _db;
    await db.insert(
      'messages',
      {
        'id': message.id,
        'chat_jid': message.chatJid,
        'sender_jid': message.senderJid,
        'text': message.text,
        'timestamp': message.timestamp.millisecondsSinceEpoch,
        'is_from_me': message.isFromMe ? 1 : 0,
        'status': message.status,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Retrieves messages for a given chat ordered by timestamp ascending.
  Future<List<MessageItem>> getMessages(String chatJid, {int limit = 100}) async {
    final db = await _db;
    final maps = await db.query(
      'messages',
      where: 'chat_jid = ?',
      whereArgs: [chatJid],
      orderBy: 'timestamp ASC',
      limit: limit,
    );
    return maps.map((m) {
      return MessageItem(
        id: m['id'] as String,
        chatJid: m['chat_jid'] as String,
        senderJid: m['sender_jid'] as String,
        text: m['text'] as String,
        timestamp: DateTime.fromMillisecondsSinceEpoch(m['timestamp'] as int),
        isFromMe: (m['is_from_me'] as int) == 1,
        status: m['status'] as String? ?? 'sent',
      );
    }).toList();
  }

  /// Deletes all cached messages for a given chat.
  Future<void> deleteChatMessages(String chatJid) async {
    final db = await _db;
    await db.delete(
      'messages',
      where: 'chat_jid = ?',
      whereArgs: [chatJid],
    );
  }

  /// Updates message status to read in local SQLite cache.
  Future<void> markMessagesAsRead(String chatJid, [List<String>? messageIds]) async {
    final db = await _db;
    if (messageIds != null && messageIds.isNotEmpty) {
      final placeholders = List.filled(messageIds.length, '?').join(',');
      await db.update(
        'messages',
        {'status': 'read'},
        where: 'id IN ($placeholders)',
        whereArgs: messageIds,
      );
    } else {
      await db.update(
        'messages',
        {'status': 'read'},
        where: 'chat_jid = ? AND is_from_me = 0',
        whereArgs: [chatJid],
      );
    }
  }
}
