import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_endpoints.dart';
import '../../../core/network/dio_client.dart';

class DiscipleLink {
  const DiscipleLink({
    required this.id,
    required this.makerId,
    required this.discipleId,
    required this.active,
    this.dateAssigned,
    this.dateEnded,
  });

  factory DiscipleLink.fromJson(Map<String, dynamic> j) => DiscipleLink(
        id: j['id'] as String,
        makerId: j['makerId'] as String,
        discipleId: j['discipleId'] as String,
        active: j['active'] as bool? ?? true,
        dateAssigned: j['dateAssigned'] != null
            ? DateTime.parse(j['dateAssigned'] as String)
            : null,
        dateEnded: j['dateEnded'] != null
            ? DateTime.parse(j['dateEnded'] as String)
            : null,
      );

  final String id;
  final String makerId;
  final String discipleId;
  final bool active;
  final DateTime? dateAssigned;
  final DateTime? dateEnded;
}

class DiscipleshipRepository {
  DiscipleshipRepository(this._dio);
  final Dio _dio;

  Future<DiscipleLink> assign({
    required String makerId,
    required String discipleId,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.discipleshipLinks,
      data: {'makerId': makerId, 'discipleId': discipleId},
    );
    return DiscipleLink.fromJson(res.data!);
  }

  Future<DiscipleLink> end(String linkId, DateTime when) async {
    final res = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.discipleshipLinkEnd(linkId),
      data: {'when': when.toIso8601String().substring(0, 10)},
    );
    return DiscipleLink.fromJson(res.data!);
  }

  Future<List<DiscipleLink>> linksOf(String makerId) async {
    final res = await _dio.get<List<dynamic>>(
      ApiEndpoints.discipleshipMakerDisciples(makerId),
    );
    return res.data!
        .map((e) => DiscipleLink.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> recordSession({
    required String makerId,
    required DateTime dateOccurred,
    String? theme,
    String? location,
    String? description,
    List<String> presentDiscipleIds = const [],
  }) async {
    await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.discipleshipRecords,
      data: {
        'makerId': makerId,
        'dateOccurred': dateOccurred.toIso8601String().substring(0, 10),
        if (theme != null) 'theme': theme,
        if (location != null) 'location': location,
        if (description != null) 'description': description,
        'presentDiscipleIds': presentDiscipleIds,
      },
    );
  }
}

final discipleshipRepositoryProvider = Provider<DiscipleshipRepository>((ref) {
  return DiscipleshipRepository(ref.watch(dioProvider));
});
