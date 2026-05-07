import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/rbac/permissions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/perm_gate.dart';
import '../application/bible_club_providers.dart';
import '../domain/bible_club_models.dart';

class BibleClubListScreen extends ConsumerStatefulWidget {
  const BibleClubListScreen({super.key});

  @override
  ConsumerState<BibleClubListScreen> createState() =>
      _BibleClubListScreenState();
}

class _BibleClubListScreenState extends ConsumerState<BibleClubListScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final clubsAsync = ref.watch(bibleClubsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Bible Club Directory')),
      floatingActionButton: PermGate(
        perm: Perm.bibleClubCreate,
        child: FloatingActionButton(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          onPressed: () => context.push('/clubs/new'),
          child: const Icon(Icons.add),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(bibleClubsProvider),
        child: clubsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => _ErrorView(
            message: e.toString(),
            onRetry: () => ref.invalidate(bibleClubsProvider),
          ),
          data: (clubs) {
            final filtered = _query.isEmpty
                ? clubs
                : clubs
                    .where((c) =>
                        c.name.toLowerCase().contains(_query.toLowerCase()))
                    .toList();
            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _CountBanner(count: clubs.length),
                const SizedBox(height: 16),
                TextField(
                  decoration: const InputDecoration(
                    hintText: 'Rechercher un Bible Club…',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (v) => setState(() => _query = v),
                ),
                const SizedBox(height: 16),
                Text(
                  'PRESENT BIBLE CLUBS',
                  style: Theme.of(context)
                      .textTheme
                      .labelLarge
                      ?.copyWith(color: AppColors.textMuted),
                ),
                const SizedBox(height: 8),
                if (filtered.isEmpty)
                  const _EmptyState()
                else
                  ...filtered.map(
                    (c) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _ClubCard(
                        club: c,
                        onTap: () => context.push('/clubs/${c.id}'),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _CountBanner extends StatelessWidget {
  const _CountBanner({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      gradient: AppColors.primaryGradient,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'TOTAL REGISTERED BIBLE CLUBS',
            style: TextStyle(
              color: Colors.white70,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$count',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 48,
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
              ),
              const SizedBox(width: 12),
              const Padding(
                padding: EdgeInsets.only(bottom: 6),
                child: Text(
                  'Clubs Active',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ClubCard extends StatelessWidget {
  const _ClubCard({required this.club, required this.onTap});
  final BibleClub club;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: const Text(
              'BBC',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  club.name,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 8,
                  children: [
                    if (club.schoolName != null)
                      Text(club.schoolName!,
                          style: Theme.of(context).textTheme.bodyMedium),
                    if (club.goalNbFaithful != null)
                      Text('• Objectif ${club.goalNbFaithful}',
                          style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.textMuted),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          const Icon(Icons.account_tree_outlined,
              size: 64, color: AppColors.textMuted),
          const SizedBox(height: 12),
          Text('Aucun Bible Club',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 4),
          Text('Créez le premier Bible Club pour commencer.',
              style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 48, color: AppColors.danger),
          const SizedBox(height: 12),
          Text(message),
          const SizedBox(height: 12),
          TextButton(onPressed: onRetry, child: const Text('Réessayer')),
        ],
      ),
    );
  }
}
