/// Represents a participant in a WhatsApp group.
class GroupParticipant {
  final String jid;
  final String? displayName;
  final bool isAdmin;
  final bool isSuperAdmin;

  const GroupParticipant({
    required this.jid,
    this.displayName,
    this.isAdmin = false,
    this.isSuperAdmin = false,
  });

  GroupParticipant copyWith({
    String? jid,
    String? displayName,
    bool? isAdmin,
    bool? isSuperAdmin,
  }) {
    return GroupParticipant(
      jid: jid ?? this.jid,
      displayName: displayName ?? this.displayName,
      isAdmin: isAdmin ?? this.isAdmin,
      isSuperAdmin: isSuperAdmin ?? this.isSuperAdmin,
    );
  }

  factory GroupParticipant.fromJson(Map<String, dynamic> json) {
    return GroupParticipant(
      jid: json['jid'] as String? ?? json['user_jid'] as String? ?? '',
      displayName: json['display_name'] as String? ??
          json['displayName'] as String?,
      isAdmin: json['is_admin'] as bool? ??
          json['isAdmin'] as bool? ??
          false,
      isSuperAdmin: json['is_super_admin'] as bool? ??
          json['isSuperAdmin'] as bool? ??
          false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'jid': jid,
      if (displayName != null) 'display_name': displayName,
      'is_admin': isAdmin,
      'is_super_admin': isSuperAdmin,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GroupParticipant &&
          runtimeType == other.runtimeType &&
          jid == other.jid &&
          displayName == other.displayName &&
          isAdmin == other.isAdmin &&
          isSuperAdmin == other.isSuperAdmin;

  @override
  int get hashCode => Object.hash(jid, displayName, isAdmin, isSuperAdmin);
}
