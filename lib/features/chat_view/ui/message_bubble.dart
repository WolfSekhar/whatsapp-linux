import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:material_ui/material_ui.dart';
import '../../../domain/models/message_item.dart';
import '../../../domain/models/reaction_item.dart';
import '../../../theme/app_colors.dart';
import 'interactions/message_context_menu.dart';
import 'interactions/quoted_preview_card.dart';
import 'interactions/reaction_pills.dart';
import 'media/media_bubble_router.dart';
import 'message_bubble_footer.dart';

/// WhatsApp-styled speech bubble supporting text, media, quotes, and reactions.
class MessageBubble extends StatelessWidget {
  final MessageItem message;
  final List<ReactionItem> reactions;
  final VoidCallback? onMediaTap;
  final VoidCallback? onOpen;
  final VoidCallback? onDownload;
  final VoidCallback? onQuotedTap;
  final void Function(MessageMenuAction action)? onMenuAction;
  final ValueChanged<String>? onReactionTap;

  const MessageBubble({
    super.key,
    required this.message,
    this.reactions = const [],
    this.onMediaTap,
    this.onOpen,
    this.onDownload,
    this.onQuotedTap,
    this.onMenuAction,
    this.onReactionTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMe = message.isFromMe;
    final hasMedia = message.mediaType != null && message.mediaType!.isNotEmpty;

    if (message.mediaType == 'sticker') {
      return Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
          child: MediaBubbleRouter(message: message),
        ),
      );
    }

    final bubbleBg = isMe
        ? (isDark ? const Color(0xFF005C4B) : const Color(0xFFD9FDD3))
        : (isDark ? AppColors.darkPanel : AppColors.lightPanel);

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onSecondaryTapUp: (details) async {
          final action = await MessageContextMenu.show(
            context: context,
            position: details.globalPosition,
            message: message,
          );
          if (action != null) onMenuAction?.call(action);
        },
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
            mainAxisSize: MainAxisSize.min,
            children: [
              if (message.quoted != null)
                QuotedPreviewCard(quoted: message.quoted!, onTap: onQuotedTap),
              if (message.isRevoked)
                _buildRevokedContent(isDark)
              else if (hasMedia)
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
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      height: 1.3,
                    ),
                  ),
                ),
              const SizedBox(height: 2),
              MessageBubbleFooter(message: message),
              if (reactions.isNotEmpty)
                ReactionPills(reactions: reactions, onReactionTap: onReactionTap),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRevokedContent(bool isDark) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(FluentIcons.prohibited_16_regular, size: 14, color: Colors.grey),
          const SizedBox(width: 6),
          Text(
            'This message was deleted',
            style: TextStyle(
              fontSize: 13,
              fontStyle: FontStyle.italic,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
        ],
      );
}
