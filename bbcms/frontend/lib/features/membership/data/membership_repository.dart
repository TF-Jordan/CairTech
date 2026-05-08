import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_endpoints.dart';
import '../../../core/network/dio_client.dart';
import '../domain/membership_models.dart';

class MembershipRepository {
  MembershipRepository(this._dio);
  final Dio _dio;

  Future<List<MembershipRequest>> list({MembershipRequestStatus? status}) async {
    final res = await _dio.get<List<dynamic>>(
      ApiEndpoints.membershipRequests,
      queryParameters: status == null ? null : {'status': status.apiValue},
    );
    return res.data!
        .map((e) => MembershipRequest.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<MembershipRequest> approve(
    String id, {
    required String assignedBibleClubId,
    required String assignedLevelId,
    String? comment,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.membershipRequestApprove(id),
      data: {
        'assignedBibleClubId': assignedBibleClubId,
        'assignedLevelId': assignedLevelId,
        if (comment != null) 'comment': comment,
      },
    );
    return MembershipRequest.fromJson(res.data!);
  }

  Future<MembershipRequest> reject(String id, {String? comment}) async {
    final res = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.membershipRequestReject(id),
      data: {if (comment != null) 'comment': comment},
    );
    return MembershipRequest.fromJson(res.data!);
  }

  Future<MembershipRequest> cancel(String id) async {
    final res = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.membershipRequestCancel(id),
    );
    return MembershipRequest.fromJson(res.data!);
  }
}

final membershipRepositoryProvider = Provider<MembershipRepository>((ref) {
  return MembershipRepository(ref.watch(dioProvider));
});

final membershipRequestsProvider = FutureProvider.autoDispose
    .family<List<MembershipRequest>, MembershipRequestStatus?>(
  (ref, status) =>
      ref.watch(membershipRepositoryProvider).list(status: status),
);
