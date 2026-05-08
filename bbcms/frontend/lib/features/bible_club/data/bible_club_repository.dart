import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_endpoints.dart';
import '../../../core/network/dio_client.dart';
import '../domain/bible_club_models.dart';

class BibleClubRepository {
  BibleClubRepository(this._dio);
  final Dio _dio;

  Future<List<BibleClub>> list() async {
    final res = await _dio.get<List<dynamic>>(ApiEndpoints.bibleClubs);
    return res.data!
        .map((e) => BibleClub.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<BibleClub> getById(String id) async {
    final res =
        await _dio.get<Map<String, dynamic>>(ApiEndpoints.bibleClubById(id));
    return BibleClub.fromJson(res.data!);
  }

  Future<BibleClub> create(CreateBibleClubRequest req) async {
    final res = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.bibleClubs,
      data: req.toJson(),
    );
    return BibleClub.fromJson(res.data!);
  }

  Future<BibleClub> setGoal(String id, int goal) async {
    final res = await _dio.put<Map<String, dynamic>>(
      ApiEndpoints.bibleClubGoal(id),
      data: {'goalNbFaithful': goal},
    );
    return BibleClub.fromJson(res.data!);
  }

  Future<BibleClub> setTriumvirate(
    String id, {
    String? presidentId,
    String? vicePresidentId,
    String? secretaryId,
  }) async {
    final res = await _dio.put<Map<String, dynamic>>(
      ApiEndpoints.bibleClubTriumvirate(id),
      data: {
        if (presidentId != null) 'presidentId': presidentId,
        if (vicePresidentId != null) 'vicePresidentId': vicePresidentId,
        if (secretaryId != null) 'secretaryId': secretaryId,
      },
    );
    return BibleClub.fromJson(res.data!);
  }

  Future<void> delete(String id) async {
    await _dio.delete<void>(ApiEndpoints.bibleClubById(id));
  }

  Future<List<Level>> listLevels(String bibleClubId) async {
    final res = await _dio.get<List<dynamic>>(
      ApiEndpoints.bibleClubLevels(bibleClubId),
    );
    return res.data!
        .map((e) => Level.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Level> createLevel(String bibleClubId, CreateLevelRequest req) async {
    final res = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.bibleClubLevels(bibleClubId),
      data: req.toJson(),
    );
    return Level.fromJson(res.data!);
  }

  Future<Level> updateLevel(
    String bibleClubId,
    String levelId,
    String name,
  ) async {
    final res = await _dio.put<Map<String, dynamic>>(
      ApiEndpoints.bibleClubLevelById(bibleClubId, levelId),
      data: {'name': name},
    );
    return Level.fromJson(res.data!);
  }

  Future<Level> setLevelPresident(
    String bibleClubId,
    String levelId,
    String memberId,
  ) async {
    final res = await _dio.put<Map<String, dynamic>>(
      ApiEndpoints.bibleClubLevelPresident(bibleClubId, levelId),
      data: {'memberId': memberId},
    );
    return Level.fromJson(res.data!);
  }

  Future<void> deleteLevel(String bibleClubId, String levelId) async {
    await _dio.delete<void>(
      ApiEndpoints.bibleClubLevelById(bibleClubId, levelId),
    );
  }
}

final bibleClubRepositoryProvider = Provider<BibleClubRepository>((ref) {
  return BibleClubRepository(ref.watch(dioProvider));
});
