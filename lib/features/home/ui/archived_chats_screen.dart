import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:material_ui/material_ui.dart';
import 'package:yaru/yaru.dart';

import '../../../domain/chat.dart';
import '../../../theme/app_colors.dart';
import '../controllers/chat_controller.dart';

/// Screen displaying all archived chats with unarchive action and back navigation.
class ArchivedChatsScreen extends StatelessWidget {
  final ChatController controller;
  final VoidCallback? onBack;
  final ValueChanged<Chat>? onChatTap;

  const ArchivedChatsScreen({
    super.key,
    required this.controller,
    this.onBack,
    this.onChatTap,
  });

  void _pop(BuildContext ctx) =>
      onBack != null ? onBack!() : Navigator.maybePop(ctx);

  void _select(Chat chat) {
    controller.selectChat(chat.jid);
    onChatTap?.call(chat);
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final (fg, sub) = dark
        ? (AppColors.darkTextPrimary, AppColors.darkTextSecondary)
        : (AppColors.lightTextPrimary, AppColors.lightTextSecondary);

    return Container(
      color: dark ? AppColors.darkBackground : AppColors.lightBackground,
      child: Column(
        children: [
          _buildHeader(context, fg),
          const Divider(height: 1),
          Expanded(
            child: ListenableBuilder(
              listenable: controller,
              builder: (ctx, _) {
                final list = controller.chatRepository.currentChats
                    .where((c) => c.isArchived)
                    .toList();
                return list.isEmpty
                    ? _buildEmpty(sub)
                    : ListView.separated(
                        itemCount: list.length,
                        separatorBuilder: (_, _) => const Divider(height: 1),
                        itemBuilder: (_, i) =>
                            _buildTile(list[i], dark, fg, sub),
                      );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Color fg) {
    final ts = TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: fg);
    return SizedBox(
      height: 48,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(FluentIcons.arrow_left_24_regular, size: 20),
            tooltip: 'Back',
            onPressed: () => _pop(context),
          ),
          Text('Archived Chats', style: ts),
        ],
      ),
    );
  }

  Widget _buildEmpty(Color sub) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          FluentIcons.archive_24_regular,
          size: 48,
          color: sub.withAlpha(120),
        ),
        const SizedBox(height: 12),
        Text('No archived chats', style: TextStyle(color: sub)),
      ],
    ),
  );

  Widget _buildTile(Chat c, bool dark, Color fg, Color sub) {
    final sel = controller.selectedChatJid == c.jid;
    final init = c.name.isNotEmpty ? c.name[0].toUpperCase() : '?';
    final bg = sel ? AppColors.viridian.withAlpha(dark ? 64 : 30) : null;
    final titleStyle = TextStyle(
      fontSize: 14,
      fontWeight: sel ? FontWeight.bold : FontWeight.w500,
      color: fg,
    );

    return Container(
      color: bg,
      child: YaruListTile(
        onTap: () => _select(c),
        leading: CircleAvatar(
          radius: 18,
          backgroundColor: dark ? AppColors.darkBorder : Colors.grey.shade300,
          child: Text(
            init,
            style: TextStyle(fontWeight: FontWeight.bold, color: fg),
          ),
        ),
        title: Text(
          c.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: titleStyle,
        ),
        subtitle: Text(
          c.lastMessage ?? 'No messages yet',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 12, color: sub),
        ),
        trailing: IconButton(
          icon: const Icon(FluentIcons.archive_arrow_back_24_regular, size: 20),
          tooltip: 'Unarchive chat',
          onPressed: () => controller.chatRepository.archiveChat(c.jid, false),
        ),
      ),
    );
  }
}
