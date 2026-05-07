import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_endpoints.dart';
import '../../../core/network/dio_client.dart';
import '../domain/member_models.dart';

class MemberRepository {
  MemberRepository(this._dio);
  final Dio _dio;

  Future<List<Member>> listByBibleClub(String bibleClubId) async {
    final res = await _dio.get<List<dynamic>>(
      ApiEndpoints.members,
      queryParameters: {'bibleClubId': bibleClubId},
    );
    return res.data!
        .map((e) => Member.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Member> getById(String id) async {
    final res =
        await _dio.get<Map<String, dynamic>>(ApiEndpoints.memberById(id));
    return Member.fromJson(res.data!);
  }

  Future<Member> transferLevel(String id, String newLevelId) async {
    final res = await _dio.put<Map<String, dynamic>>(
      ApiEndpoints.memberLevel(id),
      data: {'newLevelId': newLevelId},
    );
    return Member.fromJson(res.data!);
  }

  Future<Member> transferBibleClub(
    String id, {
    required String newBibleClubId,
    required String newLevelId,
  }) async {
    final res = await _dio.put<Map<String, dynamic>>(
      ApiEndpoints.memberBibleClub(id),
      data: {'newBibleClubId': newBibleClubId, 'newLevelId': newLevelId},
    );
    return Member.fromJson(res.data!);
  }

  Future<Member> addDepartment(String id, Department dept) async {
    final res = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.memberDepartments(id),
      data: {'department': dept.apiValue},
    );
    return Member.fromJson(res.data!);
  }

  Future<Member> removeDepartment(String id, Department dept) async {
    final res = await _dio.delete<Map<String, dynamic>>(
      ApiEndpoints.memberDepartmentDelete(id, dept.apiValue),
    );
    return Member.fromJson(res.data!);
  }

  Future<Member> leave(String id) async {
    final res = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.memberLeave(id),
    );
    return Member.fromJson(res.data!);
  }
}

final memberRepositoryProvider = Provider<MemberRepository>((ref) {
  return MemberRepository(ref.watch(dioProvider));
});

final membersByClubProvider = FutureProvider.autoDispose
    .family<List<Member>, String>((ref, bibleClubId) async {
  return ref.watch(memberRepositoryProvider).listByBibleClub(bibleClubId);
});

final memberProvider =
    FutureProvider.autoDispose.family<Member, String>((ref, id) async {
  return ref.watch(memberRepositoryProvider).getById(id);
});
