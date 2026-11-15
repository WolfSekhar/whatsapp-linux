import 'package:material_ui/material_ui.dart';
import '../../../domain/chat.dart';
import '../../../domain/repositories/i_chat_repository.dart';
import '../../../domain/repositories/i_media_repository.dart';
import '../../../theme/app_colors.dart';
import '../controllers/conversation_controller.dart';
import 'chat_header.dart';
import 'media_viewer_dialog.dart';
import 'message_bubble.dart';
import 'message_input_bar.dart';

/// Full interactive active conversation pane displaying messages and input controls.
class ChatConversationView extends StatefulWidget {
  final Chat chat;
  final IChatRepository repository;
  final IMediaRepository? mediaRepository;

  const ChatConversationView({
    super.key,
    required this.chat,
    required this.repository,
    this.mediaRepository,
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
              builder: (context, _) {
                if (_controller.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                final msgs = _controller.messages;
                if (msgs.isEmpty) {
                  return Center(
                    child: Text(
                      'No messages yet. Type below to start.',
                      style: TextStyle(
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                  );
                }
                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: msgs.length,
                  itemBuilder: (context, i) {
                    final msg = msgs[i];
                    return MessageBubble(
                      message: msg,
                      onMediaTap: () => MediaViewerDialog.show(
                        context,
                        title: msg.fileName ?? widget.chat.name,
                        subtitle: widget.chat.name,
                        mediaType: msg.mediaType,
                        localPath: msg.localPath,
                        onDownload: () => _controller.downloadMedia(msg),
                      ),
                      onOpen: () => _controller.openMedia(msg),
                      onDownload: () => _controller.downloadMedia(msg),
                    );
                  },
                );
              },
            ),
          ),
        ),
        const Divider(height: 1),
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
  }

  @override
  void dispose() {
    _controller.removeListener(_scrollToBottom);
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
