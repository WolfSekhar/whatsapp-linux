// ignore_for_file: avoid_print
import 'package:flutter_whatsapp/domain/domain.dart';

void main() async {
  print('Running Stage 5 Status Stories verification...');

  // 1. StatusStoryItem creation, serialization, deserialization
  final now = DateTime.now();
  final story1 = StatusStoryItem(
    id: 'story_1',
    senderJid: 'user1@s.whatsapp.net',
    senderName: 'Alice',
    timestamp: now,
    caption: 'Exploring Linux!',
    mediaType: 'text',
    backgroundColor: '#005C4B',
    isViewed: false,
  );

  assert(story1.id == 'story_1');
  assert(story1.senderJid == 'user1@s.whatsapp.net');
  assert(story1.senderName == 'Alice');
  assert(story1.caption == 'Exploring Linux!');
  assert(story1.mediaType == 'text');
  assert(story1.backgroundColor == '#005C4B');
  assert(!story1.isViewed);

  // 2. toJson & fromJson
  final json = story1.toJson();
  final reconstructed = StatusStoryItem.fromJson(json);
  assert(reconstructed.id == story1.id);
  assert(reconstructed.senderJid == story1.senderJid);
  assert(reconstructed.caption == story1.caption);
  assert(reconstructed.isViewed == story1.isViewed);
  assert(reconstructed.backgroundColor == story1.backgroundColor);

  // 3. copyWith
  final viewedStory = story1.copyWith(isViewed: true, caption: 'Updated caption');
  assert(viewedStory.isViewed);
  assert(viewedStory.caption == 'Updated caption');
  assert(viewedStory.id == story1.id);
  assert(viewedStory.senderJid == story1.senderJid);

  // 4. Multiple stories and grouping
  final story2 = StatusStoryItem(
    id: 'story_2',
    senderJid: 'user1@s.whatsapp.net',
    senderName: 'Alice',
    timestamp: now.add(const Duration(minutes: 5)),
    mediaType: 'image',
    mediaUrl: '/tmp/test_image.png',
    caption: 'A nice photo',
  );

  final story3 = StatusStoryItem(
    id: 'story_3',
    senderJid: 'user2@s.whatsapp.net',
    senderName: 'Bob',
    timestamp: now.add(const Duration(minutes: 10)),
    caption: 'Bob announcement',
  );

  final stories = [story1, story2, story3];

  // Grouping logic test
  final grouped = <String, List<StatusStoryItem>>{};
  for (final s in stories) {
    grouped.putIfAbsent(s.senderJid, () => []).add(s);
  }

  assert(grouped.length == 2);
  assert(grouped['user1@s.whatsapp.net']?.length == 2);
  assert(grouped['user2@s.whatsapp.net']?.length == 1);

  // Unread status calculation
  final unreadStories = stories.where((s) => !s.isViewed).toList();
  assert(unreadStories.length == 3);

  final user1HasUnread = grouped['user1@s.whatsapp.net']!.any((s) => !s.isViewed);
  assert(user1HasUnread);

  print('✓ All Stage 5 Status Stories tests passed successfully!');
}
