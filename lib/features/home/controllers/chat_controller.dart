import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../core/notifications/linux_notification_service.dart';
import '../../../domain/chat.dart';
import '../../../domain/chat_repository.dart';
import '../../../domain/models/chat_filter_type.dart';
import '../../../domain/models/chat_sorter.dart';
import '../../../domain/repositories/i_group_repository.dart';
import '../../../domain/repositories/i_interaction_repository.dart';
import '../../../domain/repositories/i_media_repository.dart';
import '../../../domain/repositories/i_settings_repository.dart';
import '../../settings/controllers/settings_controller.dart';

/// State management controller for desktop chat navigation and search.
class ChatController extends ChangeNotifier {
  final IChatRepository chatRepository;
  final IMediaRepository? mediaRepository;
  final IInteractionRepository? interactionRepository;
  final IGroupRepository? groupRepository;
  final ISettingsRepository? settingsRepository;
  final SettingsController? settingsController;
  final LinuxNotificationService? notificationService;
  StreamSubscription<List<Chat>>? _subscription;
  StreamSubscription<dynamic>? _msgSubscription;

  List<Chat> _allChats = const [];
  String? _selectedChatJid;
  String _searchQuery = '';
  ChatFilterType _activeFilter = ChatFilterType.all;
  bool _isLoading = true;

  ChatController({
    required this.chatRepository,
    this.mediaRepository,
    this.interactionRepository,
    this.groupRepository,
    this.settingsRepository,
    this.settingsController,
    this.notificationService,
  }) {
    _init();
  }

  void _init() {
    _allChats = chatRepository.currentChats;
    if (_allChats.isNotEmpty) _isLoading = false;
    _subscription = chatRepository.chatsStream.listen(
      (chats) { _allChats = chats; _isLoading = false; notifyListeners(); },
      onError: (_) { _isLoading = false; notifyListeners(); },
    );
    _msgSubscription = chatRepository.messageStream.listen((msg) {
      if (!msg.isFromMe) {
        notificationService?.showNotification(
          title: msg.chatJid,
          body: msg.text,
          preferences: settingsController?.preferences,
        );
      }
    });
  }

  String? get selectedChatJid => _selectedChatJid;
  String get searchQuery => _searchQuery;
  ChatFilterType get activeFilter => _activeFilter;
  bool get isLoading => _isLoading;
  bool get hasArchivedChats => _allChats.any((c) => c.isArchived);
  int get archivedCount => _allChats.where((c) => c.isArchived).length;
  int get unreadCount => _allChats.where((c) => !c.isArchived && c.unreadCount > 0).length;

  void setFilter(ChatFilterType filter) {
    if (_activeFilter == filter) return;
    _activeFilter = filter;
    notifyListeners();
  }

  List<Chat> get chats {
    final query = _searchQuery.trim().toLowerCase();
    final list = _allChats.where((c) {
      if (_activeFilter == ChatFilterType.archived ? !c.isArchived : c.isArchived) return false;
      if (_activeFilter == ChatFilterType.unread && c.unreadCount <= 0) return false;
      if (_activeFilter == ChatFilterType.groups && !c.isGroup) return false;
      if (query.isNotEmpty) {
        return c.name.toLowerCase().contains(query) || (c.lastMessage?.toLowerCase().contains(query) ?? false);
      }
      return true;
    }).toList();
    sortChats(list);
    return list;
  }

  Chat? get selectedChat {
    final jid = _selectedChatJid;
    if (jid == null) return null;
    try {
      return _allChats.firstWhere((c) => c.jid == jid);
    } catch (_) {
      return null;
    }
  }

  void selectChat(String? jid) {
    if (_selectedChatJid == jid) return;
    _selectedChatJid = jid;
    if (jid != null) chatRepository.markAsRead(jid);
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void clearSearch() {
    if (_searchQuery.isEmpty) return;
    _searchQuery = '';
    notifyListeners();
  }

  Future<void> refresh() => chatRepository.fetchChats();
  Future<void> pinChat(String jid, bool pin) => chatRepository.pinChat(jid, pin);
  Future<void> archiveChat(String jid, bool archive) => chatRepository.archiveChat(jid, archive);
  Future<void> muteChat(String jid, {int duration = 0, bool mute = true}) =>
      chatRepository.muteChat(jid, durationSeconds: duration, mute: mute);
  Future<void> clearChat(String jid) => chatRepository.clearChat(jid);
  Future<void> deleteChat(String jid) => chatRepository.deleteChat(jid);
  Future<void> markAsRead(String jid) => chatRepository.markAsRead(jid);

  Future<void> markAsUnread(String jid) async {
    try { await (chatRepository as dynamic).markAsUnread(jid); } catch (_) {}
    final idx = _allChats.indexWhere((c) => c.jid == jid);
    if (idx != -1) {
      final list = List<Chat>.from(_allChats);
      list[idx] = list[idx].copyWith(unreadCount: 1);
      _allChats = list;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _msgSubscription?.cancel();
    super.dispose();
  }
}
