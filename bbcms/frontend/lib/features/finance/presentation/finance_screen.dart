import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/primary_button.dart';
import '../data/finance_repository.dart';
import '../domain/finance_models.dart';

class FinanceScreen extends ConsumerStatefulWidget {
  const FinanceScreen({super.key});

  @override
  ConsumerState<FinanceScreen> createState() => _FinanceScreenState();
}

class _FinanceScreenState extends ConsumerState<FinanceScreen> {
  final _bibleClubId = TextEditingController();
  String? _loaded;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Finance')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Cotisations par Bible Club',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                TextField(
                  controller: _bibleClubId,
                  decoration:
                      const InputDecoration(labelText: 'Bible Club ID'),
                ),
                const SizedBox(height: 12),
                PrimaryButton(
                  label: 'Charger',
                  icon: Icons.search,
                  onPressed: () => setState(
                      () => _loaded = _bibleClubId.text.trim()),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (_loaded != null && _loaded!.isNotEmpty)
            _List(bibleClubId: _loaded!),
        ],
      ),
    );
  }
}

class _List extends ConsumerWidget {
  const _List({required this.bibleClubId});
  final String bibleClubId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncContribs = ref.watch(contributionsProvider(bibleClubId));
    return asyncContribs.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Text('$e'),
      data: (list) => Column(
        children: list
            .map((c) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _ContribCard(contrib: c),
                ))
            .toList(),
      ),
    );
  }
}

class _ContribCard extends StatelessWidget {
  const _ContribCard({required this.contrib});
  final FinancialContribution contrib;

  @override
  Widget build(BuildContext context) {
    final pct = contrib.objectiveAmount == 0
        ? 0.0
        : (contrib.totalContributed / contrib.objectiveAmount)
            .clamp(0.0, 1.0);
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(contrib.title,
                    style: Theme.of(context).textTheme.titleLarge),
              ),
              Chip(label: Text(contrib.status)),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: pct,
            backgroundColor: AppColors.surfaceAlt,
            minHeight: 12,
            borderRadius: BorderRadius.circular(8),
          ),
          const SizedBox(height: 8),
          Text(
            '${contrib.totalContributed.toStringAsFixed(0)} / '
            '${contrib.objectiveAmount.toStringAsFixed(0)} ${contrib.currency} '
            '(${(pct * 100).toStringAsFixed(0)}%)',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Ajouter un paiement'),
                onPressed: () => _addPayment(context, contrib),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _addPayment(
    BuildContext context,
    FinancialContribution c,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _PaymentSheet(contribution: c),
    );
  }
}

class _PaymentSheet extends ConsumerStatefulWidget {
  const _PaymentSheet({required this.contribution});
  final FinancialContribution contribution;

  @override
  ConsumerState<_PaymentSheet> createState() => _PaymentSheetState();
}

class _PaymentSheetState extends ConsumerState<_PaymentSheet> {
  final _name = TextEditingController();
  final _amount = TextEditingController();
  final _ref = TextEditingController();
  PaymentChannel _channel = PaymentChannel.cash;
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Nouveau paiement',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 12),
          TextField(
            controller: _name,
            decoration: const InputDecoration(labelText: 'Nom du donateur'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _amount,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Montant *'),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<PaymentChannel>(
            value: _channel,
            decoration: const InputDecoration(labelText: 'Canal'),
            items: PaymentChannel.values
                .map((e) =>
                    DropdownMenuItem(value: e, child: Text(e.label)))
                .toList(),
            onChanged: (v) => setState(() => _channel = v!),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _ref,
            decoration: const InputDecoration(labelText: 'Référence'),
          ),
          const SizedBox(height: 16),
          PrimaryButton(
            label: 'Enregistrer',
            icon: Icons.check,
            loading: _saving,
            onPressed: () async {
              setState(() => _saving = true);
              try {
                await ref.read(financeRepositoryProvider).addPayment(
                      widget.contribution.id,
                      contributorName:
                          _name.text.trim().isEmpty ? null : _name.text,
                      amount: double.tryParse(_amount.text) ?? 0,
                      channel: _channel,
                      reference:
                          _ref.text.trim().isEmpty ? null : _ref.text,
                    );
                ref.invalidate(contributionsProvider);
                if (context.mounted) Navigator.pop(context);
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text('$e')));
                }
              } finally {
                if (mounted) setState(() => _saving = false);
              }
            },
          ),
        ],
      ),
    );
  }
}
