import 'dart:async';

/// Abstract contract for managing the lifecycle of the daemon background process.
abstract interface class IDaemonProcessManager {
  /// Starts the daemon process at [executablePath] with optional [arguments].
  Future<void> start(String executablePath, [List<String>? arguments]);

  /// Stops the running daemon process cleanly by sending SIGTERM.
  Future<void> stop();

  /// Stream of decoded UTF-8 stdout lines emitted by the process.
  Stream<String> get stdoutLines;

  /// Stream of decoded UTF-8 stderr lines emitted by the process.
  Stream<String> get stderrLines;

  /// Sends a single text line to the daemon process via stdin.
  void sendLine(String line);

  /// Whether the daemon process is currently running and active.
  bool get isRunning;
}
