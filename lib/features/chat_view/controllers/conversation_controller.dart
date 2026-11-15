import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../domain/models/message_item.dart';
import '../../../domain/models/quoted_item.dart';
import '../../../domain/models/reaction_item.dart';
import '../../../domain/repositories/i_chat_repository.dart';
import '../../../domain/repositories/i_interaction_repository.dart';
import '../../../domain/repositories/i_media_repository.dart';
import 'conversation_interaction_handler.dart';

/// Controller managing message history and dispatch for an active conversation.
class ConversationController extends ChangeNotifier {
  final IChatRepository repository;
  final IMediaRepository? mediaRepository;
  final IInteractionRepository? interactionRepository;
  final String chatJid;
  final List<MessageItem> _messages = [];
  late final ConversationInteractionHandler _interactionHandler;
  StreamSubscription<MessageItem>? _messageSub;
  bool _isLoading = true;

  ConversationController({
    required this.repository,
    required this.chatJid,
    this.mediaRepository,
    this.interactionRepository,
  }) {
    _interactionHandler = ConversationInteractionHandler(
      interactionRepository: interactionRepository,
      chatJid: chatJid,
      onStateChanged: notifyListeners,
    );
    _init();
  }

  List<MessageItem> get messages => List.unmodifiable(_messages);
  bool get isLoading => _isLoading;
  QuotedItem? get activeQuote => _interactionHandler.activeQuote;
  List<ReactionItem> getReactions(String msgId) => _interactionHandler.getReactions(msgId);

  void setReply(MessageItem msg) => _interactionHandler.setReply(msg);
  void clearReply() => _interactionHandler.clearReply();
  Future<void> react(MessageItem msg, String emoji) => _interactionHandler.react(msg, emoji);
  Future<void> revokeMessage(MessageItem msg) => _interactionHandler.revokeMessage(msg);
  Future<void> deleteForMe(MessageItem msg) => _interactionHandler.deleteForMe(msg);

  Future<void> toggleStar(MessageItem msg) async {
    final idx = _messages.indexWhere((m) => m.id == msg.id);
    if (idx != -1) {
      _messages[idx] = _messages[idx].copyWith(isStarred: !msg.isStarred);
      notifyListeners();
    }
    await _interactionHandler.toggleStar(msg);
  }

  Future<void> _init() async {
    _messages.addAll(await repository.getMessages(chatJid));
    _isLoading = false;
    notifyListeners();

    _messageSub = repository.messageStream.listen((msg) {
      final isMatch = msg.chatJid == chatJid ||
          (msg.chatJid.contains('@') &&
              chatJid.contains('@') &&
              msg.chatJid.split('@').first == chatJid.split('@').first);
      if (isMatch) {
        final existingIndex = _messages.indexWhere((m) => m.id == msg.id);
        if (existingIndex != -1) {
          _messages[existingIndex] = msg;
        } else {
          _messages.add(msg);
        }
        notifyListeners();
      }
    });
  }

  /// Sends a text message to the active chat and appends an optimistic local bubble.
  Future<void> sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    final quote = _interactionHandler.activeQuote;
    _interactionHandler.clearReply();

    final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
    final localMsg = MessageItem(
      id: tempId,
      chatJid: chatJid,
      senderJid: 'me',
      text: trimmed,
      timestamp: DateTime.now(),
      isFromMe: true,
      status: 'pending',
      quoted: quote,
    );
    _messages.add(localMsg);
    notifyListeners();

    try {
      await repository.sendMessage(chatJid, trimmed, quoted: quote);
    } catch (_) {
      final idx = _messages.indexWhere((m) => m.id == tempId);
      if (idx != -1) {
        _messages[idx] = localMsg.copyWith(status: 'error');
        notifyListeners();
      }
    }
  }

  /// Downloads media attachment for [msg] and updates local message state.
  Future<void> downloadMedia(MessageItem msg) async {
    if (mediaRepository == null) return;
    final path = await mediaRepository!.downloadMedia(
      messageId: msg.id,
      chatJid: chatJid,
      mediaType: msg.mediaType,
    );
    if (path != null) {
      final idx = _messages.indexWhere((m) => m.id == msg.id);
      if (idx != -1) {
        _messages[idx] = _messages[idx].copyWith(localPath: path);
        notifyListeners();
      }
    }
  }

  /// Opens cached media with native desktop app or downloads then opens.
  Future<void> openMedia(MessageItem msg) async {
    if (mediaRepository == null) return;
    if (msg.localPath != null && mediaRepository!.isFileAvailable(msg.localPath)) {
      await mediaRepository!.openMediaFile(msg.localPath!);
    } else {
      await downloadMedia(msg);
      final idx = _messages.indexWhere((m) => m.id == msg.id);
      if (idx != -1 && _messages[idx].localPath != null) {
        await mediaRepository!.openMediaFile(_messages[idx].localPath!);
      }
    }
  }

  @override
  void dispose() {
    _messageSub?.cancel();
    _interactionHandler.dispose();
    super.dispose();
  }
}
