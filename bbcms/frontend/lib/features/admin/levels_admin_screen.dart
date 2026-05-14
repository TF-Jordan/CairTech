import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_client.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/labeled_field.dart';
import '../../core/widgets/pill_tag.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/round_icon.dart';
import '../../core/widgets/screen_header.dart';

class LevelsAdminScreen extends ConsumerStatefulWidget {
  const LevelsAdminScreen({super.key, required this.bibleClubId});

  final String bibleClubId;

  @override
  ConsumerState<LevelsAdminScreen> createState() => _LevelsAdminScreenState();
}

class _LevelsAdminScreenState extends ConsumerState<LevelsAdminScreen> {
  List<Map<String, dynamic>>? _levels;
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      _levels =
          await ref.read(apiClientProvider).listLevels(widget.bibleClubId);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _create() async {
    final TextEditingController name = TextEditingController();
    String type = 'L1';
    final bool? ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: BbcColors.bg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext c) => StatefulBuilder(
        builder: (BuildContext c, void Function(void Function()) setS) =>
            Padding(
          padding: EdgeInsets.only(
              left: 22,
              right: 22,
              top: 24,
              bottom: MediaQuery.of(c).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Nouveau niveau',
                  style: BbcTypo.serif(size: 22, height: 1.1)),
              const SizedBox(height: 16),
              LabeledField(label: 'Nom', controller: name),
              const SizedBox(height: 12),
              Text('TYPE',
                  style: BbcTypo.mono(size: 10, color: BbcColors.muted)),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                children: <Widget>[
                  for (final String t in const <String>[
                    'L1', 'L2', 'L3', 'L4', 'L5', 'L6', 'L7'
                  ])
                    InkWell(
                      onTap: () => setS(() => type = t),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: type == t ? BbcColors.ink : BbcColors.surface,
                          border: Border.all(
                              color:
                                  type == t ? BbcColors.ink : BbcColors.hair),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(t,
                            style: BbcTypo.sans(
                                size: 12,
                                weight: FontWeight.w500,
                                color:
                                    type == t ? Colors.white : BbcColors.ink)),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              PrimaryButton(
                label: 'Créer',
                trailing: const Icon(Icons.check),
                onPressed: () => Navigator.of(c).pop(true),
              ),
            ],
          ),
        ),
      ),
    );
    if (ok != true) return;
    try {
      await ref.read(apiClientProvider).createLevel(
        widget.bibleClubId,
        <String, dynamic>{'name': name.text.trim(), 'type': type},
      );
      _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Erreur: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BbcColors.bg,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            ScreenHeader(
              eyebrow: 'Admin · Organization',
              title: 'Niveaux',
              actions: <Widget>[
                RoundIcon(
                  icon: Icons.arrow_back,
                  onTap: () => Navigator.maybePop(context),
                ),
                RoundIcon(icon: Icons.refresh, onTap: _load),
                RoundIcon(icon: Icons.add, onTap: _create),
              ],
            ),
            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(color: BbcColors.ink))
                  : _error != null
                      ? EmptyState(title: 'Indisponible', message: _error)
                      : _levels == null || _levels!.isEmpty
                          ? const EmptyState(title: 'Aucun niveau')
                          : ListView.separated(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              itemCount: _levels!.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 6),
                              itemBuilder: (BuildContext c, int i) {
                                final Map<String, dynamic> l = _levels![i];
                                return Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: BbcColors.surface,
                                    border: Border.all(color: BbcColors.hair),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: <Widget>[
                                      PillTag(
                                          (l['type'] as String?) ?? 'L?',
                                          kind: PillKind.ink),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          (l['name'] as String?) ?? 'Niveau',
                                          style: BbcTypo.sans(
                                              size: 14,
                                              weight: FontWeight.w500),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }
}
