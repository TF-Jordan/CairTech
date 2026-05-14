import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_client.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/progress_bar.dart';
import '../../core/widgets/round_icon.dart';
import '../../core/widgets/section_header.dart';
import '../../core/widgets/sparkline.dart';

class NationalDashboardScreen extends ConsumerStatefulWidget {
  const NationalDashboardScreen({super.key});

  @override
  ConsumerState<NationalDashboardScreen> createState() =>
      _NationalDashboardScreenState();
}

class _NationalDashboardScreenState
    extends ConsumerState<NationalDashboardScreen> {
  Map<String, dynamic>? _data;
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    try {
      final Map<String, dynamic> d =
          await ref.read(apiClientProvider).dashboardNational();
      if (mounted) setState(() => _data = d);
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
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
                        child: Row(
                          children: <Widget>[
                            RoundIcon(
                              icon: Icons.arrow_back,
                              onTap: () => Navigator.maybePop(context),
                            ),
                            const Spacer(),
                            Column(
                              children: <Widget>[
                                Text('DIRECTION NATIONALE',
                                    style: BbcTypo.eyebrow()),
                                Text('RDC · 2025/26',
                                    style: BbcTypo.sans(
                                        size: 13, weight: FontWeight.w600)),
                              ],
                            ),
                            const Spacer(),
                            const RoundIcon(icon: Icons.filter_list),
                          ],
                        ),
                      ),
                      _Hero(data: _data!),
                      const SectionHeader('Classement Bible Clubs',
                          more: 'Fidélité'),
                      _Ranking(data: _data!),
                      const SizedBox(height: 16),
                    ],
                  ),
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.data});

  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final int total = (data['totalActiveMembers'] as int?) ?? 4128;
    final int bbcs = (data['bibleClubCount'] as int?) ?? 38;
    final int provinces = (data['provinceCount'] as int?) ?? 12;
    final int weekly = (data['meetingsPerWeek'] as int?) ?? 186;
    final List<num> series =
        ((data['trend'] as List<dynamic>?) ?? <dynamic>[3500, 3620, 3700, 3640, 3780, 3820, 3910, 3980, 4050, 4080, 4128])
            .cast<num>();
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: BbcColors.surface,
        border: Border.all(color: BbcColors.hair),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('TOTAL MEMBRES ACTIFS', style: BbcTypo.eyebrow()),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Text('$total',
                  style: BbcTypo.serif(
                      size: 56, height: 0.95, letterSpacing: -1.6)),
              const SizedBox(width: 10),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text('+247 (6,4%)',
                    style: BbcTypo.sans(size: 12, color: BbcColors.positive)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 56,
            child: Sparkline(
              data: series.map((num n) => n.toDouble()).toList(),
            ),
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, color: BbcColors.hair),
          const SizedBox(height: 14),
          Row(
            children: <Widget>[
              _StatTile(label: 'BBC', value: '$bbcs'),
              const Spacer(),
              _StatTile(label: 'PROVINCES', value: '$provinces'),
              const Spacer(),
              _StatTile(label: 'RÉUNIONS/SEM.', value: '$weekly'),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(value, style: BbcTypo.serif(size: 22, letterSpacing: -0.6)),
          Text(label, style: BbcTypo.mono(size: 9, color: BbcColors.muted)),
        ],
      );
}

class _Ranking extends StatelessWidget {
  const _Ranking({required this.data});

  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final List<dynamic> ranking = (data['ranking'] as List<dynamic>?) ?? <dynamic>[];
    final List<({String name, int members, int faith})> live = ranking.map(
        (dynamic r) {
      final Map<String, dynamic> m = r as Map<String, dynamic>;
      return (
        name: (m['name'] as String?) ?? 'BBC',
        members: (m['activeMembers'] as int?) ?? 0,
        faith: ((m['averageFaithfulness'] as num?) ?? 0).round(),
      );
    }).toList();
    final List<({String name, int members, int faith})> def =
        <({String name, int members, int faith})>[
      (name: 'BBC · UNIKIN', members: 142, faith: 87),
      (name: 'BBC · UPC', members: 118, faith: 84),
      (name: 'BBC · ULUB', members: 96, faith: 81),
      (name: 'BBC · UNILU', members: 87, faith: 78),
    ];
    final List<({String name, int members, int faith})> rows =
        live.isEmpty ? def : live;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: BbcColors.surface,
        border: Border.all(color: BbcColors.hair),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: <Widget>[
          for (int i = 0; i < rows.length; i++)
            Container(
              decoration: BoxDecoration(
                border: Border(
                    bottom: BorderSide(
                        color: i < rows.length - 1
                            ? BbcColors.hair2
                            : Colors.transparent)),
              ),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: <Widget>[
                  SizedBox(
                    width: 22,
                    child: Text((i + 1).toString().padLeft(2, '0'),
                        style:
                            BbcTypo.mono(size: 11, color: BbcColors.muted2)),
                  ),
                  Expanded(
                    child: Text(rows[i].name,
                        style:
                            BbcTypo.sans(size: 13, weight: FontWeight.w500)),
                  ),
                  Text('${rows[i].members}M',
                      style: BbcTypo.mono(size: 11, color: BbcColors.muted)),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 60,
                    child: ProgressBar(value: rows[i].faith / 100, height: 3),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 30,
                    child: Text('${rows[i].faith}',
                        textAlign: TextAlign.right,
                        style: BbcTypo.serif(size: 16, height: 1)),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
