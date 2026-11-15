import '../models/reaction_item.dart';

/// Contract for handling message interactions: reactions, quoting, starring, and revoking.
abstract interface class IInteractionRepository {
  /// Sends an emoji reaction for a message.
  Future<void> sendReaction({
    required String chatJid,
    required String senderJid,
    required String msgId,
    required String emoji,
  });

  /// Stars or unstars a message.
  Future<void> starMessage({
    required String chatJid,
    required String senderJid,
    required String msgId,
    required bool fromMe,
    required bool isStarred,
  });

  /// Revokes a message for everyone.
  Future<void> revokeMessage({
    required String chatJid,
    required String senderJid,
    required String msgId,
  });

  /// Deletes a message locally ("delete for me").
  Future<void> deleteMessageForMe(String msgId);

  /// Retrieves reactions for a message from local storage.
  Future<List<ReactionItem>> getReactions(String msgId);

  /// Stream of reaction events.
  Stream<ReactionItem> get reactionStream;

  /// Stream of revoked message IDs.
  Stream<String> get revokeStream;

  /// Disposes interaction subscriptions.
  void dispose();
}
