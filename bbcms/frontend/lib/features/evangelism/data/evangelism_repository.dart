import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_endpoints.dart';
import '../../../core/network/dio_client.dart';
import '../domain/evangelism_models.dart';

class EvangelismRepository {
  EvangelismRepository(this._dio);
  final Dio _dio;

  Future<List<EvangelismProgram>> listPrograms() async {
    final res =
        await _dio.get<List<dynamic>>(ApiEndpoints.evangelismPrograms);
    return res.data!
        .map((e) => EvangelismProgram.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<EvangelismProgram> draft(DraftEvangelismProgramRequest req) async {
    final res = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.evangelismPrograms,
      data: req.toJson(),
    );
    return EvangelismProgram.fromJson(res.data!);
  }

  Future<EvangelismProgram> activate(String id) async {
    final res = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.evangelismProgramActivate(id),
    );
    return EvangelismProgram.fromJson(res.data!);
  }

  Future<EvangelismProgram> close(String id) async {
    final res = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.evangelismProgramClose(id),
    );
    return EvangelismProgram.fromJson(res.data!);
  }

  Future<void> addRecord(
    String programId,
    CreateEvangelismRecordRequest req,
  ) async {
    await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.evangelismProgramRecords(programId),
      data: req.toJson(),
    );
  }
}

final evangelismRepositoryProvider = Provider<EvangelismRepository>((ref) {
  return EvangelismRepository(ref.watch(dioProvider));
});

final evangelismProgramsProvider =
    FutureProvider.autoDispose<List<EvangelismProgram>>((ref) {
  return ref.watch(evangelismRepositoryProvider).listPrograms();
});
