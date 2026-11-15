/// Strongly-typed models for IPC communication with the WhatsApp daemon.
library;

/// Outgoing request sent to the daemon over IPC stdin.
class IpcRequest {
  const IpcRequest({
    required this.id,
    required this.action,
    this.params,
  });

  final String id;
  final String action;
  final Map<String, dynamic>? params;

  Map<String, dynamic> toJson() => {
    'id': id,
    'action': action,
    if (params != null) 'params': params,
  };

  factory IpcRequest.fromJson(Map<String, dynamic> json) => IpcRequest(
    id: json['id'] as String? ?? '',
    action: json['action'] as String? ?? '',
    params: (json['params'] as Map?)?.cast<String, dynamic>(),
  );
}

/// Incoming response received from the daemon over IPC stdout.
class IpcResponse {
  const IpcResponse({
    required this.id,
    this.result,
    this.error,
  });

  final String id;
  final Map<String, dynamic>? result;
  final String? error;

  bool get isSuccess => error == null;

  Map<String, dynamic> toJson() => {
    'id': id,
    if (result != null) 'result': result,
    if (error != null) 'error': error,
  };

  factory IpcResponse.fromJson(Map<String, dynamic> json) => IpcResponse(
    id: json['id'] as String? ?? '',
    result: (json['result'] as Map?)?.cast<String, dynamic>(),
    error: json['error'] as String?,
  );
}

/// Incoming broadcast event received from the daemon over IPC stdout.
class IpcEvent {
  const IpcEvent({
    required this.event,
    this.data,
  });

  final String event;
  final dynamic data;

  Map<String, dynamic> toJson() => {
    'event': event,
    if (data != null) 'data': data,
  };

  factory IpcEvent.fromJson(Map<String, dynamic> json) => IpcEvent(
    event: json['event'] as String? ?? '',
    data: json['data'],
  );
}
