enum MeetingType { bibleStudy, outreach, training, worship }

extension MeetingTypeX on MeetingType {
  String get apiValue => switch (this) {
        MeetingType.bibleStudy => 'BIBLE_STUDY',
        MeetingType.outreach => 'OUTREACH',
        MeetingType.training => 'TRAINING',
        MeetingType.worship => 'WORSHIP',
      };

  String get label => switch (this) {
        MeetingType.bibleStudy => 'Étude biblique',
        MeetingType.outreach => 'Évangélisation',
        MeetingType.training => 'Formation',
        MeetingType.worship => 'Adoration',
      };

  static MeetingType fromApi(String v) => MeetingType.values.firstWhere(
        (e) => e.apiValue == v,
        orElse: () => MeetingType.bibleStudy,
      );
}

enum MeetingStatus { planned, started, ended, completed, cancelled }

extension MeetingStatusX on MeetingStatus {
  String get apiValue => switch (this) {
        MeetingStatus.planned => 'PLANNED',
        MeetingStatus.started => 'STARTED',
        MeetingStatus.ended => 'ENDED',
        MeetingStatus.completed => 'COMPLETED',
        MeetingStatus.cancelled => 'CANCELLED',
      };

  String get label => switch (this) {
        MeetingStatus.planned => 'Planifiée',
        MeetingStatus.started => 'En cours',
        MeetingStatus.ended => 'Terminée',
        MeetingStatus.completed => 'Validée',
        MeetingStatus.cancelled => 'Annulée',
      };

  static MeetingStatus fromApi(String v) => MeetingStatus.values.firstWhere(
        (e) => e.apiValue == v,
        orElse: () => MeetingStatus.planned,
      );
}

enum PresenceRole { presenter, participant, visitor }

extension PresenceRoleX on PresenceRole {
  String get apiValue => switch (this) {
        PresenceRole.presenter => 'PRESENTER',
        PresenceRole.participant => 'PARTICIPANT',
        PresenceRole.visitor => 'VISITOR',
      };
}

class Meeting {
  const Meeting({
    required this.id,
    required this.title,
    required this.type,
    required this.status,
    this.bibleClubId,
    this.levelId,
    this.plannedDate,
    this.plannedStartTime,
    this.dateOccurred,
    this.durationMinutes,
    this.nbBelievers,
    this.maxPictures,
    this.summary,
    this.teacherMemberId,
  });

  factory Meeting.fromJson(Map<String, dynamic> json) => Meeting(
        id: json['id'] as String,
        title: json['title'] as String,
        type: MeetingTypeX.fromApi(json['type'] as String),
        status: MeetingStatusX.fromApi(json['status'] as String),
        bibleClubId: json['bibleClubId'] as String?,
        levelId: json['levelId'] as String?,
        plannedDate: json['plannedDate'] != null
            ? DateTime.parse(json['plannedDate'] as String)
            : null,
        plannedStartTime: json['plannedStartTime'] as String?,
        dateOccurred: json['dateOccurred'] != null
            ? DateTime.parse(json['dateOccurred'] as String)
            : null,
        durationMinutes: (json['durationMinutes'] as num?)?.toInt(),
        nbBelievers: (json['nbBelievers'] as num?)?.toInt(),
        maxPictures: (json['maxPictures'] as num?)?.toInt(),
        summary: json['summary'] as String?,
        teacherMemberId: json['teacherMemberId'] as String?,
      );

  final String id;
  final String title;
  final MeetingType type;
  final MeetingStatus status;
  final String? bibleClubId;
  final String? levelId;
  final DateTime? plannedDate;
  final String? plannedStartTime;
  final DateTime? dateOccurred;
  final int? durationMinutes;
  final int? nbBelievers;
  final int? maxPictures;
  final String? summary;
  final String? teacherMemberId;
}

class PlanMeetingRequest {
  const PlanMeetingRequest({
    required this.title,
    required this.type,
    required this.plannedDate,
    required this.plannedStartTime,
    this.plannedEndTime,
    this.bibleClubId,
    this.levelId,
    this.teacherMemberId,
    this.maxPictures,
  });

  final String title;
  final MeetingType type;
  final DateTime plannedDate;
  final String plannedStartTime; // HH:mm
  final String? plannedEndTime;
  final String? bibleClubId;
  final String? levelId;
  final String? teacherMemberId;
  final int? maxPictures;

  Map<String, dynamic> toJson() => {
        'title': title,
        'type': type.apiValue,
        'plannedDate': plannedDate.toIso8601String().substring(0, 10),
        'plannedStartTime': plannedStartTime,
        if (plannedEndTime != null) 'plannedEndTime': plannedEndTime,
        if (bibleClubId != null) 'bibleClubId': bibleClubId,
        if (levelId != null) 'levelId': levelId,
        if (teacherMemberId != null) 'teacherMemberId': teacherMemberId,
        if (maxPictures != null) 'maxPictures': maxPictures,
      };
}

class RecordMeetingRequest {
  const RecordMeetingRequest({
    required this.nbBelievers,
    this.dateOccurred,
    this.startTime,
    this.endTime,
    this.summary,
    this.presents = const [],
    this.pictures = const [],
  });

  final int nbBelievers;
  final DateTime? dateOccurred;
  final String? startTime;
  final String? endTime;
  final String? summary;
  final List<({String memberId, PresenceRole role})> presents;
  final List<({String fileId, String? caption})> pictures;

  Map<String, dynamic> toJson() => {
        'nbBelievers': nbBelievers,
        if (dateOccurred != null)
          'dateOccurred': dateOccurred!.toIso8601String().substring(0, 10),
        if (startTime != null) 'startTime': startTime,
        if (endTime != null) 'endTime': endTime,
        if (summary != null) 'summary': summary,
        'presents': presents
            .map((p) => {'memberId': p.memberId, 'role': p.role.apiValue})
            .toList(),
        'pictures': pictures
            .map((p) => {
                  'fileId': p.fileId,
                  if (p.caption != null) 'caption': p.caption,
                })
            .toList(),
      };
}
