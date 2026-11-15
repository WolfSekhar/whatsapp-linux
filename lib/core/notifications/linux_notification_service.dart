import 'dart:io';
import '../../domain/models/app_preferences.dart';

/// Service responsible for delivering native desktop notifications on Linux.
class LinuxNotificationService {
  final String appName;
  final String defaultIcon;

  const LinuxNotificationService({
    this.appName = 'WhatsApp Linux',
    this.defaultIcon = 'whatsapp',
  });

  /// Sends a desktop notification if enabled in [preferences].
  Future<bool> showNotification({
    required String title,
    required String body,
    String? icon,
    AppPreferences? preferences,
  }) async {
    if (!Platform.isLinux) return false;

    if (preferences != null && !preferences.desktopNotifications) {
      return false;
    }

    final displayBody = (preferences != null && !preferences.messagePreview)
        ? 'New message received'
        : body;

    try {
      final args = <String>[
        '--app-name=$appName',
        '--icon=${icon ?? defaultIcon}',
        '--urgency=normal',
        '--hint=string:sound-name:message-new-instant',
        title,
        displayBody,
      ];

      final result = await Process.run('notify-send', args);

      if (preferences?.soundAlerts ?? true) {
        _playNotificationSound();
      }

      return result.exitCode == 0;
    } catch (_) {
      return false;
    }
  }

  /// Attempts to play a native Linux alert sound using freedesktop sound utilities.
  void _playNotificationSound() {
    try {
      Process.run('canberra-gtk-play', ['-i', 'message-new-instant']).catchError((_) {
        return ProcessResult(0, 1, '', 'canberra-gtk-play unavailable');
      });
    } catch (_) {
      // Ignored if sound player is not installed or audio is muted.
    }
  }
}
