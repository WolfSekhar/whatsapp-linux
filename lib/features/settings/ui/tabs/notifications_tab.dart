import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/notifications/linux_notification_service.dart';
import '../../../../theme/app_colors.dart';
import '../../controllers/settings_controller.dart';

/// Notifications settings tab for desktop popups, previews, and sound alerts.
class NotificationsTab extends StatelessWidget {
  final SettingsController controller;
  final LinuxNotificationService _notificationService;

  const NotificationsTab({
    super.key,
    required this.controller,
    LinuxNotificationService? notificationService,
  }) : _notificationService =
            notificationService ?? const LinuxNotificationService();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final prefs = controller.preferences;
        return ListView(
          padding: const EdgeInsets.all(24),
          children: [
            _buildSectionHeader('System Notifications'),
            const SizedBox(height: 8),
            SwitchListTile(
              secondary: const Icon(FluentIcons.alert_24_regular),
              title: const Text('Desktop Notifications'),
              subtitle: const Text(
                'Show native system notification popups for new messages',
              ),
              value: prefs.desktopNotifications,
              onChanged: (val) => controller.updateDesktopNotifications(val),
            ),
            SwitchListTile(
              secondary: const Icon(FluentIcons.chat_24_regular),
              title: const Text('Show Message Preview'),
              subtitle: const Text(
                'Display sender name and message text in notifications',
              ),
              value: prefs.messagePreview,
              onChanged: prefs.desktopNotifications
                  ? (val) => controller.updateMessagePreview(val)
                  : null,
            ),
            const Divider(height: 32),
            _buildSectionHeader('Sounds & Alerts'),
            const SizedBox(height: 8),
            SwitchListTile(
              secondary: const Icon(FluentIcons.speaker_2_24_regular),
              title: const Text('Sound Alerts'),
              subtitle: const Text(
                'Play alert sound for incoming messages',
              ),
              value: prefs.soundAlerts,
              onChanged: (val) => controller.updateSoundAlerts(val),
            ),
            const SizedBox(height: 24),
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton.icon(
                icon: const Icon(FluentIcons.send_24_regular, size: 18),
                label: const Text('Send Test Notification'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryGreen,
                ),
                onPressed: () async {
                  await _notificationService.showNotification(
                    title: 'WhatsApp Linux',
                    body: 'Desktop notifications are active and working!',
                    preferences: controller.preferences,
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: AppColors.primaryGreen,
      ),
    );
  }
}
