/// Represents a WhatsApp chat conversation.
class ChatItem {
  final String jid;
  final String name;
  final String? lastMessage;
  final DateTime lastMessageTimestamp;
  final int unreadCount;
  final String? avatarUrl;
  final bool isGroup;
  final bool isPinned;
  final bool isArchived;
  final int muteUntil;

  ChatItem({
    required this.jid,
    String? name,
    this.lastMessage,
    DateTime? lastMessageTimestamp,
    DateTime? lastMessageTime,
    this.unreadCount = 0,
    this.avatarUrl,
    this.isGroup = false,
    this.isPinned = false,
    this.isArchived = false,
    this.muteUntil = 0,
  })  : name = (name != null && name.trim().isNotEmpty) ? name.trim() : formatJidName(jid),
        lastMessageTimestamp = lastMessageTimestamp ?? lastMessageTime ?? DateTime.fromMillisecondsSinceEpoch(0);

  static String formatJidName(String jid) {
    final at = jid.indexOf('@');
    final user = at != -1 ? jid.substring(0, at) : jid;
    if (jid.endsWith('@s.whatsapp.net')) return '+$user';
    if (jid.endsWith('@g.us')) return 'Group Chat';
    return user.isNotEmpty ? user : 'Contact';
  }

  DateTime get lastMessageTime => lastMessageTimestamp;
  bool get isMuted => muteUntil > 0 && (muteUntil == -1 || muteUntil * 1000 > DateTime.now().millisecondsSinceEpoch);

  factory ChatItem.fromJson(Map<String, dynamic> json) {
    final rawTs = json['lastMessageTimestamp'] ?? json['last_message_timestamp'] ?? json['last_timestamp'] ?? json['timestamp'];
    DateTime timestamp;
    if (rawTs is int) {
      timestamp = DateTime.fromMillisecondsSinceEpoch(rawTs > 100000000000 ? rawTs : rawTs * 1000);
    } else if (rawTs is String) {
      timestamp = DateTime.tryParse(rawTs) ?? DateTime.fromMillisecondsSinceEpoch(0);
    } else {
      timestamp = DateTime.fromMillisecondsSinceEpoch(0);
    }

    final rawJid = json['jid'] as String? ?? '';
    final pinnedVal = json['isPinned'] ?? json['is_pinned'];
    final bool pinned = pinnedVal is bool ? pinnedVal : (((json['pinned'] as num?)?.toInt() ?? 0) > 0);
    final archVal = json['isArchived'] ?? json['is_archived'] ?? json['archived'];
    final bool archived = archVal is bool ? archVal : false;

    return ChatItem(
      jid: rawJid,
      name: (json['name'] as String?)?.trim(),
      lastMessage: json['lastMessage'] as String? ?? json['last_message'] as String? ?? json['body'] as String?,
      lastMessageTimestamp: timestamp,
      unreadCount: (json['unreadCount'] ?? json['unread_count'] as num?)?.toInt() ?? 0,
      avatarUrl: json['avatarUrl'] as String? ?? json['avatar_url'] as String?,
      isGroup: (json['isGroup'] ?? json['is_group'] as bool?) ?? rawJid.endsWith('@g.us'),
      isPinned: pinned,
      isArchived: archived,
      muteUntil: (json['muteUntil'] ?? json['mute_until'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'jid': jid,
    'name': name,
    if (lastMessage != null) 'lastMessage': lastMessage,
    'lastMessageTimestamp': lastMessageTimestamp.millisecondsSinceEpoch,
    'unreadCount': unreadCount,
    if (avatarUrl != null) 'avatarUrl': avatarUrl,
    'isGroup': isGroup,
    'isPinned': isPinned,
    'isArchived': isArchived,
    'muteUntil': muteUntil,
  };

  ChatItem copyWith({
    String? jid,
    String? name,
    String? lastMessage,
    DateTime? lastMessageTimestamp,
    DateTime? lastMessageTime,
    int? unreadCount,
    String? avatarUrl,
    bool? isGroup,
    bool? isPinned,
    bool? isArchived,
    int? muteUntil,
  }) => ChatItem(
    jid: jid ?? this.jid,
    name: name ?? this.name,
    lastMessage: lastMessage ?? this.lastMessage,
    lastMessageTimestamp: lastMessageTimestamp ?? lastMessageTime ?? this.lastMessageTimestamp,
    unreadCount: unreadCount ?? this.unreadCount,
    avatarUrl: avatarUrl ?? this.avatarUrl,
    isGroup: isGroup ?? this.isGroup,
    isPinned: isPinned ?? this.isPinned,
    isArchived: isArchived ?? this.isArchived,
    muteUntil: muteUntil ?? this.muteUntil,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatItem &&
          runtimeType == other.runtimeType &&
          jid == other.jid &&
          name == other.name &&
          lastMessage == other.lastMessage &&
          lastMessageTimestamp == other.lastMessageTimestamp &&
          unreadCount == other.unreadCount &&
          avatarUrl == other.avatarUrl &&
          isGroup == other.isGroup &&
          isPinned == other.isPinned &&
          isArchived == other.isArchived &&
          muteUntil == other.muteUntil;

  @override
  int get hashCode => Object.hash(
        jid,
        name,
        lastMessage,
        lastMessageTimestamp,
        unreadCount,
        avatarUrl,
        isGroup,
        isPinned,
        isArchived,
        muteUntil,
      );

  @override
  String toString() => 'ChatItem(jid: $jid, name: $name, unread: $unreadCount, pin: $isPinned, arch: $isArchived)';
}
