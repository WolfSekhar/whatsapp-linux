import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../domain/models/status_story_item.dart';
import '../../../domain/repositories/i_settings_repository.dart';

/// Controller managing ephemeral status stories, auto-advance, and grouping.
class StatusController extends ChangeNotifier {
  final ISettingsRepository repository;
  StreamSubscription<List<StatusStoryItem>>? _subscription;
  Timer? _timer;

  List<StatusStoryItem> _stories = const [];
  String? _selectedSenderJid;
  int _storyIndex = 0;
  double _progress = 0.0;
  bool _isPaused = false;
  bool _isLoading = true;

  StatusController({required this.repository}) {
    _init();
  }

  bool get isLoading => _isLoading;
  bool get isPaused => _isPaused;
  double get progress => _progress;
  int get storyIndex => _storyIndex;
  String? get selectedSenderJid => _selectedSenderJid;
  List<StatusStoryItem> get allStories => _stories;
  int get unreadCount => _stories.where((s) => !s.isViewed).length;
  bool get hasUnread => unreadCount > 0;

  Map<String, List<StatusStoryItem>> get groupedStories {
    final map = <String, List<StatusStoryItem>>{};
    for (final s in _stories) {
      map.putIfAbsent(s.senderJid, () => []).add(s);
    }
    return map;
  }

  List<String> get contactJids => groupedStories.keys.toList();

  List<StatusStoryItem> get currentContactStories {
    final jid = _selectedSenderJid;
    return jid == null ? const [] : (groupedStories[jid] ?? const []);
  }

  StatusStoryItem? get currentStory {
    final list = currentContactStories;
    return (_storyIndex >= 0 && _storyIndex < list.length) ? list[_storyIndex] : null;
  }

  Future<void> _init() async {
    try {
      _stories = await repository.getStatusStories();
      if (_stories.isNotEmpty && _selectedSenderJid == null) {
        _selectedSenderJid = _stories.first.senderJid;
      }
    } catch (_) {}
    _isLoading = false;
    notifyListeners();
    _subscription = repository.statusStream.listen((updated) {
      _stories = updated;
      notifyListeners();
    });
  }

  void selectContact(String jid) {
    if (_selectedSenderJid == jid && _storyIndex == 0) return;
    _selectedSenderJid = jid;
    _storyIndex = 0;
    _startStory();
  }

  void _startStory() {
    _progress = 0.0;
    final story = currentStory;
    if (story != null && !story.isViewed) {
      repository.markStoryViewed(story.id);
    }
    _restartTimer();
    notifyListeners();
  }

  void _restartTimer() {
    _timer?.cancel();
    _isPaused = false;
    _timer = Timer.periodic(const Duration(milliseconds: 50), (t) {
      if (_isPaused) return;
      _progress += 0.01;
      if (_progress >= 1.0) {
        nextStory();
      } else {
        notifyListeners();
      }
    });
  }

  void nextStory() {
    if (_storyIndex + 1 < currentContactStories.length) {
      _storyIndex++;
      _startStory();
      return;
    }
    final jids = contactJids;
    final curIdx = jids.indexOf(_selectedSenderJid ?? '');
    if (curIdx != -1 && curIdx + 1 < jids.length) {
      selectContact(jids[curIdx + 1]);
    } else {
      _timer?.cancel();
      _progress = 1.0;
      notifyListeners();
    }
  }

  void previousStory() {
    if (_progress > 0.25 || _storyIndex == 0) {
      _startStory();
    } else {
      _storyIndex--;
      _startStory();
    }
  }

  void pause() {
    _isPaused = true;
    notifyListeners();
  }

  void resume() {
    _isPaused = false;
    notifyListeners();
  }

  void togglePause() => _isPaused ? resume() : pause();

  @override
  void dispose() {
    _timer?.cancel();
    _subscription?.cancel();
    super.dispose();
  }
}
