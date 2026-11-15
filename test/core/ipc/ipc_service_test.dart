import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_whatsapp/core/ipc/i_process_manager.dart';
import 'package:flutter_whatsapp/core/ipc/ipc_exception.dart';
import 'package:flutter_whatsapp/core/ipc/ipc_service.dart';

class FakeProcessManager implements IDaemonProcessManager {
  final StreamController<String> _stdoutCtrl =
      StreamController<String>.broadcast();
  final StreamController<String> _stderrCtrl =
      StreamController<String>.broadcast();
  final List<String> sentLines = [];
  bool running = true;

  @override
  Stream<String> get stdoutLines => _stdoutCtrl.stream;

  @override
  Stream<String> get stderrLines => _stderrCtrl.stream;

  @override
  bool get isRunning => running;

  @override
  Future<void> start(String executablePath, [List<String>? arguments]) async {
    running = true;
  }

  @override
  Future<void> stop() async {
    running = false;
  }

  @override
  void sendLine(String line) {
    sentLines.add(line);
  }

  void emitStdout(String line) => _stdoutCtrl.add(line);
  void emitStderr(String line) => _stderrCtrl.add(line);

  void close() {
    _stdoutCtrl.close();
    _stderrCtrl.close();
  }
}

void main() {
  late FakeProcessManager processManager;
  late IpcService ipcService;

  setUp(() async {
    processManager = FakeProcessManager();
    ipcService = IpcService(
      processManager: processManager,
      defaultTimeout: const Duration(milliseconds: 200),
    );
    await ipcService.initialize();
  });

  tearDown(() async {
    await ipcService.dispose();
    processManager.close();
  });

  test('sendRequest sends JSON and completes on matching response', () async {
    final future = ipcService.sendRequest('ping', {'foo': 'bar'});
    expect(processManager.sentLines.length, 1);

    final sentJson = jsonDecode(processManager.sentLines.first);
    expect(sentJson['action'], 'ping');
    expect(sentJson['params'], {'foo': 'bar'});
    final reqId = sentJson['id'];

    processManager.emitStdout(jsonEncode({
      'id': reqId,
      'result': {'pong': true},
    }));

    final result = await future;
    expect(result, {'pong': true});
  });

  test('sendRequest completes with IpcException on daemon error', () async {
    final future = ipcService.sendRequest('get_session');
    final sentJson = jsonDecode(processManager.sentLines.first);

    processManager.emitStdout(jsonEncode({
      'id': sentJson['id'],
      'error': 'Session not found',
    }));

    expect(
      () => future,
      throwsA(
        isA<IpcException>().having(
          (e) => e.message,
          'message',
          'Session not found',
        ),
      ),
    );
  });

  test('sendRequest times out if daemon does not respond', () async {
    expect(
      () => ipcService.sendRequest('slow_call'),
      throwsA(isA<TimeoutException>()),
    );
  });

  test('events are broadcast and filtered by onEvent', () async {
    final allEvents = <String>[];
    final qrEvents = <String>[];

    ipcService.allEvents.listen((e) => allEvents.add(e.event));
    ipcService.onEvent('qr_code').listen((e) => qrEvents.add(e.data['code']));

    processManager.emitStdout(jsonEncode({
      'event': 'qr_code',
      'data': {'code': 'qr_123'},
    }));
    processManager.emitStdout(jsonEncode({
      'event': 'connected',
      'data': {'user': '12345'},
    }));

    await Future<void>.delayed(const Duration(milliseconds: 50));
    expect(allEvents, ['qr_code', 'connected']);
    expect(qrEvents, ['qr_123']);
  });

  test('ignores non-JSON output without failing', () async {
    processManager.emitStdout('INFO: starting daemon v1.0.0');
    processManager.emitStdout('');
    await Future<void>.delayed(const Duration(milliseconds: 20));
  });
}
