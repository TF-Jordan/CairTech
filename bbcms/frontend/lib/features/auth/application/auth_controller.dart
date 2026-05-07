import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/failures.dart';
import '../../../core/rbac/auth_session.dart';
import '../data/auth_repository.dart';
import '../domain/auth_models.dart';

class AuthController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      try {
        await ref.read(authRepositoryProvider).login(
              email: email,
              password: password,
            );
        await ref.read(authSessionProvider.notifier).refresh();
      } on DioException catch (e) {
        final f = e.error;
        if (f is AppFailure) throw f;
        rethrow;
      }
    });
  }

  Future<void> logout() async {
    await ref.read(authRepositoryProvider).logout();
    await ref.read(authSessionProvider.notifier).clear();
  }

  Future<UserAccount> register(RegisterRequest req) async {
    try {
      return await ref.read(authRepositoryProvider).register(req);
    } on DioException catch (e) {
      final f = e.error;
      if (f is AppFailure) throw f;
      rethrow;
    }
  }

  Future<UserAccount> activate(String token) async {
    try {
      return await ref.read(authRepositoryProvider).activate(token);
    } on DioException catch (e) {
      final f = e.error;
      if (f is AppFailure) throw f;
      rethrow;
    }
  }
}

final authControllerProvider =
    AsyncNotifierProvider<AuthController, void>(AuthController.new);
