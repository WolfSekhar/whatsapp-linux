import 'dart:async';
import 'ipc_message.dart';

/// Abstract interface for communicating with the WhatsApp daemon over IPC.
abstract interface class IIpcService {
  /// Initializes the IPC communication channels and starts listening.
  Future<void> initialize();

  /// Gracefully tears down pending requests and terminates connections.
  Future<void> dispose();

  /// Sends a request with [action] and optional [params], returning the result.
  Future<Map<String, dynamic>> sendRequest(
    String action, [
    Map<String, dynamic>? params,
  ]);

  /// Returns a stream of events matching the specified [eventName].
  Stream<IpcEvent> onEvent(String eventName);

  /// Returns a broadcast stream of all incoming daemon events.
  Stream<IpcEvent> get allEvents;
}
