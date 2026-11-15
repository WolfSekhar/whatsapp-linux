import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:material_ui/material_ui.dart';
import '../../../domain/models/message_item.dart';
import '../../../theme/app_colors.dart';
import 'media/media_bubble_router.dart';

/// WhatsApp-styled speech bubble supporting text and rich media attachments.
class MessageBubble extends StatelessWidget {
  final MessageItem message;
  final VoidCallback? onMediaTap;
  final VoidCallback? onOpen;
  final VoidCallback? onDownload;

  const MessageBubble({
    super.key,
    required this.message,
    this.onMediaTap,
    this.onOpen,
    this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMe = message.isFromMe;
    final hasMedia = message.mediaType != null && message.mediaType!.isNotEmpty;
    final isSticker = message.mediaType == 'sticker';

    if (isSticker) {
      return Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
          child: MediaBubbleRouter(
            message: message,
            onMediaTap: onMediaTap,
            onOpen: onOpen,
            onDownload: onDownload,
          ),
        ),
      );
    }

    final bubbleBg = isMe
        ? (isDark ? const Color(0xFF005C4B) : const Color(0xFFD9FDD3))
        : (isDark ? AppColors.darkPanel : AppColors.lightPanel);
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final timeColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
        constraints: const BoxConstraints(maxWidth: 520),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: bubbleBg,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(8),
            topRight: const Radius.circular(8),
            bottomLeft: Radius.circular(isMe ? 8 : 2),
            bottomRight: Radius.circular(isMe ? 2 : 8),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(isDark ? 30 : 15),
              blurRadius: 1,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (hasMedia)
              MediaBubbleRouter(
                message: message,
                onMediaTap: onMediaTap,
                onOpen: onOpen,
                onDownload: onDownload,
              )
            else
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  message.text,
                  style: TextStyle(fontSize: 14, color: textColor, height: 1.3),
                ),
              ),
            const SizedBox(height: 2),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _formatTime(message.timestamp),
                  style: TextStyle(fontSize: 11, color: timeColor),
                ),
                if (isMe) ...[
                  const SizedBox(width: 4),
                  _buildStatusIcon(message.status),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIcon(String status) {
    if (status == 'pending') {
      return const Icon(FluentIcons.clock_16_regular, size: 12, color: Colors.grey);
    }
    final isDelivered = status == 'delivered' || status == 'read';
    final isRead = status == 'read';
    final color = isRead ? const Color(0xFF53BDEB) : Colors.grey;

    return Icon(
      isDelivered
          ? FluentIcons.checkmark_starburst_16_regular
          : FluentIcons.checkmark_16_regular,
      size: 13,
      color: color,
    );
  }

  String _formatTime(DateTime time) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}
