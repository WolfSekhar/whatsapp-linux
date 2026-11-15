import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:material_ui/material_ui.dart';
import '../../../domain/models/chat_item.dart';

/// Available actions for the chat tile desktop context menu.
enum ChatTileMenuAction {
  pin,
  unpin,
  markRead,
  markUnread,
  archive,
  unarchive,
  mute,
  clear,
  delete,
}

/// Helper for displaying right-click desktop context menu on a chat tile.
class ChatTileContextMenu {
  const ChatTileContextMenu._();

  /// Shows the context menu at [position] for the given [chat].
  static Future<ChatTileMenuAction?> show(
    BuildContext context,
    Offset position,
    ChatItem chat,
  ) async {
    final isPinned = chat.isPinned;
    final isUnread = chat.unreadCount > 0;
    final isArchived = chat.isArchived;

    return showMenu<ChatTileMenuAction>(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        position.dx + 1,
        position.dy + 1,
      ),
      items: [
        _buildItem(
          isPinned ? ChatTileMenuAction.unpin : ChatTileMenuAction.pin,
          isPinned ? 'Unpin chat' : 'Pin chat',
          isPinned ? FluentIcons.pin_off_24_regular : FluentIcons.pin_24_regular,
        ),
        _buildItem(
          isUnread ? ChatTileMenuAction.markRead : ChatTileMenuAction.markUnread,
          isUnread ? 'Mark as read' : 'Mark as unread',
          isUnread ? FluentIcons.mail_read_24_regular : FluentIcons.mail_unread_24_regular,
        ),
        _buildItem(
          isArchived ? ChatTileMenuAction.unarchive : ChatTileMenuAction.archive,
          isArchived ? 'Unarchive chat' : 'Archive chat',
          FluentIcons.archive_24_regular,
        ),
        _buildItem(
          ChatTileMenuAction.mute,
          chat.isMuted ? 'Unmute' : 'Mute notifications',
          FluentIcons.speaker_mute_24_regular,
        ),
        const PopupMenuDivider(),
        _buildItem(
          ChatTileMenuAction.clear,
          'Clear messages',
          FluentIcons.broom_24_regular,
          isDestructive: true,
        ),
        _buildItem(
          ChatTileMenuAction.delete,
          'Delete chat',
          FluentIcons.delete_24_regular,
          isDestructive: true,
        ),
      ],
    );
  }

  static PopupMenuItem<ChatTileMenuAction> _buildItem(
    ChatTileMenuAction action,
    String title,
    IconData icon, {
    bool isDestructive = false,
  }) {
    return PopupMenuItem<ChatTileMenuAction>(
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
