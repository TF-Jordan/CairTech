import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../network/api_endpoints.dart';
import '../network/dio_client.dart';
import 'sync_models.dart';

class SyncClient {
  SyncClient(this._dio);
  final Dio _dio;

  Future<SyncBatch> pull({
    required SyncEntityKind kind,
    required String deviceId,
    DateTime? since,
    int limit = 100,
  }) async {
    final res = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.syncChanges,
      queryParameters: {
        'kind': kind.apiValue,
        if (since != null) 'since': since.toUtc().toIso8601String(),
        'limit': limit,
      },
      options: Options(headers: {'X-Device-Id': deviceId}),
    );
    return SyncBatch.fromJson(res.data!);
  }
}

final syncClientProvider = Provider<SyncClient>((ref) {
  return SyncClient(ref.watch(dioProvider));
});
