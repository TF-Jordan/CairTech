import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_endpoints.dart';
import '../../../core/network/dio_client.dart';
import '../domain/finance_models.dart';

class FinanceRepository {
  FinanceRepository(this._dio);
  final Dio _dio;

  Future<List<FinancialContribution>> listByBibleClub(
    String bibleClubId,
  ) async {
    final res = await _dio.get<List<dynamic>>(
      ApiEndpoints.financeContributions,
      queryParameters: {'bibleClubId': bibleClubId},
    );
    return res.data!
        .map((e) =>
            FinancialContribution.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<FinancialContribution> getById(String id) async {
    final res = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.financeContributionById(id),
    );
    return FinancialContribution.fromJson(res.data!);
  }

  Future<FinancialContribution> open({
    required String bibleClubId,
    required String title,
    required double objective,
    String? description,
    DateTime? dateOpen,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.financeContributions,
      data: {
        'bibleClubId': bibleClubId,
        'title': title,
        'objective': objective,
        if (description != null) 'description': description,
        if (dateOpen != null)
          'dateOpen': dateOpen.toIso8601String().substring(0, 10),
      },
    );
    return FinancialContribution.fromJson(res.data!);
  }

  Future<FinancialContribution> close(String id, DateTime when) async {
    final res = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.financeContributionClose(id),
      data: {'when': when.toIso8601String().substring(0, 10)},
    );
    return FinancialContribution.fromJson(res.data!);
  }

  Future<List<ContributionLine>> payments(String contributionId) async {
    final res = await _dio.get<List<dynamic>>(
      ApiEndpoints.financeContributionPayments(contributionId),
    );
    return res.data!
        .map((e) => ContributionLine.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<ContributionLine> addPayment(
    String contributionId, {
    String? memberId,
    String? contributorName,
    required double amount,
    required PaymentChannel channel,
    String? reference,
    DateTime? paymentDate,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.financeContributionPayments(contributionId),
      data: {
        if (memberId != null) 'memberId': memberId,
        if (contributorName != null) 'contributorName': contributorName,
        'amount': amount,
        'channel': channel.apiValue,
        if (reference != null) 'reference': reference,
        if (paymentDate != null)
          'paymentDate': paymentDate.toIso8601String().substring(0, 10),
      },
    );
    return ContributionLine.fromJson(res.data!);
  }
}

final financeRepositoryProvider = Provider<FinanceRepository>((ref) {
  return FinanceRepository(ref.watch(dioProvider));
});

final contributionsProvider = FutureProvider.autoDispose
    .family<List<FinancialContribution>, String>((ref, bibleClubId) {
  return ref.watch(financeRepositoryProvider).listByBibleClub(bibleClubId);
});

final contributionPaymentsProvider = FutureProvider.autoDispose
    .family<List<ContributionLine>, String>((ref, contribId) {
  return ref.watch(financeRepositoryProvider).payments(contribId);
});
