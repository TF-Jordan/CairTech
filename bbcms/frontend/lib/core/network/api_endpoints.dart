/// Centralized API endpoints for BBCMS backend.
///
/// Base URL is configured via `--dart-define=BBCMS_API_BASE_URL=...`.
/// Default: `http://localhost:8080/api/v1/bbcms`.
///
/// All paths are relative to [ApiEndpoints.baseUrl].
class ApiEndpoints {
  const ApiEndpoints._();

  static const String baseUrl = String.fromEnvironment(
    'BBCMS_API_BASE_URL',
    defaultValue: 'http://localhost:8080/api/v1/bbcms',
  );

  // --------------------------------------------------------------------------
  // AUTH
  // --------------------------------------------------------------------------
  static const String authLogin = '/auth/login';
  static const String authRefresh = '/auth/refresh';
  static const String authLogout = '/auth/logout';

  // --------------------------------------------------------------------------
  // USERS
  // --------------------------------------------------------------------------
  static const String users = '/users';
  static const String usersActivate = '/users/activate';
  static String userById(String id) => '/users/$id';

  // --------------------------------------------------------------------------
  // MEMBERSHIP REQUESTS
  // --------------------------------------------------------------------------
  static const String membershipRequests = '/membership-requests';
  static String membershipRequestById(String id) => '/membership-requests/$id';
  static String membershipRequestApprove(String id) =>
      '/membership-requests/$id/approve';
  static String membershipRequestReject(String id) =>
      '/membership-requests/$id/reject';
  static String membershipRequestCancel(String id) =>
      '/membership-requests/$id/cancel';

  // --------------------------------------------------------------------------
  // MEMBERS
  // --------------------------------------------------------------------------
  static const String members = '/members';
  static String memberById(String id) => '/members/$id';
  static String memberLevel(String id) => '/members/$id/level';
  static String memberBibleClub(String id) => '/members/$id/bible-club';
  static String memberDepartments(String id) => '/members/$id/departments';
  static String memberDepartmentDelete(String id, String dept) =>
      '/members/$id/departments/$dept';
  static String memberLeave(String id) => '/members/$id/leave';

  // --------------------------------------------------------------------------
  // BIBLE CLUBS
  // --------------------------------------------------------------------------
  static const String bibleClubs = '/bible-clubs';
  static String bibleClubById(String id) => '/bible-clubs/$id';
  static String bibleClubGoal(String id) => '/bible-clubs/$id/goal';
  static String bibleClubTriumvirate(String id) =>
      '/bible-clubs/$id/triumvirate';
  static String bibleClubReset(String id) => '/bible-clubs/$id/reset';

  // --------------------------------------------------------------------------
  // LEVELS
  // --------------------------------------------------------------------------
  static String bibleClubLevels(String bibleClubId) =>
      '/bible-clubs/$bibleClubId/levels';
  static String bibleClubLevelById(String bibleClubId, String levelId) =>
      '/bible-clubs/$bibleClubId/levels/$levelId';
  static String bibleClubLevelPresident(String bibleClubId, String levelId) =>
      '/bible-clubs/$bibleClubId/levels/$levelId/president';

  // --------------------------------------------------------------------------
  // MEETINGS
  // --------------------------------------------------------------------------
  static const String meetings = '/meetings';
  static String meetingById(String id) => '/meetings/$id';
  static String meetingStart(String id) => '/meetings/$id/start';
  static String meetingEnd(String id) => '/meetings/$id/end';
  static String meetingRecord(String id) => '/meetings/$id/record';
  static String meetingCancel(String id) => '/meetings/$id/cancel';

  // --------------------------------------------------------------------------
  // EVENTS
  // --------------------------------------------------------------------------
  static const String events = '/events';
  static String eventById(String id) => '/events/$id';
  static String eventOpenRegistration(String id) =>
      '/events/$id/open-registration';
  static String eventStart(String id) => '/events/$id/start';
  static String eventEnd(String id) => '/events/$id/end';
  static String eventCancel(String id) => '/events/$id/cancel';
  static String eventEnroll(String id) => '/events/$id/enroll';
  static String eventPresence(String id) => '/events/$id/presence';
  static String eventParticipations(String id) => '/events/$id/participations';

  // --------------------------------------------------------------------------
  // ATTENDANCE / FAITHFULNESS
  // --------------------------------------------------------------------------
  static String attendanceMember(String memberId) =>
      '/attendance/members/$memberId';
  static String attendanceMemberRecompute(String memberId) =>
      '/attendance/members/$memberId/recompute';
  static String attendanceFaithful(String bibleClubId) =>
      '/attendance/bible-clubs/$bibleClubId/faithful';
  static const String attendanceRecomputeAll = '/attendance/recompute-all';

  // --------------------------------------------------------------------------
  // EVANGELISM
  // --------------------------------------------------------------------------
  static const String evangelismPrograms = '/evangelism/programs';
  static String evangelismProgramById(String id) => '/evangelism/programs/$id';
  static String evangelismProgramDates(String id) =>
      '/evangelism/programs/$id/dates';
  static String evangelismProgramBibleClubs(String id) =>
      '/evangelism/programs/$id/bible-clubs';
  static String evangelismProgramActivate(String id) =>
      '/evangelism/programs/$id/activate';
  static String evangelismProgramClose(String id) =>
      '/evangelism/programs/$id/close';
  static String evangelismProgramRecords(String id) =>
      '/evangelism/programs/$id/records';

  // --------------------------------------------------------------------------
  // DISCIPLESHIP
  // --------------------------------------------------------------------------
  static const String discipleshipLinks = '/discipleship/links';
  static String discipleshipLinkEnd(String id) =>
      '/discipleship/links/$id/end';
  static String discipleshipMakerDisciples(String makerId) =>
      '/discipleship/makers/$makerId/disciples';
  static const String discipleshipRecords = '/discipleship/records';
  static String discipleshipMakerRecords(String makerId) =>
      '/discipleship/makers/$makerId/records';

  // --------------------------------------------------------------------------
  // INTERCESSION
  // --------------------------------------------------------------------------
  static const String intercessionChains = '/intercession/chains';
  static String intercessionChainStart(String id) =>
      '/intercession/chains/$id/start';
  static String intercessionChainClose(String id) =>
      '/intercession/chains/$id/close';
  static String intercessionBibleClubChains(String bibleClubId) =>
      '/intercession/bible-clubs/$bibleClubId/chains';
  static String intercessionChainSlots(String chainId) =>
      '/intercession/chains/$chainId/slots';
  static String intercessionSlotCover(String slotId) =>
      '/intercession/slots/$slotId/cover';
  static String intercessionSlotUncover(String slotId) =>
      '/intercession/slots/$slotId/uncover';

  // --------------------------------------------------------------------------
  // FINANCE
  // --------------------------------------------------------------------------
  static const String financeContributions = '/finance/contributions';
  static String financeContributionById(String id) =>
      '/finance/contributions/$id';
  static String financeContributionClose(String id) =>
      '/finance/contributions/$id/close';
  static String financeContributionPayments(String id) =>
      '/finance/contributions/$id/payments';

  // --------------------------------------------------------------------------
  // PUBLICATIONS
  // --------------------------------------------------------------------------
  static const String dailyVerses = '/publications/daily-verses';
  static String dailyVerseById(String id) => '/publications/daily-verses/$id';
  static String dailyVersePublish(String id) =>
      '/publications/daily-verses/$id/publish';
  static const String announcements = '/publications/announcements';
  static String announcementPublish(String id) =>
      '/publications/announcements/$id/publish';

  // --------------------------------------------------------------------------
  // DASHBOARDS
  // --------------------------------------------------------------------------
  static String dashboardBibleClub(String id) => '/dashboards/bible-clubs/$id';
  static const String dashboardNational = '/dashboards/national';

  // --------------------------------------------------------------------------
  // SYNC
  // --------------------------------------------------------------------------
  static const String syncChanges = '/sync/changes';
}
