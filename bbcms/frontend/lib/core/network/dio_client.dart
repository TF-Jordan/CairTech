import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../storage/token_storage.dart';
import 'api_endpoints.dart';
import 'auth_interceptor.dart';
import 'error_interceptor.dart';

/// Provides the configured [Dio] used by all repositories.
final dioProvider = Provider<Dio>((ref) {
  final storage = ref.watch(tokenStorageProvider);

  final base = BaseOptions(
    baseUrl: ApiEndpoints.baseUrl,
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 20),
    sendTimeout: const Duration(seconds: 20),
    headers: {'Content-Type': 'application/json'},
  );

  final refreshDio = Dio(base);
  final dio = Dio(base);

  dio.interceptors.addAll([
    AuthInterceptor(storage: storage, refreshDio: refreshDio),
    ErrorInterceptor(),
    PrettyDioLogger(
      requestHeader: false,
      requestBody: true,
      responseBody: false,
      compact: true,
    ),
  ]);
  refreshDio.interceptors.add(ErrorInterceptor());

  return dio;
});
