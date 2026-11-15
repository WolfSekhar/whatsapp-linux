import 'dart:async';
import '../../../domain/models/message_item.dart';
import '../../../domain/models/quoted_item.dart';
import '../../../domain/models/reaction_item.dart';
import '../../../domain/repositories/i_interaction_repository.dart';

/// Manages interaction state (active quote, reactions, stars, revokes) for a conversation.
class ConversationInteractionHandler {
  final IInteractionRepository? interactionRepository;
  final String chatJid;
  final void Function() onStateChanged;

  QuotedItem? _activeQuote;
  final Map<String, List<ReactionItem>> _reactions = {};
  StreamSubscription<ReactionItem>? _reactionSub;
  StreamSubscription<String>? _revokeSub;

  ConversationInteractionHandler({
    required this.interactionRepository,
    required this.chatJid,
    required this.onStateChanged,
  }) {
    _init();
  }

  QuotedItem? get activeQuote => _activeQuote;
  List<ReactionItem> getReactions(String msgId) => _reactions[msgId] ?? const [];

  void _init() {
    if (interactionRepository == null) return;
    _reactionSub = interactionRepository!.reactionStream.listen((reaction) {
      final list = _reactions.putIfAbsent(reaction.msgId, () => []);
      list.removeWhere((r) => r.senderJid == reaction.senderJid);
      if (reaction.emoji.isNotEmpty) {
        list.add(reaction);
      }
      onStateChanged();
    });

    _revokeSub = interactionRepository!.revokeStream.listen((_) => onStateChanged());
  }

  /// Sets the active message being replied to.
  void setReply(MessageItem msg) {
    _activeQuote = QuotedItem(
      id: msg.id,
      senderJid: msg.isFromMe ? 'me' : msg.senderJid,
      text: msg.text,
    );
    onStateChanged();
  }

  /// Clears active reply quote.
  void clearReply() {
    _activeQuote = null;
    onStateChanged();
  }

  /// Sends or toggles an emoji reaction on [msg].
  Future<void> react(MessageItem msg, String emoji) async {
    if (interactionRepository == null) return;
    final list = _reactions.putIfAbsent(msg.id, () => []);
    final existingIdx = list.indexWhere((r) => r.senderJid == 'me');
    final activeEmoji = existingIdx != -1 ? list[existingIdx].emoji : '';
    final newEmoji = activeEmoji == emoji ? '' : emoji;

    await interactionRepository!.sendReaction(
      chatJid: chatJid,
      senderJid: msg.senderJid,
      msgId: msg.id,
      emoji: newEmoji,
    );
  }

  /// Toggles starred status of [msg].
  Future<void> toggleStar(MessageItem msg) async {
    if (interactionRepository == null) return;
    await interactionRepository!.starMessage(
      chatJid: chatJid,
      senderJid: msg.senderJid,
      msgId: msg.id,
      fromMe: msg.isFromMe,
      isStarred: !msg.isStarred,
    );
  }

  /// Revokes a message for everyone.
  Future<void> revokeMessage(MessageItem msg) async {
    if (interactionRepository == null) return;
    await interactionRepository!.revokeMessage(
      chatJid: chatJid,
      senderJid: msg.senderJid,
      msgId: msg.id,
    );
  }

  /// Deletes a message locally for me.
  Future<void> deleteForMe(MessageItem msg) async {
    if (interactionRepository == null) return;
    await interactionRepository!.deleteMessageForMe(msg.id);
  }

  void dispose() {
    _reactionSub?.cancel();
    _revokeSub?.cancel();
  }
}
