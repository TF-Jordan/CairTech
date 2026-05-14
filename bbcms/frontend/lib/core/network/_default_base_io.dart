/// Default API base URL when no `--dart-define=API_BASE_URL=...` is provided.
/// Mobile/desktop implementation (uses `dart:io`).
library;

import 'dart:io' show Platform;

String defaultApiBaseUrl() {
  if (Platform.isAndroid) return 'http://10.0.2.2:8080';
  return 'http://localhost:8080';
}
