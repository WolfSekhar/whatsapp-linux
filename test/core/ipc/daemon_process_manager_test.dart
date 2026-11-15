import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_whatsapp/core/ipc/daemon_process_manager.dart';

class FakeProcess implements Process {
  FakeProcess() {
    stdin = IOSink(stdinController.sink);
  }

  final StreamController<List<int>> stdoutController =
      StreamController<List<int>>();
  final StreamController<List<int>> stderrController =
      StreamController<List<int>>();
  final StreamController<List<int>> stdinController =
      StreamController<List<int>>();
  final Completer<int> exitCompleter = Completer<int>();
  ProcessSignal? killedSignal;

  @override
  late final IOSink stdin;

  @override
  Stream<List<int>> get stdout => stdoutController.stream;

  @override
  Stream<List<int>> get stderr => stderrController.stream;

  @override
  Future<int> get exitCode => exitCompleter.future;

  @override
  int get pid => 12345;

  @override
  bool kill([ProcessSignal signal = ProcessSignal.sigterm]) {
    killedSignal = signal;
    if (!exitCompleter.isCompleted) {
      exitCompleter.complete(0);
    }
    return true;
  }
}

void main() {
  test('DaemonProcessManager lifecycle and streams', () async {
    late FakeProcess fakeProcess;
    final manager = DaemonProcessManager(
      launcher: (exec, args) async {
        fakeProcess = FakeProcess();
        return fakeProcess;
      },
    );

    expect(manager.isRunning, isFalse);
    await manager.start('/dummy/path');
    expect(manager.isRunning, isTrue);

    final receivedStdout = <String>[];
    manager.stdoutLines.listen(receivedStdout.add);

    fakeProcess.stdoutController.add(utf8.encode('{"event":"ready"}\n'));
    await Future<void>.delayed(const Duration(milliseconds: 30));

    expect(receivedStdout, ['{"event":"ready"}']);

    await manager.stop();
    expect(manager.isRunning, isFalse);
    expect(fakeProcess.killedSignal, ProcessSignal.sigterm);
    manager.dispose();
  });

  test('DaemonProcessManager auto-restarts on unexpected crash', () async {
    var launchCount = 0;
    FakeProcess? lastProcess;

    final manager = DaemonProcessManager(
      restartDelay: const Duration(milliseconds: 20),
      launcher: (exec, args) async {
        launchCount++;
        final proc = FakeProcess();
        lastProcess = proc;
        return proc;
      },
    );

    await manager.start('/dummy/daemon');
    expect(launchCount, 1);

    // Simulate unexpected crash (exit code without calling manager.stop())
    lastProcess?.exitCompleter.complete(1);

    // Wait for auto-restart delay
    await Future<void>.delayed(const Duration(milliseconds: 60));

    expect(launchCount, 2);
    expect(manager.isRunning, isTrue);

    await manager.stop();
    manager.dispose();
  });
}
