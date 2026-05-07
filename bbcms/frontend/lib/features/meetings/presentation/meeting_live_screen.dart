import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/primary_button.dart';
import '../data/meeting_repository.dart';
import '../domain/meeting_models.dart';

/// Live workflow screen: PLANNED → STARTED → ENDED → COMPLETED.
class MeetingLiveScreen extends ConsumerWidget {
  const MeetingLiveScreen({required this.id, super.key});
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncMeeting = ref.watch(meetingProvider(id));
    return Scaffold(
      appBar: AppBar(title: const Text('Réunion')),
      body: asyncMeeting.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (m) => ListView(
          padding: const EdgeInsets.all(20),
          children: [
            GlassCard(
              gradient: AppColors.primaryGradient,
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    m.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${m.type.label} • ${m.status.label}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _StatusActions(meeting: m),
            const SizedBox(height: 16),
            if (m.status == MeetingStatus.ended ||
                m.status == MeetingStatus.completed)
              _RecordCard(meeting: m),
          ],
        ),
      ),
    );
  }
}

class _StatusActions extends ConsumerWidget {
  const _StatusActions({required this.meeting});
  final Meeting meeting;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.read(meetingRepositoryProvider);
    return GlassCard(
      child: Column(
        children: [
          if (meeting.status == MeetingStatus.planned)
            PrimaryButton(
              label: 'Démarrer la réunion',
              icon: Icons.play_arrow_rounded,
              onPressed: () async {
                final now = DateTime.now();
                await repo.start(
                  meeting.id,
                  dateOccurred: now,
                  startTime:
                      '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
                );
                ref.invalidate(meetingProvider(meeting.id));
              },
            ),
          if (meeting.status == MeetingStatus.started)
            PrimaryButton(
              label: 'Terminer la réunion',
              icon: Icons.stop_rounded,
              onPressed: () async {
                final now = DateTime.now();
                await repo.end(
                  meeting.id,
                  endTime:
                      '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
                );
                ref.invalidate(meetingProvider(meeting.id));
              },
            ),
          if (meeting.status == MeetingStatus.planned ||
              meeting.status == MeetingStatus.started) ...[
            const SizedBox(height: 8),
            OutlinedButton.icon(
              icon: const Icon(Icons.cancel_outlined),
              label: const Text('Annuler la réunion'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.danger,
                side: const BorderSide(color: AppColors.danger),
              ),
              onPressed: () async {
                await repo.cancel(meeting.id);
                ref.invalidate(meetingProvider(meeting.id));
              },
            ),
          ],
        ],
      ),
    );
  }
}

class _RecordCard extends ConsumerStatefulWidget {
  const _RecordCard({required this.meeting});
  final Meeting meeting;

  @override
  ConsumerState<_RecordCard> createState() => _RecordCardState();
}

class _RecordCardState extends ConsumerState<_RecordCard> {
  final _nbBelievers = TextEditingController(text: '0');
  final _summary = TextEditingController();
  final _memberIdsCtl = TextEditingController();
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Enregistrer le compte rendu',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _nbBelievers,
            decoration:
                const InputDecoration(labelText: 'Nombre de croyants'),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _summary,
            maxLines: 4,
            decoration: const InputDecoration(labelText: 'Résumé'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _memberIdsCtl,
            decoration: const InputDecoration(
              labelText: 'IDs de membres présents (séparés par virgule)',
              helperText:
                  'Saisie rapide V1. Sélecteur multi-membres en V2.',
            ),
          ),
          const SizedBox(height: 16),
          PrimaryButton(
            label: 'Soumettre le compte rendu',
            icon: Icons.save,
            loading: _saving,
            onPressed: () async {
              setState(() => _saving = true);
              try {
                final ids = _memberIdsCtl.text
                    .split(',')
                    .map((s) => s.trim())
                    .where((s) => s.isNotEmpty)
                    .toList();
                final presents = ids
                    .map((id) =>
                        (memberId: id, role: PresenceRole.participant))
                    .toList();
                await ref.read(meetingRepositoryProvider).record(
                      widget.meeting.id,
                      RecordMeetingRequest(
                        nbBelievers: int.tryParse(_nbBelievers.text) ?? 0,
                        summary: _summary.text.trim().isEmpty
                            ? null
                            : _summary.text,
                        presents: presents,
                      ),
                    );
                ref.invalidate(meetingProvider(widget.meeting.id));
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Compte rendu envoyé.')),
                  );
                }
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
