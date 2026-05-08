enum EvangelismProgramType { doorToDoor, meeting, campaign, events }

extension EvangelismProgramTypeX on EvangelismProgramType {
  String get apiValue => switch (this) {
        EvangelismProgramType.doorToDoor => 'DOOR_TO_DOOR',
        EvangelismProgramType.meeting => 'MEETING',
        EvangelismProgramType.campaign => 'CAMPAIGN',
        EvangelismProgramType.events => 'EVENTS',
      };

  String get label => switch (this) {
        EvangelismProgramType.doorToDoor => 'Porte-à-porte',
        EvangelismProgramType.meeting => 'Rencontre',
        EvangelismProgramType.campaign => 'Campagne',
        EvangelismProgramType.events => 'Événements',
      };

  static EvangelismProgramType fromApi(String v) =>
      EvangelismProgramType.values.firstWhere(
        (e) => e.apiValue == v,
        orElse: () => EvangelismProgramType.meeting,
      );
}

enum EvangelismProgramStatus { draft, running, closed }

extension EvangelismProgramStatusX on EvangelismProgramStatus {
  String get apiValue => switch (this) {
        EvangelismProgramStatus.draft => 'DRAFT',
        EvangelismProgramStatus.running => 'RUNNING',
        EvangelismProgramStatus.closed => 'CLOSED',
      };

  String get label => switch (this) {
        EvangelismProgramStatus.draft => 'Brouillon',
        EvangelismProgramStatus.running => 'En cours',
        EvangelismProgramStatus.closed => 'Clos',
      };

  static EvangelismProgramStatus fromApi(String v) =>
      EvangelismProgramStatus.values.firstWhere(
        (e) => e.apiValue == v,
        orElse: () => EvangelismProgramStatus.draft,
      );
}

class EvangelismProgram {
  const EvangelismProgram({
    required this.id,
    required this.title,
    required this.type,
    required this.status,
    required this.objectiveBelievers,
    required this.totalSaved,
    this.percentageReached = 0,
    this.dates = const [],
    this.bibleClubIds = const [],
  });

  factory EvangelismProgram.fromJson(Map<String, dynamic> json) =>
      EvangelismProgram(
        id: json['id'] as String,
        title: json['title'] as String,
        type: EvangelismProgramTypeX.fromApi(json['type'] as String),
        status:
            EvangelismProgramStatusX.fromApi(json['status'] as String),
        objectiveBelievers: (json['objectiveBelievers'] as num).toInt(),
        totalSaved: (json['totalSaved'] as num?)?.toInt() ?? 0,
        percentageReached:
            (json['percentageReached'] as num?)?.toDouble() ?? 0,
        dates: ((json['dates'] as List?) ?? const [])
            .map((e) => DateTime.parse(e as String))
            .toList(),
        bibleClubIds: ((json['bibleClubIds'] as List?) ?? const [])
            .map((e) => e as String)
            .toList(),
      );

  final String id;
  final String title;
  final EvangelismProgramType type;
  final EvangelismProgramStatus status;
  final int objectiveBelievers;
  final int totalSaved;
  final double percentageReached;
  final List<DateTime> dates;
  final List<String> bibleClubIds;
}

class DraftEvangelismProgramRequest {
  const DraftEvangelismProgramRequest({
    required this.title,
    required this.type,
    required this.objective,
  });

  final String title;
  final EvangelismProgramType type;
  final int objective;

  Map<String, dynamic> toJson() => {
        'title': title,
        'type': type.apiValue,
        'objective': objective,
      };
}

class CreateEvangelismRecordRequest {
  const CreateEvangelismRecordRequest({
    required this.date,
    this.preached = 0,
    this.believed = 0,
    this.encouraged = 0,
    this.tracts = 0,
    this.savedContacts,
    this.notes,
    this.participantMemberIds = const [],
  });

  final DateTime date;
  final int preached;
  final int believed;
  final int encouraged;
  final int tracts;
  final String? savedContacts;
  final String? notes;
  final List<String> participantMemberIds;

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String().substring(0, 10),
        'preached': preached,
        'believed': believed,
        'encouraged': encouraged,
        'tracts': tracts,
        if (savedContacts != null) 'savedContacts': savedContacts,
        if (notes != null) 'notes': notes,
        'participantMemberIds': participantMemberIds,
      };
}
