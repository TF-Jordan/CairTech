enum PaymentChannel { cash, mobileMoney, bankTransfer, check }

extension PaymentChannelX on PaymentChannel {
  String get apiValue => switch (this) {
        PaymentChannel.cash => 'CASH',
        PaymentChannel.mobileMoney => 'MOBILE_MONEY',
        PaymentChannel.bankTransfer => 'BANK_TRANSFER',
        PaymentChannel.check => 'CHECK',
      };

  String get label => switch (this) {
        PaymentChannel.cash => 'Espèces',
        PaymentChannel.mobileMoney => 'Mobile Money',
        PaymentChannel.bankTransfer => 'Virement',
        PaymentChannel.check => 'Chèque',
      };

  static PaymentChannel fromApi(String v) =>
      PaymentChannel.values.firstWhere(
        (e) => e.apiValue == v,
        orElse: () => PaymentChannel.cash,
      );
}

class FinancialContribution {
  const FinancialContribution({
    required this.id,
    required this.bibleClubId,
    required this.title,
    required this.objectiveAmount,
    required this.totalContributed,
    required this.percentageReached,
    required this.status,
    required this.currency,
    this.dateOpen,
    this.dateClose,
  });

  factory FinancialContribution.fromJson(Map<String, dynamic> j) =>
      FinancialContribution(
        id: j['id'] as String,
        bibleClubId: j['bibleClubId'] as String,
        title: j['title'] as String,
        objectiveAmount: (j['objectiveAmount'] as num).toDouble(),
        currency: j['currency'] as String? ?? 'XAF',
        totalContributed:
            (j['totalContributed'] as num?)?.toDouble() ?? 0,
        percentageReached:
            (j['percentageReached'] as num?)?.toDouble() ?? 0,
        status: j['status'] as String,
        dateOpen: j['dateOpen'] != null
            ? DateTime.parse(j['dateOpen'] as String)
            : null,
        dateClose: j['dateClose'] != null
            ? DateTime.parse(j['dateClose'] as String)
            : null,
      );

  final String id;
  final String bibleClubId;
  final String title;
  final double objectiveAmount;
  final String currency;
  final double totalContributed;
  final double percentageReached;
  final String status;
  final DateTime? dateOpen;
  final DateTime? dateClose;
}

class ContributionLine {
  const ContributionLine({
    required this.id,
    required this.contributionId,
    required this.amount,
    required this.paymentChannel,
    this.contributorMemberId,
    this.contributorName,
    this.paymentReference,
    this.paymentDate,
  });

  factory ContributionLine.fromJson(Map<String, dynamic> j) =>
      ContributionLine(
        id: j['id'] as String,
        contributionId: j['contributionId'] as String,
        contributorMemberId: j['contributorMemberId'] as String?,
        contributorName: j['contributorName'] as String?,
        amount: (j['amount'] as num).toDouble(),
        paymentChannel:
            PaymentChannelX.fromApi(j['paymentChannel'] as String),
        paymentReference: j['paymentReference'] as String?,
        paymentDate: j['paymentDate'] != null
            ? DateTime.parse(j['paymentDate'] as String)
            : null,
      );

  final String id;
  final String contributionId;
  final String? contributorMemberId;
  final String? contributorName;
  final double amount;
  final PaymentChannel paymentChannel;
  final String? paymentReference;
  final DateTime? paymentDate;
}
