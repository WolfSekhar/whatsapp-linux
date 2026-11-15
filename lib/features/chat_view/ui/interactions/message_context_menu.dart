import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import '../../../../domain/models/message_item.dart';

/// Desktop context menu actions for message bubble right-click.
enum MessageMenuAction { reply, react, star, copy, deleteForMe, deleteForEveryone }

class MessageContextMenu {
  static Future<MessageMenuAction?> show({
    required BuildContext context,
    required Offset position,
    required MessageItem message,
  }) async {
    final isMe = message.isFromMe;
    final isStarred = message.isStarred;

    final selected = await showMenu<MessageMenuAction>(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        position.dx + 1,
        position.dy + 1,
      ),
      items: [
        _buildItem(
          MessageMenuAction.reply,
          'Reply',
          FluentIcons.arrow_reply_24_regular,
        ),
        _buildItem(
          MessageMenuAction.react,
          'React',
          FluentIcons.emoji_smile_slight_24_regular,
        ),
        _buildItem(
          MessageMenuAction.star,
          isStarred ? 'Unstar' : 'Star',
          isStarred ? FluentIcons.star_off_24_regular : FluentIcons.star_24_regular,
        ),
        _buildItem(
          MessageMenuAction.copy,
          'Copy text',
          FluentIcons.copy_24_regular,
        ),
        const PopupMenuDivider(),
        _buildItem(
          MessageMenuAction.deleteForMe,
          'Delete for me',
          FluentIcons.delete_24_regular,
          isDestructive: true,
        ),
        if (isMe)
          _buildItem(
            MessageMenuAction.deleteForEveryone,
            'Delete for everyone',
            FluentIcons.delete_dismiss_24_regular,
            isDestructive: true,
          ),
      ],
    );

    if (selected == MessageMenuAction.copy && message.text.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: message.text));
    }

    return selected;
  }

  static PopupMenuItem<MessageMenuAction> _buildItem(
    MessageMenuAction action,
    String title,
    IconData icon, {
    bool isDestructive = false,
  }) {
    return PopupMenuItem<MessageMenuAction>(
      value: action,
      height: 36,
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: isDestructive ? Colors.redAccent : null,
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              color: isDestructive ? Colors.redAccent : null,
            ),
          ),
        ],
      ),
    );
  }
}
