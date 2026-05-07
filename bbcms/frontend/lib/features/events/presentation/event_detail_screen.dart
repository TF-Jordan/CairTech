import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/rbac/permissions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/perm_gate.dart';
import '../../../core/widgets/primary_button.dart';
import '../data/event_repository.dart';
import '../domain/event_models.dart';

class EventDetailScreen extends ConsumerWidget {
  const EventDetailScreen({required this.id, super.key});
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncEvent = ref.watch(eventProvider(id));
    return Scaffold(
      appBar: AppBar(title: const Text('Événement')),
      body: asyncEvent.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (e) => ListView(
          padding: const EdgeInsets.all(20),
          children: [
            GlassCard(
              gradient: AppColors.primaryGradient,
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    e.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text('${e.type.label} • ${e.status.label}',
                      style: const TextStyle(color: Colors.white70)),
                  if (e.location != null) ...[
                    const SizedBox(height: 4),
                    Text('📍 ${e.location}',
                        style: const TextStyle(color: Colors.white)),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            PermGate(
              perm: Perm.eventEnroll,
              child: GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Inscription',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    PrimaryButton(
                      label: 'M\'inscrire à cet événement',
                      icon: Icons.how_to_reg,
                      onPressed: () => _enroll(context, ref),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            _EventActions(event: e),
          ],
        ),
      ),
    );
  }

  Future<void> _enroll(BuildContext context, WidgetRef ref) async {
    final c = TextEditingController();
    final memberId = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Member ID'),
        content: TextField(
          controller: c,
          decoration: const InputDecoration(labelText: 'UUID du membre'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, c.text.trim()),
            child: const Text('Inscrire'),
          ),
        ],
      ),
    );
    if (memberId != null && memberId.isNotEmpty) {
      try {
        await ref.read(eventRepositoryProvider).enroll(id, memberId);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Inscription enregistrée.')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('$e')));
        }
      }
    }
  }
}

class _EventActions extends ConsumerWidget {
  const _EventActions({required this.event});
  final EventModel event;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.read(eventRepositoryProvider);
    return PermGate(
      perm: Perm.eventPlan,
      child: GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Cycle de vie',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            if (event.status == EventStatus.planned)
              ElevatedButton(
                onPressed: () async {
                  await repo.openRegistration(event.id);
                  ref.invalidate(eventProvider(event.id));
                },
                child: const Text('Ouvrir les inscriptions'),
              ),
            if (event.status == EventStatus.registrationOpen)
              ElevatedButton(
                onPressed: () async {
                  await repo.start(event.id, DateTime.now());
                  ref.invalidate(eventProvider(event.id));
                },
                child: const Text('Démarrer'),
              ),
            if (event.status == EventStatus.started)
              ElevatedButton(
                onPressed: () async {
                  await repo.end(event.id, DateTime.now());
                  ref.invalidate(eventProvider(event.id));
                },
                child: const Text('Terminer'),
              ),
          ],
        ),
      ),
    );
  }
}
