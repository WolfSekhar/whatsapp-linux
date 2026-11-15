/// Represents an emoji reaction to a message.
class ReactionItem {
  final String msgId;
  final String senderJid;
  final String emoji;
  final DateTime timestamp;

  const ReactionItem({
    required this.msgId,
    required this.senderJid,
    required this.emoji,
    required this.timestamp,
  });

  factory ReactionItem.fromJson(Map<String, dynamic> json) {
    final rawTs = json['timestamp'];
    DateTime ts;
    if (rawTs is int) {
      ts = DateTime.fromMillisecondsSinceEpoch(
        rawTs > 100000000000 ? rawTs : rawTs * 1000,
      );
    } else {
      ts = DateTime.now();
    }
    return ReactionItem(
      msgId: json['msg_id'] as String? ?? json['msgId'] as String? ?? '',
      senderJid: json['sender_jid'] as String? ??
          json['senderJid'] as String? ??
          '',
      emoji: json['emoji'] as String? ?? '',
      timestamp: ts,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'msg_id': msgId,
      'sender_jid': senderJid,
      'emoji': emoji,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReactionItem &&
          runtimeType == other.runtimeType &&
          msgId == other.msgId &&
          senderJid == other.senderJid &&
          emoji == other.emoji;

  @override
  int get hashCode => Object.hash(msgId, senderJid, emoji);
}
