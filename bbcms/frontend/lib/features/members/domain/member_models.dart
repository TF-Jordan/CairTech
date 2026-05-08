enum MemberKind { student, professional, mentor, nationalLeader }

extension MemberKindX on MemberKind {
  String get apiValue => switch (this) {
        MemberKind.student => 'STUDENT',
        MemberKind.professional => 'PROFESSIONAL',
        MemberKind.mentor => 'MENTOR',
        MemberKind.nationalLeader => 'NATIONAL_LEADER',
      };

  String get label => switch (this) {
        MemberKind.student => 'Étudiant',
        MemberKind.professional => 'Professionnel',
        MemberKind.mentor => 'Mentor',
        MemberKind.nationalLeader => 'Leader national',
      };

  static MemberKind fromApi(String v) => MemberKind.values.firstWhere(
        (e) => e.apiValue == v,
        orElse: () => MemberKind.student,
      );
}

enum MemberStatus { active, inactive, removed, transferred }

extension MemberStatusX on MemberStatus {
  String get apiValue => switch (this) {
        MemberStatus.active => 'ACTIVE',
        MemberStatus.inactive => 'INACTIVE',
        MemberStatus.removed => 'REMOVED',
        MemberStatus.transferred => 'TRANSFERRED',
      };

  static MemberStatus fromApi(String v) => MemberStatus.values.firstWhere(
        (e) => e.apiValue == v,
        orElse: () => MemberStatus.active,
      );
}

enum Department {
  intercessor,
  discipleMaker,
  charis,
  divineShakers,
  actOfChrist,
  academics,
  mightyMenOfValor,
  ladies,
}

extension DepartmentX on Department {
  String get apiValue => switch (this) {
        Department.intercessor => 'INTERCESSOR',
        Department.discipleMaker => 'DISCIPLE_MAKER',
        Department.charis => 'CHARIS',
        Department.divineShakers => 'DIVINE_SHAKERS',
        Department.actOfChrist => 'ACT_OF_CHRIST',
        Department.academics => 'ACADEMICS',
        Department.mightyMenOfValor => 'MIGHTY_MEN_OF_VALOR',
        Department.ladies => 'LADIES',
      };

  String get label => switch (this) {
        Department.intercessor => 'Intercesseur',
        Department.discipleMaker => 'Disciple-maker',
        Department.charis => 'Charis',
        Department.divineShakers => 'Divine Shakers',
        Department.actOfChrist => 'Act of Christ',
        Department.academics => 'Académie',
        Department.mightyMenOfValor => 'Mighty Men',
        Department.ladies => 'Ladies',
      };

  static Department fromApi(String v) => Department.values.firstWhere(
        (e) => e.apiValue == v,
        orElse: () => Department.academics,
      );
}

class Member {
  const Member({
    required this.id,
    required this.userAccountId,
    required this.kind,
    required this.status,
    this.bibleClubId,
    this.levelId,
    this.participationScore,
    this.faithfulPercentage,
    this.profession,
    this.professionalPosition,
    this.departments = const {},
  });

  factory Member.fromJson(Map<String, dynamic> json) => Member(
        id: json['id'] as String,
        userAccountId: json['userAccountId'] as String,
        kind: MemberKindX.fromApi(json['kind'] as String),
        status: MemberStatusX.fromApi(json['status'] as String),
        bibleClubId: json['bibleClubId'] as String?,
        levelId: json['levelId'] as String?,
        participationScore: (json['participationScore'] as num?)?.toInt(),
        faithfulPercentage:
            (json['faithfulPercentage'] as num?)?.toDouble(),
        profession: json['profession'] as String?,
        professionalPosition: json['professionalPosition'] as String?,
        departments: ((json['departments'] as List?) ?? const [])
            .map((e) => DepartmentX.fromApi(e as String))
            .toSet(),
      );

  final String id;
  final String userAccountId;
  final MemberKind kind;
  final MemberStatus status;
  final String? bibleClubId;
  final String? levelId;
  final int? participationScore;
  final double? faithfulPercentage;
  final String? profession;
  final String? professionalPosition;
  final Set<Department> departments;

  bool get isFaithful => (faithfulPercentage ?? 0) >= 0.8;
}
