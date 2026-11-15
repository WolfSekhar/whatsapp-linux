/// Represents an ephemeral status / story update from a contact or self.
class StatusStoryItem {
  final String id;
  final String senderJid;
  final String senderName;
  final DateTime timestamp;
  final String? caption;
  final String? mediaUrl;
  final String mediaType; // "text", "image", "video"
  final String? backgroundColor;
  final bool isViewed;

  const StatusStoryItem({
    required this.id,
    required this.senderJid,
    required this.senderName,
    required this.timestamp,
    this.caption,
    this.mediaUrl,
    this.mediaType = 'text',
    this.backgroundColor,
    this.isViewed = false,
  });

  StatusStoryItem copyWith({
    String? id,
    String? senderJid,
    String? senderName,
    DateTime? timestamp,
    String? caption,
    String? mediaUrl,
    String? mediaType,
    String? backgroundColor,
    bool? isViewed,
  }) {
    return StatusStoryItem(
      id: id ?? this.id,
      senderJid: senderJid ?? this.senderJid,
      senderName: senderName ?? this.senderName,
      timestamp: timestamp ?? this.timestamp,
      caption: caption ?? this.caption,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      mediaType: mediaType ?? this.mediaType,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      isViewed: isViewed ?? this.isViewed,
    );
  }

  factory StatusStoryItem.fromJson(Map<String, dynamic> json) {
    return StatusStoryItem(
      id: json['id'] as String? ?? '',
      senderJid: json['sender_jid'] as String? ?? '',
      senderName: json['sender_name'] as String? ?? '',
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        (json['timestamp'] as num?)?.toInt() ?? 0,
      ),
      caption: json['caption'] as String?,
      mediaUrl: json['media_url'] as String?,
      mediaType: json['media_type'] as String? ?? 'text',
      backgroundColor: json['background_color'] as String?,
      isViewed: json['is_viewed'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sender_jid': senderJid,
      'sender_name': senderName,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'caption': caption,
      'media_url': mediaUrl,
      'media_type': mediaType,
      'background_color': backgroundColor,
      'is_viewed': isViewed,
    };
  }
}
