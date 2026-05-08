import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_endpoints.dart';
import '../../../core/network/dio_client.dart';

class PrayerChain {
  const PrayerChain({
    required this.id,
    required this.bibleClubId,
    required this.title,
    required this.status,
    this.dateStart,
    this.dateEnd,
  });

  factory PrayerChain.fromJson(Map<String, dynamic> j) => PrayerChain(
        id: j['id'] as String,
        bibleClubId: j['bibleClubId'] as String,
        title: j['title'] as String,
        status: j['status'] as String,
        dateStart: j['dateStart'] != null
            ? DateTime.parse(j['dateStart'] as String)
            : null,
        dateEnd: j['dateEnd'] != null
            ? DateTime.parse(j['dateEnd'] as String)
            : null,
      );

  final String id;
  final String bibleClubId;
  final String title;
  final String status;
  final DateTime? dateStart;
  final DateTime? dateEnd;
}

class PrayerSlot {
  const PrayerSlot({
    required this.id,
    required this.prayerChainId,
    required this.dtStart,
    required this.dtEnd,
    required this.covered,
    this.intercessorMemberId,
    this.note,
  });

  factory PrayerSlot.fromJson(Map<String, dynamic> j) => PrayerSlot(
        id: j['id'] as String,
        prayerChainId: j['prayerChainId'] as String,
        intercessorMemberId: j['intercessorMemberId'] as String?,
        dtStart: DateTime.parse(j['dtStart'] as String),
        dtEnd: DateTime.parse(j['dtEnd'] as String),
        covered: j['covered'] as bool? ?? false,
        note: j['note'] as String?,
      );

  final String id;
  final String prayerChainId;
  final String? intercessorMemberId;
  final DateTime dtStart;
  final DateTime dtEnd;
  final bool covered;
  final String? note;
}

class IntercessionRepository {
  IntercessionRepository(this._dio);
  final Dio _dio;

  Future<List<PrayerChain>> chainsByBibleClub(String bibleClubId) async {
    final res = await _dio.get<List<dynamic>>(
      ApiEndpoints.intercessionBibleClubChains(bibleClubId),
    );
    return res.data!
        .map((e) => PrayerChain.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<PrayerChain> draft({
    required String bibleClubId,
    required String title,
    required DateTime dateStart,
    DateTime? dateEnd,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.intercessionChains,
      data: {
        'bibleClubId': bibleClubId,
        'title': title,
        'dateStart': dateStart.toIso8601String().substring(0, 10),
        if (dateEnd != null)
          'dateEnd': dateEnd.toIso8601String().substring(0, 10),
      },
    );
    return PrayerChain.fromJson(res.data!);
  }

  Future<PrayerChain> start(String id) async {
    final res = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.intercessionChainStart(id),
    );
    return PrayerChain.fromJson(res.data!);
  }

  Future<PrayerChain> close(String id) async {
    final res = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.intercessionChainClose(id),
    );
    return PrayerChain.fromJson(res.data!);
  }

  Future<List<PrayerSlot>> slots(String chainId) async {
    final res = await _dio
        .get<List<dynamic>>(ApiEndpoints.intercessionChainSlots(chainId));
    return res.data!
        .map((e) => PrayerSlot.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<PrayerSlot> addSlot(
    String chainId, {
    required DateTime start,
    required DateTime end,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.intercessionChainSlots(chainId),
      data: {
        'start': start.toUtc().toIso8601String(),
        'end': end.toUtc().toIso8601String(),
      },
    );
    return PrayerSlot.fromJson(res.data!);
  }

  Future<PrayerSlot> cover(
    String slotId, {
    required String intercessorMemberId,
    String? note,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.intercessionSlotCover(slotId),
      data: {
        'intercessorMemberId': intercessorMemberId,
        if (note != null) 'note': note,
      },
    );
    return PrayerSlot.fromJson(res.data!);
  }
}

final intercessionRepositoryProvider = Provider<IntercessionRepository>((ref) {
  return IntercessionRepository(ref.watch(dioProvider));
});
