import 'group_participant.dart';

/// Represents detailed metadata for a WhatsApp group chat.
class GroupInfo {
  final String jid;
  final String? ownerJid;
  final String topic;
  final String? topicSetBy;
  final DateTime? topicSetAt;
  final DateTime? creationTimestamp;
  final bool isLocked;
  final bool isAnnounce;
  final List<GroupParticipant> participants;

  const GroupInfo({
    required this.jid,
    this.ownerJid,
    required this.topic,
    this.topicSetBy,
    this.topicSetAt,
    this.creationTimestamp,
    this.isLocked = false,
    this.isAnnounce = false,
    this.participants = const [],
  });

  GroupInfo copyWith({
    String? jid,
    String? ownerJid,
    String? topic,
    String? topicSetBy,
    DateTime? topicSetAt,
    DateTime? creationTimestamp,
    bool? isLocked,
    bool? isAnnounce,
    List<GroupParticipant>? participants,
  }) {
    return GroupInfo(
      jid: jid ?? this.jid,
      ownerJid: ownerJid ?? this.ownerJid,
      topic: topic ?? this.topic,
      topicSetBy: topicSetBy ?? this.topicSetBy,
      topicSetAt: topicSetAt ?? this.topicSetAt,
      creationTimestamp: creationTimestamp ?? this.creationTimestamp,
      isLocked: isLocked ?? this.isLocked,
      isAnnounce: isAnnounce ?? this.isAnnounce,
      participants: participants ?? this.participants,
    );
  }

  factory GroupInfo.fromJson(Map<String, dynamic> json) {
    final rawParticipants = json['participants'];
    final participants = <GroupParticipant>[];
    if (rawParticipants is List) {
      for (final p in rawParticipants) {
        if (p is Map) {
          participants.add(
            GroupParticipant.fromJson(Map<String, dynamic>.from(p)),
          );
        }
      }
    }

    return GroupInfo(
      jid: json['jid'] as String? ?? json['group_jid'] as String? ?? '',
      ownerJid: json['owner_jid'] as String? ?? json['ownerJid'] as String?,
      topic: json['topic'] as String? ?? json['subject'] as String? ?? '',
      topicSetBy: json['topic_set_by'] as String? ??
          json['topicSetBy'] as String?,
      topicSetAt: _parseDateTime(json['topic_set_at'] ?? json['topicSetAt']),
      creationTimestamp: _parseDateTime(
        json['creation_timestamp'] ??
            json['creationTimestamp'] ??
            json['created_at'],
      ),
      isLocked:
          json['is_locked'] as bool? ?? json['isLocked'] as bool? ?? false,
      isAnnounce:
          json['is_announce'] as bool? ?? json['isAnnounce'] as bool? ?? false,
      participants: participants,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'jid': jid,
      if (ownerJid != null) 'owner_jid': ownerJid,
      'topic': topic,
      if (topicSetBy != null) 'topic_set_by': topicSetBy,
      if (topicSetAt != null) 'topic_set_at': topicSetAt!.millisecondsSinceEpoch,
      if (creationTimestamp != null)
        'creation_timestamp': creationTimestamp!.millisecondsSinceEpoch,
      'is_locked': isLocked,
      'is_announce': isAnnounce,
      'participants': participants.map((p) => p.toJson()).toList(),
    };
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(
        value > 100000000000 ? value : value * 1000,
      );
    }
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}
