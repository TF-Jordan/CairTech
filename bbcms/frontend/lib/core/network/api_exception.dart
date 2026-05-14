/// Normalized API error consumed by the UI layer.
class ApiException implements Exception {
  ApiException({
    required this.code,
    required this.message,
    this.statusCode,
    this.details,
  });

  factory ApiException.fromResponse(int? status, Map<String, dynamic>? body) {
    if (body == null) {
      return ApiException(
        code: 'BBCMS_UNKNOWN',
        message: 'Erreur inconnue',
        statusCode: status,
      );
    }
    return ApiException(
      code: (body['code'] as String?) ?? 'BBCMS_UNKNOWN',
      message: (body['message'] as String?) ?? 'Erreur inattendue',
      statusCode: status,
      details: body,
    );
  }

  final String code;
  final String message;
  final int? statusCode;
  final Map<String, dynamic>? details;

  bool get isUnauthorized => statusCode == 401;
  bool get isForbidden => statusCode == 403;
  bool get isRateLimited => code == 'BBCMS_RATE_LIMITED' || statusCode == 429;

  @override
  String toString() => '[$code] $message (HTTP ${statusCode ?? '?'})';
}
