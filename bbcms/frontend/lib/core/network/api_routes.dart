/// Centralized backend API routes (Spring Boot WebFlux backend in `../backend/`).
///
/// Every route below maps 1:1 to a `@RequestMapping` in a controller, with the
/// required permission(s) commented when applicable. Keep this file as the
/// single source of truth — do NOT hardcode paths anywhere else in `lib/`.
class ApiRoutes {
  ApiRoutes._();

  static const String prefix = '/api/v1/bbcms';

  // ─── Auth ──────────────────────────────────────────────────────
  static const String authLogin = '$prefix/auth/login'; // public
  static const String authRefresh = '$prefix/auth/refresh'; // public
  static const String authLogout = '$prefix/auth/logout'; // public

  // ─── Users / Identity ──────────────────────────────────────────
  static const String users = '$prefix/users'; // POST public (register)
  static const String userActivate = '$prefix/users/activate'; // POST public
  static String userById(String id) => '$prefix/users/$id'; // GET

  // ─── Membership requests ───────────────────────────────────────
  static const String membershipRequests = '$prefix/membership-requests';
  static String membershipRequestById(String id) => '$membershipRequests/$id';
  static String membershipRequestApprove(String id) => '$membershipRequests/$id/approve';
  static String membershipRequestReject(String id) => '$membershipRequests/$id/reject';
  static String membershipRequestCancel(String id) => '$membershipRequests/$id/cancel';

  // ─── Public registry (no auth required) ────────────────────────
  static const String publicBibleClubs = '$prefix/public/bible-clubs';
  static String publicLevelsOf(String bibleClubId) =>
      '$prefix/public/bible-clubs/$bibleClubId/levels';

  // ─── Bible clubs (RBAC) ────────────────────────────────────────
  static const String bibleClubs = '$prefix/bible-clubs';
  static String bibleClubById(String id) => '$bibleClubs/$id';
  static String bibleClubGoal(String id) => '$bibleClubs/$id/goal';
  static String bibleClubTriumvirate(String id) => '$bibleClubs/$id/triumvirate';
  static String bibleClubReset(String id) => '$bibleClubs/$id/reset';

  // ─── Levels ────────────────────────────────────────────────────
  static String levelsOf(String bibleClubId) => '$bibleClubs/$bibleClubId/levels';
  static String levelById(String bibleClubId, String levelId) =>
      '$bibleClubs/$bibleClubId/levels/$levelId';
  static String levelPresident(String bibleClubId, String levelId) =>
      '$bibleClubs/$bibleClubId/levels/$levelId/president';

  // ─── Members ───────────────────────────────────────────────────
  static const String members = '$prefix/members';
  static String memberById(String id) => '$members/$id';
  static String memberLevel(String id) => '$members/$id/level';
  static String memberBbc(String id) => '$members/$id/bible-club';
  static String memberDepartments(String id) => '$members/$id/departments';
  static String memberDepartment(String id, String dept) => '$members/$id/departments/$dept';
  static String memberLeave(String id) => '$members/$id/leave';

  // ─── Meetings ──────────────────────────────────────────────────
  static const String meetings = '$prefix/meetings';
  static String meetingById(String id) => '$meetings/$id';
  static String meetingStart(String id) => '$meetings/$id/start';
  static String meetingEnd(String id) => '$meetings/$id/end';
  static String meetingRecord(String id) => '$meetings/$id/record';
  static String meetingCancel(String id) => '$meetings/$id/cancel';

  // ─── Events ────────────────────────────────────────────────────
  static const String events = '$prefix/events';
  static String eventById(String id) => '$events/$id';
  static String eventOpenReg(String id) => '$events/$id/open-registration';
  static String eventStart(String id) => '$events/$id/start';
  static String eventEnd(String id) => '$events/$id/end';
  static String eventCancel(String id) => '$events/$id/cancel';
  static String eventEnroll(String id) => '$events/$id/enroll';
  static String eventPresence(String id) => '$events/$id/presence';
  static String eventParticipations(String id) => '$events/$id/participations';

  // ─── Attendance ────────────────────────────────────────────────
  static String attendanceMember(String memberId) => '$prefix/attendance/members/$memberId';
  static String attendanceRecompute(String memberId) =>
      '$prefix/attendance/members/$memberId/recompute';
  static String attendanceFaithful(String bibleClubId) =>
      '$prefix/attendance/bible-clubs/$bibleClubId/faithful';
  static const String attendanceRecomputeAll = '$prefix/attendance/recompute-all';

  // ─── Evangelism ────────────────────────────────────────────────
  static const String evangelismPrograms = '$prefix/evangelism/programs';
  static String evangelismProgramById(String id) => '$evangelismPrograms/$id';
  static String evangelismProgramDates(String id) => '$evangelismPrograms/$id/dates';
  static String evangelismProgramBbcs(String id) => '$evangelismPrograms/$id/bible-clubs';
  static String evangelismProgramActivate(String id) => '$evangelismPrograms/$id/activate';
  static String evangelismProgramClose(String id) => '$evangelismPrograms/$id/close';
  static String evangelismRecords(String programId) => '$evangelismPrograms/$programId/records';

  // ─── Discipleship ──────────────────────────────────────────────
  static const String discipleshipLinks = '$prefix/discipleship/links';
  static String discipleshipLinkEnd(String id) => '$discipleshipLinks/$id/end';
  static const String discipleshipRecords = '$prefix/discipleship/records';
  static String discipleshipDisciplesOf(String makerId) =>
      '$prefix/discipleship/makers/$makerId/disciples';
  static String discipleshipRecordsOf(String makerId) =>
      '$prefix/discipleship/makers/$makerId/records';

  // ─── Intercession ──────────────────────────────────────────────
  static const String intercessionChains = '$prefix/intercession/chains';
  static String intercessionChainStart(String id) => '$intercessionChains/$id/start';
  static String intercessionChainClose(String id) => '$intercessionChains/$id/close';
  static String intercessionChainsOf(String bibleClubId) =>
      '$prefix/intercession/bible-clubs/$bibleClubId/chains';
  static String intercessionChainSlots(String chainId) => '$intercessionChains/$chainId/slots';
  static String intercessionSlotCover(String slotId) =>
      '$prefix/intercession/slots/$slotId/cover';
  static String intercessionSlotUncover(String slotId) =>
      '$prefix/intercession/slots/$slotId/uncover';

  // ─── Finance ───────────────────────────────────────────────────
  static const String financeContributions = '$prefix/finance/contributions';
  static String contributionById(String id) => '$financeContributions/$id';
  static String contributionClose(String id) => '$financeContributions/$id/close';
  static String contributionPayments(String id) => '$financeContributions/$id/payments';

  // ─── Publications ──────────────────────────────────────────────
  static const String dailyVerses = '$prefix/publications/daily-verses';
  static String dailyVerseById(String id) => '$dailyVerses/$id';
  static String dailyVersePublish(String id) => '$dailyVerses/$id/publish';
  static const String announcements = '$prefix/publications/announcements';
  static String announcementPublish(String id) => '$announcements/$id/publish';

  // ─── Dashboards ────────────────────────────────────────────────
  static String dashboardBbc(String bibleClubId) => '$prefix/dashboards/bible-clubs/$bibleClubId';
  static const String dashboardNational = '$prefix/dashboards/national';

  // ─── Sync ──────────────────────────────────────────────────────
  static const String syncChanges = '$prefix/sync/changes';

  // ─── Files (NEW, added by frontend implementation) ─────────────
  static const String files = '$prefix/files';
  static String fileUrl(String id) => '$files/$id/url';
  static String fileById(String id) => '$files/$id';
}
