import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../core/widgets/avatar.dart';
import '../../core/widgets/pill_tag.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/progress_bar.dart';
import '../../core/widgets/round_icon.dart';
import '../../core/widgets/screen_header.dart';
import '../../core/widgets/section_header.dart';

class PrayerChainScreen extends ConsumerWidget {
  const PrayerChainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: BbcColors.bg,
      body: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          ScreenHeader(
            eyebrow: 'Intercession · 24h',
            title: 'Chaîne de prière',
            actions: <Widget>[
              RoundIcon(
                icon: Icons.arrow_back,
                onTap: () => Navigator.maybePop(context),
              ),
              const RoundIcon(icon: Icons.more_horiz),
            ],
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: BbcColors.surface,
              border: Border.all(color: BbcColors.hair),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text('Réveil de Pentecôte 2026',
                              style: BbcTypo.sans(
                                  size: 14, weight: FontWeight.w500)),
                          Text('BBC · UNIKIN · Démarrée il y a 14h',
                              style: BbcTypo.meta()),
                        ],
                      ),
                    ),
                    const PillTag('En cours', kind: PillKind.success),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: <Widget>[
                    SizedBox(
                      width: 60,
                      height: 60,
                      child: Stack(
                        alignment: Alignment.center,
                        children: <Widget>[
                          CustomPaint(
                            size: const Size(60, 60),
                            painter: _ChainPainter(value: 14 / 24),
                          ),
                          Text('14h',
                              style:
                                  BbcTypo.serif(size: 18, height: 1)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Text('SLOTS COUVERTS',
                                  style: BbcTypo.mono(
                                      size: 9, color: BbcColors.muted)),
                              const Spacer(),
                              Text('14 / 24',
                                  style:
                                      BbcTypo.serif(size: 18, height: 1)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const ProgressBar(value: 14 / 24),
                          const SizedBox(height: 4),
                          Text('10 créneaux libres · prochaine relève à 11:00',
                              style: BbcTypo.meta()),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SectionHeader('Créneaux 24h', more: 'Aujourd\'hui'),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: BbcColors.surface,
              border: Border.all(color: BbcColors.hair),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: <Widget>[
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 6, mainAxisSpacing: 5, crossAxisSpacing: 5),
                  itemCount: 24,
                  itemBuilder: (BuildContext c, int i) {
                    final bool filled = const <int>[
                      0, 1, 2, 3, 5, 6, 7, 9, 10, 11, 12, 14, 15, 17, 21, 22
                    ].contains(i);
                    final bool me = i == 10;
                    return Container(
                      decoration: BoxDecoration(
                        color: me
                            ? BbcColors.ink
                            : filled
                                ? BbcColors.surface2
                                : Colors.transparent,
                        border: Border.all(
                            color: me ? BbcColors.ink : BbcColors.hair),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Text('${i.toString().padLeft(2, '0')}h',
                          style: BbcTypo.mono(
                              size: 10,
                              color: me
                                  ? Colors.white
                                  : filled
                                      ? BbcColors.ink
                                      : BbcColors.muted2)),
                    );
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  children: <Widget>[
                    _LegendDot(color: BbcColors.ink, label: 'Vous'),
                    const SizedBox(width: 12),
                    _LegendDot(color: BbcColors.surface2, label: 'Pris'),
                    const SizedBox(width: 12),
                    _LegendDot(color: Colors.transparent, label: 'Libre'),
                  ],
                ),
              ],
            ),
          ),
          const SectionHeader('Sujets de prière', more: '8 actifs'),
          Container(
            color: BbcColors.surface,
            child: Column(
              children: <Widget>[
                for (final ({String n, String t, int m}) s
                    in <({String n, String t, int m})>[
                      (n: '01', t: 'Réveil de la jeunesse universitaire', m: 24),
                      (n: '02', t: 'Famille du frère Mukendi (deuil)', m: 18),
                      (n: '03', t: 'Examens nationaux — étudiants L3', m: 12),
                      (n: '04', t: 'Église persécutée — Sahel', m: 9),
                    ])
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 14),
                    decoration: const BoxDecoration(
                      border:
                          Border(bottom: BorderSide(color: BbcColors.hair)),
                    ),
                    child: Row(
                      children: <Widget>[
                        SizedBox(
                          width: 22,
                          child: Text(s.n,
                              style: BbcTypo.mono(
                                  size: 11, color: BbcColors.muted2)),
                        ),
                        Expanded(
                          child: Text(s.t, style: BbcTypo.sans(size: 13)),
                        ),
                        const Icon(Icons.favorite_outline,
                            size: 12, color: BbcColors.muted),
                        const SizedBox(width: 4),
                        Text('${s.m}',
                            style: BbcTypo.meta(color: BbcColors.muted)),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 22),
            child: PrimaryButton(
              label: 'Réserver un créneau',
              trailing: const Icon(Icons.add),
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
        children: <Widget>[
          Container(
            width: 9,
            height: 9,
            decoration: BoxDecoration(
              color: color,
              border: Border.all(color: BbcColors.hair),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 5),
          Text(label, style: BbcTypo.sans(size: 10.5)),
        ],
      );
}

class _ChainPainter extends CustomPainter {
  _ChainPainter({required this.value});

  final double value;

  @override
  void paint(Canvas canvas, Size size) {
    final double r = (size.shortestSide - 3) / 2;
    final Offset c = Offset(size.width / 2, size.height / 2);
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..color = BbcColors.hair
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke,
    );
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r),
      -math.pi / 2,
      value * 2 * math.pi,
      false,
      Paint()
        ..color = BbcColors.ink
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(covariant _ChainPainter old) => old.value != value;
}
