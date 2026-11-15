import 'dart:async';
import '../models/status_story_item.dart';

/// Manages ephemeral status story updates, read receipts, and broadcasts.
class StatusStoryHandler {
  final List<StatusStoryItem> _stories = [];
  final _statusController =
      StreamController<List<StatusStoryItem>>.broadcast();

  Stream<List<StatusStoryItem>> get statusStream => _statusController.stream;

  /// Retrieves cached stories, populating default samples if empty.
  List<StatusStoryItem> getStories() {
    if (_stories.isEmpty) _initSampleStories();
    return List.unmodifiable(_stories);
  }

  /// Marks a specific status item as viewed and notifies subscribers.
  void markViewed(String storyId) {
    final index = _stories.indexWhere((s) => s.id == storyId);
    if (index != -1) {
      _stories[index] = _stories[index].copyWith(isViewed: true);
      _statusController.add(List.unmodifiable(_stories));
    }
  }

  void _initSampleStories() {
    final now = DateTime.now();
    _stories.addAll([
      StatusStoryItem(
        id: 'story_sample_1',
        senderJid: 'status_1@s.whatsapp.net',
        senderName: 'WhatsApp Updates',
        timestamp: now.subtract(const Duration(minutes: 45)),
        caption: 'Welcome to WhatsApp for Linux!',
      ),
      StatusStoryItem(
        id: 'story_sample_2',
        senderJid: 'status_2@s.whatsapp.net',
        senderName: 'Release Channel',
        timestamp: now.subtract(const Duration(hours: 3)),
        caption: 'Native Wayland & GTK performance enabled.',
      ),
    ]);
  }
}
