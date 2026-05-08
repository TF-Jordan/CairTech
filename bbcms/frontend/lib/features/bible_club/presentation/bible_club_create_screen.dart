import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/primary_button.dart';
import '../application/bible_club_providers.dart';
import '../data/bible_club_repository.dart';
import '../domain/bible_club_models.dart';

class BibleClubCreateScreen extends ConsumerStatefulWidget {
  const BibleClubCreateScreen({super.key});

  @override
  ConsumerState<BibleClubCreateScreen> createState() =>
      _BibleClubCreateScreenState();
}

class _BibleClubCreateScreenState extends ConsumerState<BibleClubCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _profile = TextEditingController();
  final _school = TextEditingController();
  final _goal = TextEditingController();
  DateTime? _date;
  bool _loading = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await ref.read(bibleClubRepositoryProvider).create(
            CreateBibleClubRequest(
              name: _name.text.trim(),
              profile: _profile.text.trim().isEmpty ? null : _profile.text,
              schoolName: _school.text.trim().isEmpty ? null : _school.text,
              goalNbFaithful: int.tryParse(_goal.text),
              dateCreated: _date,
            ),
          );
      ref.invalidate(bibleClubsProvider);
      if (mounted) context.pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Bible Club')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'Nom *'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Requis' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _profile,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _school,
              decoration: const InputDecoration(labelText: 'École'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _goal,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Objectif fidèles (nombre)',
              ),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: () async {
                final d = await showDatePicker(
                  context: context,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                  initialDate: DateTime.now(),
                );
                if (d != null) setState(() => _date = d);
              },
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Date de création',
                  suffixIcon: Icon(Icons.calendar_today_outlined),
                ),
                child: Text(_date == null
                    ? 'mm/jj/aaaa'
                    : _date!.toIso8601String().substring(0, 10)),
              ),
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              label: 'Créer le Bible Club',
              icon: Icons.check,
              loading: _loading,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}
