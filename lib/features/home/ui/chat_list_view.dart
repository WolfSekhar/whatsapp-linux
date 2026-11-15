import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:material_ui/material_ui.dart';
import 'package:yaru/yaru.dart';
import '../../../domain/chat.dart';
import '../../../domain/models/chat_filter_type.dart';
import '../controllers/chat_controller.dart';
import 'archived_row_tile.dart';
import 'chat_tile.dart';
import 'chat_tile_action_handler.dart';
import 'chat_tile_context_menu.dart';
import 'filters/chat_filter_pills.dart';

/// Conversation list pane styled with desktop search, filter pills, and context actions.
class ChatListView extends StatelessWidget {
  final ChatController controller;

  const ChatListView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final chats = controller.chats;
        final isArchived = controller.activeFilter == ChatFilterType.archived;

        return Column(
          children: [
            _buildHeader(isArchived),
            _buildSearchBox(),
            if (!isArchived)
              ChatFilterPills(
                activeFilter: controller.activeFilter,
                unreadCount: controller.unreadCount,
                onSelectFilter: controller.setFilter,
              ),
            const Divider(height: 1),
            Expanded(
              child: controller.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildList(context, chats, isArchived),
            ),
          ],
        );
      },
    );
  }

  Widget _buildList(BuildContext context, List<Chat> chats, bool isArchived) {
    final showArchived = !isArchived && controller.hasArchivedChats;
    final total = chats.length + (showArchived ? 1 : 0);
    if (total == 0) return _buildEmptySearch(isArchived);

    return ListView.separated(
      itemCount: total,
      separatorBuilder: (context, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        if (showArchived && index == 0) {
          return ArchivedRowTile(
            count: controller.archivedCount,
            onTap: () => controller.setFilter(ChatFilterType.archived),
          );
        }
        final chat = chats[showArchived ? index - 1 : index];
        return ChatTile(
          chat: chat,
          isSelected: controller.selectedChatJid == chat.jid,
          onTap: () => controller.selectChat(chat.jid),
          onSecondaryTapDown: (details) async {
            final action = await ChatTileContextMenu.show(context, details.globalPosition, chat);
            if (action != null) {
              ChatTileActionHandler.handle(action: action, chat: chat, controller: controller);
            }
          },
        );
      },
    );
  }

  Widget _buildHeader(bool isArchived) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (isArchived)
                IconButton(
                  icon: const Icon(FluentIcons.arrow_left_24_regular, size: 20),
                  tooltip: 'Back to all chats',
                  onPressed: () => controller.setFilter(ChatFilterType.all),
                ),
              Text(
                isArchived ? 'Archived' : 'Chats',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          if (!isArchived)
            Row(
              children: [
                IconButton(
                  icon: const Icon(FluentIcons.compose_24_regular, size: 18),
                  tooltip: 'New Chat',
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(FluentIcons.more_vertical_24_regular, size: 18),
                  tooltip: 'Menu',
                  onPressed: () {},
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildSearchBox() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: YaruSearchField(
        hintText: 'Search or start new chat',
        autofocus: false,
        onChanged: controller.setSearchQuery,
        onClear: controller.clearSearch,
      ),
    );
  }

  Widget _buildEmptySearch(bool isArchived) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          isArchived ? 'No archived chats' : 'No chats found',
          style: const TextStyle(color: Colors.grey, fontSize: 13),
        ),
      ),
    );
  }
}
