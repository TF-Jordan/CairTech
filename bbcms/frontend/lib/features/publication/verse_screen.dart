import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_client.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../core/widgets/avatar.dart';
import '../../core/widgets/chip_selector.dart';
import '../../core/widgets/pill_tag.dart';
import '../../core/widgets/round_icon.dart';
import '../../core/widgets/screen_header.dart';
import '../../core/widgets/section_header.dart';

class VerseScreen extends ConsumerStatefulWidget {
  const VerseScreen({super.key});

  @override
  ConsumerState<VerseScreen> createState() => _VerseScreenState();
}

class _VerseScreenState extends ConsumerState<VerseScreen> {
  String _tab = 'Verset du jour';
  Map<String, dynamic>? _verse;
  List<Map<String, dynamic>> _announcements = <Map<String, dynamic>>[];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    try {
      final ApiClient api = ref.read(apiClientProvider);
      final List<Map<String, dynamic>> verses = await api.listDailyVerses();
      final List<Map<String, dynamic>> ann = await api.listAnnouncements();
      if (mounted) {
        setState(() {
          _verse = verses.isEmpty ? null : verses.first;
          _announcements = ann;
        });
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final String verse = (_verse?['verseText'] as String?) ??
        '« L\'Éternel est mon berger : je ne manquerai de rien. Il me fait reposer dans de verts pâturages, il me dirige près des eaux paisibles. »';
    final String reference = (_verse?['reference'] as String?) ?? 'PSAUME 23.1–4';
    final String title = (_verse?['title'] as String?) ?? 'JEUDI 8 MAI';
    return Scaffold(
      backgroundColor: BbcColors.bg,
      body: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const ScreenHeader(
            eyebrow: 'Spirituel',
            title: 'Verset & Annonces',
            actions: <Widget>[
              RoundIcon(icon: Icons.search),
              RoundIcon(icon: Icons.notifications_outlined),
            ],
          ),
          ChipSelector(
            options: const <String>[
              'Verset du jour',
              'Annonces',
              'Méditations',
              'Archives'
            ],
            selected: _tab,
            onChanged: (String v) => setState(() => _tab = v),
          ),
          const SizedBox(height: 14),
          // Editorial dark verse card
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 28),
            decoration: BoxDecoration(
              color: BbcColors.ink,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('${title.toUpperCase()} · $reference',
                    style: BbcTypo.mono(
                        size: 10, color: Colors.white.withOpacity(0.55))),
                const SizedBox(height: 18),
                Text(verse,
                    style: BbcTypo.serif(
                        size: 26,
                        color: Colors.white,
                        height: 1.3,
                        letterSpacing: -0.1)),
                const SizedBox(height: 28),
                Container(
                    height: 1, color: Colors.white.withOpacity(0.12)),
                const SizedBox(height: 16),
                Row(
                  children: <Widget>[
                    Icon(Icons.favorite_outline,
                        size: 13, color: Colors.white.withOpacity(0.65)),
                    const SizedBox(width: 5),
                    Text('482',
                        style: BbcTypo.sans(
                            size: 11, color: Colors.white.withOpacity(0.65))),
                    const SizedBox(width: 16),
                    Icon(Icons.send_outlined,
                        size: 13, color: Colors.white.withOpacity(0.65)),
                    const SizedBox(width: 5),
                    Text('Partager',
                        style: BbcTypo.sans(
                            size: 11, color: Colors.white.withOpacity(0.65))),
                    const Spacer(),
                    Text('SEGOND 21',
                        style: BbcTypo.mono(
                            size: 10, color: Colors.white.withOpacity(0.45))),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 6),
            child: Text('MÉDITATION DU JOUR',
                style: BbcTypo.mono(size: 10, color: BbcColors.muted)),
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
                    const Avatar(name: 'Pasteur Mwamba', size: AvatarSize.sm),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text('Pasteur Joseph Mwamba',
                              style: BbcTypo.sans(
                                  size: 13, weight: FontWeight.w500)),
                          Text('Direction nationale · 4 min',
                              style: BbcTypo.meta()),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text('Reposer en celui qui pourvoit',
                    style: BbcTypo.serif(size: 21, height: 1.2)),
                const SizedBox(height: 8),
                Text(
                  'David ne dit pas qu\'il ne manque de rien parce qu\'il est riche, mais parce que l\'Éternel est son berger. Le repos est la posture du croyant qui a appris à se confier…',
                  style: BbcTypo.sans(
                      size: 13, color: BbcColors.ink2, height: 1.55),
                ),
                const SizedBox(height: 14),
                Row(
                  children: <Widget>[
                    const PillTag('Lecture'),
                    const Spacer(),
                    Text('LIRE LA SUITE →',
                        style:
                            BbcTypo.mono(size: 10, color: BbcColors.muted)),
                  ],
                ),
              ],
            ),
          ),
          SectionHeader('Annonces de la semaine',
              more: '${_announcements.length} actives'),
          Container(
            color: BbcColors.surface,
            child: _announcements.isEmpty
                ? Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                    color: BbcColors.surface,
                    child: Text('Aucune annonce active.',
                        style: BbcTypo.meta()),
                  )
                : Column(
                    children: <Widget>[
                      for (final Map<String, dynamic> a in _announcements)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 14),
                          decoration: const BoxDecoration(
                            border: Border(
                                bottom:
                                    BorderSide(color: BbcColors.hair)),
                          ),
                          child: Row(
                            children: <Widget>[
                              Container(
                                width: 4,
                                height: 36,
                                color: BbcColors.accent,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text((a['title'] as String?) ?? '',
                                        style: BbcTypo.sans(
                                            size: 13,
                                            weight: FontWeight.w500)),
                                    if (a['content'] != null)
                                      Text(a['content'] as String,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: BbcTypo.meta()),
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_right,
                                  size: 14, color: BbcColors.muted2),
                            ],
                          ),
                        ),
                    ],
                  ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
