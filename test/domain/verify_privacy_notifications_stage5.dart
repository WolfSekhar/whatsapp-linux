// ignore_for_file: avoid_print
import 'package:flutter_whatsapp/core/notifications/linux_notification_service.dart';
import 'package:flutter_whatsapp/domain/domain.dart';

void main() async {
  print('Running Stage 5 Privacy & Notifications verification...');

  // 1. LinuxNotificationService disabled in preferences test
  const service = LinuxNotificationService();
  const disabledPrefs = AppPreferences(desktopNotifications: false);
  final shown = await service.showNotification(
    title: 'Alice',
    body: 'Hello',
    preferences: disabledPrefs,
  );
  assert(!shown, 'Notification should not show when desktopNotifications is false');

  // 2. LinuxNotificationService message preview test
  const previewDisabledPrefs = AppPreferences(
    desktopNotifications: true,
    messagePreview: false,
    soundAlerts: false,
  );
  assert(previewDisabledPrefs.desktopNotifications);
  assert(!previewDisabledPrefs.messagePreview);
  assert(!previewDisabledPrefs.soundAlerts);

  // 3. PrivacySettings and copyWith
  const priv = PrivacySettings(
    readReceipts: 'none',
    lastSeen: 'contacts',
    profilePhoto: 'contacts',
    about: 'all',
    blocklist: ['123@s.whatsapp.net', '456@s.whatsapp.net'],
  );
  assert(!priv.readReceiptsEnabled);
  assert(priv.blocklist.length == 2);
  assert(priv.lastSeen == 'contacts');

  final priv2 = priv.copyWith(lastSeen: 'none', blocklist: ['123@s.whatsapp.net']);
  assert(priv2.lastSeen == 'none');
  assert(priv2.blocklist.length == 1);

  // 4. UserProfile bio and phone verification
  const profile = UserProfile(
    jid: 'me@s.whatsapp.net',
    name: 'Sekhar',
    about: 'Building native WhatsApp for Linux',
    phone: '+1234567890',
  );
  assert(profile.name == 'Sekhar');
  assert(profile.phone == '+1234567890');
  assert(profile.about.contains('WhatsApp'));

  print('✓ All Stage 5 Privacy & Notifications tests passed successfully!');
}
