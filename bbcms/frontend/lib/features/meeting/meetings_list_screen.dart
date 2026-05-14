import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../core/utils/jwt_session.dart';
import '../../core/widgets/chip_selector.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/round_icon.dart';
import '../../core/widgets/screen_header.dart';
import '../auth/auth_controller.dart';

class MeetingsListScreen extends ConsumerStatefulWidget {
  const MeetingsListScreen({super.key});

  @override
  ConsumerState<MeetingsListScreen> createState() => _MeetingsListScreenState();
}

class _MeetingsListScreenState extends ConsumerState<MeetingsListScreen> {
  String _filter = 'À venir';

  // NOTE: backend has GET /meetings/{id} per-meeting only — list endpoint is
  // not yet implemented in the controller surface we surveyed. Until a list
  // endpoint exists, we render the demo data set the design intends.
  late final List<Map<String, dynamic>> _demo = <Map<String, dynamic>>[
    <String, dynamic>{
      'date': <String>['VEN', '09', 'MAI'],
      'title': 'Cellule de prière',
      'time': '06h00 — 07h00',
      'loc': 'Salle Goshen',
      'type': 'PRIÈRE',
      'n': 18,
      'status': 'live',
    },
    <String, dynamic>{
      'date': <String>['SAM', '10', 'MAI'],
      'title': 'Étude — Romains 8',
      'time': '16h00 — 18h00',
      'loc': 'Salle B · Amphi',
      'type': 'ÉTUDE',
      'n': 42,
      'status': 'soon',
    },
    <String, dynamic>{
      'date': <String>['DIM', '11', 'MAI'],
      'title': 'Culte mensuel BBC',
      'time': '09h00 — 12h00',
      'loc': 'Auditorium central',
      'type': 'CULTE',
      'n': 132,
      'status': 'planned',
    },
    <String, dynamic>{
      'date': <String>['MAR', '13', 'MAI'],
      'title': 'Discipulat — L2',
      'time': '17h00 — 18h30',
      'loc': 'Salle 4',
      'type': 'DISCIP.',
      'n': 8,
      'status': 'planned',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final JwtSession? s = ref.watch(sessionProvider);
    final bool canPlan = s?.canPlanMeetings ?? false;
    return Scaffold(
      backgroundColor: BbcColors.bg,
      body: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          ScreenHeader(
            eyebrow: 'BBC · ${s?.bibleClubId == null ? "Tous" : "Mon club"}',
            title: 'Réunions',
            actions: <Widget>[
              const RoundIcon(icon: Icons.search),
              if (canPlan)
                RoundIcon(
                  icon: Icons.add,
                  onTap: () => context.push('/meetings/new'),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: ChipSelector(
              options: const <String>['Toutes', 'À venir', 'En cours', 'Tenues', 'Études', 'Prière'],
              selected: _filter,
              onChanged: (String v) => setState(() => _filter = v),
            ),
          ),
          if (_demo.isEmpty)
            const EmptyState(title: 'Aucune réunion', message: 'Aucune réunion à venir pour ce filtre.')
          else
            for (final Map<String, dynamic> m in _demo) _MeetingRow(m: m),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _MeetingRow extends StatelessWidget {
  const _MeetingRow({required this.m});

  final Map<String, dynamic> m;

  @override
  Widget build(BuildContext context) {
    final bool live = m['status'] == 'live';
    return InkWell(
      onTap: () => context.push('/meetings/demo-${m['title']}'),
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: BbcColors.surface,
          border: Border.all(color: BbcColors.hair),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: 50,
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: live ? BbcColors.ink : BbcColors.surface2,
                border: Border.all(color: live ? BbcColors.ink : BbcColors.hair),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: <Widget>[
                  Text((m['date'] as List<String>)[0],
                      style: BbcTypo.mono(
                          size: 9,
                          color: live ? Colors.white70 : BbcColors.muted)),
                  Text((m['date'] as List<String>)[1],
                      style: BbcTypo.serif(
                          size: 20,
                          color: live ? Colors.white : BbcColors.ink,
                          height: 1)),
                  Text((m['date'] as List<String>)[2],
                      style: BbcTypo.mono(
                          size: 8,
                          color: live ? Colors.white60 : BbcColors.muted2)),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(m['title'] as String,
                            style: BbcTypo.sans(
                                size: 13.5, weight: FontWeight.w500)),
                      ),
                      if (live)
                        Row(
                          children: <Widget>[
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: BbcColors.danger,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text('EN COURS',
                                style: BbcTypo.mono(
                                    size: 9,
                                    color: BbcColors.danger,
                                    weight: FontWeight.w600)),
                          ],
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: <Widget>[
                      const Icon(Icons.access_time, size: 11, color: BbcColors.muted),
                      const SizedBox(width: 3),
                      Text(m['time'] as String,
                          style: BbcTypo.meta(color: BbcColors.muted)),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Row(
                          children: <Widget>[
                            const Icon(Icons.place_outlined,
                                size: 11, color: BbcColors.muted),
                            const SizedBox(width: 3),
                            Expanded(
                              child: Text(m['loc'] as String,
                                  overflow: TextOverflow.ellipsis,
                                  style: BbcTypo.meta(color: BbcColors.muted)),
                            ),
                          ],
                        ),
                      ),
                      Text(m['type'] as String,
                          style: BbcTypo.mono(
                              size: 9.5, color: BbcColors.muted2)),
                      const SizedBox(width: 6),
                      Text('· ${m['n']}',
                          style: BbcTypo.mono(
                              size: 10,
                              color: BbcColors.ink,
                              weight: FontWeight.w600)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
