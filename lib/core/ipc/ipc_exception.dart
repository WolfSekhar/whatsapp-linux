/// Exception thrown during IPC communication or request execution.
class IpcException implements Exception {
  const IpcException(this.message, [this.requestId]);

  final String message;
  final String? requestId;

  @override
  String toString() {
    if (requestId != null) {
      return 'IpcException(id: $requestId): $message';
    }
    return 'IpcException: $message';
  }
}
