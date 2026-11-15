/// Represents a WhatsApp message in a conversation.
class MessageItem {
  final String id;
  final String chatJid;
  final String senderJid;
  final String text;
  final DateTime timestamp;
  final bool isFromMe;
  final String status;

  const MessageItem({
    required this.id,
    required this.chatJid,
    required this.senderJid,
    required this.text,
    required this.timestamp,
    required this.isFromMe,
    this.status = 'sent',
  });

  factory MessageItem.fromJson(Map<String, dynamic> json) {
    final rawTs = json['timestamp'] ?? json['time'];
    DateTime timestamp;
    if (rawTs is int) {
      timestamp = DateTime.fromMillisecondsSinceEpoch(
        rawTs > 100000000000 ? rawTs : rawTs * 1000,
      );
    } else if (rawTs is String) {
      timestamp = DateTime.tryParse(rawTs) ??
          DateTime.fromMillisecondsSinceEpoch(0);
    } else {
      timestamp = DateTime.fromMillisecondsSinceEpoch(0);
    }

    return MessageItem(
      id: json['id'] as String? ?? '',
      chatJid: json['chatJid'] as String? ??
          json['chat_jid'] as String? ??
          '',
      senderJid: json['senderJid'] as String? ??
          json['sender_jid'] as String? ??
          '',
      text: json['text'] as String? ??
          json['body'] as String? ??
          '',
      timestamp: timestamp,
      isFromMe: (json['isFromMe'] ??
              json['from_me'] ??
              json['is_from_me'] as bool?) ??
          false,
      status: json['status'] as String? ?? 'sent',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chatJid': chatJid,
      'senderJid': senderJid,
      'text': text,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'isFromMe': isFromMe,
      'status': status,
    };
  }

  MessageItem copyWith({
    String? id,
    String? chatJid,
    String? senderJid,
    String? text,
    DateTime? timestamp,
    bool? isFromMe,
    String? status,
  }) {
    return MessageItem(
      id: id ?? this.id,
      chatJid: chatJid ?? this.chatJid,
      senderJid: senderJid ?? this.senderJid,
      text: text ?? this.text,
      timestamp: timestamp ?? this.timestamp,
      isFromMe: isFromMe ?? this.isFromMe,
      status: status ?? this.status,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessageItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          chatJid == other.chatJid &&
          senderJid == other.senderJid &&
          text == other.text &&
          timestamp == other.timestamp &&
          isFromMe == other.isFromMe &&
          status == other.status;

  @override
  int get hashCode => Object.hash(
        id,
        chatJid,
        senderJid,
        text,
        timestamp,
        isFromMe,
        status,
      );

  @override
  String toString() =>
      'MessageItem(id: $id, chatJid: $chatJid, text: $text)';
}
