import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../../domain/models/reaction_item.dart';
import 'local_database.dart';

/// Data Access Object for message reactions cached in local SQLite.
class ReactionDao {
  Future<Database> get _db => LocalDatabase.database;

  /// Saves or updates a reaction for a given message. Removes reaction if emoji is empty.
  Future<void> saveReaction(ReactionItem reaction) async {
    final db = await _db;
    if (reaction.emoji.isEmpty) {
      await deleteReaction(reaction.msgId, reaction.senderJid);
      return;
    }
    await db.insert(
      'message_reactions',
      {
        'msg_id': reaction.msgId,
        'sender_jid': reaction.senderJid,
        'emoji': reaction.emoji,
        'timestamp': reaction.timestamp.millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Retrieves all reactions for a given message ID.
  Future<List<ReactionItem>> getReactions(String msgId) async {
    final db = await _db;
    final maps = await db.query(
      'message_reactions',
      where: 'msg_id = ?',
      whereArgs: [msgId],
      orderBy: 'timestamp ASC',
    );
    return maps.map((m) {
      return ReactionItem(
        msgId: m['msg_id'] as String,
        senderJid: m['sender_jid'] as String,
        emoji: m['emoji'] as String,
        timestamp: DateTime.fromMillisecondsSinceEpoch(m['timestamp'] as int),
      );
    }).toList();
  }

  /// Deletes a specific reaction by message ID and sender JID.
  Future<void> deleteReaction(String msgId, String senderJid) async {
    final db = await _db;
    await db.delete(
      'message_reactions',
      where: 'msg_id = ? AND sender_jid = ?',
      whereArgs: [msgId, senderJid],
    );
  }

  /// Clears all reactions for a message.
  Future<void> deleteReactionsForMessage(String msgId) async {
    final db = await _db;
    await db.delete(
      'message_reactions',
      where: 'msg_id = ?',
      whereArgs: [msgId],
    );
  }
}
