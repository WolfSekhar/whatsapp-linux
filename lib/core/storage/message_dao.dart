import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../../domain/models/message_item.dart';
import '../../domain/models/quoted_item.dart';
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
        'quoted_id': message.quoted?.id,
        'quoted_sender': message.quoted?.senderJid,
        'quoted_text': message.quoted?.text,
        'is_starred': message.isStarred ? 1 : 0,
        'is_revoked': message.isRevoked ? 1 : 0,
        'media_type': message.mediaType,
        'file_name': message.fileName,
        'file_size': message.fileSize,
        'mime_type': message.mimeType,
        'local_path': message.localPath,
        'thumbnail': message.thumbnailBase64,
        'duration': message.duration,
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
      final qId = m['quoted_id'] as String?;
      final quoted = (qId != null && qId.isNotEmpty)
          ? QuotedItem(
              id: qId,
              senderJid: m['quoted_sender'] as String? ?? '',
              text: m['quoted_text'] as String? ?? '',
            )
          : null;
      return MessageItem(
        id: m['id'] as String,
        chatJid: m['chat_jid'] as String,
        senderJid: m['sender_jid'] as String,
        text: m['text'] as String,
        timestamp: DateTime.fromMillisecondsSinceEpoch(m['timestamp'] as int),
        isFromMe: (m['is_from_me'] as int) == 1,
        status: m['status'] as String? ?? 'sent',
        quoted: quoted,
        isStarred: (m['is_starred'] as int? ?? 0) == 1,
        isRevoked: (m['is_revoked'] as int? ?? 0) == 1,
        mediaType: m['media_type'] as String?,
        fileName: m['file_name'] as String?,
        fileSize: m['file_size'] as int?,
        mimeType: m['mime_type'] as String?,
        localPath: m['local_path'] as String?,
        thumbnailBase64: m['thumbnail'] as String?,
        duration: m['duration'] as int?,
      );
    }).toList();
  }

  /// Toggles or updates starred state of a message.
  Future<void> setStarred(String msgId, bool isStarred) async {
    final db = await _db;
    await db.update('messages', {'is_starred': isStarred ? 1 : 0}, where: 'id = ?', whereArgs: [msgId]);
  }

  /// Marks a message as revoked in local cache.
  Future<void> setRevoked(String msgId, bool isRevoked) async {
    final db = await _db;
    await db.update('messages', {'is_revoked': isRevoked ? 1 : 0}, where: 'id = ?', whereArgs: [msgId]);
  }

  /// Deletes a single message from cache.
  Future<void> deleteMessage(String msgId) async {
    final db = await _db;
    await db.delete('messages', where: 'id = ?', whereArgs: [msgId]);
  }

  /// Updates local file path for a downloaded media message.
  Future<void> updateMessageLocalPath(String id, String localPath) async {
    final db = await _db;
    await db.update('messages', {'local_path': localPath}, where: 'id = ?', whereArgs: [id]);
  }

  /// Deletes all cached messages for a given chat.
  Future<void> deleteChatMessages(String chatJid) async {
    final db = await _db;
    await db.delete('messages', where: 'chat_jid = ?', whereArgs: [chatJid]);
  }

  /// Updates message status to read in local SQLite cache.
  Future<void> markMessagesAsRead(String chatJid, [List<String>? messageIds]) async {
    final db = await _db;
    if (messageIds != null && messageIds.isNotEmpty) {
      final placeholders = List.filled(messageIds.length, '?').join(',');
      await db.update('messages', {'status': 'read'}, where: 'id IN ($placeholders)', whereArgs: messageIds);
    } else {
      await db.update('messages', {'status': 'read'}, where: 'chat_jid = ? AND is_from_me = 0', whereArgs: [chatJid]);
    }
  }
}
