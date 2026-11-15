// ignore_for_file: avoid_print
import 'dart:async';
import 'package:flutter_whatsapp/core/ipc/i_ipc_service.dart';
import 'package:flutter_whatsapp/core/ipc/ipc_message.dart';
import 'package:flutter_whatsapp/core/storage/message_dao.dart';
import 'package:flutter_whatsapp/domain/domain.dart';
import 'package:flutter_whatsapp/domain/repositories/media_repository.dart';

class MockMessageDaoForMedia extends MessageDao {
  final Map<String, String> localPaths = {};

  @override
  Future<void> updateMessageLocalPath(String id, String localPath) async {
    localPaths[id] = localPath;
  }
}

class MockIpcForMedia implements IIpcService {
  final StreamController<IpcEvent> _ctrl = StreamController<IpcEvent>.broadcast();
  String? lastAction;
  Map<String, dynamic>? lastParams;
  Map<String, dynamic> responseResult = {};

  @override
  Stream<IpcEvent> get allEvents => _ctrl.stream;

  @override
  Stream<IpcEvent> onEvent(String eventName) =>
      _ctrl.stream.where((e) => e.event == eventName);

  @override
  Future<Map<String, dynamic>> sendRequest(String action, [Map<String, dynamic>? params]) async {
    lastAction = action;
    lastParams = params;
    return responseResult;
  }

  @override
  Future<void> initialize() async {}

  @override
  Future<void> dispose() async => _ctrl.close();
}

Future<void> testMediaMessageSerialization() async {
  final json = {
    'id': 'msg_img_1',
    'chat_jid': 'chat1@s.whatsapp.net',
    'sender_jid': 'user1@s.whatsapp.net',
    'body': 'Photo caption',
    'timestamp': 1700000000000,
    'from_me': false,
    'media_type': 'image',
    'file_name': 'photo.jpg',
    'file_size': 204800,
    'mime_type': 'image/jpeg',
    'thumbnail_base64': 'dGh1bWI=',
    'local_path': '/path/to/photo.jpg',
    'duration': 15,
  };

  final item = MessageItem.fromJson(json);
  assert(item.id == 'msg_img_1');
  assert(item.mediaType == 'image');
  assert(item.fileName == 'photo.jpg');
  assert(item.fileSize == 204800);
  assert(item.mimeType == 'image/jpeg');
  assert(item.thumbnailBase64 == 'dGh1bWI=');
  assert(item.localPath == '/path/to/photo.jpg');
  assert(item.duration == 15);

  final out = item.toJson();
  assert(out['media_type'] == 'image');
  assert(out['file_name'] == 'photo.jpg');
  assert(out['file_size'] == 204800);
  assert(out['mime_type'] == 'image/jpeg');
  assert(out['local_path'] == '/path/to/photo.jpg');

  print('✓ MessageItem media serialization passed');
}

Future<void> testMediaRepositoryDownload() async {
  final ipc = MockIpcForMedia();
  final dao = MockMessageDaoForMedia();
  final repo = MediaRepository(ipc, messageDao: dao);

  ipc.responseResult = {
    'file_path': '/tmp/test_download.jpg',
    'mime_type': 'image/jpeg',
    'file_size': 12345,
  };

  final path = await repo.downloadMedia(
    messageId: 'msg_99',
    chatJid: 'chat@s.whatsapp.net',
    mediaType: 'image',
  );

  assert(path == '/tmp/test_download.jpg');
  assert(ipc.lastAction == 'download_media');
  assert(ipc.lastParams?['message_id'] == 'msg_99');
  assert(ipc.lastParams?['chat_jid'] == 'chat@s.whatsapp.net');
  assert(ipc.lastParams?['media_type'] == 'image');
  assert(dao.localPaths['msg_99'] == '/tmp/test_download.jpg');

  assert(!repo.isFileAvailable(null));
  assert(!repo.isFileAvailable('/non/existent/path/here.png'));

  print('✓ MediaRepository download & caching passed');
}

Future<void> main() async {
  await testMediaMessageSerialization();
  await testMediaRepositoryDownload();
  print('\nAll media tests passed successfully!');
}
