import 'package:jwt_decoder/jwt_decoder.dart';

/// Decoded JWT payload from the BBCMS backend. Mirrors `JjwtIssuer.JwtClaims`.
class JwtSession {
  JwtSession({
    required this.userId,
    required this.email,
    required this.userType,
    required this.roles,
    required this.permissions,
    required this.bibleClubId,
    required this.expiresAt,
  });

  factory JwtSession.parse(String accessToken) {
    final Map<String, dynamic> claims = JwtDecoder.decode(accessToken);
    final List<dynamic> rawRoles = (claims['roles'] as List<dynamic>?) ?? <dynamic>[];
    final List<dynamic> rawPerms = (claims['permissions'] as List<dynamic>?) ?? <dynamic>[];
    final DateTime exp = DateTime.fromMillisecondsSinceEpoch(
        ((claims['exp'] as num).toInt()) * 1000,
        isUtc: true);
    return JwtSession(
      userId: claims['sub'] as String,
      email: (claims['email'] as String?) ?? '',
      userType: (claims['userType'] as String?) ?? 'VISITOR',
      roles: rawRoles.map((dynamic r) => r as String).toSet(),
      permissions: rawPerms.map((dynamic p) => p as String).toSet(),
      bibleClubId: claims['bibleClubId'] as String?,
      expiresAt: exp,
    );
  }

  final String userId;
  final String email;
  final String userType;
  final Set<String> roles;
  final Set<String> permissions;
  final String? bibleClubId;
  final DateTime expiresAt;

  bool hasPermission(String code) => permissions.contains(code);
  bool hasAnyPermission(Iterable<String> codes) => codes.any(permissions.contains);
  bool hasRole(String role) => roles.contains(role);

  /// SUPER_ADMIN bootstrap role from `17-seed-roles.xml`: has every permission.
  /// Treated as "god-mode" in the UI.
  bool get isSuperAdmin => hasRole('SYSTEM_ADMIN');
  bool get isNationalLeader => hasRole('NATIONAL_LEADER');
  bool get isBbcLeader => hasRole('BBC_LEADER');
  bool get isMentor => hasRole('MENTOR');
  bool get isStudent => hasRole('STUDENT') || userType == 'STUDENT';
  bool get isVisitor => hasRole('VISITOR') || userType == 'VISITOR';

  bool get canSeeNationalDashboard =>
      isSuperAdmin || hasPermission('bbcms:dashboard:national');
  bool get canSeeBbcDashboard =>
      isSuperAdmin || hasPermission('bbcms:dashboard:bbc');
  bool get canManageMembershipRequests =>
      isSuperAdmin || hasAnyPermission(<String>[
        'bbcms:membership-request:approve',
        'bbcms:membership-request:reject',
        'bbcms:membership-request:read',
      ]);
  bool get canManageBibleClubs => isSuperAdmin || hasPermission('bbcms:bible-club:create');
  bool get canPlanMeetings => isSuperAdmin || hasPermission('bbcms:meeting:plan');
  bool get canPublishVerse => isSuperAdmin || hasPermission('bbcms:publication:daily-verse');
  bool get canPublishAnnouncement =>
      isSuperAdmin || hasPermission('bbcms:publication:announcement');
  bool get canManageIntercession =>
      isSuperAdmin || hasPermission('bbcms:intercession:chain-manage');
  bool get canManageEvangelism =>
      isSuperAdmin || hasPermission('bbcms:evangelism:program-create');
  bool get canManageDiscipleship =>
      isSuperAdmin || hasPermission('bbcms:discipleship:assign');
  bool get canManageFinance =>
      isSuperAdmin || hasPermission('bbcms:financial:contribution-create');
  bool get canResetBbc => isSuperAdmin || hasPermission('bbcms:bible-club:reset');
  bool get canRecomputeAttendance =>
      isSuperAdmin || hasPermission('bbcms:faithfulness:compute');
}
