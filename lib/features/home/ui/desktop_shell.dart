import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:material_ui/material_ui.dart';
import '../../../theme/app_colors.dart';
import '../../chat_view/chat_view.dart';
import '../../settings/controllers/settings_controller.dart';
import '../../settings/ui/profile_drawer.dart';
import '../../settings/ui/settings_dialog.dart';
import '../../shell/shell.dart';
import '../../status/controllers/status_controller.dart';
import '../../status/ui/status_stories_viewer.dart';
import '../controllers/chat_controller.dart';
import 'chat_list_view.dart';
import 'empty_chat_view.dart';

/// Top-level desktop shell providing three-pane native Linux layout.
class DesktopShell extends StatefulWidget {
  final ChatController controller;
  final SettingsController? settingsController;
  final StatusController? statusController;

  const DesktopShell({
    super.key,
    required this.controller,
    this.settingsController,
    this.statusController,
  });

  @override
  State<DesktopShell> createState() => _DesktopShellState();
}

class _DesktopShellState extends State<DesktopShell> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  SettingsController? get _settings =>
      widget.settingsController ?? widget.controller.settingsController;

  @override
  Widget build(BuildContext context) {
    final settings = _settings;
    return Scaffold(
      key: _scaffoldKey,
      drawer: settings != null ? ProfileDrawer(controller: settings) : null,
      appBar: const NativeWindowHeader(
        statusText: 'Connected',
        isConnected: true,
      ),
      body: Row(
        children: [
          _buildRail(context),
          const VerticalDivider(width: 1),
          SizedBox(
            width: 360,
            child: ChatListView(controller: widget.controller),
          ),
          const VerticalDivider(width: 1),
          Expanded(
            child: ListenableBuilder(
              listenable: widget.controller,
              builder: (context, _) {
                final chat = widget.controller.selectedChat;
                if (chat == null) return const EmptyChatView();
                return ChatConversationView(
                  chat: chat,
                  repository: widget.controller.chatRepository,
                  mediaRepository: widget.controller.mediaRepository,
                  interactionRepository: widget.controller.interactionRepository,
                  groupRepository: widget.controller.groupRepository,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRail(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final railBg = isDark ? AppColors.darkRail : AppColors.lightRail;

    return Container(
      width: 58,
      color: railBg,
      child: Column(
        children: [
          const SizedBox(height: 12),
          IconButton(
            icon: const Icon(FluentIcons.chat_24_filled, color: AppColors.primaryGreen, size: 22),
            tooltip: 'Chats',
            onPressed: () {},
          ),
          const SizedBox(height: 8),
          _buildStatusButton(),
          const SizedBox(height: 8),
          IconButton(
            icon: const Icon(FluentIcons.settings_24_regular, size: 22),
            tooltip: 'Settings',
            onPressed: () {
              final s = _settings;
              if (s != null) SettingsDialog.show(context, controller: s);
            },
          ),
          const Spacer(),
          IconButton(
            icon: const CircleAvatar(
              radius: 16,
              child: Icon(FluentIcons.person_24_regular, size: 18),
            ),
            tooltip: 'Profile',
            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildStatusButton() {
    final status = widget.statusController;
    Widget button = IconButton(
      icon: const Icon(FluentIcons.status_24_regular, size: 22),
      tooltip: 'Status',
      onPressed: status == null
          ? null
          : () => StatusStoriesViewer.show(context, controller: status),
    );

    if (status == null) return button;

    return ListenableBuilder(
      listenable: status,
      builder: (context, _) => Badge(
        isLabelVisible: status.hasUnread,
        backgroundColor: AppColors.primaryGreen,
        smallSize: 8,
        child: button,
      ),
    );
  }
}
