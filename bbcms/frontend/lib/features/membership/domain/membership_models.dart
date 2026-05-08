enum MembershipRequestStatus { pending, approved, rejected, cancelled }

extension MembershipRequestStatusX on MembershipRequestStatus {
  String get apiValue => switch (this) {
        MembershipRequestStatus.pending => 'PENDING',
        MembershipRequestStatus.approved => 'APPROVED',
        MembershipRequestStatus.rejected => 'REJECTED',
        MembershipRequestStatus.cancelled => 'CANCELLED',
      };

  String get label => switch (this) {
        MembershipRequestStatus.pending => 'En attente',
        MembershipRequestStatus.approved => 'Approuvée',
        MembershipRequestStatus.rejected => 'Rejetée',
        MembershipRequestStatus.cancelled => 'Annulée',
      };

  static MembershipRequestStatus fromApi(String v) =>
      MembershipRequestStatus.values.firstWhere(
        (e) => e.apiValue == v,
        orElse: () => MembershipRequestStatus.pending,
      );
}

class MembershipRequest {
  const MembershipRequest({
    required this.id,
    required this.userAccountId,
    required this.requestedType,
    required this.status,
    this.bibleClubId,
    this.levelId,
    this.profession,
    this.decisionBy,
    this.decisionAt,
    this.decisionComment,
  });

  factory MembershipRequest.fromJson(Map<String, dynamic> json) =>
      MembershipRequest(
        id: json['id'] as String,
        userAccountId: json['userAccountId'] as String,
        requestedType: json['requestedType'] as String,
        status: MembershipRequestStatusX.fromApi(json['status'] as String),
        bibleClubId: json['bibleClubId'] as String?,
        levelId: json['levelId'] as String?,
        profession: json['profession'] as String?,
        decisionBy: json['decisionBy'] as String?,
        decisionAt: json['decisionAt'] != null
            ? DateTime.parse(json['decisionAt'] as String)
            : null,
        decisionComment: json['decisionComment'] as String?,
      );

  final String id;
  final String userAccountId;
  final String requestedType;
  final MembershipRequestStatus status;
  final String? bibleClubId;
  final String? levelId;
  final String? profession;
  final String? decisionBy;
  final DateTime? decisionAt;
  final String? decisionComment;
}
