import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_endpoints.dart';
import '../../../core/network/dio_client.dart';

class BibleClubLite {
  const BibleClubLite({
    required this.id,
    required this.name,
    this.schoolName,
  });

  factory BibleClubLite.fromJson(Map<String, dynamic> j) => BibleClubLite(
        id: j['id'] as String,
        name: j['name'] as String,
        schoolName: j['schoolName'] as String?,
      );

  final String id;
  final String name;
  final String? schoolName;
}

class LevelLite {
  const LevelLite({required this.id, required this.name, required this.type});

  factory LevelLite.fromJson(Map<String, dynamic> j) => LevelLite(
        id: j['id'] as String,
        name: j['name'] as String,
        type: j['type'] as String,
      );

  final String id;
  final String name;
  final String type;
}

/// Anonymous-friendly registry used by the registration form.
class RegistryRepository {
  RegistryRepository(this._dio);
  final Dio _dio;

  Future<List<BibleClubLite>> bibleClubs() async {
    final res = await _dio.get<List<dynamic>>(
      ApiEndpoints.publicBibleClubs,
      options: Options(extra: const {'skipAuth': true}),
    );
    return res.data!
        .map((e) => BibleClubLite.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<LevelLite>> levels(String bibleClubId) async {
    final res = await _dio.get<List<dynamic>>(
      ApiEndpoints.publicLevels(bibleClubId),
      options: Options(extra: const {'skipAuth': true}),
    );
    return res.data!
        .map((e) => LevelLite.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

final registryRepositoryProvider = Provider<RegistryRepository>((ref) {
  return RegistryRepository(ref.watch(dioProvider));
});

final publicBibleClubsProvider =
    FutureProvider.autoDispose<List<BibleClubLite>>((ref) {
  return ref.watch(registryRepositoryProvider).bibleClubs();
});

final publicLevelsProvider = FutureProvider.autoDispose
    .family<List<LevelLite>, String>((ref, bibleClubId) {
  return ref.watch(registryRepositoryProvider).levels(bibleClubId);
});
