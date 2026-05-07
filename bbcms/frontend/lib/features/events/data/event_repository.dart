import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_endpoints.dart';
import '../../../core/network/dio_client.dart';
import '../domain/event_models.dart';

class EventRepository {
  EventRepository(this._dio);
  final Dio _dio;

  Future<List<EventModel>> list() async {
    final res = await _dio.get<List<dynamic>>(ApiEndpoints.events);
    return res.data!
        .map((e) => EventModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<EventModel> getById(String id) async {
    final res =
        await _dio.get<Map<String, dynamic>>(ApiEndpoints.eventById(id));
    return EventModel.fromJson(res.data!);
  }

  Future<EventModel> plan(PlanEventRequest req) async {
    final res = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.events,
      data: req.toJson(),
    );
    return EventModel.fromJson(res.data!);
  }

  Future<EventModel> openRegistration(String id) async {
    final res = await _dio
        .post<Map<String, dynamic>>(ApiEndpoints.eventOpenRegistration(id));
    return EventModel.fromJson(res.data!);
  }

  Future<EventModel> start(String id, DateTime when) async {
    final res = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.eventStart(id),
      data: {'when': when.toUtc().toIso8601String()},
    );
    return EventModel.fromJson(res.data!);
  }

  Future<EventModel> end(String id, DateTime when) async {
    final res = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.eventEnd(id),
      data: {'when': when.toUtc().toIso8601String()},
    );
    return EventModel.fromJson(res.data!);
  }

  Future<EventModel> cancel(String id) async {
    final res =
        await _dio.post<Map<String, dynamic>>(ApiEndpoints.eventCancel(id));
    return EventModel.fromJson(res.data!);
  }

  Future<EventParticipation> enroll(String id, String memberId) async {
    final res = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.eventEnroll(id),
      data: {'memberId': memberId},
    );
    return EventParticipation.fromJson(res.data!);
  }

  Future<EventParticipation> markPresent(
    String id, {
    required String memberId,
    required DateTime when,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.eventPresence(id),
      data: {'memberId': memberId, 'when': when.toUtc().toIso8601String()},
    );
    return EventParticipation.fromJson(res.data!);
  }

  Future<List<EventParticipation>> participations(String id) async {
    final res =
        await _dio.get<List<dynamic>>(ApiEndpoints.eventParticipations(id));
    return res.data!
        .map((e) => EventParticipation.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

final eventRepositoryProvider = Provider<EventRepository>((ref) {
  return EventRepository(ref.watch(dioProvider));
});

final eventsProvider =
    FutureProvider.autoDispose<List<EventModel>>((ref) async {
  return ref.watch(eventRepositoryProvider).list();
});

final eventProvider =
    FutureProvider.autoDispose.family<EventModel, String>((ref, id) async {
  return ref.watch(eventRepositoryProvider).getById(id);
});
