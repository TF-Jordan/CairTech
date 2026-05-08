import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/glass_card.dart';
import '../data/membership_repository.dart';
import '../domain/membership_models.dart';

class MembershipRequestsScreen extends ConsumerStatefulWidget {
  const MembershipRequestsScreen({super.key});

  @override
  ConsumerState<MembershipRequestsScreen> createState() =>
      _MembershipRequestsScreenState();
}

class _MembershipRequestsScreenState
    extends ConsumerState<MembershipRequestsScreen> {
  MembershipRequestStatus? _status = MembershipRequestStatus.pending;

  @override
  Widget build(BuildContext context) {
    final asyncReqs = ref.watch(membershipRequestsProvider(_status));
    return Scaffold(
      appBar: AppBar(title: const Text('Demandes d\'adhésion')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final s in [
                    null,
                    ...MembershipRequestStatus.values,
                  ])
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        selected: _status == s,
                        label: Text(s == null ? 'Tous' : s.label),
                        onSelected: (_) => setState(() => _status = s),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Expanded(
            child: asyncReqs.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('$e')),
              data: (reqs) => RefreshIndicator(
                onRefresh: () async =>
                    ref.invalidate(membershipRequestsProvider(_status)),
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: reqs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) => _RequestCard(req: reqs[i]),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RequestCard extends ConsumerWidget {
  const _RequestCard({required this.req});
  final MembershipRequest req;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPending = req.status == MembershipRequestStatus.pending;
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                backgroundColor: AppColors.primaryContainer,
                child: Icon(Icons.person, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(req.userAccountId.substring(0, 8),
                        style: Theme.of(context).textTheme.titleLarge),
                    Text(
                      '${req.requestedType} • ${req.profession ?? '-'}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              Chip(label: Text(req.status.label)),
            ],
          ),
          if (isPending) ...[
            const Divider(),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.close),
                    label: const Text('Rejeter'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.danger,
                      side: const BorderSide(color: AppColors.danger),
                    ),
                    onPressed: () async {
                      await ref
                          .read(membershipRepositoryProvider)
                          .reject(req.id);
                      ref.invalidate(membershipRequestsProvider);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.check),
                    label: const Text('Approuver'),
                    onPressed: () => _approve(context, ref),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _approve(BuildContext context, WidgetRef ref) async {
    final bibleClubCtl = TextEditingController(text: req.bibleClubId ?? '');
    final levelCtl = TextEditingController(text: req.levelId ?? '');
    final commentCtl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Approuver l\'adhésion'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: bibleClubCtl,
              decoration:
                  const InputDecoration(labelText: 'Bible Club (UUID)'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: levelCtl,
              decoration: const InputDecoration(labelText: 'Level (UUID)'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: commentCtl,
              decoration: const InputDecoration(labelText: 'Commentaire'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Approuver'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ref.read(membershipRepositoryProvider).approve(
            req.id,
            assignedBibleClubId: bibleClubCtl.text.trim(),
            assignedLevelId: levelCtl.text.trim(),
            comment: commentCtl.text.trim().isEmpty
                ? null
                : commentCtl.text.trim(),
          );
      ref.invalidate(membershipRequestsProvider);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }
}
