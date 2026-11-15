/// Represents contact profile details.
class ContactInfo {
  final String jid;
  final String displayName;
  final String? phone;
  final String? about;
  final bool isBlocked;

  const ContactInfo({
    required this.jid,
    required this.displayName,
    this.phone,
    this.about,
    this.isBlocked = false,
  });

  ContactInfo copyWith({
    String? jid,
    String? displayName,
    String? phone,
    String? about,
    bool? isBlocked,
  }) {
    return ContactInfo(
      jid: jid ?? this.jid,
      displayName: displayName ?? this.displayName,
      phone: phone ?? this.phone,
      about: about ?? this.about,
      isBlocked: isBlocked ?? this.isBlocked,
    );
  }

  factory ContactInfo.fromJson(Map<String, dynamic> json) {
    return ContactInfo(
      jid: json['jid'] as String? ?? '',
      displayName: json['display_name'] as String? ??
          json['displayName'] as String? ??
          json['name'] as String? ??
          '',
      phone: json['phone'] as String?,
      about: json['about'] as String? ?? json['status'] as String?,
      isBlocked: json['is_blocked'] as bool? ??
          json['isBlocked'] as bool? ??
          false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'jid': jid,
      'display_name': displayName,
      if (phone != null) 'phone': phone,
      if (about != null) 'about': about,
      'is_blocked': isBlocked,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContactInfo &&
          runtimeType == other.runtimeType &&
          jid == other.jid &&
          displayName == other.displayName &&
          phone == other.phone &&
          about == other.about &&
          isBlocked == other.isBlocked;

  @override
  int get hashCode => Object.hash(jid, displayName, phone, about, isBlocked);
}
