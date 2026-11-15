import '../models/contact_info.dart';
import '../models/group_info.dart';

/// Contract for managing WhatsApp group metadata, participants, and contacts.
abstract interface class IGroupRepository {
  /// Fetches real-time metadata and participant details for [jid].
  Future<GroupInfo> getGroupInfo(String jid);

  /// Updates the group topic / subject for [jid].
  Future<void> updateGroupTopic(String jid, String topic);

  /// Updates participants for [jid] with [action] ("add", "remove", "promote", "demote").
  Future<void> updateParticipants(
    String jid,
    List<String> userJids,
    String action,
  );

  /// Leaves the specified group [jid].
  Future<void> leaveGroup(String jid);

  /// Fetches contact profile information for [jid].
  Future<ContactInfo> getContactInfo(String jid);
}
