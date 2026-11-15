import 'dart:async';

import '../../core/ipc/i_ipc_service.dart';
import '../../core/ipc/ipc_message.dart';
import '../models/auth_state.dart';
import 'i_auth_repository.dart';

/// Concrete implementation of [IAuthRepository] communicating via [IIpcService].
class AuthRepository implements IAuthRepository {
  final IIpcService _ipcService;
  final StreamController<AuthState> _authStateController =
      StreamController<AuthState>.broadcast();
  StreamSubscription<IpcEvent>? _eventSubscription;

  AuthState _currentAuthState = const AuthState.initial();

  AuthRepository(this._ipcService) {
    _eventSubscription = _ipcService.allEvents.listen(_handleIpcEvent);
  }

  void _handleIpcEvent(IpcEvent event) {
    final data = event.data is Map ? (event.data as Map) : const {};

    switch (event.event) {
      case 'qr':
        final code = data['code'] as String? ?? data['qr'] as String? ?? '';
        final timeout = (data['timeout_seconds'] ??
                data['timeout'] as num?)?.toInt() ??
            20;
        _updateState(AuthState.qrReady(code, timeout));
        break;
      case 'connecting':
        _updateState(const AuthState.connecting());
        break;
      case 'connected':
        final jid = data['jid'] as String? ?? '';
        final phone = data['phone'] as String? ??
            (jid.contains('@') ? jid.split('@').first : jid);
        _updateState(AuthState.connected(jid, phone));
        break;
      case 'logged_out':
      case 'loggedOut':
        _updateState(const AuthState.loggedOut());
        break;
      case 'error':
        final msg = data['message'] as String? ?? 'Authentication error';
        _updateState(AuthState.error(msg));
        break;
    }
  }

  void _updateState(AuthState newState) {
    _currentAuthState = newState;
    if (!_authStateController.isClosed) {
      _authStateController.add(newState);
    }
  }

  @override
  Stream<AuthState> get authStateStream => _authStateController.stream;

  @override
  AuthState get currentAuthState => _currentAuthState;

  @override
  Future<void> requestLogin() async {
    _updateState(const AuthState.connecting());
    try {
      await _ipcService.sendRequest('login');
    } catch (e) {
      _updateState(AuthState.error(e.toString()));
      rethrow;
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _ipcService.sendRequest('logout');
    } finally {
      _updateState(const AuthState.loggedOut());
    }
  }

  @override
  void dispose() {
    _eventSubscription?.cancel();
    _eventSubscription = null;
    _authStateController.close();
  }
}
