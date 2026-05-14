import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_client.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../core/utils/jwt_session.dart';
import '../../core/widgets/avatar.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/round_icon.dart';
import '../../core/widgets/screen_header.dart';
import '../../core/widgets/section_header.dart';
import '../auth/auth_controller.dart';

class DiscipleshipScreen extends ConsumerStatefulWidget {
  const DiscipleshipScreen({super.key});

  @override
  ConsumerState<DiscipleshipScreen> createState() => _DiscipleshipScreenState();
}

class _DiscipleshipScreenState extends ConsumerState<DiscipleshipScreen> {
  List<Map<String, dynamic>>? _disciples;
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final JwtSession? s = ref.read(sessionProvider);
    if (s == null) return;
    try {
      _disciples =
          await ref.read(apiClientProvider).listDisciplesOf(s.userId);
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BbcColors.bg,
      body: SafeArea(
        child: _loading
            ? const Center(
                child: CircularProgressIndicator(color: BbcColors.ink))
            : ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  ScreenHeader(
                    eyebrow: 'Mentor',
                    title: 'Discipulat',
                    actions: <Widget>[
                      RoundIcon(
                        icon: Icons.arrow_back,
                        onTap: () => Navigator.maybePop(context),
                      ),
                      const RoundIcon(icon: Icons.event_outlined),
                      const RoundIcon(icon: Icons.more_horiz),
                    ],
                  ),
                  if (_error != null)
                    EmptyState(title: 'Indisponible', message: _error)
                  else
                    _MentorRelation(disciples: _disciples ?? <Map<String, dynamic>>[]),
                  const SectionHeader('Parcours · L1 → L2', more: 'Module 8'),
                  _Curriculum(),
                  const SizedBox(height: 24),
                ],
              ),
      ),
    );
  }
}

class _MentorRelation extends StatelessWidget {
  const _MentorRelation({required this.disciples});

  final List<Map<String, dynamic>> disciples;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: BbcColors.surface,
        border: Border.all(color: BbcColors.hair),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Column(
                children: <Widget>[
                  const Avatar(name: 'Vous', color: BbcColors.gold),
                  const SizedBox(height: 6),
                  Text('MENTOR',
                      style:
                          BbcTypo.mono(size: 9, color: BbcColors.muted)),
                ],
              ),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  height: 1,
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(color: BbcColors.hair, width: 1),
                    ),
                  ),
                ),
              ),
              Column(
                children: <Widget>[
                  Avatar(
                      name: disciples.isEmpty
                          ? 'Disciple'
                          : (disciples.first['discipleName'] as String? ??
                              '—')),
                  const SizedBox(height: 6),
                  Text('DISCIPLE',
                      style:
                          BbcTypo.mono(size: 9, color: BbcColors.muted)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(height: 1, color: BbcColors.hair),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              Expanded(child: _stat('SESSIONS', '${disciples.length * 7}')),
              Expanded(child: _stat('MODULES', '7/12')),
              Expanded(child: _stat('RÉGULARITÉ', '92%')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stat(String l, String v) => Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(v, style: BbcTypo.serif(size: 18, height: 1)),
          const SizedBox(height: 3),
          Text(l, style: BbcTypo.mono(size: 9, color: BbcColors.muted)),
        ],
      );
}

class _Curriculum extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final List<({String n, String t, String s, String d})> modules =
        <({String n, String t, String s, String d})>[
      (n: 'M01', t: 'Assurance du salut', s: 'done', d: 'Janv.'),
      (n: 'M02', t: 'Lecture quotidienne de la Bible', s: 'done', d: 'Janv.'),
      (n: 'M03', t: 'La prière', s: 'done', d: 'Févr.'),
      (n: 'M04', t: 'Vie d\'adoration', s: 'done', d: 'Févr.'),
      (n: 'M05', t: 'L\'Esprit Saint', s: 'done', d: 'Mars'),
      (n: 'M06', t: 'Le combat spirituel', s: 'done', d: 'Mars'),
      (n: 'M07', t: 'Communion fraternelle', s: 'done', d: 'Avr.'),
      (n: 'M08', t: 'Témoigner du Christ', s: 'active', d: 'En cours'),
      (n: 'M09', t: 'Disciples & multiplication', s: 'todo', d: '—'),
      (n: 'M10', t: 'Servir l\'Église', s: 'todo', d: '—'),
    ];
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: BbcColors.surface,
        border: Border.all(color: BbcColors.hair),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: <Widget>[
          for (int i = 0; i < modules.length; i++)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: i < modules.length - 1
                        ? BbcColors.hair2
                        : Colors.transparent,
                  ),
                ),
              ),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: modules[i].s == 'done'
                          ? BbcColors.ink
                          : modules[i].s == 'active'
                              ? BbcColors.accent
                              : Colors.transparent,
                      border: Border.all(
                        color: modules[i].s == 'done'
                            ? BbcColors.ink
                            : modules[i].s == 'active'
                                ? BbcColors.accent
                                : BbcColors.hair,
                        width: 1.5,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: modules[i].s == 'done'
                        ? const Icon(Icons.check, size: 12, color: Colors.white)
                        : modules[i].s == 'active'
                            ? Center(
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle),
                                ),
                              )
                            : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Row(
                      children: <Widget>[
                        Text(modules[i].n,
                            style: BbcTypo.mono(
                                size: 9.5, color: BbcColors.muted2)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(modules[i].t,
                              style: BbcTypo.sans(
                                size: 13,
                                weight: modules[i].s == 'active'
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                                color: modules[i].s == 'todo'
                                    ? BbcColors.muted
                                    : BbcColors.ink,
                              )),
                        ),
                      ],
                    ),
                  ),
                  Text(modules[i].d.toUpperCase(),
                      style: BbcTypo.mono(
                          size: 10, color: BbcColors.muted2)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
