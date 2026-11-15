import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:material_ui/material_ui.dart';
import 'package:yaru/yaru.dart';
import '../../../domain/chat.dart';
import '../../../theme/app_colors.dart';

/// Conversation tile styled for Yaru Linux desktop with Stage 3 indicators.
class ChatTile extends StatelessWidget {
  final Chat chat;
  final bool isSelected;
  final VoidCallback onTap;
  final GestureTapDownCallback? onSecondaryTapDown;

  const ChatTile({
    super.key,
    required this.chat,
    required this.isSelected,
    required this.onTap,
    this.onSecondaryTapDown,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final secondaryTextColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    final hasTimestamp = chat.lastMessageTimestamp.millisecondsSinceEpoch > 0;
    final hour = chat.lastMessageTime.hour.toString().padLeft(2, '0');
    final minute = chat.lastMessageTime.minute.toString().padLeft(2, '0');
    final timeStr = hasTimestamp ? '$hour:$minute' : '';
    final cleanName = chat.name.replaceAll('+', '').trim();
    final initial = cleanName.isNotEmpty ? cleanName[0].toUpperCase() : '?';

    final selectedBg = isDark
        ? AppColors.viridian.withValues(alpha: 0.25)
        : AppColors.viridian.withValues(alpha: 0.12);

    return GestureDetector(
      onSecondaryTapDown: onSecondaryTapDown,
      child: Container(
        color: isSelected ? selectedBg : Colors.transparent,
        child: YaruListTile(
          onTap: onTap,
          mouseCursor: SystemMouseCursors.click,
          hoverColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.04),
          leading: CircleAvatar(
            radius: 20,
            backgroundColor: isDark ? AppColors.darkBorder : Colors.grey.shade300,
            child: chat.isGroup && cleanName.isEmpty
                ? Icon(FluentIcons.people_20_regular, size: 20, color: primaryTextColor)
                : Text(initial, style: TextStyle(fontWeight: FontWeight.bold, color: primaryTextColor)),
          ),
          title: Text(
            chat.name,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected || chat.unreadCount > 0 ? FontWeight.w600 : FontWeight.w500,
              color: primaryTextColor,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            chat.lastMessage ?? 'No messages yet',
            style: TextStyle(fontSize: 12, color: secondaryTextColor),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: _buildTrailing(timeStr, secondaryTextColor),
        ),
      ),
    );
  }

  Widget _buildTrailing(String timeStr, Color secondaryTextColor) {
    final hasIndicators = chat.isPinned || chat.isMuted || chat.unreadCount > 0;
    if (timeStr.isEmpty && !hasIndicators) return const SizedBox.shrink();

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (timeStr.isNotEmpty)
          Text(
            timeStr,
            style: TextStyle(
              fontSize: 11,
              fontWeight: chat.unreadCount > 0 ? FontWeight.w600 : FontWeight.normal,
              color: chat.unreadCount > 0 ? AppColors.primaryGreen : secondaryTextColor,
            ),
          ),
        if (hasIndicators) ...[
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (chat.isMuted) ...[
                Icon(FluentIcons.speaker_mute_16_regular, size: 14, color: secondaryTextColor),
                if (chat.isPinned || chat.unreadCount > 0) const SizedBox(width: 4),
              ],
              if (chat.isPinned) ...[
                Icon(FluentIcons.pin_16_regular, size: 14, color: secondaryTextColor),
                if (chat.unreadCount > 0) const SizedBox(width: 4),
              ],
              if (chat.unreadCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${chat.unreadCount}',
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}
