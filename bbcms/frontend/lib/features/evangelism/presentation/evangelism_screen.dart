import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/rbac/permissions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/perm_gate.dart';
import '../data/evangelism_repository.dart';
import '../domain/evangelism_models.dart';

class EvangelismScreen extends ConsumerWidget {
  const EvangelismScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncProgs = ref.watch(evangelismProgramsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Évangélisation')),
      floatingActionButton: PermGate(
        perm: Perm.evangelismProgramCreate,
        child: FloatingActionButton(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          onPressed: () => _draft(context, ref),
          child: const Icon(Icons.add),
        ),
      ),
      body: asyncProgs.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (progs) => RefreshIndicator(
          onRefresh: () async => ref.invalidate(evangelismProgramsProvider),
          child: ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: progs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) => _ProgramCard(prog: progs[i]),
          ),
        ),
      ),
    );
  }

  Future<void> _draft(BuildContext context, WidgetRef ref) async {
    final title = TextEditingController();
    final goal = TextEditingController(text: '50');
    EvangelismProgramType type = EvangelismProgramType.doorToDoor;
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: const Text('Nouveau programme'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: title,
                decoration: const InputDecoration(labelText: 'Titre'),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<EvangelismProgramType>(
                value: type,
                items: EvangelismProgramType.values
                    .map((e) =>
                        DropdownMenuItem(value: e, child: Text(e.label)))
                    .toList(),
                onChanged: (v) => setS(() => type = v!),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: goal,
                decoration: const InputDecoration(labelText: 'Objectif'),
                keyboardType: TextInputType.number,
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
              child: const Text('Créer'),
            ),
          ],
        ),
      ),
    );
    if (ok != true) return;
    try {
      await ref.read(evangelismRepositoryProvider).draft(
            DraftEvangelismProgramRequest(
              title: title.text.trim(),
              type: type,
              objective: int.tryParse(goal.text) ?? 0,
            ),
          );
      ref.invalidate(evangelismProgramsProvider);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }
}

class _ProgramCard extends ConsumerWidget {
  const _ProgramCard({required this.prog});
  final EvangelismProgram prog;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pct = prog.objectiveBelievers == 0
        ? 0.0
        : prog.totalSaved / prog.objectiveBelievers;
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(prog.title,
                    style: Theme.of(context).textTheme.titleLarge),
              ),
              Chip(label: Text(prog.status.label)),
            ],
          ),
          const SizedBox(height: 8),
          Text('${prog.type.label}',
              style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: pct.clamp(0.0, 1.0),
            backgroundColor: AppColors.surfaceAlt,
            minHeight: 10,
            borderRadius: BorderRadius.circular(6),
          ),
          const SizedBox(height: 6),
          Text('${prog.totalSaved} / ${prog.objectiveBelievers} sauvés'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              if (prog.status == EvangelismProgramStatus.draft)
                ElevatedButton(
                  onPressed: () async {
                    await ref
                        .read(evangelismRepositoryProvider)
                        .activate(prog.id);
                    ref.invalidate(evangelismProgramsProvider);
                  },
                  child: const Text('Activer'),
                ),
              if (prog.status == EvangelismProgramStatus.running)
                OutlinedButton(
                  onPressed: () async {
                    await ref
                        .read(evangelismRepositoryProvider)
                        .close(prog.id);
                    ref.invalidate(evangelismProgramsProvider);
                  },
                  child: const Text('Clore'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
