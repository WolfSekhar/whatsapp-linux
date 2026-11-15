import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:material_ui/material_ui.dart';
import 'package:yaru/yaru.dart';
import '../controllers/chat_controller.dart';
import 'chat_tile.dart';

/// Conversation list pane styled with desktop search and actions.
class ChatListView extends StatelessWidget {
  final ChatController controller;

  const ChatListView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final chats = controller.chats;

        return Column(
          children: [
            _buildHeader(context),
            _buildSearchBox(),
            const Divider(height: 1),
            Expanded(
              child: controller.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : chats.isEmpty
                      ? _buildEmptySearch()
                      : ListView.separated(
                          itemCount: chats.length,
                          separatorBuilder: (context, _) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final chat = chats[index];
                            final isSelected = controller.selectedChatJid == chat.jid;
                            return ChatTile(
                              chat: chat,
                              isSelected: isSelected,
                              onTap: () => controller.selectChat(chat.jid),
                            );
                          },
                        ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Chats',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: YaruSearchField(
        hintText: 'Search or start new chat',
        autofocus: false,
        onChanged: controller.setSearchQuery,
        onClear: controller.clearSearch,
      ),
    );
  }

  Widget _buildEmptySearch() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'No chats found',
          style: TextStyle(color: Colors.grey, fontSize: 13),
        ),
      ),
    );
  }
}
