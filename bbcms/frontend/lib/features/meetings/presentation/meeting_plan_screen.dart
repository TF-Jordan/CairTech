import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/primary_button.dart';
import '../data/meeting_repository.dart';
import '../domain/meeting_models.dart';

class MeetingPlanScreen extends ConsumerStatefulWidget {
  const MeetingPlanScreen({super.key});

  @override
  ConsumerState<MeetingPlanScreen> createState() => _MeetingPlanScreenState();
}

class _MeetingPlanScreenState extends ConsumerState<MeetingPlanScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _bibleClubId = TextEditingController();
  final _levelId = TextEditingController();
  MeetingType _type = MeetingType.bibleStudy;
  DateTime _date = DateTime.now();
  TimeOfDay _start = TimeOfDay.now();
  TimeOfDay? _end;
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Planifier une réunion')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: _title,
              decoration: const InputDecoration(labelText: 'Titre *'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Requis' : null,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<MeetingType>(
              value: _type,
              decoration: const InputDecoration(labelText: 'Type'),
              items: MeetingType.values
                  .map((e) =>
                      DropdownMenuItem(value: e, child: Text(e.label)))
                  .toList(),
              onChanged: (v) => setState(() => _type = v!),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: () async {
                final d = await showDatePicker(
                  context: context,
                  firstDate: DateTime.now().subtract(const Duration(days: 30)),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                  initialDate: _date,
                );
                if (d != null) setState(() => _date = d);
              },
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Date',
                  suffixIcon: Icon(Icons.calendar_today_outlined),
                ),
                child: Text(_date.toIso8601String().substring(0, 10)),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _timeField('Début', _start, (t) => _start = t)),
                const SizedBox(width: 12),
                Expanded(
                  child: _timeField(
                    'Fin',
                    _end ?? TimeOfDay.now(),
                    (t) => _end = t,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _bibleClubId,
              decoration:
                  const InputDecoration(labelText: 'Bible Club (UUID)'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _levelId,
              decoration: const InputDecoration(labelText: 'Level (UUID)'),
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              label: 'Planifier',
              icon: Icons.event_available,
              loading: _loading,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }

  Widget _timeField(String label, TimeOfDay value, void Function(TimeOfDay) on) {
    return InkWell(
      onTap: () async {
        final t = await showTimePicker(context: context, initialTime: value);
        if (t != null) setState(() => on(t));
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: const Icon(Icons.schedule),
        ),
        child: Text(_fmt(value)),
      ),
    );
  }

  String _fmt(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final m = await ref.read(meetingRepositoryProvider).plan(
            PlanMeetingRequest(
              title: _title.text.trim(),
              type: _type,
              plannedDate: _date,
              plannedStartTime: _fmt(_start),
              plannedEndTime: _end == null ? null : _fmt(_end!),
              bibleClubId: _bibleClubId.text.trim().isEmpty
                  ? null
                  : _bibleClubId.text.trim(),
              levelId: _levelId.text.trim().isEmpty
                  ? null
                  : _levelId.text.trim(),
            ),
          );
      if (mounted) context.go('/meetings/${m.id}');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('$e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}
