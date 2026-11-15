import '../models/auth_state.dart';

/// Contract for authentication operations and observing auth status.
abstract interface class IAuthRepository {
  /// Stream emitting real-time authentication state updates.
  Stream<AuthState> get authStateStream;

  /// Current cached authentication state snapshot.
  AuthState get currentAuthState;

  /// Initiates WhatsApp connection and requests login / QR code.
  Future<void> requestLogin();

  /// Logs out the user from WhatsApp and clears session.
  Future<void> logout();

  /// Releases resources and stream subscriptions.
  void dispose();
}
