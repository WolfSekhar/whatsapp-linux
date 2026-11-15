import 'package:flutter/foundation.dart';
import '../../../domain/chat.dart';
import '../../../domain/models/contact_info.dart';
import '../../../domain/models/group_info.dart';
import '../../../domain/models/group_participant.dart';
import '../../../domain/repositories/i_group_repository.dart';

/// Controller managing inspection, state, and administrative operations for a chat.
class ChatInfoController extends ChangeNotifier {
  final Chat chat;
  final IGroupRepository repository;

  GroupInfo? groupInfo;
  ContactInfo? contactInfo;
  bool isLoading = false;
  String? errorMessage;
  String searchQuery = '';

  ChatInfoController({
    required this.chat,
    required this.repository,
  }) {
    loadInfo();
  }

  void setSearchQuery(String q) {
    searchQuery = q;
    notifyListeners();
  }

  List<GroupParticipant> get filteredParticipants {
    final list = groupInfo?.participants ?? const [];
    final q = searchQuery.trim().toLowerCase();
    if (q.isEmpty) return list;
    return list.where((p) {
      final name = (p.displayName ?? '').toLowerCase();
      final jid = p.jid.toLowerCase();
      return name.contains(q) || jid.contains(q);
    }).toList();
  }

  Future<void> loadInfo() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      if (chat.isGroup) {
        groupInfo = await repository.getGroupInfo(chat.jid);
      } else {
        contactInfo = await repository.getContactInfo(chat.jid);
      }
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateTopic(String topic) async {
    try {
      await repository.updateGroupTopic(chat.jid, topic);
      await loadInfo();
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> addParticipant(String userJid) async {
    try {
      await repository.updateParticipants(chat.jid, [userJid], 'add');
      await loadInfo();
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> removeParticipant(String userJid) async {
    try {
      await repository.updateParticipants(chat.jid, [userJid], 'remove');
      await loadInfo();
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> promoteParticipant(String userJid) async {
    try {
      await repository.updateParticipants(chat.jid, [userJid], 'promote');
      await loadInfo();
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> demoteParticipant(String userJid) async {
    try {
      await repository.updateParticipants(chat.jid, [userJid], 'demote');
      await loadInfo();
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> leaveGroup() async {
    try {
      await repository.leaveGroup(chat.jid);
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
    }
  }
}
