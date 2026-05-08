/// Catalogue des permissions BBCMS (format `bbcms:resource:action`).
class Perm {
  const Perm._();

  // Bible Club
  static const bibleClubCreate = 'bbcms:bible-club:create';
  static const bibleClubRead = 'bbcms:bible-club:read';
  static const bibleClubReadPartial = 'bbcms:bible-club:read-partial';
  static const bibleClubSetGoal = 'bbcms:bible-club:set-goal';
  static const bibleClubAssignLeader = 'bbcms:bible-club:assign-leader';
  static const bibleClubDelete = 'bbcms:bible-club:delete';
  static const bibleClubReset = 'bbcms:bible-club:reset';

  // Level
  static const levelCreate = 'bbcms:level:create';
  static const levelRead = 'bbcms:level:read';
  static const levelUpdate = 'bbcms:level:update';
  static const levelDelete = 'bbcms:level:delete';

  // Member
  static const memberRead = 'bbcms:member:read';
  static const memberUpdate = 'bbcms:member:update';
  static const memberTransfer = 'bbcms:member:transfer';
  static const memberLeave = 'bbcms:member:leave';

  // Membership Request
  static const membershipRequestRead = 'bbcms:membership-request:read';
  static const membershipRequestApprove = 'bbcms:membership-request:approve';
  static const membershipRequestReject = 'bbcms:membership-request:reject';

  // Meeting
  static const meetingPlan = 'bbcms:meeting:plan';
  static const meetingStart = 'bbcms:meeting:start';
  static const meetingEnd = 'bbcms:meeting:end';
  static const meetingRecord = 'bbcms:meeting:record';
  static const meetingCancel = 'bbcms:meeting:cancel';
  static const meetingRead = 'bbcms:meeting:read';

  // Event
  static const eventPlan = 'bbcms:event:plan';
  static const eventRead = 'bbcms:event:read';
  static const eventEnroll = 'bbcms:event:enroll';
  static const eventRecordPresence = 'bbcms:event:record-presence';

  // Attendance
  static const faithfulnessRead = 'bbcms:faithfulness:read';
  static const faithfulnessCompute = 'bbcms:faithfulness:compute';

  // Evangelism
  static const evangelismRead = 'bbcms:evangelism:read';
  static const evangelismProgramCreate = 'bbcms:evangelism:program-create';
  static const evangelismRecordCreate = 'bbcms:evangelism:record-create';

  // Discipleship
  static const discipleshipRead = 'bbcms:discipleship:read';
  static const discipleshipAssign = 'bbcms:discipleship:assign';
  static const discipleshipRecordCreate = 'bbcms:discipleship:record-create';

  // Intercession
  static const intercessionRead = 'bbcms:intercession:read';
  static const intercessionChainManage = 'bbcms:intercession:chain-manage';

  // Finance
  static const financialContribCreate = 'bbcms:financial:contribution-create';
  static const financialContribRead = 'bbcms:financial:contribution-read';
  static const financialContribRecord = 'bbcms:financial:contribution-record';

  // Publication
  static const publicationRead = 'bbcms:publication:read';
  static const publicationDailyVerse = 'bbcms:publication:daily-verse';
  static const publicationAnnouncement = 'bbcms:publication:announcement';

  // Dashboards
  static const dashboardBbc = 'bbcms:dashboard:bbc';
  static const dashboardNational = 'bbcms:dashboard:national';
}
