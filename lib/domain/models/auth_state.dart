/// Represents the authentication state of the WhatsApp client.
sealed class AuthState {
  const AuthState();

  const factory AuthState.initial() = AuthInitial;
  const factory AuthState.qrReady(String qrCode, int timeoutSeconds) =
      AuthQrReady;
  const factory AuthState.connecting() = AuthConnecting;
  const factory AuthState.connected(String jid, String phone) = AuthConnected;
  const factory AuthState.loggedOut() = AuthLoggedOut;
  const factory AuthState.error(String message) = AuthError;
}

/// Initial uninitialized state before any connection attempt.
final class AuthInitial extends AuthState {
  const AuthInitial();

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is AuthInitial;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'AuthState.initial()';
}

/// State when QR code has been received and is waiting to be scanned.
final class AuthQrReady extends AuthState {
  final String qrCode;
  final int timeoutSeconds;

  const AuthQrReady(this.qrCode, this.timeoutSeconds);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthQrReady &&
          runtimeType == other.runtimeType &&
          qrCode == other.qrCode &&
          timeoutSeconds == other.timeoutSeconds;

  @override
  int get hashCode => Object.hash(qrCode, timeoutSeconds);

  @override
  String toString() =>
      'AuthState.qrReady(timeoutSeconds: $timeoutSeconds)';
}

/// State when client is attempting to establish a connection.
final class AuthConnecting extends AuthState {
  const AuthConnecting();

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is AuthConnecting;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'AuthState.connecting()';
}

/// State when client is authenticated and connected to WhatsApp.
final class AuthConnected extends AuthState {
  final String jid;
  final String phone;

  const AuthConnected(this.jid, this.phone);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthConnected &&
          runtimeType == other.runtimeType &&
          jid == other.jid &&
          phone == other.phone;

  @override
  int get hashCode => Object.hash(jid, phone);

  @override
  String toString() => 'AuthState.connected(jid: $jid, phone: $phone)';
}

/// State when client has logged out or was logged out by WhatsApp.
final class AuthLoggedOut extends AuthState {
  const AuthLoggedOut();

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is AuthLoggedOut;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'AuthState.loggedOut()';
}

/// State when an authentication or connection error has occurred.
final class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthError &&
          runtimeType == other.runtimeType &&
          message == other.message;

  @override
  int get hashCode => message.hashCode;

  @override
  String toString() => 'AuthState.error(message: $message)';
}
