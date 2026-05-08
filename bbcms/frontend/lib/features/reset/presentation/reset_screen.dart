import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/primary_button.dart';
import '../data/reset_repository.dart';

class ResetScreen extends ConsumerStatefulWidget {
  const ResetScreen({required this.bibleClubId, super.key});
  final String bibleClubId;

  @override
  ConsumerState<ResetScreen> createState() => _ResetScreenState();
}

class _ResetScreenState extends ConsumerState<ResetScreen> {
  int _step = 0;
  int _academicYear = DateTime.now().year;
  ResetSnapshot? _snapshot;
  bool _loading = false;
  String? _error;

  Future<void> _confirm() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final snap = await ref
          .read(resetRepositoryProvider)
          .reset(widget.bibleClubId, _academicYear);
      setState(() {
        _snapshot = snap;
        _step = 2;
      });
    } catch (e) {
      setState(() => _error = '$e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reset annuel')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          GlassCard(
            gradient: AppColors.primaryGradient,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Workflow annuel',
                    style: TextStyle(color: Colors.white70, fontSize: 12)),
                SizedBox(height: 4),
                Text(
                  'Snapshot · Archive PDF · Transferts L1→L7',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (_step == 0)
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Année académique',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => setState(() => _academicYear -= 1),
                        icon: const Icon(Icons.remove),
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            '$_academicYear',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => setState(() => _academicYear += 1),
                        icon: const Icon(Icons.add),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  PrimaryButton(
                    label: 'Continuer',
                    icon: Icons.arrow_forward,
                    onPressed: () => setState(() => _step = 1),
                  ),
                ],
              ),
            ),
          if (_step == 1)
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.warning_amber_rounded,
                      color: AppColors.warning, size: 40),
                  const SizedBox(height: 12),
                  Text('Confirmation',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(
                    'Cette action transfère tous les niveaux (L1→L2, …, L7→sortis), '
                    'génère une archive PDF et réinitialise les scores. Irréversible.',
                  ),
                  const SizedBox(height: 16),
                  if (_error != null) ...[
                    Text(_error!,
                        style: const TextStyle(color: AppColors.danger)),
                    const SizedBox(height: 8),
                  ],
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _loading
                              ? null
                              : () => setState(() => _step = 0),
                          child: const Text('Retour'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: PrimaryButton(
                          label: 'Lancer le reset',
                          icon: Icons.bolt,
                          loading: _loading,
                          onPressed: _confirm,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          if (_step == 2 && _snapshot != null)
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.check_circle_rounded,
                      color: AppColors.success, size: 48),
                  const SizedBox(height: 12),
                  Text('Reset terminé',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 12),
                  _row('Année', '${_snapshot!.academicYear}'),
                  _row('Membres avant', '${_snapshot!.nbMembersBefore}'),
                  _row('Fidèles', '${_snapshot!.nbFaithfulBefore}'),
                  _row('Réunions', '${_snapshot!.nbMeetings}'),
                  _row(
                    'Objectif atteint',
                    '${(_snapshot!.percentageReached * 100).toStringAsFixed(0)}%',
                  ),
                  if (_snapshot!.archiveFileId != null)
                    _row('Archive', _snapshot!.archiveFileId!),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textMuted)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
