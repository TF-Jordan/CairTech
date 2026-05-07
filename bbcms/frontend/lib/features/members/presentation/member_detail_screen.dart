import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/rbac/permissions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/perm_gate.dart';
import '../data/member_repository.dart';
import '../domain/member_models.dart';

class MemberDetailScreen extends ConsumerWidget {
  const MemberDetailScreen({required this.id, super.key});
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncMember = ref.watch(memberProvider(id));
    return Scaffold(
      appBar: AppBar(title: const Text('Membre')),
      body: asyncMember.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (m) => ListView(
          padding: const EdgeInsets.all(20),
          children: [
            GlassCard(
              gradient: AppColors.primaryGradient,
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 36,
                    backgroundColor: Colors.white24,
                    child: Icon(Icons.person, size: 36, color: Colors.white),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    m.userAccountId,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    m.kind.label,
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (m.kind == MemberKind.student)
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Fidélité',
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: (m.faithfulPercentage ?? 0).clamp(0.0, 1.0),
                      minHeight: 12,
                      backgroundColor: AppColors.surfaceAlt,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${((m.faithfulPercentage ?? 0) * 100).toStringAsFixed(0)}% '
                      '(score ${m.participationScore ?? 0})',
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
                      Text('Départements',
                          style: Theme.of(context).textTheme.titleLarge),
                      PermGate(
                        perm: Perm.memberUpdate,
                        child: TextButton.icon(
                          icon: const Icon(Icons.edit),
                          label: const Text('Gérer'),
                          onPressed: () =>
                              _editDepartments(context, ref, m),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (m.departments.isEmpty)
                    const Text('Aucun département')
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: m.departments
                          .map((d) => Chip(label: Text(d.label)))
                          .toList(),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _editDepartments(
    BuildContext context,
    WidgetRef ref,
    Member member,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _DeptSheet(member: member),
    );
    ref.invalidate(memberProvider(member.id));
  }
}

class _DeptSheet extends ConsumerStatefulWidget {
  const _DeptSheet({required this.member});
  final Member member;

  @override
  ConsumerState<_DeptSheet> createState() => _DeptSheetState();
}

class _DeptSheetState extends ConsumerState<_DeptSheet> {
  late Set<Department> _selected = {...widget.member.departments};
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
          Text('Départements',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: Department.values
                .map(
                  (d) => FilterChip(
                    label: Text(d.label),
                    selected: _selected.contains(d),
                    onSelected: (v) => setState(() {
                      v ? _selected.add(d) : _selected.remove(d);
                    }),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _saving
                ? null
                : () async {
                    setState(() => _saving = true);
                    try {
                      final repo = ref.read(memberRepositoryProvider);
                      final toAdd = _selected.difference(widget.member.departments);
                      final toRemove = widget.member.departments.difference(_selected);
                      for (final d in toAdd) {
                        await repo.addDepartment(widget.member.id, d);
                      }
                      for (final d in toRemove) {
                        await repo.removeDepartment(widget.member.id, d);
                      }
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
            child: Text(_saving ? '…' : 'Enregistrer'),
          ),
        ],
      ),
    );
  }
}
