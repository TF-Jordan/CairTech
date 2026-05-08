/// Domain failure types surfaced to UI.
sealed class AppFailure implements Exception {
  const AppFailure(this.message, {this.code});
  final String message;
  final String? code;

  @override
  String toString() => '$runtimeType($code): $message';
}

class NetworkFailure extends AppFailure {
  const NetworkFailure(super.message, {super.code});
}

class UnauthorizedFailure extends AppFailure {
  const UnauthorizedFailure([super.message = 'Session expirée'])
    : super(code: 'UNAUTHORIZED');
}

class ForbiddenFailure extends AppFailure {
  const ForbiddenFailure([super.message = 'Permission refusée'])
    : super(code: 'FORBIDDEN');
}

class NotFoundFailure extends AppFailure {
  const NotFoundFailure([super.message = 'Ressource introuvable'])
    : super(code: 'NOT_FOUND');
}

class RateLimitedFailure extends AppFailure {
  const RateLimitedFailure([super.message = 'Trop de requêtes'])
    : super(code: 'RATE_LIMITED');
}

class ValidationFailure extends AppFailure {
  const ValidationFailure(super.message, {super.code, this.fields = const {}});
  final Map<String, String> fields;
}

class ServerFailure extends AppFailure {
  const ServerFailure(super.message, {super.code});
}

class UnknownFailure extends AppFailure {
  const UnknownFailure([super.message = 'Erreur inconnue']);
}
