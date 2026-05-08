import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_endpoints.dart';
import '../../../core/network/dio_client.dart';
import '../domain/meeting_models.dart';

class MeetingRepository {
  MeetingRepository(this._dio);
  final Dio _dio;

  Future<Meeting> getById(String id) async {
    final res =
        await _dio.get<Map<String, dynamic>>(ApiEndpoints.meetingById(id));
    return Meeting.fromJson(res.data!);
  }

  Future<Meeting> plan(PlanMeetingRequest req) async {
    final res = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.meetings,
      data: req.toJson(),
    );
    return Meeting.fromJson(res.data!);
  }

  Future<Meeting> start(
    String id, {
    required DateTime dateOccurred,
    required String startTime,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.meetingStart(id),
      data: {
        'dateOccurred': dateOccurred.toIso8601String().substring(0, 10),
        'startTime': startTime,
      },
    );
    return Meeting.fromJson(res.data!);
  }

  Future<Meeting> end(String id, {required String endTime}) async {
    final res = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.meetingEnd(id),
      data: {'endTime': endTime},
    );
    return Meeting.fromJson(res.data!);
  }

  Future<Meeting> record(String id, RecordMeetingRequest req) async {
    final res = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.meetingRecord(id),
      data: req.toJson(),
    );
    return Meeting.fromJson(res.data!);
  }

  Future<Meeting> cancel(String id) async {
    final res = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.meetingCancel(id),
    );
    return Meeting.fromJson(res.data!);
  }
}

final meetingRepositoryProvider = Provider<MeetingRepository>((ref) {
  return MeetingRepository(ref.watch(dioProvider));
});

final meetingProvider =
    FutureProvider.autoDispose.family<Meeting, String>((ref, id) {
  return ref.watch(meetingRepositoryProvider).getById(id);
});
