import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_client.dart';
import '../../core/network/api_exception.dart';
import '../../core/storage/secure_token_store.dart';
import '../../core/utils/jwt_session.dart';

class AuthState {
  AuthState({this.session, this.loading = false, this.error});

  final JwtSession? session;
  final bool loading;
  final String? error;

  bool get isAuthenticated => session != null;

  AuthState copyWith({JwtSession? session, bool? loading, String? error, bool clearSession = false}) =>
      AuthState(
        session: clearSession ? null : session ?? this.session,
        loading: loading ?? this.loading,
        error: error,
      );
}

class AuthController extends StateNotifier<AuthState> {
  AuthController(this._ref) : super(AuthState()) {
    _bootstrap();
  }

  final Ref _ref;
  String? _refreshToken;

  Future<void> _bootstrap() async {
    final SecureTokenStore store = _ref.read(tokenStoreProvider);
    final TokenPair? pair = await store.read();
    if (pair == null) return;
    try {
      final JwtSession session = JwtSession.parse(pair.accessToken);
      _refreshToken = pair.refreshToken;
      state = state.copyWith(session: session);
    } catch (_) {
      await store.clear();
    }
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(loading: true, error: null);
    try {
      final ApiClient api = _ref.read(apiClientProvider);
      final Map<String, dynamic> data = await api.login(email, password);
      final String access = data['accessToken'] as String;
      final String refresh = data['refreshToken'] as String;
      await _ref.read(tokenStoreProvider).save(TokenPair(accessToken: access, refreshToken: refresh));
      _refreshToken = refresh;
      state = state.copyWith(session: JwtSession.parse(access), loading: false);
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(loading: false, error: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(loading: false, error: 'Connexion impossible');
      return false;
    }
  }

  Future<void> logout() async {
    if (_refreshToken != null) {
      try {
        await _ref.read(apiClientProvider).logout(_refreshToken!);
      } catch (_) {/* ignore */}
    }
    await _ref.read(tokenStoreProvider).clear();
    _refreshToken = null;
    state = AuthState();
  }
}

final StateNotifierProvider<AuthController, AuthState> authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>(
        (Ref ref) => AuthController(ref));

final Provider<JwtSession?> sessionProvider = Provider<JwtSession?>(
  (Ref ref) => ref.watch(authControllerProvider).session,
);
