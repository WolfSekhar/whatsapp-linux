import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:material_ui/material_ui.dart';
import '../../../theme/app_colors.dart';

/// Clean in-app window header respecting native desktop server-side window decorations.
class NativeWindowHeader extends StatelessWidget implements PreferredSizeWidget {
  final String statusText;
  final bool isConnected;
  final Widget? trailingActions;

  const NativeWindowHeader({
    super.key,
    this.statusText = 'WhatsApp',
    this.isConnected = false,
    this.trailingActions,
  });

  @override
  Size get preferredSize => const Size.fromHeight(42);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dotColor = isConnected ? AppColors.primaryGreen : Colors.orangeAccent;
    final headerBg = isDark ? AppColors.darkRail : AppColors.lightRail;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return Container(
      height: preferredSize.height,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: headerBg,
        border: Border(bottom: BorderSide(color: borderColor, width: 1)),
      ),
      child: Row(
        children: [
          const Icon(
            FluentIcons.chat_24_filled,
            color: AppColors.primaryGreen,
            size: 20,
          ),
          const SizedBox(width: 10),
          Text(
            'WhatsApp',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: textColor,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            statusText,
            style: TextStyle(
              fontSize: 11,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
          const Spacer(),
          ?trailingActions,
        ],
      ),
    );
  }
}
