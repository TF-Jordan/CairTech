import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_client.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../core/utils/jwt_session.dart';
import '../../core/widgets/avatar.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/pill_tag.dart';
import '../../core/widgets/progress_bar.dart';
import '../../core/widgets/round_icon.dart';
import '../../core/widgets/screen_header.dart';
import '../../core/widgets/section_header.dart';
import '../auth/auth_controller.dart';

class LeaderDashboardScreen extends ConsumerStatefulWidget {
  const LeaderDashboardScreen({super.key});

  @override
  ConsumerState<LeaderDashboardScreen> createState() => _LeaderDashboardScreenState();
}

class _LeaderDashboardScreenState extends ConsumerState<LeaderDashboardScreen> {
  Map<String, dynamic>? _data;
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final JwtSession? s = ref.read(sessionProvider);
    final String? bbcId = s?.bibleClubId;
    if (bbcId == null) {
      setState(() {
        _loading = false;
        _error = 'Aucun Bible Club associé à ce compte';
      });
      return;
    }
    try {
      final Map<String, dynamic> data =
          await ref.read(apiClientProvider).dashboardBbc(bbcId);
      if (mounted) setState(() => _data = data);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
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
            ? const Center(child: CircularProgressIndicator(color: BbcColors.ink))
            : _error != null
                ? EmptyState(title: 'Indisponible', message: _error)
                : ListView(
                    padding: EdgeInsets.zero,
                    children: <Widget>[
                      ScreenHeader(
                        eyebrow: 'BBC · 2025/26',
                        title: 'Tableau de bord',
                        subtitle: 'Vue responsable',
                        actions: <Widget>[
                          RoundIcon(
                            icon: Icons.arrow_back,
                            onTap: () => Navigator.maybePop(context),
                          ),
                          const RoundIcon(icon: Icons.filter_list),
                          const RoundIcon(icon: Icons.more_horiz),
                        ],
                      ),
                      _KpiGrid(data: _data!),
                      const SectionHeader('Répartition par niveau'),
                      _LevelsDistribution(data: _data!),
                      const SectionHeader('Veille d\'inactivité', more: 'Suivi'),
                      _InactivityList(data: _data!),
                      const SizedBox(height: 24),
                    ],
                  ),
      ),
    );
  }
}

class _KpiGrid extends StatelessWidget {
  const _KpiGrid({required this.data});

  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final int active = (data['activeMembers'] as int?) ?? 0;
    final num avg = (data['averageFaithfulness'] as num?) ?? 0;
    final int meetings = (data['meetingsHeld'] as int?) ?? 0;
    final int inactive = (data['inactiveMembers'] as int?) ?? 0;
    final List<_Kpi> kpis = <_Kpi>[
      _Kpi('Membres actifs', '$active', '+6 ce mois', BbcColors.positive,
          Icons.group_outlined),
      _Kpi('Fidélité moy.', '${avg.toStringAsFixed(0)}%', 'Cible 80',
          BbcColors.warn, Icons.trending_up),
      _Kpi('Réunions tenues', '$meetings', 'planifiées', BbcColors.muted,
          Icons.event_outlined),
      _Kpi('Inactifs >4 sem.', '$inactive', 'Suivi requis', BbcColors.danger,
          Icons.access_time),
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 1.4,
        children: <Widget>[
          for (final _Kpi k in kpis)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: BbcColors.surface,
                border: Border.all(color: BbcColors.hair),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                          child: Text(k.label.toUpperCase(),
                              style:
                                  BbcTypo.mono(size: 9, color: BbcColors.muted))),
                      Icon(k.icon, size: 14, color: k.color),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(k.value,
                      style: BbcTypo.serif(size: 30, height: 1, letterSpacing: -0.6)),
                  const SizedBox(height: 4),
                  Text(k.sub, style: BbcTypo.sans(size: 10.5, color: k.color)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _Kpi {
  _Kpi(this.label, this.value, this.sub, this.color, this.icon);

  final String label;
  final String value;
  final String sub;
  final Color color;
  final IconData icon;
}

class _LevelsDistribution extends StatelessWidget {
  const _LevelsDistribution({required this.data});

  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final List<dynamic> rows =
        (data['levelDistribution'] as List<dynamic>?) ?? <dynamic>[];
    final List<({String label, int count, double pct, Color color})> defaults =
        <({String label, int count, double pct, Color color})>[
      (label: 'L1 · Initiation', count: 32, pct: 0.85, color: BbcColors.ink),
      (label: 'L2 · Affermissement', count: 41, pct: 0.72, color: BbcColors.accent),
      (label: 'L3 · Engagement', count: 38, pct: 0.81, color: BbcColors.gold),
      (label: 'L4 · Service', count: 18, pct: 0.92, color: BbcColors.positive),
    ];
    final List<({String label, int count, double pct, Color color})> live = rows
        .map((dynamic r) {
          final Map<String, dynamic> m = r as Map<String, dynamic>;
          return (
            label: (m['levelName'] as String?) ?? 'Niveau',
            count: (m['memberCount'] as int?) ?? 0,
            pct: ((m['faithfulnessAvg'] as num?) ?? 0).toDouble() / 100,
            color: BbcColors.ink,
          );
        })
        .toList();
    final List<({String label, int count, double pct, Color color})> data2 =
        live.isEmpty ? defaults : live;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: BbcColors.surface,
        border: Border.all(color: BbcColors.hair),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: <Widget>[
          for (int i = 0; i < data2.length; i++) ...<Widget>[
            if (i > 0) const SizedBox(height: 14),
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(data2[i].label,
                      style:
                          BbcTypo.sans(size: 12.5, weight: FontWeight.w500)),
                ),
                Text('${(data2[i].pct * 100).round()}%',
                    style: BbcTypo.mono(size: 10.5, color: BbcColors.muted)),
                const SizedBox(width: 10),
                SizedBox(
                  width: 28,
                  child: Text('${data2[i].count}',
                      textAlign: TextAlign.right,
                      style: BbcTypo.serif(size: 16, height: 1)),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ProgressBar(value: data2[i].pct, color: data2[i].color),
          ],
        ],
      ),
    );
  }
}

class _InactivityList extends StatelessWidget {
  const _InactivityList({required this.data});

  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final List<dynamic> rows =
        (data['watchlist'] as List<dynamic>?) ?? <dynamic>[];
    if (rows.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Text('Aucun membre signalé inactif.', style: BbcTypo.meta()),
      );
    }
    return Container(
      decoration: const BoxDecoration(
        color: BbcColors.surface,
        border: Border.symmetric(
            horizontal: BorderSide(color: BbcColors.hair)),
      ),
      child: Column(
        children: <Widget>[
          for (final dynamic r in rows)
            Builder(builder: (BuildContext context) {
              final Map<String, dynamic> m = r as Map<String, dynamic>;
              final String name = (m['fullName'] as String?) ?? 'Membre';
              final int weeks = (m['weeksInactive'] as int?) ?? 0;
              final String level = (m['levelName'] as String?) ?? '';
              return Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 14),
                child: Row(
                  children: <Widget>[
                    Avatar(name: name, size: AvatarSize.sm),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(name,
                              style: BbcTypo.sans(
                                  size: 13.5, weight: FontWeight.w500)),
                          Text('Absent depuis $weeks semaines · $level',
                              style: BbcTypo.meta()),
                        ],
                      ),
                    ),
                    const PillTag('À contacter', kind: PillKind.warn),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}
