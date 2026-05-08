import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_endpoints.dart';
import '../../../core/network/dio_client.dart';

class DailyVerse {
  const DailyVerse({
    required this.id,
    required this.title,
    required this.reference,
    required this.verseText,
    required this.publishDate,
    required this.status,
    this.reflectionText,
    this.imageFileId,
    this.audience,
  });

  factory DailyVerse.fromJson(Map<String, dynamic> j) => DailyVerse(
        id: j['id'] as String,
        title: j['title'] as String,
        reference: j['reference'] as String,
        verseText: j['verseText'] as String,
        reflectionText: j['reflectionText'] as String?,
        imageFileId: j['imageFileId'] as String?,
        publishDate: DateTime.parse(j['publishDate'] as String),
        status: j['status'] as String,
        audience: j['audience'] as String?,
      );

  final String id;
  final String title;
  final String reference;
  final String verseText;
  final String? reflectionText;
  final String? imageFileId;
  final DateTime publishDate;
  final String status;
  final String? audience;
}

class Announcement {
  const Announcement({
    required this.id,
    required this.title,
    required this.content,
    required this.type,
    required this.publishDate,
    required this.status,
    this.imageFileId,
    this.audience,
  });

  factory Announcement.fromJson(Map<String, dynamic> j) => Announcement(
        id: j['id'] as String,
        title: j['title'] as String,
        content: j['content'] as String,
        imageFileId: j['imageFileId'] as String?,
        type: j['type'] as String,
        publishDate: DateTime.parse(j['publishDate'] as String),
        status: j['status'] as String,
        audience: j['audience'] as String?,
      );

  final String id;
  final String title;
  final String content;
  final String? imageFileId;
  final String type;
  final DateTime publishDate;
  final String status;
  final String? audience;
}

class PublicationsRepository {
  PublicationsRepository(this._dio);
  final Dio _dio;

  Future<List<DailyVerse>> dailyVerses() async {
    final res = await _dio.get<List<dynamic>>(ApiEndpoints.dailyVerses);
    return res.data!
        .map((e) => DailyVerse.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<Announcement>> announcements() async {
    final res = await _dio.get<List<dynamic>>(ApiEndpoints.announcements);
    return res.data!
        .map((e) => Announcement.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

final publicationsRepositoryProvider = Provider<PublicationsRepository>((ref) {
  return PublicationsRepository(ref.watch(dioProvider));
});

final dailyVersesProvider =
    FutureProvider.autoDispose<List<DailyVerse>>((ref) {
  return ref.watch(publicationsRepositoryProvider).dailyVerses();
});

final announcementsProvider =
    FutureProvider.autoDispose<List<Announcement>>((ref) {
  return ref.watch(publicationsRepositoryProvider).announcements();
});
