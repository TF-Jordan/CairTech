import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_endpoints.dart';
import '../../../core/network/dio_client.dart';

class AttendanceScore {
  const AttendanceScore({
    required this.id,
    required this.memberId,
    required this.bibleClubId,
    required this.levelId,
    required this.academicYear,
    required this.score,
    required this.totalEligible,
    required this.faithfulPercentage,
    required this.faithful,
    this.lastComputedAt,
  });

  factory AttendanceScore.fromJson(Map<String, dynamic> j) =>
      AttendanceScore(
        id: j['id'] as String,
        memberId: j['memberId'] as String,
        bibleClubId: j['bibleClubId'] as String,
        levelId: j['levelId'] as String,
        academicYear: (j['academicYear'] as num).toInt(),
        score: (j['score'] as num).toInt(),
        totalEligible: (j['totalEligible'] as num).toInt(),
        faithfulPercentage: (j['faithfulPercentage'] as num).toDouble(),
        faithful: j['faithful'] as bool? ?? false,
        lastComputedAt: j['lastComputedAt'] != null
            ? DateTime.parse(j['lastComputedAt'] as String)
            : null,
      );

  final String id;
  final String memberId;
  final String bibleClubId;
  final String levelId;
  final int academicYear;
  final int score;
  final int totalEligible;
  final double faithfulPercentage;
  final bool faithful;
  final DateTime? lastComputedAt;
}

class AttendanceRepository {
  AttendanceRepository(this._dio);
  final Dio _dio;

  Future<AttendanceScore> ofMember(String memberId, {int? academicYear}) async {
    final res = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.attendanceMember(memberId),
      queryParameters:
          academicYear == null ? null : {'academicYear': academicYear},
    );
    return AttendanceScore.fromJson(res.data!);
  }

  Future<AttendanceScore> recompute(String memberId) async {
    final res = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.attendanceMemberRecompute(memberId),
    );
    return AttendanceScore.fromJson(res.data!);
  }

  Future<List<AttendanceScore>> faithfulOf(
    String bibleClubId, {
    int? academicYear,
  }) async {
    final res = await _dio.get<List<dynamic>>(
      ApiEndpoints.attendanceFaithful(bibleClubId),
      queryParameters:
          academicYear == null ? null : {'academicYear': academicYear},
    );
    return res.data!
        .map((e) => AttendanceScore.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<int> recomputeAll() async {
    final res = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.attendanceRecomputeAll,
    );
    return (res.data!['studentsProcessed'] as num).toInt();
  }
}

final attendanceRepositoryProvider = Provider<AttendanceRepository>((ref) {
  return AttendanceRepository(ref.watch(dioProvider));
});
