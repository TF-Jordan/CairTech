import 'dart:async';
import 'dart:io' show Platform;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../storage/secure_token_store.dart';
import 'api_exception.dart';
import 'api_routes.dart';

/// Resolved API base URL, with sensible per-platform defaults.
///
/// Override at runtime: `flutter run --dart-define=API_BASE_URL=...`.
///
/// Defaults:
/// - Android (emulator only):    http://10.0.2.2:8080   (the host's loopback)
/// - Everything else (desktop,
///   web, iOS sim, real device):  http://localhost:8080
///
/// On a real Android device, pass your host's LAN IP, e.g.
///   --dart-define=API_BASE_URL=http://192.168.1.42:8080
String get apiBaseUrl {
  const String fromEnv = String.fromEnvironment('API_BASE_URL');
  if (fromEnv.isNotEmpty) return fromEnv;
  if (!kIsWeb && Platform.isAndroid) return 'http://10.0.2.2:8080';
  return 'http://localhost:8080';
}

class _RefreshState {
  Completer<String?>? inFlight;
}

/// Singleton Dio instance with:
///  - Bearer-token injection on every request,
///  - Single-flight refresh on 401 (auto-retries the original request),
///  - Normalized [ApiException] on failures.
class BbcmsDioFactory {
  BbcmsDioFactory({
    required this.tokenStore,
    required this.onSessionLost,
  });

  final SecureTokenStore tokenStore;
  final FutureOr<void> Function() onSessionLost;
  final _RefreshState _refresh = _RefreshState();

  Dio build() {
    final Dio dio = Dio(BaseOptions(
      baseUrl: apiBaseUrl,
      connectTimeout: const Duration(seconds: 12),
      receiveTimeout: const Duration(seconds: 20),
      sendTimeout: const Duration(seconds: 20),
      headers: <String, String>{
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      validateStatus: (int? s) => s != null && s < 500,
    ));

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (RequestOptions opts, RequestInterceptorHandler handler) async {
        if (!_isPublic(opts.path)) {
          final TokenPair? pair = await tokenStore.read();
          if (pair != null) {
            opts.headers['Authorization'] = 'Bearer ${pair.accessToken}';
          }
        }
        return handler.next(opts);
      },
      onResponse: (Response<dynamic> resp, ResponseInterceptorHandler handler) {
        if (resp.statusCode != null && resp.statusCode! >= 400) {
          return handler.reject(DioException(
            requestOptions: resp.requestOptions,
            response: resp,
            type: DioExceptionType.badResponse,
            error: ApiException.fromResponse(
              resp.statusCode,
              resp.data is Map<String, dynamic> ? resp.data as Map<String, dynamic> : null,
            ),
          ));
        }
        return handler.next(resp);
      },
      onError: (DioException err, ErrorInterceptorHandler handler) async {
        final int? status = err.response?.statusCode;
        final String path = err.requestOptions.path;

        // Auto-refresh on 401 (single-flight, ignore for /auth/* paths).
        if (status == 401 && !_isAuthPath(path)) {
          final String? newAccess = await _refreshOnce(dio);
          if (newAccess != null) {
            final RequestOptions retry = err.requestOptions;
            retry.headers['Authorization'] = 'Bearer $newAccess';
            try {
              final Response<dynamic> r = await dio.fetch<dynamic>(retry);
              return handler.resolve(r);
            } catch (_) {
              // fallthrough to onSessionLost below
            }
          }
          await onSessionLost();
        }

        handler.reject(DioException(
          requestOptions: err.requestOptions,
          response: err.response,
          type: err.type,
          error: ApiException.fromResponse(
            status,
            err.response?.data is Map<String, dynamic>
                ? err.response?.data as Map<String, dynamic>
                : null,
          ),
        ));
      },
    ));

    if (kDebugMode) {
      dio.interceptors.add(LogInterceptor(
        request: false,
        requestBody: false,
        responseBody: false,
        error: true,
      ));
    }
    return dio;
  }

  Future<String?> _refreshOnce(Dio dio) {
    if (_refresh.inFlight != null) return _refresh.inFlight!.future;
    final Completer<String?> c = Completer<String?>();
    _refresh.inFlight = c;
    () async {
      try {
        final TokenPair? pair = await tokenStore.read();
        if (pair == null) {
          c.complete(null);
          return;
        }
        final Response<dynamic> resp = await Dio(BaseOptions(baseUrl: apiBaseUrl))
            .post<dynamic>(ApiRoutes.authRefresh,
                data: <String, String>{'refreshToken': pair.refreshToken});
        if (resp.statusCode == 200 && resp.data is Map<String, dynamic>) {
          final Map<String, dynamic> body = resp.data as Map<String, dynamic>;
          final String access = body['accessToken'] as String;
          final String refresh = body['refreshToken'] as String;
          await tokenStore.save(TokenPair(accessToken: access, refreshToken: refresh));
          c.complete(access);
        } else {
          c.complete(null);
        }
      } catch (_) {
        c.complete(null);
      } finally {
        _refresh.inFlight = null;
      }
    }();
    return c.future;
  }

  bool _isPublic(String path) {
    return path.contains('/auth/login') ||
        path.contains('/auth/refresh') ||
        path.contains('/users/activate') ||
        path.contains('/public/');
  }

  bool _isAuthPath(String path) =>
      path.contains('/auth/login') || path.contains('/auth/refresh');
}

final Provider<Dio> dioProvider = Provider<Dio>((Ref ref) {
  final SecureTokenStore store = ref.watch(tokenStoreProvider);
  final BbcmsDioFactory factory = BbcmsDioFactory(
    tokenStore: store,
    onSessionLost: () async {
      await store.clear();
    },
  );
  return factory.build();
});
