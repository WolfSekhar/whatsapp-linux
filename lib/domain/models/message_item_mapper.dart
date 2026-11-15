import 'message_item.dart';
import 'quoted_item.dart';

/// Serialization mapper for [MessageItem].
class MessageItemMapper {
  static MessageItem fromJson(Map<String, dynamic> json) {
    final rawTs = json['timestamp'] ?? json['time'];
    DateTime timestamp = DateTime.fromMillisecondsSinceEpoch(0);
    if (rawTs is int) {
      timestamp = DateTime.fromMillisecondsSinceEpoch(
        rawTs > 100000000000 ? rawTs : rawTs * 1000,
      );
    } else if (rawTs is String) {
      timestamp = DateTime.tryParse(rawTs) ?? timestamp;
    }

    QuotedItem? quoted;
    if (json['quoted'] is Map) {
      quoted = QuotedItem.fromJson(Map<String, dynamic>.from(json['quoted'] as Map));
    } else if (json['quoted_id'] != null && (json['quoted_id'] as String).isNotEmpty) {
      quoted = QuotedItem(
        id: json['quoted_id'] as String,
        senderJid: json['quoted_sender'] as String? ?? '',
        text: json['quoted_text'] as String? ?? '',
      );
    }

    return MessageItem(
      id: json['id'] as String? ?? '',
      chatJid: json['chatJid'] as String? ?? json['chat_jid'] as String? ?? '',
      senderJid: json['senderJid'] as String? ?? json['sender_jid'] as String? ?? '',
      text: json['text'] as String? ?? json['body'] as String? ?? '',
      timestamp: timestamp,
      isFromMe: (json['isFromMe'] ?? json['from_me'] ?? json['is_from_me'] as bool?) ?? false,
      status: json['status'] as String? ?? 'sent',
      quoted: quoted,
      isStarred: json['isStarred'] == true || json['is_starred'] == 1,
      isRevoked: json['isRevoked'] == true || json['is_revoked'] == 1,
      mediaType: json['mediaType'] as String? ?? json['media_type'] as String?,
      fileName: json['fileName'] as String? ?? json['file_name'] as String?,
      fileSize: json['fileSize'] as int? ?? json['file_size'] as int?,
      mimeType: json['mimeType'] as String? ?? json['mime_type'] as String?,
      localPath: json['localPath'] as String? ?? json['local_path'] as String?,
      thumbnailBase64: json['thumbnailBase64'] as String? ??
          json['thumbnail_base64'] as String? ??
          json['thumbnail'] as String?,
      duration: json['duration'] as int?,
    );
  }

  static Map<String, dynamic> toJson(MessageItem item) {
    return {
      'id': item.id,
      'chatJid': item.chatJid,
      'senderJid': item.senderJid,
      'text': item.text,
      'timestamp': item.timestamp.millisecondsSinceEpoch,
      'isFromMe': item.isFromMe,
      'status': item.status,
      'is_starred': item.isStarred ? 1 : 0,
      'is_revoked': item.isRevoked ? 1 : 0,
      if (item.quoted != null) 'quoted': item.quoted!.toJson(),
      if (item.mediaType != null) 'media_type': item.mediaType,
      if (item.fileName != null) 'file_name': item.fileName,
      if (item.fileSize != null) 'file_size': item.fileSize,
      if (item.mimeType != null) 'mime_type': item.mimeType,
      if (item.localPath != null) 'local_path': item.localPath,
      if (item.thumbnailBase64 != null) 'thumbnail_base64': item.thumbnailBase64,
      if (item.duration != null) 'duration': item.duration,
    };
  }
}
