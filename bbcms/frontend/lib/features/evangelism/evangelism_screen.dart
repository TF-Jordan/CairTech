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
import '../../core/widgets/section_header.dart';

class EvangelismScreen extends ConsumerStatefulWidget {
  const EvangelismScreen({super.key});

  @override
  ConsumerState<EvangelismScreen> createState() => _EvangelismScreenState();
}

class _EvangelismScreenState extends ConsumerState<EvangelismScreen> {
  List<Map<String, dynamic>>? _programs;
  String? _error;
  bool _loading = true;
  String _encounter = 'PERSON';
  String _response = 'DECISION';
  final TextEditingController _location = TextEditingController();
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    try {
      _programs = await ref.read(apiClientProvider).listEvangelismPrograms();
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _record(Map<String, dynamic> program) async {
    setState(() => _busy = true);
    try {
      await ref.read(apiClientProvider).recordEvangelism(
        program['id'] as String,
        <String, dynamic>{
          'date': DateTime.now().toIso8601String().split('T').first,
          'encounterType': _encounter,
          'response': _response,
          'location': _location.text.trim().isEmpty ? null : _location.text.trim(),
        },
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Enregistrement sauvegardé')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Erreur: $e')));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic>? active = _programs?.cast<Map<String, dynamic>?>()
        .firstWhere(
            (Map<String, dynamic>? p) => (p?['status'] as String?) == 'ACTIVE',
            orElse: () => null);
    return Scaffold(
      backgroundColor: BbcColors.bg,
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: BbcColors.ink))
            : ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  ScreenHeader(
                    eyebrow: 'Mission · Programmes',
                    title: 'Évangélisation',
                    actions: <Widget>[
                      RoundIcon(
                        icon: Icons.arrow_back,
                        onTap: () => Navigator.maybePop(context),
                      ),
                      const RoundIcon(icon: Icons.map_outlined),
                      const RoundIcon(icon: Icons.add),
                    ],
                  ),
                  if (active != null) _ActiveProgramHero(program: active),
                  if (active == null && _programs != null && _programs!.isEmpty)
                    const EmptyState(
                      title: 'Aucun programme actif',
                      message: 'Créez un programme depuis le panneau admin.',
                    ),
                  if (active == null && _error != null)
                    EmptyState(title: 'Indisponible', message: _error),
                  if (active != null) ...<Widget>[
                    const SectionHeader('Nouvel enregistrement',
                        more: 'Anonyme OK'),
                    _RecordForm(
                      encounter: _encounter,
                      onEncounterChanged: (String v) =>
                          setState(() => _encounter = v),
                      response: _response,
                      onResponseChanged: (String v) =>
                          setState(() => _response = v),
                      location: _location,
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.fromLTRB(16, 14, 16, 22),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: PrimaryButton(
                              label: 'Anonyme',
                              style: BbcButtonStyle.ghost,
                              onPressed: _busy ? null : () => _record(active),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 2,
                            child: PrimaryButton(
                              label: 'Enregistrer',
                              busy: _busy,
                              trailing: const Icon(Icons.check),
                              onPressed: _busy ? null : () => _record(active),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
      ),
    );
  }
}

class _ActiveProgramHero extends StatelessWidget {
  const _ActiveProgramHero({required this.program});

  final Map<String, dynamic> program;

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.fromLTRB(22, 20, 22, 20),
        decoration: BoxDecoration(
          color: BbcColors.ink,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Row(children: <Widget>[
              PillTag('En cours',
                  kind: PillKind.accent, leading: Icon(Icons.flag_outlined)),
            ]),
            const SizedBox(height: 14),
            Text((program['title'] as String?) ?? 'Programme',
                style: BbcTypo.serif(
                    size: 24, color: Colors.white, height: 1.15)),
            const SizedBox(height: 4),
            Text((program['type'] as String?) ?? '',
                style: BbcTypo.sans(
                    size: 12.5, color: Colors.white.withOpacity(0.7))),
            const SizedBox(height: 18),
            Container(height: 1, color: Colors.white.withOpacity(0.12)),
            const SizedBox(height: 14),
            Row(
              children: <Widget>[
                _stat('ÉVANGÉLISÉS', '${program['recordCount'] ?? 0}'),
                const Spacer(),
                _stat('DÉCISIONS', '${program['decisionCount'] ?? 0}'),
                const Spacer(),
                _stat('À SUIVRE', '${program['followUpCount'] ?? 0}'),
              ],
            ),
          ],
        ),
      );

  Widget _stat(String l, String v) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(v,
              style: BbcTypo.serif(
                  size: 24, color: Colors.white, height: 1, letterSpacing: -0.6)),
          const SizedBox(height: 4),
          Text(l,
              style: BbcTypo.mono(
                  size: 9, color: Colors.white.withOpacity(0.5))),
        ],
      );
}

class _RecordForm extends StatelessWidget {
  const _RecordForm({
    required this.encounter,
    required this.onEncounterChanged,
    required this.response,
    required this.onResponseChanged,
    required this.location,
  });

  final String encounter;
  final ValueChanged<String> onEncounterChanged;
  final String response;
  final ValueChanged<String> onResponseChanged;
  final TextEditingController location;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: BbcColors.surface,
        border: Border.all(color: BbcColors.hair),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('TYPE DE RENCONTRE',
              style: BbcTypo.mono(size: 10, color: BbcColors.muted)),
          const SizedBox(height: 6),
          Row(
            children: <Widget>[
              for (final ({String c, String l, IconData i}) t
                  in const <({String c, String l, IconData i})>[
                (c: 'PERSON', l: 'Personne', i: Icons.person_outline),
                (c: 'GROUP', l: 'Groupe', i: Icons.group_outlined),
                (c: 'FAMILY', l: 'Famille', i: Icons.favorite_outline),
              ]) ...<Widget>[
                Expanded(
                  child: InkWell(
                    onTap: () => onEncounterChanged(t.c),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: encounter == t.c
                            ? BbcColors.ink
                            : BbcColors.surface2,
                        border: Border.all(
                            color: encounter == t.c
                                ? BbcColors.ink
                                : BbcColors.hair),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: <Widget>[
                          Icon(t.i,
                              size: 14,
                              color: encounter == t.c
                                  ? Colors.white
                                  : BbcColors.ink),
                          const SizedBox(height: 4),
                          Text(t.l,
                              style: BbcTypo.sans(
                                  size: 12,
                                  weight: FontWeight.w500,
                                  color: encounter == t.c
                                      ? Colors.white
                                      : BbcColors.ink)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 14),
          Text('RÉPONSE',
              style: BbcTypo.mono(size: 10, color: BbcColors.muted)),
          const SizedBox(height: 6),
          for (final ({String c, String l, String s}) r
              in const <({String c, String l, String s})>[
            (c: 'DECISION', l: 'A reçu Christ', s: 'Décision claire — accompagnement immédiat'),
            (c: 'INTERESTED', l: 'Intéressé', s: 'Désir de revoir, lecture de tract'),
            (c: 'INDIFFERENT', l: 'Indifférent', s: 'Conversation respectueuse'),
            (c: 'REFUSED', l: 'Refus', s: 'Reste en prière'),
          ])
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: InkWell(
                onTap: () => onResponseChanged(r.c),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: response == r.c
                        ? BbcColors.positive.withOpacity(0.05)
                        : BbcColors.surface2,
                    border: Border.all(
                        color: response == r.c
                            ? BbcColors.positive
                            : BbcColors.hair),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: <Widget>[
                      Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          color: response == r.c
                              ? BbcColors.positive
                              : Colors.transparent,
                          border: Border.all(
                              color: response == r.c
                                  ? BbcColors.positive
                                  : BbcColors.hair,
                              width: 1.5),
                          shape: BoxShape.circle,
                        ),
                        child: response == r.c
                            ? Center(
                                child: Container(
                                  width: 7,
                                  height: 7,
                                  decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle),
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(r.l,
                                style: BbcTypo.sans(
                                    size: 13, weight: FontWeight.w500)),
                            Text(r.s, style: BbcTypo.meta()),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          const SizedBox(height: 4),
          LabeledField(
              label: 'Lieu',
              controller: location,
              icon: Icons.place_outlined),
        ],
      ),
    );
  }
}
