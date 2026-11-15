// ignore_for_file: avoid_print
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_whatsapp/core/ipc/ipc.dart';
import 'fake_process.dart';

Future<void> testMessages() async {
  final req = IpcRequest(id: '1', action: 'pair', params: {'mode': 'qr'});
  final reqJson = req.toJson();
  assert(reqJson['id'] == '1');
  assert(reqJson['action'] == 'pair');
  final reqParsed = IpcRequest.fromJson(reqJson);
  assert(reqParsed.id == '1');
  assert(reqParsed.action == 'pair');
  assert(reqParsed.params?['mode'] == 'qr');

  final res = IpcResponse(id: '1', result: {'ok': true});
  assert(res.isSuccess);
  final resParsed = IpcResponse.fromJson(res.toJson());
  assert(resParsed.isSuccess);
  assert(resParsed.result?['ok'] == true);

  final resErr = IpcResponse(id: '2', error: 'failed');
  assert(!resErr.isSuccess);
  final resErrParsed = IpcResponse.fromJson(resErr.toJson());
  assert(!resErrParsed.isSuccess);
  assert(resErrParsed.error == 'failed');

  final ev = IpcEvent(event: 'qr_code', data: 'data123');
  final evParsed = IpcEvent.fromJson(ev.toJson());
  assert(evParsed.event == 'qr_code');
  assert(evParsed.data == 'data123');
  print('✓ testMessages passed');
}

Future<void> testIpcService() async {
  final fakePm = FakeProcessManager();
  final service = IpcService(
    processManager: fakePm,
    defaultTimeout: const Duration(milliseconds: 300),
  );
  await service.initialize();

  final futureRes = service.sendRequest('ping', {'a': 1});
  assert(fakePm.sentLines.length == 1);
  final sent = jsonDecode(fakePm.sentLines.first);
  assert(sent['action'] == 'ping');
  fakePm.emitStdout(jsonEncode({'id': sent['id'], 'result': {'pong': true}}));
  final res = await futureRes;
  assert(res['pong'] == true);

  final futureErr = service.sendRequest('fail');
  final sent2 = jsonDecode(fakePm.sentLines[1]);
  fakePm.emitStdout(jsonEncode({'id': sent2['id'], 'error': 'custom error'}));
  try {
    await futureErr;
    assert(false, 'Should have thrown');
  } catch (e) {
    assert(e is IpcException && e.message == 'custom error');
  }

  final events = <String>[];
  service.onEvent('test_ev').listen((e) => events.add(e.data as String));
  fakePm.emitStdout(jsonEncode({'event': 'test_ev', 'data': 'val1'}));
  fakePm.emitStdout(jsonEncode({'event': 'other_ev', 'data': 'val2'}));
  fakePm.emitStdout(jsonEncode({'event': 'test_ev', 'data': 'val3'}));
  await Future<void>.delayed(const Duration(milliseconds: 50));
  assert(events.length == 2 && events[0] == 'val1' && events[1] == 'val3');

  await service.dispose();
  fakePm.close();
  print('✓ testIpcService passed');
}

Future<void> testDaemonProcessManager() async {
  late MockProcess mock;
  final manager = DaemonProcessManager(
    launcher: (exec, args) async {
      mock = MockProcess();
      return mock;
    },
  );

  assert(!manager.isRunning);
  await manager.start('/dummy/daemon');
  assert(manager.isRunning);

  final lines = <String>[];
  manager.stdoutLines.listen(lines.add);
  mock.stdoutController.add(utf8.encode('line 1\nline 2\n'));
  await Future<void>.delayed(const Duration(milliseconds: 30));
  assert(lines.length == 2 && lines[0] == 'line 1' && lines[1] == 'line 2');

  await manager.stop();
  assert(!manager.isRunning);
  assert(mock.killedSignal == ProcessSignal.sigterm);
  manager.dispose();
  print('✓ testDaemonProcessManager passed');
}

Future<void> main() async {
  await testMessages();
  await testIpcService();
  await testDaemonProcessManager();
  print('\nALL IPC TESTS PASSED!');
}
