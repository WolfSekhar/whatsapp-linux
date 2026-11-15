/// Represents a quoted parent message snippet.
class QuotedItem {
  final String id;
  final String senderJid;
  final String text;

  const QuotedItem({
    required this.id,
    required this.senderJid,
    required this.text,
  });

  factory QuotedItem.fromJson(Map<String, dynamic> json) {
    return QuotedItem(
      id: json['id'] as String? ?? json['stanza_id'] as String? ?? '',
      senderJid: json['sender_jid'] as String? ??
          json['participant'] as String? ??
          json['senderJid'] as String? ??
          '',
      text: json['text'] as String? ?? json['body'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sender_jid': senderJid,
      'text': text,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuotedItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          senderJid == other.senderJid &&
          text == other.text;

  @override
  int get hashCode => Object.hash(id, senderJid, text);
}
