import 'message_item_mapper.dart';
import 'quoted_item.dart';

/// Represents a WhatsApp message in a conversation.
class MessageItem {
  final String id;
  final String chatJid;
  final String senderJid;
  final String text;
  final DateTime timestamp;
  final bool isFromMe;
  final String status;
  final QuotedItem? quoted;
  final bool isStarred;
  final bool isRevoked;
  final String? mediaType;
  final String? fileName;
  final int? fileSize;
  final String? mimeType;
  final String? localPath;
  final String? thumbnailBase64;
  final int? duration;

  const MessageItem({
    required this.id,
    required this.chatJid,
    required this.senderJid,
    required this.text,
    required this.timestamp,
    required this.isFromMe,
    this.status = 'sent',
    this.quoted,
    this.isStarred = false,
    this.isRevoked = false,
    this.mediaType,
    this.fileName,
    this.fileSize,
    this.mimeType,
    this.localPath,
    this.thumbnailBase64,
    this.duration,
  });

  factory MessageItem.fromJson(Map<String, dynamic> json) =>
      MessageItemMapper.fromJson(json);

  Map<String, dynamic> toJson() => MessageItemMapper.toJson(this);

  MessageItem copyWith({
    String? id,
    String? chatJid,
    String? senderJid,
    String? text,
    DateTime? timestamp,
    bool? isFromMe,
    String? status,
    QuotedItem? quoted,
    bool? isStarred,
    bool? isRevoked,
    String? mediaType,
    String? fileName,
    int? fileSize,
    String? mimeType,
    String? localPath,
    String? thumbnailBase64,
    int? duration,
  }) {
    return MessageItem(
      id: id ?? this.id,
      chatJid: chatJid ?? this.chatJid,
      senderJid: senderJid ?? this.senderJid,
      text: text ?? this.text,
      timestamp: timestamp ?? this.timestamp,
      isFromMe: isFromMe ?? this.isFromMe,
      status: status ?? this.status,
      quoted: quoted ?? this.quoted,
      isStarred: isStarred ?? this.isStarred,
      isRevoked: isRevoked ?? this.isRevoked,
      mediaType: mediaType ?? this.mediaType,
      fileName: fileName ?? this.fileName,
      fileSize: fileSize ?? this.fileSize,
      mimeType: mimeType ?? this.mimeType,
      localPath: localPath ?? this.localPath,
      thumbnailBase64: thumbnailBase64 ?? this.thumbnailBase64,
      duration: duration ?? this.duration,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessageItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          chatJid == other.chatJid &&
          localPath == other.localPath &&
          isStarred == other.isStarred &&
          isRevoked == other.isRevoked &&
          status == other.status;

  @override
  int get hashCode => Object.hash(id, chatJid, isStarred, isRevoked, status);

  @override
  String toString() => 'MessageItem(id: $id, type: $mediaType, text: $text)';
}
