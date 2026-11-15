import 'package:material_ui/material_ui.dart';
import '../../../domain/chat.dart';
import '../../../domain/repositories/i_chat_repository.dart';
import '../../../domain/repositories/i_group_repository.dart';
import '../../../domain/repositories/i_interaction_repository.dart';
import '../../../domain/repositories/i_media_repository.dart';
import '../../../theme/app_colors.dart';
import '../../chat_info/controllers/chat_info_controller.dart';
import '../../chat_info/ui/chat_info_drawer.dart';
import '../controllers/conversation_controller.dart';
import 'chat_header.dart';
import 'chat_message_list.dart';
import 'conversation_input_area.dart';

/// Full interactive active conversation pane displaying messages and info drawer.
class ChatConversationView extends StatefulWidget {
  final Chat chat;
  final IChatRepository repository;
  final IMediaRepository? mediaRepository;
  final IInteractionRepository? interactionRepository;
  final IGroupRepository? groupRepository;

  const ChatConversationView({
    super.key,
    required this.chat,
    required this.repository,
    this.mediaRepository,
    this.interactionRepository,
    this.groupRepository,
  });

  @override
  State<ChatConversationView> createState() => _ChatConversationViewState();
}

class _ChatConversationViewState extends State<ChatConversationView> {
  final ScrollController _scrollController = ScrollController();
  late ConversationController _controller;
  ChatInfoController? _infoController;
  bool _isInfoDrawerOpen = false;

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  void _initControllers() {
    _controller = ConversationController(
      repository: widget.repository,
      mediaRepository: widget.mediaRepository,
      interactionRepository: widget.interactionRepository,
      chatJid: widget.chat.jid,
    )..addListener(_scrollToBottom);

    final repo = widget.groupRepository;
    if (repo != null) {
      _infoController = ChatInfoController(chat: widget.chat, repository: repo);
    }
  }

  @override
  void didUpdateWidget(ChatConversationView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.chat.jid != widget.chat.jid) {
      _controller.removeListener(_scrollToBottom);
      _controller.dispose();
      _infoController?.dispose();
      _initControllers();
      _isInfoDrawerOpen = false;
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBackground : const Color(0xFFEFEAE2);

    return Row(
      children: [
        Expanded(
          child: Column(
            children: [
              ChatHeader(
                chat: widget.chat,
                onInfoTap: () => setState(() => _isInfoDrawerOpen = !_isInfoDrawerOpen),
              ),
              const Divider(height: 1),
              Expanded(
                child: Container(
                  color: bg,
                  child: ListenableBuilder(
                    listenable: _controller,
                    builder: (context, _) => ChatMessageList(
                      scrollController: _scrollController,
                      controller: _controller,
                      chat: widget.chat,
                    ),
                  ),
                ),
              ),
              const Divider(height: 1),
              ConversationInputArea(controller: _controller, chatName: widget.chat.name),
            ],
          ),
        ),
        if (_isInfoDrawerOpen && _infoController != null)
          ChatInfoDrawer(
            controller: _infoController!,
            onClose: () => setState(() => _isInfoDrawerOpen = false),
          ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.removeListener(_scrollToBottom);
    _controller.dispose();
    _infoController?.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
