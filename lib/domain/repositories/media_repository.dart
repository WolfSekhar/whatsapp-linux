import 'dart:io';
import '../../core/ipc/i_ipc_service.dart';
import '../../core/storage/message_dao.dart';
import 'i_media_repository.dart';

/// Concrete implementation of [IMediaRepository] using IPC and local SQLite cache.
class MediaRepository implements IMediaRepository {
  final IIpcService _ipcService;
  final MessageDao _messageDao;

  MediaRepository(this._ipcService, {MessageDao? messageDao})
      : _messageDao = messageDao ?? MessageDao();

  @override
  Future<String?> downloadMedia({
    required String messageId,
    required String chatJid,
    String? mediaType,
  }) async {
    try {
      final params = <String, dynamic>{
        'message_id': messageId,
        'chat_jid': chatJid,
      };
      if (mediaType != null) {
        params['media_type'] = mediaType;
      }
      final res = await _ipcService.sendRequest('download_media', params);

      final filePath = res['file_path'] as String?;
      if (filePath != null && filePath.isNotEmpty) {
        await _messageDao.updateMessageLocalPath(messageId, filePath);
        return filePath;
      }
    } catch (_) {}
    return null;
  }

  @override
  Future<bool> openMediaFile(String filePath) async {
    try {
      if (!isFileAvailable(filePath)) return false;
      final result = await Process.run('xdg-open', [filePath]);
      return result.exitCode == 0;
    } catch (_) {
      return false;
    }
  }

  @override
  bool isFileAvailable(String? filePath) {
    if (filePath == null || filePath.isEmpty) return false;
    return File(filePath).existsSync();
  }
}
