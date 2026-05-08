import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/glass_card.dart';
import '../data/member_repository.dart';
import '../domain/member_models.dart';

class MembersListScreen extends ConsumerStatefulWidget {
  const MembersListScreen({required this.bibleClubId, super.key});
  final String bibleClubId;

  @override
  ConsumerState<MembersListScreen> createState() => _MembersListScreenState();
}

class _MembersListScreenState extends ConsumerState<MembersListScreen> {
  MemberKind? _filter;

  @override
  Widget build(BuildContext context) {
    final asyncMembers = ref.watch(membersByClubProvider(widget.bibleClubId));
    return Scaffold(
      appBar: AppBar(title: const Text('Membres')),
      body: asyncMembers.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (members) {
          final filtered = _filter == null
              ? members
              : members.where((m) => m.kind == _filter).toList();
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _Chip(
                        selected: _filter == null,
                        label: 'Tous',
                        onTap: () => setState(() => _filter = null),
                      ),
                      for (final k in MemberKind.values)
                        _Chip(
                          selected: _filter == k,
                          label: k.label,
                          onTap: () => setState(() => _filter = k),
                        ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) {
                    final m = filtered[i];
                    return GlassCard(
                      onTap: () => context.push('/members/${m.id}'),
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: AppColors.primaryContainer,
                            child: Icon(
                              m.kind == MemberKind.student
                                  ? Icons.school
                                  : Icons.work,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(m.userAccountId.substring(0, 8),
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge),
                                Text(
                                  '${m.kind.label} • ${m.status.apiValue}',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                          if (m.kind == MemberKind.student)
                            _FaithRing(value: m.faithfulPercentage ?? 0),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.selected,
    required this.label,
    required this.onTap,
  });
  final bool selected;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        selected: selected,
        label: Text(label),
        onSelected: (_) => onTap(),
      ),
    );
  }
}

class _FaithRing extends StatelessWidget {
  const _FaithRing({required this.value});
  final double value;

  @override
  Widget build(BuildContext context) {
    final pct = (value * 100).clamp(0, 100).toInt();
    return SizedBox(
      width: 44,
      height: 44,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: value.clamp(0.0, 1.0),
            strokeWidth: 4,
            backgroundColor: AppColors.surfaceAlt,
            color: pct >= 80 ? AppColors.success : AppColors.primary,
          ),
          Text('$pct%', style: const TextStyle(fontSize: 10)),
        ],
      ),
    );
  }
}
