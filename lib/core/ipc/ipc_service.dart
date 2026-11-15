import 'dart:async';
import 'dart:convert';

import 'i_ipc_service.dart';
import 'i_process_manager.dart';
import 'ipc_exception.dart';
import 'ipc_message.dart';

/// Concrete implementation of [IIpcService] handling request/response matching
/// and event dispatching over the daemon's stdin/stdout streams.
class IpcService implements IIpcService {
  IpcService({
    required this._processManager,
    this._defaultTimeout = const Duration(seconds: 30),
  });

  final IDaemonProcessManager _processManager;
  final Duration _defaultTimeout;
  final StreamController<IpcEvent> _eventController =
      StreamController<IpcEvent>.broadcast();
  final Map<String, Completer<Map<String, dynamic>>> _pending = {};

  StreamSubscription<String>? _stdoutSub;
  int _counter = 0;

  @override
  Stream<IpcEvent> get allEvents => _eventController.stream;

  @override
  Stream<IpcEvent> onEvent(String eventName) =>
      _eventController.stream.where((e) => e.event == eventName);

  @override
  Future<void> initialize() async {
    _stdoutSub?.cancel();
    _stdoutSub = _processManager.stdoutLines.listen(
      _handleLine,
      onError: (Object error) {
        // Stderr or stream errors can be observed without terminating IPC
      },
    );
  }

  void _handleLine(String line) {
    final trimmed = line.trim();
    if (trimmed.isEmpty) return;

    try {
      final decoded = jsonDecode(trimmed);
      if (decoded is! Map<String, dynamic>) return;

      if (decoded.containsKey('id')) {
        final res = IpcResponse.fromJson(decoded);
        final completer = _pending.remove(res.id);
        if (completer != null && !completer.isCompleted) {
          if (res.isSuccess) {
            completer.complete(res.result ?? const <String, dynamic>{});
          } else {
            completer.completeError(
              IpcException(res.error ?? 'Unknown error', res.id),
            );
          }
        }
      } else if (decoded.containsKey('event')) {
        final event = IpcEvent.fromJson(decoded);
        if (!_eventController.isClosed) {
          _eventController.add(event);
        }
      }
    } catch (_) {
      // Non-JSON diagnostic output from the daemon is ignored.
    }
  }

  @override
  Future<Map<String, dynamic>> sendRequest(
    String action, [
    Map<String, dynamic>? params,
  ]) {
    final id = 'req_${++_counter}';
    final request = IpcRequest(id: id, action: action, params: params);
    final completer = Completer<Map<String, dynamic>>();
    _pending[id] = completer;

    _processManager.sendLine(jsonEncode(request.toJson()));

    return completer.future.timeout(
      _defaultTimeout,
      onTimeout: () {
        _pending.remove(id);
        throw TimeoutException('IPC request "$action" ($id) timed out');
      },
    );
  }

  @override
  Future<void> dispose() async {
    await _stdoutSub?.cancel();
    _stdoutSub = null;

    for (final entry in _pending.entries) {
      if (!entry.value.isCompleted) {
        entry.value.completeError(
          IpcException('IPC service disposed', entry.key),
        );
      }
    }
    _pending.clear();
    await _eventController.close();
  }
}
