import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api_routes.dart';
import 'dio_client.dart';

/// Typed facade over the backend REST API. Every public method maps to one
/// `@RequestMapping` in the Spring Boot controllers under `bbcms/backend/`.
class ApiClient {
  ApiClient(this._dio);

  final Dio _dio;

  // ─── AUTH ───────────────────────────────────────────────────────
  Future<Map<String, dynamic>> login(String email, String password) async {
    final Response<dynamic> r = await _dio.post<dynamic>(ApiRoutes.authLogin,
        data: <String, String>{'email': email, 'password': password});
    return r.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> refresh(String refreshToken) async {
    final Response<dynamic> r = await _dio.post<dynamic>(ApiRoutes.authRefresh,
        data: <String, String>{'refreshToken': refreshToken});
    return r.data as Map<String, dynamic>;
  }

  Future<void> logout(String refreshToken) =>
      _dio.post<dynamic>(ApiRoutes.authLogout,
          data: <String, String>{'refreshToken': refreshToken});

  // ─── USERS ──────────────────────────────────────────────────────
  Future<Map<String, dynamic>> registerUser(Map<String, dynamic> body) async {
    final Response<dynamic> r = await _dio.post<dynamic>(ApiRoutes.users, data: body);
    return r.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> activateAccount(String token) async {
    final Response<dynamic> r = await _dio.post<dynamic>(
      ApiRoutes.userActivate,
      queryParameters: <String, String>{'token': token},
    );
    return r.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getUser(String id) async {
    final Response<dynamic> r = await _dio.get<dynamic>(ApiRoutes.userById(id));
    return r.data as Map<String, dynamic>;
  }

  // ─── MEMBERSHIP REQUESTS ────────────────────────────────────────
  Future<List<Map<String, dynamic>>> listMembershipRequests({String? status}) async {
    final Response<dynamic> r = await _dio.get<dynamic>(
      ApiRoutes.membershipRequests,
      queryParameters: status != null ? <String, String>{'status': status} : null,
    );
    return (r.data as List<dynamic>).cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> getMembershipRequest(String id) async {
    final Response<dynamic> r = await _dio.get<dynamic>(ApiRoutes.membershipRequestById(id));
    return r.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> approveMembershipRequest(
    String id,
    Map<String, dynamic> body,
  ) async {
    final Response<dynamic> r =
        await _dio.post<dynamic>(ApiRoutes.membershipRequestApprove(id), data: body);
    return r.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> rejectMembershipRequest(
    String id,
    Map<String, dynamic> body,
  ) async {
    final Response<dynamic> r =
        await _dio.post<dynamic>(ApiRoutes.membershipRequestReject(id), data: body);
    return r.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> cancelMembershipRequest(String id) async {
    final Response<dynamic> r = await _dio.post<dynamic>(ApiRoutes.membershipRequestCancel(id));
    return r.data as Map<String, dynamic>;
  }

  // ─── PUBLIC REGISTRY ────────────────────────────────────────────
  Future<List<Map<String, dynamic>>> publicBibleClubs() async {
    final Response<dynamic> r = await _dio.get<dynamic>(ApiRoutes.publicBibleClubs);
    return (r.data as List<dynamic>).cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> publicLevels(String bibleClubId) async {
    final Response<dynamic> r = await _dio.get<dynamic>(ApiRoutes.publicLevelsOf(bibleClubId));
    return (r.data as List<dynamic>).cast<Map<String, dynamic>>();
  }

  // ─── BIBLE CLUBS ────────────────────────────────────────────────
  Future<List<Map<String, dynamic>>> listBibleClubs() async {
    final Response<dynamic> r = await _dio.get<dynamic>(ApiRoutes.bibleClubs);
    return (r.data as List<dynamic>).cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> getBibleClub(String id) async {
    final Response<dynamic> r = await _dio.get<dynamic>(ApiRoutes.bibleClubById(id));
    return r.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> createBibleClub(Map<String, dynamic> body) async {
    final Response<dynamic> r = await _dio.post<dynamic>(ApiRoutes.bibleClubs, data: body);
    return r.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> setBibleClubGoal(String id, int goal) async {
    final Response<dynamic> r = await _dio.put<dynamic>(
      ApiRoutes.bibleClubGoal(id),
      data: <String, int>{'goalNbFaithful': goal},
    );
    return r.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> assignTriumvirate(
    String id, {
    String? presidentId,
    String? vicePresidentId,
    String? secretaryId,
  }) async {
    final Response<dynamic> r = await _dio.put<dynamic>(
      ApiRoutes.bibleClubTriumvirate(id),
      data: <String, String?>{
        'presidentId': presidentId,
        'vicePresidentId': vicePresidentId,
        'secretaryId': secretaryId,
      },
    );
    return r.data as Map<String, dynamic>;
  }

  Future<void> deleteBibleClub(String id) =>
      _dio.delete<dynamic>(ApiRoutes.bibleClubById(id));

  Future<Map<String, dynamic>> resetBibleClub(String id) async {
    final Response<dynamic> r = await _dio.post<dynamic>(ApiRoutes.bibleClubReset(id));
    return r.data as Map<String, dynamic>;
  }

  // ─── LEVELS ─────────────────────────────────────────────────────
  Future<List<Map<String, dynamic>>> listLevels(String bibleClubId) async {
    final Response<dynamic> r = await _dio.get<dynamic>(ApiRoutes.levelsOf(bibleClubId));
    return (r.data as List<dynamic>).cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> createLevel(String bibleClubId, Map<String, dynamic> body) async {
    final Response<dynamic> r =
        await _dio.post<dynamic>(ApiRoutes.levelsOf(bibleClubId), data: body);
    return r.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> renameLevel(
      String bibleClubId, String levelId, String name) async {
    final Response<dynamic> r = await _dio.put<dynamic>(
      ApiRoutes.levelById(bibleClubId, levelId),
      data: <String, String>{'name': name},
    );
    return r.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> assignLevelPresident(
      String bibleClubId, String levelId, String memberId) async {
    final Response<dynamic> r = await _dio.put<dynamic>(
      ApiRoutes.levelPresident(bibleClubId, levelId),
      data: <String, String>{'memberId': memberId},
    );
    return r.data as Map<String, dynamic>;
  }

  Future<void> deleteLevel(String bibleClubId, String levelId) =>
      _dio.delete<dynamic>(ApiRoutes.levelById(bibleClubId, levelId));

  // ─── MEMBERS ────────────────────────────────────────────────────
  Future<List<Map<String, dynamic>>> listMembers(String bibleClubId) async {
    final Response<dynamic> r = await _dio.get<dynamic>(
      ApiRoutes.members,
      queryParameters: <String, String>{'bibleClubId': bibleClubId},
    );
    return (r.data as List<dynamic>).cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> getMember(String id) async {
    final Response<dynamic> r = await _dio.get<dynamic>(ApiRoutes.memberById(id));
    return r.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> transferMemberLevel(String id, String newLevelId) async {
    final Response<dynamic> r = await _dio.put<dynamic>(
      ApiRoutes.memberLevel(id),
      data: <String, String>{'newLevelId': newLevelId},
    );
    return r.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> transferMemberBbc(
      String id, String newBibleClubId, String newLevelId) async {
    final Response<dynamic> r = await _dio.put<dynamic>(
      ApiRoutes.memberBbc(id),
      data: <String, String>{
        'newBibleClubId': newBibleClubId,
        'newLevelId': newLevelId,
      },
    );
    return r.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> addMemberDepartment(String id, String department) async {
    final Response<dynamic> r = await _dio.post<dynamic>(
      ApiRoutes.memberDepartments(id),
      data: <String, String>{'department': department},
    );
    return r.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> removeMemberDepartment(String id, String department) async {
    final Response<dynamic> r =
        await _dio.delete<dynamic>(ApiRoutes.memberDepartment(id, department));
    return r.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> leaveMember(String id) async {
    final Response<dynamic> r = await _dio.post<dynamic>(ApiRoutes.memberLeave(id));
    return r.data as Map<String, dynamic>;
  }

  // ─── MEETINGS ───────────────────────────────────────────────────
  Future<Map<String, dynamic>> planMeeting(Map<String, dynamic> body) async {
    final Response<dynamic> r = await _dio.post<dynamic>(ApiRoutes.meetings, data: body);
    return r.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getMeeting(String id) async {
    final Response<dynamic> r = await _dio.get<dynamic>(ApiRoutes.meetingById(id));
    return r.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> startMeeting(String id, Map<String, dynamic> body) async {
    final Response<dynamic> r = await _dio.post<dynamic>(ApiRoutes.meetingStart(id), data: body);
    return r.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> endMeeting(String id, Map<String, dynamic> body) async {
    final Response<dynamic> r = await _dio.post<dynamic>(ApiRoutes.meetingEnd(id), data: body);
    return r.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> recordMeeting(String id, Map<String, dynamic> body) async {
    final Response<dynamic> r =
        await _dio.post<dynamic>(ApiRoutes.meetingRecord(id), data: body);
    return r.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> cancelMeeting(String id) async {
    final Response<dynamic> r = await _dio.post<dynamic>(ApiRoutes.meetingCancel(id));
    return r.data as Map<String, dynamic>;
  }

  // ─── EVENTS ─────────────────────────────────────────────────────
  Future<List<Map<String, dynamic>>> listEvents() async {
    final Response<dynamic> r = await _dio.get<dynamic>(ApiRoutes.events);
    return (r.data as List<dynamic>).cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> planEvent(Map<String, dynamic> body) async {
    final Response<dynamic> r = await _dio.post<dynamic>(ApiRoutes.events, data: body);
    return r.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getEvent(String id) async {
    final Response<dynamic> r = await _dio.get<dynamic>(ApiRoutes.eventById(id));
    return r.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> openEventRegistration(String id) async {
    final Response<dynamic> r = await _dio.post<dynamic>(ApiRoutes.eventOpenReg(id));
    return r.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> startEvent(String id, Map<String, dynamic> body) async {
    final Response<dynamic> r = await _dio.post<dynamic>(ApiRoutes.eventStart(id), data: body);
    return r.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> endEvent(String id, Map<String, dynamic> body) async {
    final Response<dynamic> r = await _dio.post<dynamic>(ApiRoutes.eventEnd(id), data: body);
    return r.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> cancelEvent(String id) async {
    final Response<dynamic> r = await _dio.post<dynamic>(ApiRoutes.eventCancel(id));
    return r.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> enrollEvent(String id, String memberId) async {
    final Response<dynamic> r = await _dio.post<dynamic>(
      ApiRoutes.eventEnroll(id),
      data: <String, String>{'memberId': memberId},
    );
    return r.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> markEventPresence(
      String id, String memberId, DateTime when) async {
    final Response<dynamic> r = await _dio.post<dynamic>(
      ApiRoutes.eventPresence(id),
      data: <String, String>{'memberId': memberId, 'when': when.toIso8601String()},
    );
    return r.data as Map<String, dynamic>;
  }

  Future<List<Map<String, dynamic>>> listEventParticipations(String id) async {
    final Response<dynamic> r = await _dio.get<dynamic>(ApiRoutes.eventParticipations(id));
    return (r.data as List<dynamic>).cast<Map<String, dynamic>>();
  }

  // ─── ATTENDANCE ─────────────────────────────────────────────────
  Future<Map<String, dynamic>> getAttendanceScore(String memberId, {int? academicYear}) async {
    final Response<dynamic> r = await _dio.get<dynamic>(
      ApiRoutes.attendanceMember(memberId),
      queryParameters:
          academicYear != null ? <String, int>{'academicYear': academicYear} : null,
    );
    return r.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> recomputeAttendance(String memberId) async {
    final Response<dynamic> r = await _dio.post<dynamic>(ApiRoutes.attendanceRecompute(memberId));
    return r.data as Map<String, dynamic>;
  }

  Future<List<Map<String, dynamic>>> faithfulOf(String bibleClubId, {int? academicYear}) async {
    final Response<dynamic> r = await _dio.get<dynamic>(
      ApiRoutes.attendanceFaithful(bibleClubId),
      queryParameters:
          academicYear != null ? <String, int>{'academicYear': academicYear} : null,
    );
    return (r.data as List<dynamic>).cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> recomputeAllAttendance() async {
    final Response<dynamic> r = await _dio.post<dynamic>(ApiRoutes.attendanceRecomputeAll);
    return r.data as Map<String, dynamic>;
  }

  // ─── PUBLICATIONS ───────────────────────────────────────────────
  Future<List<Map<String, dynamic>>> listDailyVerses() async {
    final Response<dynamic> r = await _dio.get<dynamic>(ApiRoutes.dailyVerses);
    return (r.data as List<dynamic>).cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> getDailyVerse(String id) async {
    final Response<dynamic> r = await _dio.get<dynamic>(ApiRoutes.dailyVerseById(id));
    return r.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> draftDailyVerse(Map<String, dynamic> body) async {
    final Response<dynamic> r = await _dio.post<dynamic>(ApiRoutes.dailyVerses, data: body);
    return r.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> publishDailyVerse(String id) async {
    final Response<dynamic> r = await _dio.post<dynamic>(ApiRoutes.dailyVersePublish(id));
    return r.data as Map<String, dynamic>;
  }

  Future<List<Map<String, dynamic>>> listAnnouncements() async {
    final Response<dynamic> r = await _dio.get<dynamic>(ApiRoutes.announcements);
    return (r.data as List<dynamic>).cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> draftAnnouncement(Map<String, dynamic> body) async {
    final Response<dynamic> r = await _dio.post<dynamic>(ApiRoutes.announcements, data: body);
    return r.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> publishAnnouncement(String id) async {
    final Response<dynamic> r = await _dio.post<dynamic>(ApiRoutes.announcementPublish(id));
    return r.data as Map<String, dynamic>;
  }

  // ─── INTERCESSION ───────────────────────────────────────────────
  Future<Map<String, dynamic>> draftChain(Map<String, dynamic> body) async {
    final Response<dynamic> r = await _dio.post<dynamic>(ApiRoutes.intercessionChains, data: body);
    return r.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> startChain(String id) async {
    final Response<dynamic> r = await _dio.post<dynamic>(ApiRoutes.intercessionChainStart(id));
    return r.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> closeChain(String id) async {
    final Response<dynamic> r = await _dio.post<dynamic>(ApiRoutes.intercessionChainClose(id));
    return r.data as Map<String, dynamic>;
  }

  Future<List<Map<String, dynamic>>> listChains(String bibleClubId) async {
    final Response<dynamic> r =
        await _dio.get<dynamic>(ApiRoutes.intercessionChainsOf(bibleClubId));
    return (r.data as List<dynamic>).cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> addChainSlot(String chainId, Map<String, dynamic> body) async {
    final Response<dynamic> r =
        await _dio.post<dynamic>(ApiRoutes.intercessionChainSlots(chainId), data: body);
    return r.data as Map<String, dynamic>;
  }

  Future<List<Map<String, dynamic>>> listChainSlots(String chainId) async {
    final Response<dynamic> r =
        await _dio.get<dynamic>(ApiRoutes.intercessionChainSlots(chainId));
    return (r.data as List<dynamic>).cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> coverSlot(
      String slotId, String intercessorMemberId, {String? note}) async {
    final Response<dynamic> r = await _dio.post<dynamic>(
      ApiRoutes.intercessionSlotCover(slotId),
      data: <String, String?>{
        'intercessorMemberId': intercessorMemberId,
        'note': note,
      },
    );
    return r.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> uncoverSlot(String slotId) async {
    final Response<dynamic> r = await _dio.post<dynamic>(ApiRoutes.intercessionSlotUncover(slotId));
    return r.data as Map<String, dynamic>;
  }

  // ─── FINANCE ────────────────────────────────────────────────────
  Future<List<Map<String, dynamic>>> listContributions(String bibleClubId) async {
    final Response<dynamic> r = await _dio.get<dynamic>(
      ApiRoutes.financeContributions,
      queryParameters: <String, String>{'bibleClubId': bibleClubId},
    );
    return (r.data as List<dynamic>).cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> openContribution(Map<String, dynamic> body) async {
    final Response<dynamic> r =
        await _dio.post<dynamic>(ApiRoutes.financeContributions, data: body);
    return r.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> closeContribution(String id, {DateTime? when}) async {
    final Response<dynamic> r = await _dio.post<dynamic>(
      ApiRoutes.contributionClose(id),
      data: <String, String?>{'when': when?.toIso8601String().split('T').first},
    );
    return r.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getContribution(String id) async {
    final Response<dynamic> r = await _dio.get<dynamic>(ApiRoutes.contributionById(id));
    return r.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> recordPayment(
      String contributionId, Map<String, dynamic> body) async {
    final Response<dynamic> r =
        await _dio.post<dynamic>(ApiRoutes.contributionPayments(contributionId), data: body);
    return r.data as Map<String, dynamic>;
  }

  Future<List<Map<String, dynamic>>> listPayments(String contributionId) async {
    final Response<dynamic> r =
        await _dio.get<dynamic>(ApiRoutes.contributionPayments(contributionId));
    return (r.data as List<dynamic>).cast<Map<String, dynamic>>();
  }

  // ─── EVANGELISM ─────────────────────────────────────────────────
  Future<List<Map<String, dynamic>>> listEvangelismPrograms() async {
    final Response<dynamic> r = await _dio.get<dynamic>(ApiRoutes.evangelismPrograms);
    return (r.data as List<dynamic>).cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> getEvangelismProgram(String id) async {
    final Response<dynamic> r = await _dio.get<dynamic>(ApiRoutes.evangelismProgramById(id));
    return r.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> draftEvangelismProgram(Map<String, dynamic> body) async {
    final Response<dynamic> r =
        await _dio.post<dynamic>(ApiRoutes.evangelismPrograms, data: body);
    return r.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> addEvangelismDate(String id, String date) async {
    final Response<dynamic> r = await _dio.post<dynamic>(
      ApiRoutes.evangelismProgramDates(id),
      data: <String, String>{'date': date},
    );
    return r.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> addEvangelismBbc(String id, String bibleClubId) async {
    final Response<dynamic> r = await _dio.post<dynamic>(
      ApiRoutes.evangelismProgramBbcs(id),
      data: <String, String>{'bibleClubId': bibleClubId},
    );
    return r.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> activateEvangelismProgram(String id) async {
    final Response<dynamic> r = await _dio.post<dynamic>(ApiRoutes.evangelismProgramActivate(id));
    return r.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> closeEvangelismProgram(String id) async {
    final Response<dynamic> r = await _dio.post<dynamic>(ApiRoutes.evangelismProgramClose(id));
    return r.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> recordEvangelism(
      String programId, Map<String, dynamic> body) async {
    final Response<dynamic> r =
        await _dio.post<dynamic>(ApiRoutes.evangelismRecords(programId), data: body);
    return r.data as Map<String, dynamic>;
  }

  Future<List<Map<String, dynamic>>> listEvangelismRecords(String programId) async {
    final Response<dynamic> r = await _dio.get<dynamic>(ApiRoutes.evangelismRecords(programId));
    return (r.data as List<dynamic>).cast<Map<String, dynamic>>();
  }

  // ─── DISCIPLESHIP ───────────────────────────────────────────────
  Future<Map<String, dynamic>> assignDisciple(String makerId, String discipleId) async {
    final Response<dynamic> r = await _dio.post<dynamic>(
      ApiRoutes.discipleshipLinks,
      data: <String, String>{'makerId': makerId, 'discipleId': discipleId},
    );
    return r.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> endDiscipleship(String linkId, {String? when}) async {
    final Response<dynamic> r = await _dio.post<dynamic>(
      ApiRoutes.discipleshipLinkEnd(linkId),
      data: <String, String?>{'when': when},
    );
    return r.data as Map<String, dynamic>;
  }

  Future<List<Map<String, dynamic>>> listDisciplesOf(String makerId) async {
    final Response<dynamic> r = await _dio.get<dynamic>(ApiRoutes.discipleshipDisciplesOf(makerId));
    return (r.data as List<dynamic>).cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> recordDiscipleship(Map<String, dynamic> body) async {
    final Response<dynamic> r =
        await _dio.post<dynamic>(ApiRoutes.discipleshipRecords, data: body);
    return r.data as Map<String, dynamic>;
  }

  Future<List<Map<String, dynamic>>> listDiscipleshipRecordsOf(String makerId) async {
    final Response<dynamic> r =
        await _dio.get<dynamic>(ApiRoutes.discipleshipRecordsOf(makerId));
    return (r.data as List<dynamic>).cast<Map<String, dynamic>>();
  }

  // ─── DASHBOARDS ─────────────────────────────────────────────────
  Future<Map<String, dynamic>> dashboardBbc(String bibleClubId, {int? academicYear}) async {
    final Response<dynamic> r = await _dio.get<dynamic>(
      ApiRoutes.dashboardBbc(bibleClubId),
      queryParameters:
          academicYear != null ? <String, int>{'academicYear': academicYear} : null,
    );
    return r.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> dashboardNational({int? academicYear}) async {
    final Response<dynamic> r = await _dio.get<dynamic>(
      ApiRoutes.dashboardNational,
      queryParameters:
          academicYear != null ? <String, int>{'academicYear': academicYear} : null,
    );
    return r.data as Map<String, dynamic>;
  }

  // ─── SYNC ───────────────────────────────────────────────────────
  Future<Map<String, dynamic>> syncChanges({
    required String deviceId,
    required String kind,
    DateTime? since,
    int limit = 100,
  }) async {
    final Response<dynamic> r = await _dio.get<dynamic>(
      ApiRoutes.syncChanges,
      options: Options(headers: <String, String>{'X-Device-Id': deviceId}),
      queryParameters: <String, dynamic>{
        'kind': kind,
        if (since != null) 'since': since.toUtc().toIso8601String(),
        'limit': limit,
      },
    );
    return r.data as Map<String, dynamic>;
  }

  // ─── FILES ──────────────────────────────────────────────────────
  Future<Map<String, dynamic>> uploadFile({
    required Uint8List bytes,
    required String filename,
    required String contentType,
  }) async {
    final FormData form = FormData.fromMap(<String, dynamic>{
      'file': MultipartFile.fromBytes(bytes, filename: filename, contentType: null),
      'size': bytes.length.toString(),
    });
    final Response<dynamic> r = await _dio.post<dynamic>(
      ApiRoutes.files,
      data: form,
      options: Options(contentType: 'multipart/form-data'),
    );
    return r.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> uploadLocalFile(File f, {required String contentType}) async {
    final Uint8List bytes = await f.readAsBytes();
    return uploadFile(
      bytes: bytes,
      filename: f.path.split(Platform.pathSeparator).last,
      contentType: contentType,
    );
  }

  Future<String> getFileUrl(String id, {int ttlSeconds = 3600}) async {
    final Response<dynamic> r = await _dio.get<dynamic>(
      ApiRoutes.fileUrl(id),
      queryParameters: <String, int>{'ttlSeconds': ttlSeconds},
    );
    return (r.data as Map<String, dynamic>)['url'] as String;
  }

  Future<void> deleteFile(String id) => _dio.delete<dynamic>(ApiRoutes.fileById(id));
}

final Provider<ApiClient> apiClientProvider = Provider<ApiClient>(
  (Ref ref) => ApiClient(ref.watch(dioProvider)),
);
