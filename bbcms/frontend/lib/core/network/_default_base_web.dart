/// Default API base URL when no `--dart-define=API_BASE_URL=...` is provided.
/// Web implementation — `dart:io` is unavailable, so always use the page's
/// host or a build-time override.
library;

String defaultApiBaseUrl() => 'http://localhost:8080';
