/// Represents user-configurable privacy controls in WhatsApp.
class PrivacySettings {
  final String readReceipts; // "all", "none"
  final String lastSeen;     // "all", "contacts", "contact_blacklist", "none"
  final String profilePhoto;  // "all", "contacts", "contact_blacklist", "none"
  final String about;         // "all", "contacts", "contact_blacklist", "none"
  final List<String> blocklist;

  const PrivacySettings({
    this.readReceipts = 'all',
    this.lastSeen = 'all',
    this.profilePhoto = 'all',
    this.about = 'all',
    this.blocklist = const [],
  });

  bool get readReceiptsEnabled => readReceipts != 'none';

  PrivacySettings copyWith({
    String? readReceipts,
    String? lastSeen,
    String? profilePhoto,
    String? about,
    List<String>? blocklist,
  }) {
    return PrivacySettings(
      readReceipts: readReceipts ?? this.readReceipts,
      lastSeen: lastSeen ?? this.lastSeen,
      profilePhoto: profilePhoto ?? this.profilePhoto,
      about: about ?? this.about,
      blocklist: blocklist ?? this.blocklist,
    );
  }

  factory PrivacySettings.fromJson(Map<String, dynamic> json) {
    return PrivacySettings(
      readReceipts: json['read_receipts'] as String? ?? 'all',
      lastSeen: json['last_seen'] as String? ?? 'all',
      profilePhoto: json['profile_photo'] as String? ?? 'all',
      about: json['about'] as String? ?? 'all',
      blocklist: (json['blocklist'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'read_receipts': readReceipts,
      'last_seen': lastSeen,
      'profile_photo': profilePhoto,
      'about': about,
      'blocklist': blocklist,
    };
  }
}
