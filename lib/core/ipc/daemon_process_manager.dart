import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'i_process_manager.dart';

/// Launcher signature allowing dependency injection for testing.
typedef ProcessLauncher = Future<Process> Function(
  String executable,
  List<String> arguments,
);

/// Concrete implementation of [IDaemonProcessManager] managing the daemon lifecycle.
class DaemonProcessManager implements IDaemonProcessManager {
  DaemonProcessManager({
    ProcessLauncher? launcher,
    this._restartDelay = const Duration(seconds: 1),
  }) : _launcher = launcher ?? Process.start;

  final ProcessLauncher _launcher;
  final Duration _restartDelay;
  final StreamController<String> _stdoutController =
      StreamController<String>.broadcast();
  final StreamController<String> _stderrController =
      StreamController<String>.broadcast();

  Process? _process;
  StreamSubscription<String>? _stdoutSub;
  StreamSubscription<String>? _stderrSub;
  String? _executablePath;
  List<String> _arguments = const [];
  bool _isStopping = false;
  Timer? _restartTimer;

  @override
  Stream<String> get stdoutLines => _stdoutController.stream;

  @override
  Stream<String> get stderrLines => _stderrController.stream;

  @override
  bool get isRunning => _process != null;

  @override
  Future<void> start(
    String executablePath, [
    List<String>? arguments,
  ]) async {
    if (isRunning) return;
    _executablePath = executablePath;
    _arguments = arguments ?? const [];
    _isStopping = false;
    _restartTimer?.cancel();

    final proc = await _launcher(executablePath, _arguments);
    _process = proc;

    _stdoutSub = proc.stdout
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen(_stdoutController.add, onError: _stdoutController.addError);

    _stderrSub = proc.stderr
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen(_stderrController.add, onError: _stderrController.addError);

    proc.exitCode.then(_handleProcessExit);
  }

  void _handleProcessExit(int exitCode) {
    _cleanupProcess();
    if (!_isStopping && _executablePath != null) {
      _restartTimer = Timer(_restartDelay, () {
        if (!_isStopping && _executablePath != null) {
          start(_executablePath!, _arguments);
        }
      });
    }
  }

  void _cleanupProcess() {
    _stdoutSub?.cancel();
    _stderrSub?.cancel();
    _stdoutSub = null;
    _stderrSub = null;
    _process = null;
  }

  @override
  Future<void> stop() async {
    _isStopping = true;
    _restartTimer?.cancel();
    final proc = _process;
    if (proc == null) return;

    proc.kill(ProcessSignal.sigterm);
    await proc.exitCode.timeout(
      const Duration(seconds: 2),
      onTimeout: () {
        proc.kill(ProcessSignal.sigkill);
        return -1;
      },
    );
    _cleanupProcess();
  }

  @override
  void sendLine(String line) {
    final proc = _process;
    if (proc == null) {
      throw StateError('Daemon process is not running');
    }
    proc.stdin.writeln(line);
    proc.stdin.flush();
  }

  /// Closes internal stream controllers when permanently disposed.
  void dispose() {
    _restartTimer?.cancel();
    _cleanupProcess();
    _stdoutController.close();
    _stderrController.close();
  }
}
