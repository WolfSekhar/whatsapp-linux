import 'package:material_ui/material_ui.dart';
import '../../../domain/chat.dart';
import '../../../domain/repositories/i_chat_repository.dart';
import '../../../domain/repositories/i_interaction_repository.dart';
import '../../../domain/repositories/i_media_repository.dart';
import '../../../theme/app_colors.dart';
import '../controllers/conversation_controller.dart';
import 'chat_header.dart';
import 'chat_message_list.dart';
import 'interactions/reply_input_banner.dart';
import 'media_viewer_dialog.dart';
import 'message_input_bar.dart';

/// Full interactive active conversation pane displaying messages and input controls.
class ChatConversationView extends StatefulWidget {
  final Chat chat;
  final IChatRepository repository;
  final IMediaRepository? mediaRepository;
  final IInteractionRepository? interactionRepository;

  const ChatConversationView({
    super.key,
    required this.chat,
    required this.repository,
    this.mediaRepository,
    this.interactionRepository,
  });

  @override
  State<ChatConversationView> createState() => _ChatConversationViewState();
}

class _ChatConversationViewState extends State<ChatConversationView> {
  final ScrollController _scrollController = ScrollController();
  late ConversationController _controller;

  @override
  void initState() {
    super.initState();
    _initController();
  }

  void _initController() {
    _controller = ConversationController(
      repository: widget.repository,
      mediaRepository: widget.mediaRepository,
      interactionRepository: widget.interactionRepository,
      chatJid: widget.chat.jid,
    );
    _controller.addListener(_scrollToBottom);
  }

  @override
  void didUpdateWidget(ChatConversationView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.chat.jid != widget.chat.jid) {
      _controller.removeListener(_scrollToBottom);
      _controller.dispose();
      _initController();
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

    return Column(
      children: [
        ChatHeader(chat: widget.chat),
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
        ListenableBuilder(
          listenable: _controller,
          builder: (context, _) {
            final quote = _controller.activeQuote;
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (quote != null)
                  ReplyInputBanner(quoted: quote, onDismiss: _controller.clearReply),
                MessageInputBar(
                  onSend: _controller.sendMessage,
                  onAttach: () => MediaViewerDialog.show(
                    context,
                    title: 'Media Viewer',
                    subtitle: widget.chat.name,
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.removeListener(_scrollToBottom);
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
