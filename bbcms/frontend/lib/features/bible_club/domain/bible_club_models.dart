enum BibleClubStatus { active, underReset, archived }

extension BibleClubStatusX on BibleClubStatus {
  String get apiValue => switch (this) {
        BibleClubStatus.active => 'ACTIVE',
        BibleClubStatus.underReset => 'UNDER_RESET',
        BibleClubStatus.archived => 'ARCHIVED',
      };

  String get label => switch (this) {
        BibleClubStatus.active => 'Actif',
        BibleClubStatus.underReset => 'En reset',
        BibleClubStatus.archived => 'Archivé',
      };

  static BibleClubStatus fromApi(String v) => BibleClubStatus.values.firstWhere(
        (e) => e.apiValue == v,
        orElse: () => BibleClubStatus.active,
      );
}

enum LevelType { l1, l2, l3, l4, l5, l6, l7 }

extension LevelTypeX on LevelType {
  String get apiValue => 'L${index + 1}';
  static LevelType fromApi(String v) => LevelType.values.firstWhere(
        (e) => e.apiValue == v,
        orElse: () => LevelType.l1,
      );
}

class BibleClub {
  const BibleClub({
    required this.id,
    required this.name,
    required this.status,
    this.profile,
    this.schoolName,
    this.goalNbFaithful,
    this.dateCreated,
    this.presidentMemberId,
    this.vicePresidentMemberId,
    this.secretaryMemberId,
  });

  factory BibleClub.fromJson(Map<String, dynamic> json) => BibleClub(
        id: json['id'] as String,
        name: json['name'] as String,
        profile: json['profile'] as String?,
        schoolName: json['schoolName'] as String?,
        goalNbFaithful: (json['goalNbFaithful'] as num?)?.toInt(),
        dateCreated: json['dateCreated'] != null
            ? DateTime.parse(json['dateCreated'] as String)
            : null,
        status: BibleClubStatusX.fromApi(json['status'] as String),
        presidentMemberId: json['presidentMemberId'] as String?,
        vicePresidentMemberId: json['vicePresidentMemberId'] as String?,
        secretaryMemberId: json['secretaryMemberId'] as String?,
      );

  final String id;
  final String name;
  final String? profile;
  final String? schoolName;
  final int? goalNbFaithful;
  final DateTime? dateCreated;
  final BibleClubStatus status;
  final String? presidentMemberId;
  final String? vicePresidentMemberId;
  final String? secretaryMemberId;
}

class CreateBibleClubRequest {
  const CreateBibleClubRequest({
    required this.name,
    this.profile,
    this.schoolName,
    this.goalNbFaithful,
    this.dateCreated,
  });

  final String name;
  final String? profile;
  final String? schoolName;
  final int? goalNbFaithful;
  final DateTime? dateCreated;

  Map<String, dynamic> toJson() => {
        'name': name,
        if (profile != null) 'profile': profile,
        if (schoolName != null) 'schoolName': schoolName,
        if (goalNbFaithful != null) 'goalNbFaithful': goalNbFaithful,
        if (dateCreated != null)
          'dateCreated': dateCreated!.toIso8601String().substring(0, 10),
      };
}

class Level {
  const Level({
    required this.id,
    required this.bibleClubId,
    required this.name,
    required this.type,
    this.profile,
    this.presidentMemberId,
    this.vicePresidentMemberId,
  });

  factory Level.fromJson(Map<String, dynamic> json) => Level(
        id: json['id'] as String,
        bibleClubId: json['bibleClubId'] as String,
        name: json['name'] as String,
        profile: json['profile'] as String?,
        type: LevelTypeX.fromApi(json['type'] as String),
        presidentMemberId: json['presidentMemberId'] as String?,
        vicePresidentMemberId: json['vicePresidentMemberId'] as String?,
      );

  final String id;
  final String bibleClubId;
  final String name;
  final String? profile;
  final LevelType type;
  final String? presidentMemberId;
  final String? vicePresidentMemberId;
}

class CreateLevelRequest {
  const CreateLevelRequest({
    required this.name,
    required this.type,
    this.profile,
  });

  final String name;
  final LevelType type;
  final String? profile;

  Map<String, dynamic> toJson() => {
        'name': name,
        'type': type.apiValue,
        if (profile != null) 'profile': profile,
      };
}
