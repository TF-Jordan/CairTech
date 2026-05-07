import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/primary_button.dart';
import '../data/event_repository.dart';
import '../domain/event_models.dart';

class EventPlanScreen extends ConsumerStatefulWidget {
  const EventPlanScreen({super.key});

  @override
  ConsumerState<EventPlanScreen> createState() => _EventPlanScreenState();
}

class _EventPlanScreenState extends ConsumerState<EventPlanScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _location = TextEditingController();
  EventType _type = EventType.conference;
  DateTime _start = DateTime.now().add(const Duration(days: 7));
  DateTime? _end;
  bool _loading = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final e = await ref.read(eventRepositoryProvider).plan(
            PlanEventRequest(
              title: _title.text.trim(),
              type: _type,
              plannedStart: _start,
              plannedEnd: _end,
              location:
                  _location.text.trim().isEmpty ? null : _location.text.trim(),
            ),
          );
      ref.invalidate(eventsProvider);
      if (mounted) context.go('/events/${e.id}');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('$e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Planifier un événement')),
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
            DropdownButtonFormField<EventType>(
              value: _type,
              decoration: const InputDecoration(labelText: 'Type'),
              items: EventType.values
                  .map((e) =>
                      DropdownMenuItem(value: e, child: Text(e.label)))
                  .toList(),
              onChanged: (v) => setState(() => _type = v!),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _location,
              decoration: const InputDecoration(labelText: 'Lieu'),
            ),
            const SizedBox(height: 12),
            _DateTimeField(
              label: 'Début prévu *',
              value: _start,
              onChanged: (d) => setState(() => _start = d),
            ),
            const SizedBox(height: 12),
            _DateTimeField(
              label: 'Fin prévue',
              value: _end,
              onChanged: (d) => setState(() => _end = d),
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              label: 'Créer l\'événement',
              icon: Icons.event_available,
              loading: _loading,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}

class _DateTimeField extends StatelessWidget {
  const _DateTimeField({
    required this.label,
    required this.value,
    required this.onChanged,
  });
  final String label;
  final DateTime? value;
  final ValueChanged<DateTime> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final d = await showDatePicker(
          context: context,
          firstDate: DateTime.now().subtract(const Duration(days: 30)),
          lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
          initialDate: value ?? DateTime.now(),
        );
        if (d == null) return;
        if (!context.mounted) return;
        final t = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.fromDateTime(value ?? DateTime.now()),
        );
        if (t == null) return;
        onChanged(DateTime(d.year, d.month, d.day, t.hour, t.minute));
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: const Icon(Icons.calendar_month),
        ),
        child: Text(
          value == null ? '—' : value!.toLocal().toString().substring(0, 16),
        ),
      ),
    );
  }
}
