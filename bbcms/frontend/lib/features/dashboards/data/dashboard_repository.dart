import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_endpoints.dart';
import '../../../core/network/dio_client.dart';

/// Loose model — backend dashboard payload is rich and evolving.
/// We keep it as a Map and surface helper getters for known fields.
class DashboardPayload {
  const DashboardPayload(this.raw);
  final Map<String, dynamic> raw;

  int get memberCount => (raw['memberCount'] as num?)?.toInt() ?? 0;
  int get faithfulCount => (raw['faithfulCount'] as num?)?.toInt() ?? 0;
  int get meetingCount => (raw['meetingCount'] as num?)?.toInt() ?? 0;
  int get totalAttendance => (raw['totalAttendance'] as num?)?.toInt() ?? 0;
  int get totalBibleClubs =>
      (raw['totalBibleClubs'] as num?)?.toInt() ?? 0;
  double get percentageFaithful =>
      (raw['percentageFaithful'] as num?)?.toDouble() ?? 0;
  double get avgAttendancePerMeeting =>
      (raw['avgAttendancePerMeeting'] as num?)?.toDouble() ?? 0;
  int? get academicYear => (raw['academicYear'] as num?)?.toInt();
}

class DashboardRepository {
  DashboardRepository(this._dio);
  final Dio _dio;

  Future<DashboardPayload> bibleClub(String id, {int? academicYear}) async {
    final res = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.dashboardBibleClub(id),
      queryParameters:
          academicYear == null ? null : {'academicYear': academicYear},
    );
    return DashboardPayload(res.data!);
  }

  Future<DashboardPayload> national({int? academicYear}) async {
    final res = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.dashboardNational,
      queryParameters:
          academicYear == null ? null : {'academicYear': academicYear},
    );
    return DashboardPayload(res.data!);
  }
}

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepository(ref.watch(dioProvider));
});

final bibleClubDashboardProvider = FutureProvider.autoDispose
    .family<DashboardPayload, String>((ref, id) {
  return ref.watch(dashboardRepositoryProvider).bibleClub(id);
});

final nationalDashboardProvider =
    FutureProvider.autoDispose<DashboardPayload>((ref) {
  return ref.watch(dashboardRepositoryProvider).national();
});
