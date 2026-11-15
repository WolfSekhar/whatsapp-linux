import 'dart:async';
import 'dart:io';

import 'package:flutter_whatsapp/core/ipc/ipc.dart';

class MockProcess implements Process {
  MockProcess() {
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
  int get pid => 9999;

  @override
  bool kill([ProcessSignal signal = ProcessSignal.sigterm]) {
    killedSignal = signal;
    if (!exitCompleter.isCompleted) {
      exitCompleter.complete(0);
    }
    return true;
  }
}

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
  void sendLine(String line) => sentLines.add(line);
  void emitStdout(String line) => _stdoutCtrl.add(line);
  void close() {
    _stdoutCtrl.close();
    _stderrCtrl.close();
  }
}
