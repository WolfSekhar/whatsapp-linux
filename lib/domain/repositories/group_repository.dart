import '../../core/ipc/i_ipc_service.dart';
import '../models/contact_info.dart';
import '../models/group_info.dart';
import 'i_group_repository.dart';

/// Concrete implementation of [IGroupRepository] interacting with the Go daemon.
class GroupRepository implements IGroupRepository {
  final IIpcService _ipc;

  GroupRepository(this._ipc);

  @override
  Future<GroupInfo> getGroupInfo(String jid) async {
    final res = await _ipc.sendRequest('get_group_info', {
      'group_jid': jid,
    });
    final groupData = res['group'] is Map
        ? Map<String, dynamic>.from(res['group'] as Map)
        : res;
    return GroupInfo.fromJson(groupData);
  }

  @override
  Future<void> updateGroupTopic(String jid, String topic) async {
    await _ipc.sendRequest('update_group_topic', {
      'group_jid': jid,
      'topic': topic,
    });
  }

  @override
  Future<void> updateParticipants(
    String jid,
    List<String> userJids,
    String action,
  ) async {
    await _ipc.sendRequest('update_participants', {
      'group_jid': jid,
      'action': action,
      'participants': userJids,
    });
  }

  @override
  Future<void> leaveGroup(String jid) async {
    await _ipc.sendRequest('leave_group', {
      'group_jid': jid,
    });
  }

  @override
  Future<ContactInfo> getContactInfo(String jid) async {
    final phone = jid.split('@').first;
    return ContactInfo(
      jid: jid,
      displayName: phone,
      phone: phone,
      about: 'Hey there! I am using WhatsApp.',
      isBlocked: false,
    );
  }
}
