/// Local client preferences for theme, desktop behavior, and appearance.
class AppPreferences {
  final String themeMode; // "system", "dark", "light"
  final bool enterIsSend;
  final String? customWallpaper;
  final bool desktopNotifications;
  final bool messagePreview;
  final bool soundAlerts;
  final double fontScale;

  const AppPreferences({
    this.themeMode = 'system',
    this.enterIsSend = true,
    this.customWallpaper,
    this.desktopNotifications = true,
    this.messagePreview = true,
    this.soundAlerts = true,
    this.fontScale = 1.0,
  });

  AppPreferences copyWith({
    String? themeMode,
    bool? enterIsSend,
    String? customWallpaper,
    bool? desktopNotifications,
    bool? messagePreview,
    bool? soundAlerts,
    double? fontScale,
  }) {
    return AppPreferences(
      themeMode: themeMode ?? this.themeMode,
      enterIsSend: enterIsSend ?? this.enterIsSend,
      customWallpaper: customWallpaper ?? this.customWallpaper,
      desktopNotifications:
          desktopNotifications ?? this.desktopNotifications,
      messagePreview: messagePreview ?? this.messagePreview,
      soundAlerts: soundAlerts ?? this.soundAlerts,
      fontScale: fontScale ?? this.fontScale,
    );
  }

  factory AppPreferences.fromJson(Map<String, dynamic> json) {
    return AppPreferences(
      themeMode: json['theme_mode'] as String? ?? 'system',
      enterIsSend: json['enter_is_send'] as bool? ?? true,
      customWallpaper: json['custom_wallpaper'] as String?,
      desktopNotifications:
          json['desktop_notifications'] as bool? ?? true,
      messagePreview: json['message_preview'] as bool? ?? true,
      soundAlerts: json['sound_alerts'] as bool? ?? true,
      fontScale: (json['font_scale'] as num?)?.toDouble() ?? 1.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'theme_mode': themeMode,
      'enter_is_send': enterIsSend,
      'custom_wallpaper': customWallpaper,
      'desktop_notifications': desktopNotifications,
      'message_preview': messagePreview,
      'sound_alerts': soundAlerts,
      'font_scale': fontScale,
    };
  }
}
