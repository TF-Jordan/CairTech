import 'package:dio/dio.dart';

import '../error/failures.dart';

/// Maps Dio errors to typed [AppFailure] for the UI layer.
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final res = err.response;
    final code = res?.statusCode ?? 0;
    final body = res?.data;

    String? apiCode;
    String message = err.message ?? 'Erreur réseau';
    if (body is Map<String, dynamic>) {
      apiCode = body['code'] as String?;
      message = (body['message'] as String?) ?? message;
    }

    AppFailure failure;
    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.connectionError ||
        err.type == DioExceptionType.receiveTimeout) {
      failure = NetworkFailure(message, code: apiCode);
    } else if (code == 401) {
      failure = UnauthorizedFailure(message);
    } else if (code == 403) {
      failure = ForbiddenFailure(message);
    } else if (code == 404) {
      failure = NotFoundFailure(message);
    } else if (code == 429) {
      failure = RateLimitedFailure(message);
    } else if (code >= 400 && code < 500) {
      failure = ValidationFailure(message, code: apiCode);
    } else if (code >= 500) {
      failure = ServerFailure(message, code: apiCode);
    } else {
      failure = const UnknownFailure();
    }

    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        response: res,
        type: err.type,
        error: failure,
        message: message,
      ),
    );
  }
}
