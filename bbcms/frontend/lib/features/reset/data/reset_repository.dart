import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_endpoints.dart';
import '../../../core/network/dio_client.dart';

class ResetSnapshot {
  const ResetSnapshot({
    required this.id,
    required this.bibleClubId,
    required this.academicYear,
    required this.nbMembersBefore,
    required this.nbFaithfulBefore,
    required this.nbMeetings,
    required this.percentageReached,
    this.archivedAt,
    this.archiveFileId,
  });

  factory ResetSnapshot.fromJson(Map<String, dynamic> j) => ResetSnapshot(
        id: j['id'] as String,
        bibleClubId: j['bibleClubId'] as String,
        academicYear: (j['academicYear'] as num).toInt(),
        nbMembersBefore: (j['nbMembersBefore'] as num).toInt(),
        nbFaithfulBefore: (j['nbFaithfulBefore'] as num).toInt(),
        nbMeetings: (j['nbMeetings'] as num).toInt(),
        percentageReached: (j['percentageReached'] as num).toDouble(),
        archivedAt: j['archivedAt'] != null
            ? DateTime.parse(j['archivedAt'] as String)
            : null,
        archiveFileId: j['archiveFileId'] as String?,
      );

  final String id;
  final String bibleClubId;
  final int academicYear;
  final int nbMembersBefore;
  final int nbFaithfulBefore;
  final int nbMeetings;
  final double percentageReached;
  final DateTime? archivedAt;
  final String? archiveFileId;
}

class ResetRepository {
  ResetRepository(this._dio);
  final Dio _dio;

  Future<ResetSnapshot> reset(String bibleClubId, int academicYear) async {
    final res = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.bibleClubReset(bibleClubId),
      data: {'academicYear': academicYear},
    );
    return ResetSnapshot.fromJson(res.data!);
  }
}

final resetRepositoryProvider = Provider<ResetRepository>((ref) {
  return ResetRepository(ref.watch(dioProvider));
});
