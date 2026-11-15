import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../theme/app_colors.dart';
import '../../controllers/settings_controller.dart';

/// Tab presenting application build diagnostics, cache management, and logout.
class AboutDiagnosticsTab extends StatelessWidget {
  final SettingsController controller;
  final VoidCallback? onLogout;

  const AboutDiagnosticsTab({
    super.key,
    required this.controller,
    this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _header('About'),
        const SizedBox(height: 8),
        const ListTile(
          leading: Icon(FluentIcons.chat_24_regular, color: AppColors.primaryGreen),
          title: Text('WhatsApp for Linux'),
          subtitle: Text('v1.0.0+1 (Linux x86_64 · Wayland native)'),
        ),
        const ListTile(
          leading: Icon(FluentIcons.shield_24_regular),
          title: Text('Protocol Engine'),
          subtitle: Text('whatsmeow Multi-Device (Dynamic Version Sync)'),
        ),
        const Divider(height: 32),
        _header('Storage & Cache'),
        const SizedBox(height: 8),
        ListTile(
          leading: const Icon(FluentIcons.storage_24_regular),
          title: const Text('Local Media Cache'),
          subtitle: const Text('Cached thumbnails, voice notes, and media files'),
          trailing: OutlinedButton(
            onPressed: () => _confirmClearCache(context),
            child: const Text('Clear Cache'),
          ),
        ),
        const Divider(height: 32),
        _header('Session'),
        const SizedBox(height: 8),
        ListTile(
          leading: const Icon(
            FluentIcons.sign_out_24_regular,
            color: AppColors.errorRed,
          ),
          title: const Text('Log Out', style: TextStyle(color: AppColors.errorRed)),
          subtitle: const Text('Clear local session credentials and unpair device'),
          trailing: FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.errorRed),
            onPressed: () => _confirmLogout(context),
            child: const Text('Log Out'),
          ),
        ),
      ],
    );
  }

  Widget _header(String title) => Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryGreen,
        ),
      );

  Future<void> _confirmClearCache(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear Media Cache?'),
        content: const Text(
          'Cached media and thumbnails will be removed. Chat messages will not be deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Clear', style: TextStyle(color: AppColors.errorRed)),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await controller.clearMediaCache();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Media cache cleared successfully')),
        );
      }
    }
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log out of WhatsApp?'),
        content: const Text(
          'Are you sure you want to log out? You will need to scan QR code again to sign in.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Log Out', style: TextStyle(color: AppColors.errorRed)),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      Navigator.of(context).pop();
      onLogout?.call();
    }
  }
}
