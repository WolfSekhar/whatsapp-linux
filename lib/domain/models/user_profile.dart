/// Represents the authenticated user's profile details.
class UserProfile {
  final String jid;
  final String name;
  final String about;
  final String? avatarUrl;
  final String phone;

  const UserProfile({
    required this.jid,
    required this.name,
    this.about = '',
    this.avatarUrl,
    this.phone = '',
  });

  UserProfile copyWith({
    String? jid,
    String? name,
    String? about,
    String? avatarUrl,
    String? phone,
  }) {
    return UserProfile(
      jid: jid ?? this.jid,
      name: name ?? this.name,
      about: about ?? this.about,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      phone: phone ?? this.phone,
    );
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      jid: json['jid'] as String? ?? '',
      name: json['name'] as String? ?? 'Me',
      about: json['about'] as String? ?? 'Hey there! I am using WhatsApp.',
      avatarUrl: json['avatar_url'] as String?,
      phone: json['phone'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'jid': jid,
      'name': name,
      'about': about,
      'avatar_url': avatarUrl,
      'phone': phone,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserProfile &&
          runtimeType == other.runtimeType &&
          jid == other.jid &&
          name == other.name &&
          about == other.about &&
          avatarUrl == other.avatarUrl &&
          phone == other.phone;

  @override
  int get hashCode => Object.hash(jid, name, about, avatarUrl, phone);
}
