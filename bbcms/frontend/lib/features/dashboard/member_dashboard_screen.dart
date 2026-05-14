import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/network/api_client.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../core/utils/jwt_session.dart';
import '../../core/widgets/avatar.dart';
import '../../core/widgets/donut.dart';
import '../../core/widgets/pill_tag.dart';
import '../../core/widgets/round_icon.dart';
import '../../core/widgets/section_header.dart';
import '../../core/widgets/sparkline.dart';
import '../auth/auth_controller.dart';

class MemberDashboardScreen extends ConsumerWidget {
  const MemberDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final JwtSession? session = ref.watch(sessionProvider);
    return Scaffold(
      backgroundColor: BbcColors.bg,
      body: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          _TopBar(session: session),
          const SizedBox(height: 4),
          _FidelityHero(session: session),
          _VerseOfDay(),
          const SectionHeader('Prochaine réunion', more: 'Voir tout'),
          _NextMeetingCard(),
          const SectionHeader('Actions rapides'),
          _QuickActions(session: session),
          const SectionHeader('Présence — 12 dernières semaines', more: 'Détail'),
          _TrendCard(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.session});

  final JwtSession? session;

  @override
  Widget build(BuildContext context) {
    final String name = session?.email.split('@').first ?? 'Membre';
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
      child: Row(
        children: <Widget>[
          Avatar(name: name, size: AvatarSize.md),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(_today(), style: BbcTypo.eyebrow()),
              Text('Bonjour, $name',
                  style: BbcTypo.sans(size: 15, weight: FontWeight.w500)),
            ],
          ),
          const Spacer(),
          const RoundIcon(icon: Icons.search),
          const SizedBox(width: 6),
          const RoundIcon(icon: Icons.notifications_outlined),
        ],
      ),
    );
  }

  String _today() {
    return DateFormat('EEEE d MMMM · HH:mm', 'fr').format(DateTime.now()).toUpperCase();
  }
}

class _FidelityHero extends ConsumerWidget {
  const _FidelityHero({required this.session});

  final JwtSession? session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.fromLTRB(22, 24, 22, 20),
      decoration: BoxDecoration(
        color: BbcColors.ink,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('SCORE DE FIDÉLITÉ · ANNÉE 2025/26',
                        style: BbcTypo.mono(
                            size: 10, color: Colors.white.withOpacity(0.55))),
                    const SizedBox(height: 6),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Text('87',
                            style: BbcTypo.serif(
                                size: 72,
                                color: Colors.white,
                                letterSpacing: -2.2,
                                height: 0.9)),
                        const SizedBox(width: 8),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text('/100',
                              style: BbcTypo.mono(
                                  size: 13,
                                  color: Colors.white.withOpacity(0.55))),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Row(children: <Widget>[
                      PillTag('+4 ce mois',
                          kind: PillKind.accent,
                          leading: Icon(Icons.trending_up)),
                    ]),
                  ],
                ),
              ),
              Donut(
                value: 0.87,
                size: 82,
                stroke: 4,
                color: Colors.white,
                track: Colors.white.withOpacity(0.14),
                child: Text('87%',
                    style: BbcTypo.mono(
                        size: 11, color: Colors.white.withOpacity(0.7))),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            height: 1,
            color: Colors.white.withOpacity(0.1),
            margin: const EdgeInsets.only(bottom: 18),
          ),
          Row(
            children: <Widget>[
              Expanded(child: _statTile('PRÉSENCES', '24', '/26')),
              Expanded(child: _statTile('RÉTRACTATIONS', '02', 'sur 4 max')),
              Expanded(child: _statTile('SERVICE', '18h', 'ce trim.')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statTile(String label, String value, String sub) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(label,
              style:
                  BbcTypo.mono(size: 9, color: Colors.white.withOpacity(0.5))),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Text(value,
                  style: BbcTypo.serif(
                      size: 24,
                      color: Colors.white,
                      height: 1,
                      letterSpacing: -0.7)),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Text(sub,
                    style: BbcTypo.sans(
                        size: 10, color: Colors.white.withOpacity(0.5))),
              ),
            ],
          ),
        ],
      );
}

class _VerseOfDay extends ConsumerStatefulWidget {
  @override
  ConsumerState<_VerseOfDay> createState() => _VerseOfDayState();
}

class _VerseOfDayState extends ConsumerState<_VerseOfDay> {
  Map<String, dynamic>? _verse;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final List<Map<String, dynamic>> list =
          await ref.read(apiClientProvider).listDailyVerses();
      if (list.isNotEmpty && mounted) {
        setState(() => _verse = list.first);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final String verse = (_verse?['verseText'] as String?) ??
        '« L\'Éternel est mon berger : je ne manquerai de rien. »';
    final String ref = (_verse?['reference'] as String?) ?? 'Ps. 23.1';
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: BbcColors.surface2,
        border: Border.all(color: BbcColors.hair),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Text('VERSET DU JOUR', style: BbcTypo.eyebrow()),
              const Spacer(),
              Text(ref, style: BbcTypo.mono(size: 10, color: BbcColors.muted)),
            ],
          ),
          const SizedBox(height: 12),
          Text(verse, style: BbcTypo.serif(size: 19, height: 1.35)),
        ],
      ),
    );
  }
}

class _NextMeetingCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: BbcColors.surface,
          border: Border.all(color: BbcColors.hair),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: 52,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: BbcColors.surface2,
                border: Border.all(color: BbcColors.hair),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: <Widget>[
                  Text('SAM',
                      style: BbcTypo.mono(size: 9, color: BbcColors.muted)),
                  const SizedBox(height: 2),
                  Text('10', style: BbcTypo.serif(size: 24, height: 1)),
                  const SizedBox(height: 2),
                  Text('MAI',
                      style: BbcTypo.mono(size: 8, color: BbcColors.muted2)),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('Étude biblique — Romains 8',
                      style: BbcTypo.sans(
                          size: 14, weight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  Row(
                    children: <Widget>[
                      const Icon(Icons.access_time, size: 11, color: BbcColors.muted),
                      const SizedBox(width: 4),
                      Text('16h00 · Salle B',
                          style: BbcTypo.meta(color: BbcColors.muted)),
                    ],
                  ),
                ],
              ),
            ),
            const RoundIcon(icon: Icons.chevron_right, size: 28),
          ],
        ),
      );
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({required this.session});

  final JwtSession? session;

  @override
  Widget build(BuildContext context) {
    final List<({IconData icon, String label, String sub, String route})> actions =
        <({IconData icon, String label, String sub, String route})>[
      (
        icon: Icons.check_outlined,
        label: 'Pointer',
        sub: 'PRÉSENCE',
        route: '/meetings'
      ),
      (
        icon: Icons.payments_outlined,
        label: 'Donner',
        sub: 'CONTRIBUER',
        route: '/finance'
      ),
      (
        icon: Icons.favorite_outline,
        label: 'Prier',
        sub: 'CHAÎNE',
        route: '/prayer-chain'
      ),
      (
        icon: Icons.send_outlined,
        label: 'Évang.',
        sub: 'RAPPORT',
        route: '/evangelism'
      ),
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: <Widget>[
          for (int i = 0; i < actions.length; i++) ...<Widget>[
            if (i > 0) const SizedBox(width: 8),
            Expanded(
              child: InkWell(
                onTap: () => context.push(actions[i].route),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
                  decoration: BoxDecoration(
                    color: BbcColors.surface,
                    border: Border.all(color: BbcColors.hair),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: <Widget>[
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: BbcColors.ink,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(actions[i].icon, size: 16, color: Colors.white),
                      ),
                      const SizedBox(height: 6),
                      Text(actions[i].label,
                          style: BbcTypo.sans(
                              size: 11, weight: FontWeight.w500)),
                      const SizedBox(height: 2),
                      Text(actions[i].sub,
                          style: BbcTypo.mono(
                              size: 8.5, color: BbcColors.muted2)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TrendCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        decoration: BoxDecoration(
          color: BbcColors.surface,
          border: Border.all(color: BbcColors.hair),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('MOY. 12 SEM.',
                          style: BbcTypo.mono(
                              size: 9, color: BbcColors.muted2)),
                      const SizedBox(height: 2),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          Text('87%', style: BbcTypo.serif(size: 28, height: 1)),
                          const SizedBox(width: 6),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 2),
                            child: Text('+12 pts',
                                style: BbcTypo.sans(
                                    size: 11, color: BbcColors.positive)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const PillTag('Hebdo'),
              ],
            ),
            const SizedBox(height: 10),
            const SizedBox(
              height: 64,
              child: Sparkline(
                data: <double>[62, 64, 70, 68, 73, 78, 82, 80, 84, 87, 91, 88],
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text('S07', style: BbcTypo.mono(size: 9, color: BbcColors.muted2)),
                Text('S18', style: BbcTypo.mono(size: 9, color: BbcColors.muted2)),
              ],
            ),
          ],
        ),
      );
}
