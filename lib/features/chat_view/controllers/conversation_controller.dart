import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../domain/models/message_item.dart';
import '../../../domain/repositories/i_chat_repository.dart';

/// Controller managing message history and dispatch for an active conversation.
class ConversationController extends ChangeNotifier {
  final IChatRepository repository;
  final String chatJid;
  final List<MessageItem> _messages = [];
  StreamSubscription<MessageItem>? _messageSub;
  bool _isLoading = true;

  ConversationController({
    required this.repository,
    required this.chatJid,
  }) {
    _init();
  }

  List<MessageItem> get messages => List.unmodifiable(_messages);
  bool get isLoading => _isLoading;

  Future<void> _init() async {
    final cached = await repository.getMessages(chatJid);
    _messages.addAll(cached);
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

    final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
    final localMsg = MessageItem(
      id: tempId,
      chatJid: chatJid,
      senderJid: 'me',
      text: trimmed,
      timestamp: DateTime.now(),
      isFromMe: true,
      status: 'pending',
    );
    _messages.add(localMsg);
    notifyListeners();

    try {
      await repository.sendMessage(chatJid, trimmed);
    } catch (_) {
      final idx = _messages.indexWhere((m) => m.id == tempId);
      if (idx != -1) {
        _messages[idx] = localMsg.copyWith(status: 'error');
        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    _messageSub?.cancel();
    super.dispose();
  }
}
