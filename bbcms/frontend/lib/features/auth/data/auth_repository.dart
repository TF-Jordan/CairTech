import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_endpoints.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/storage/token_storage.dart';
import '../domain/auth_models.dart';

class AuthRepository {
  AuthRepository(this._dio, this._storage);

  final Dio _dio;
  final TokenStorage _storage;

  Future<AuthTokens> login({
    required String email,
    required String password,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.authLogin,
      data: {'email': email, 'password': password},
      options: Options(extra: const {'skipAuth': true}),
    );
    final tokens = AuthTokens.fromJson(res.data!);
    await _storage.writeTokens(
      access: tokens.accessToken,
      refresh: tokens.refreshToken,
    );
    return tokens;
  }

  Future<void> logout() async {
    final refresh = await _storage.readRefresh();
    if (refresh != null) {
      try {
        await _dio.post<void>(
          ApiEndpoints.authLogout,
          data: {'refreshToken': refresh},
          options: Options(extra: const {'skipAuth': true}),
        );
      } catch (_) {
        /* best-effort */
      }
    }
    await _storage.clear();
  }

  Future<UserAccount> register(RegisterRequest request) async {
    final res = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.users,
      data: request.toJson(),
      options: Options(extra: const {'skipAuth': true}),
    );
    return UserAccount.fromJson(res.data!);
  }

  Future<UserAccount> activate(String token) async {
    final res = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.usersActivate,
      queryParameters: {'token': token},
      options: Options(extra: const {'skipAuth': true}),
    );
    return UserAccount.fromJson(res.data!);
  }

  Future<UserAccount> getMe(String userId) async {
    final res = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.userById(userId),
    );
    return UserAccount.fromJson(res.data!);
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    ref.watch(dioProvider),
    ref.watch(tokenStorageProvider),
  );
});
