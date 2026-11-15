import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:material_ui/material_ui.dart';

import '../../../theme/app_colors.dart';
import '../controllers/settings_controller.dart';
import 'tabs/about_diagnostics_tab.dart';
import 'tabs/chats_appearance_tab.dart';
import 'tabs/general_tab.dart';
import 'tabs/notifications_tab.dart';
import 'tabs/privacy_tab.dart';

/// Desktop modal dialog displaying WhatsApp settings with tab navigation.
class SettingsDialog extends StatefulWidget {
  final SettingsController controller;
  final Widget? privacyTab, notificationsTab;
  final VoidCallback? onLogout;

  const SettingsDialog({
    super.key,
    required this.controller,
    this.privacyTab,
    this.notificationsTab,
    this.onLogout,
  });

  static Future<void> show(
    BuildContext context, {
    required SettingsController controller,
    Widget? privacyTab,
    Widget? notificationsTab,
    VoidCallback? onLogout,
  }) =>
      showDialog<void>(
        context: context,
        barrierDismissible: true,
        builder: (_) => SettingsDialog(
          controller: controller,
          privacyTab: privacyTab,
          notificationsTab: notificationsTab,
          onLogout: onLogout,
        ),
      );

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  int _selectedIndex = 0;

  static const _navItems = [
    (FluentIcons.settings_24_regular, 'General'),
    (FluentIcons.paint_bucket_24_regular, 'Chats & Appearance'),
    (FluentIcons.lock_shield_24_regular, 'Privacy'),
    (FluentIcons.alert_24_regular, 'Notifications'),
    (FluentIcons.info_24_regular, 'About & Diagnostics'),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final railBg = isDark ? AppColors.darkRail : AppColors.lightRail;

    return Dialog(
      backgroundColor: bg,
      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 820, maxHeight: 600),
        child: Column(
          children: [
            _buildHeader(context),
            const Divider(height: 1),
            Expanded(
              child: Row(
                children: [
                  Container(
                    width: 220,
                    color: railBg,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: _navItems.length,
                      itemBuilder: (ctx, i) => _buildNavItem(i, isDark),
                    ),
                  ),
                  const VerticalDivider(width: 1),
                  Expanded(child: _buildTabContent()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            const Text('Settings',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const Spacer(),
            IconButton(
              icon: const Icon(FluentIcons.dismiss_24_regular, size: 20),
              tooltip: 'Close',
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );

  Widget _buildNavItem(int index, bool isDark) {
    final item = _navItems[index];
    final isSelected = _selectedIndex == index;
    final color = isSelected
        ? AppColors.primaryGreen
        : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary);

    return ListTile(
      dense: true,
      selected: isSelected,
      selectedTileColor: isDark ? AppColors.darkPanel : Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      leading: Icon(item.$1, size: 20, color: color),
      title: Text(item.$2,
          style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal)),
      onTap: () => setState(() => _selectedIndex = index),
    );
  }

  Widget _buildTabContent() => switch (_selectedIndex) {
        0 => GeneralTab(controller: widget.controller),
        1 => ChatsAppearanceTab(controller: widget.controller),
        2 => widget.privacyTab ?? PrivacyTab(controller: widget.controller),
        3 => widget.notificationsTab ??
            NotificationsTab(controller: widget.controller),
        4 => AboutDiagnosticsTab(
            controller: widget.controller, onLogout: widget.onLogout),
        _ => const SizedBox.shrink(),
      };
}
