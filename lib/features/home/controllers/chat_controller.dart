import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../domain/chat.dart';
import '../../../domain/chat_repository.dart';
import '../../../domain/repositories/i_interaction_repository.dart';
import '../../../domain/repositories/i_media_repository.dart';

/// State management controller for desktop chat navigation and search.
class ChatController extends ChangeNotifier {
  final IChatRepository chatRepository;
  final IMediaRepository? mediaRepository;
  final IInteractionRepository? interactionRepository;
  StreamSubscription<List<Chat>>? _subscription;

  List<Chat> _allChats = const [];
  String? _selectedChatJid;
  String _searchQuery = '';
  bool _isLoading = true;

  ChatController({
    required this.chatRepository,
    this.mediaRepository,
    this.interactionRepository,
  }) {
    _init();
  }

  void _init() {
    _allChats = chatRepository.currentChats;
    if (_allChats.isNotEmpty) _isLoading = false;

    _subscription = chatRepository.chatsStream.listen(
      (chats) {
        _allChats = chats;
        _isLoading = false;
        notifyListeners();
      },
      onError: (_) {
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  String? get selectedChatJid => _selectedChatJid;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;

  /// Returns filtered chats matching search query.
  List<Chat> get chats {
    if (_searchQuery.trim().isEmpty) return _allChats;
    final query = _searchQuery.toLowerCase();
    return _allChats.where((chat) {
      final nameMatches = chat.name.toLowerCase().contains(query);
      final msgMatches = chat.lastMessage?.toLowerCase().contains(query) ?? false;
      return nameMatches || msgMatches;
    }).toList();
  }

  /// Currently active selected chat session.
  Chat? get selectedChat {
    final jid = _selectedChatJid;
    if (jid == null) return null;
    try {
      return _allChats.firstWhere((c) => c.jid == jid);
    } catch (_) {
      return null;
    }
  }

  /// Selects a chat by JID and marks it as read.
  void selectChat(String? jid) {
    if (_selectedChatJid == jid) return;
    _selectedChatJid = jid;
    if (jid != null) {
      chatRepository.markAsRead(jid);
    }
    notifyListeners();
  }

  /// Updates search filter query.
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  /// Clears active search filter.
  void clearSearch() {
    if (_searchQuery.isEmpty) return;
    _searchQuery = '';
    notifyListeners();
  }

  /// Manually triggers a reload of chats.
  Future<void> refresh() => chatRepository.fetchChats();

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
