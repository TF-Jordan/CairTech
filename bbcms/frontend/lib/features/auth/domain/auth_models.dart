/// Plain DTOs for the auth feature (kept simple, no codegen needed).

class AuthTokens {
  const AuthTokens({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresInSeconds,
    this.tokenType = 'Bearer',
  });

  factory AuthTokens.fromJson(Map<String, dynamic> json) => AuthTokens(
        accessToken: json['accessToken'] as String,
        refreshToken: json['refreshToken'] as String,
        expiresInSeconds: (json['accessTokenExpiresInSeconds'] as num).toInt(),
        tokenType: json['tokenType'] as String? ?? 'Bearer',
      );

  final String accessToken;
  final String refreshToken;
  final int expiresInSeconds;
  final String tokenType;
}

enum UserType { visitor, student, professional, nationalLeader }

extension UserTypeX on UserType {
  String get apiValue => switch (this) {
        UserType.visitor => 'VISITOR',
        UserType.student => 'STUDENT',
        UserType.professional => 'PROFESSIONAL',
        UserType.nationalLeader => 'NATIONAL_LEADER',
      };

  String get label => switch (this) {
        UserType.visitor => 'Visiteur',
        UserType.student => 'Étudiant',
        UserType.professional => 'Professionnel',
        UserType.nationalLeader => 'Leader national',
      };

  static UserType fromApi(String v) => UserType.values.firstWhere(
        (e) => e.apiValue == v,
        orElse: () => UserType.visitor,
      );
}

enum Gender { male, female }

extension GenderX on Gender {
  String get apiValue => this == Gender.male ? 'MALE' : 'FEMALE';
  String get label => this == Gender.male ? 'Homme' : 'Femme';
}

class RegisterRequest {
  const RegisterRequest({
    required this.email,
    required this.password,
    required this.firstNames,
    required this.requestedType,
    this.nextNames,
    this.phone,
    this.dateOfBirth,
    this.gender,
    this.locale = 'fr',
    this.bibleClubId,
    this.levelId,
    this.profession,
    this.dateBornAgain,
    this.howBornAgain,
    this.dateEntered,
  });

  final String email;
  final String password;
  final String firstNames;
  final String? nextNames;
  final String? phone;
  final DateTime? dateOfBirth;
  final Gender? gender;
  final String locale;
  final UserType requestedType;
  final String? bibleClubId;
  final String? levelId;
  final String? profession;
  final DateTime? dateBornAgain;
  final String? howBornAgain;
  final DateTime? dateEntered;

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
        'firstNames': firstNames,
        if (nextNames != null) 'nextNames': nextNames,
        if (phone != null) 'phone': phone,
        if (dateOfBirth != null)
          'dateOfBirth': dateOfBirth!.toIso8601String().substring(0, 10),
        if (gender != null) 'gender': gender!.apiValue,
        'locale': locale,
        'requestedType': requestedType.apiValue,
        if (bibleClubId != null) 'bibleClubId': bibleClubId,
        if (levelId != null) 'levelId': levelId,
        if (profession != null) 'profession': profession,
        if (dateBornAgain != null)
          'dateBornAgain': dateBornAgain!.toIso8601String().substring(0, 10),
        if (howBornAgain != null) 'howBornAgain': howBornAgain,
        if (dateEntered != null)
          'dateEntered': dateEntered!.toIso8601String().substring(0, 10),
      };
}

class UserAccount {
  const UserAccount({
    required this.id,
    required this.email,
    required this.status,
    required this.userType,
    this.firstNames,
    this.nextNames,
  });

  factory UserAccount.fromJson(Map<String, dynamic> json) => UserAccount(
        id: json['id'] as String,
        email: json['email'] as String,
        status: json['status'] as String,
        userType: UserTypeX.fromApi(json['userType'] as String),
        firstNames: json['firstNames'] as String?,
        nextNames: json['nextNames'] as String?,
      );

  final String id;
  final String email;
  final String status;
  final UserType userType;
  final String? firstNames;
  final String? nextNames;

  bool get isPending => status == 'PENDING';
  bool get isActive => status == 'ACTIVE';
}
