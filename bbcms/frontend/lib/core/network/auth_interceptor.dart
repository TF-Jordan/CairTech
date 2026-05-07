import 'package:dio/dio.dart';

import '../storage/token_storage.dart';
import 'api_endpoints.dart';

/// Adds Bearer token to requests and refreshes it transparently on 401.
class AuthInterceptor extends QueuedInterceptor {
  AuthInterceptor({required this.storage, required this.refreshDio});

  final TokenStorage storage;

  /// Separate Dio used to refresh tokens, no interceptor to avoid recursion.
  final Dio refreshDio;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (options.extra['skipAuth'] == true) {
      return handler.next(options);
    }
    final token = await storage.readAccess();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode != 401 ||
        err.requestOptions.extra['retried'] == true) {
      return handler.next(err);
    }

    final refresh = await storage.readRefresh();
    if (refresh == null || refresh.isEmpty) {
      await storage.clear();
      return handler.next(err);
    }

    try {
      final res = await refreshDio.post<Map<String, dynamic>>(
        ApiEndpoints.authRefresh,
        data: {'refreshToken': refresh},
      );
      final data = res.data!;
      await storage.writeTokens(
        access: data['accessToken'] as String,
        refresh: data['refreshToken'] as String,
      );

      final retry = err.requestOptions
        ..headers['Authorization'] = 'Bearer ${data['accessToken']}'
        ..extra['retried'] = true;

      final response = await refreshDio.fetch<dynamic>(retry);
      return handler.resolve(response);
    } catch (_) {
      await storage.clear();
      return handler.next(err);
    }
  }
}
