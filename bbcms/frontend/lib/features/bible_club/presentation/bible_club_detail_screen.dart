import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/rbac/permissions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/perm_gate.dart';
import '../application/bible_club_providers.dart';
import '../domain/bible_club_models.dart';

class BibleClubDetailScreen extends ConsumerWidget {
  const BibleClubDetailScreen({required this.id, super.key});
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clubAsync = ref.watch(bibleClubProvider(id));
    final levelsAsync = ref.watch(levelsProvider(id));

    return Scaffold(
      appBar: AppBar(
        title: clubAsync.maybeWhen(
          data: (c) => Text(c.name),
          orElse: () => const Text('Bible Club'),
        ),
      ),
      body: clubAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (club) => ListView(
          padding: const EdgeInsets.all(20),
          children: [
            GlassCard(
              gradient: AppColors.primaryGradient,
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    club.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (club.schoolName != null) ...[
                    const SizedBox(height: 4),
                    Text(club.schoolName!,
                        style: const TextStyle(color: Colors.white70)),
                  ],
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: [
                      _StatChip(
                          label: 'Objectif',
                          value: '${club.goalNbFaithful ?? '—'}'),
                      _StatChip(label: 'Statut', value: club.status.label),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Triumvirat',
                          style: Theme.of(context).textTheme.titleLarge),
                      PermGate(
                        perm: Perm.bibleClubAssignLeader,
                        child: TextButton.icon(
                          icon: const Icon(Icons.edit_outlined),
                          label: const Text('Modifier'),
                          onPressed: () {},
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _LeaderRow(
                      label: 'Président', memberId: club.presidentMemberId),
                  _LeaderRow(
                      label: 'Vice-Président',
                      memberId: club.vicePresidentMemberId),
                  _LeaderRow(
                      label: 'Secrétaire', memberId: club.secretaryMemberId),
                ],
              ),
            ),
            const SizedBox(height: 16),
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Niveaux / Classes',
                          style: Theme.of(context).textTheme.titleLarge),
                      PermGate(
                        perm: Perm.levelCreate,
                        child: TextButton.icon(
                          icon: const Icon(Icons.add),
                          label: const Text('Ajouter'),
                          onPressed: () => _addLevel(context, ref),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  levelsAsync.when(
                    loading: () => const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    error: (e, _) => Text('Erreur: $e'),
                    data: (levels) => levels.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: Text('Aucun niveau'),
                          )
                        : Column(
                            children: levels
                                .map((l) => ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      leading: CircleAvatar(
                                        backgroundColor:
                                            AppColors.primaryContainer,
                                        child: Text(
                                          l.type.apiValue,
                                          style: const TextStyle(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                      title: Text(l.name),
                                      subtitle: Text(l.profile ?? ''),
                                    ))
                                .toList(),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addLevel(BuildContext context, WidgetRef ref) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _AddLevelSheet(bibleClubId: id),
    );
    ref.invalidate(levelsProvider(id));
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$label: $value',
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
    );
  }
}

class _LeaderRow extends StatelessWidget {
  const _LeaderRow({required this.label, required this.memberId});
  final String label;
  final String? memberId;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const CircleAvatar(
        backgroundColor: AppColors.surfaceAlt,
        child: Icon(Icons.person, color: AppColors.primary),
      ),
      title: Text(label),
      subtitle: Text(memberId ?? 'Non assigné',
          style: TextStyle(
              color: memberId == null
                  ? AppColors.textMuted
                  : AppColors.textSecondary)),
    );
  }
}

class _AddLevelSheet extends ConsumerStatefulWidget {
  const _AddLevelSheet({required this.bibleClubId});
  final String bibleClubId;

  @override
  ConsumerState<_AddLevelSheet> createState() => _AddLevelSheetState();
}

class _AddLevelSheetState extends ConsumerState<_AddLevelSheet> {
  final _name = TextEditingController();
  LevelType _type = LevelType.l1;
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Ajouter un niveau',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          TextField(
            controller: _name,
            decoration: const InputDecoration(labelText: 'Nom *'),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<LevelType>(
            value: _type,
            decoration: const InputDecoration(labelText: 'Type'),
            items: LevelType.values
                .map((e) => DropdownMenuItem(
                      value: e,
                      child: Text(e.apiValue),
                    ))
                .toList(),
            onChanged: (v) => setState(() => _type = v!),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _loading
                ? null
                : () async {
                    if (_name.text.trim().isEmpty) return;
                    setState(() => _loading = true);
                    try {
                      await ref
                          .read(bibleClubRepositoryProvider)
                          .createLevel(
                            widget.bibleClubId,
                            CreateLevelRequest(
                              name: _name.text.trim(),
                              type: _type,
                            ),
                          );
                      if (context.mounted) Navigator.of(context).pop();
                    } catch (e) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(e.toString())),
                      );
                    } finally {
                      if (mounted) setState(() => _loading = false);
                    }
                  },
            child: Text(_loading ? '…' : 'Créer le niveau'),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
