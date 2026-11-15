import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../domain/models/auth_state.dart';
import '../../../domain/repositories/i_auth_repository.dart';

/// State management controller for WhatsApp QR authentication lifecycle.
class AuthController extends ChangeNotifier {
  final IAuthRepository authRepository;
  StreamSubscription<AuthState>? _subscription;
  Timer? _countdownTimer;

  AuthState _state = const AuthState.initial();
  bool _isLoading = false;
  int _remainingSeconds = 0;
  bool _isExpired = false;

  AuthController({required this.authRepository}) {
    _init();
  }

  /// Current authentication state from domain repository.
  AuthState get state => _state;

  /// Whether a network/IPC request is in progress.
  bool get isLoading => _isLoading;

  /// Seconds remaining before QR code expires.
  int get remainingSeconds => _remainingSeconds;

  /// Whether the current QR code has expired and needs refresh.
  bool get isExpired => _isExpired;

  /// Quick status helpers.
  bool get isQrReady => _state is AuthQrReady;
  bool get isConnecting => _state is AuthConnecting;
  bool get isConnected => _state is AuthConnected;
  bool get hasError => _state is AuthError;

  /// Raw QR payload string if available.
  String? get qrCode =>
      _state is AuthQrReady ? (_state as AuthQrReady).qrCode : null;

  /// Error message if in error state.
  String? get errorMessage =>
      _state is AuthError ? (_state as AuthError).message : null;

  void _init() {
    _state = authRepository.currentAuthState;
    _handleNewState(_state);

    _subscription = authRepository.authStateStream.listen(
      _handleNewState,
      onError: (Object error) {
        _isLoading = false;
        _state = AuthState.error(error.toString());
        notifyListeners();
      },
    );

    if (_state is AuthInitial) {
      refreshQr();
    }
  }

  void _handleNewState(AuthState newState) {
    _state = newState;
    _isLoading = false;

    if (newState is AuthQrReady) {
      _isExpired = false;
      _startCountdown(newState.timeoutSeconds);
    } else {
      _stopCountdown();
      _isExpired = false;
    }
    notifyListeners();
  }

  void _startCountdown(int seconds) {
    _stopCountdown();
    _remainingSeconds = seconds > 0 ? seconds : 60;
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 1) {
        _remainingSeconds--;
        notifyListeners();
      } else {
        _remainingSeconds = 0;
        _isExpired = true;
        _stopCountdown();
        notifyListeners();
      }
    });
  }

  void _stopCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = null;
  }

  /// Request a fresh QR code from the daemon.
  Future<void> refreshQr() async {
    _isLoading = true;
    _isExpired = false;
    notifyListeners();
    try {
      await authRepository.requestLogin();
    } catch (e) {
      _isLoading = false;
      _state = AuthState.error(e.toString());
      notifyListeners();
    }
  }

  /// Retries the login flow after failure.
  Future<void> retry() => refreshQr();

  @override
  void dispose() {
    _stopCountdown();
    _subscription?.cancel();
    super.dispose();
  }
}
