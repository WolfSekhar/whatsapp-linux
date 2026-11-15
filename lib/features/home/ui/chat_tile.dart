import 'package:material_ui/material_ui.dart';
import 'package:yaru/yaru.dart';
import '../../../domain/chat.dart';
import '../../../theme/app_colors.dart';

/// Conversation tile styled for Yaru Linux desktop.
class ChatTile extends StatelessWidget {
  final Chat chat;
  final bool isSelected;
  final VoidCallback onTap;

  const ChatTile({
    super.key,
    required this.chat,
    required this.isSelected,
    required this.onTap,
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

    return Container(
      color: isSelected
          ? (isDark ? AppColors.viridian.withValues(alpha: 0.25) : AppColors.viridian.withValues(alpha: 0.12))
          : Colors.transparent,
      child: YaruListTile(
        onTap: onTap,
        leading: CircleAvatar(
          radius: 20,
          backgroundColor: isDark ? AppColors.darkBorder : Colors.grey.shade300,
          child: Text(
            initial,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: primaryTextColor,
            ),
          ),
        ),
        title: Text(
          chat.name,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: primaryTextColor,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          chat.lastMessage ?? 'No messages yet',
          style: TextStyle(
            fontSize: 12,
            color: secondaryTextColor,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              timeStr,
              style: TextStyle(
                fontSize: 11,
                color: chat.unreadCount > 0 ? AppColors.primaryGreen : secondaryTextColor,
              ),
            ),
            if (chat.unreadCount > 0) ...[
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${chat.unreadCount}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
