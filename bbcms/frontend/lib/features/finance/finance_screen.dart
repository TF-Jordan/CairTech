import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_client.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../core/utils/jwt_session.dart';
import '../../core/widgets/pill_tag.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/progress_bar.dart';
import '../../core/widgets/round_icon.dart';
import '../../core/widgets/screen_header.dart';
import '../../core/widgets/section_header.dart';
import '../auth/auth_controller.dart';

class FinanceScreen extends ConsumerStatefulWidget {
  const FinanceScreen({super.key});

  @override
  ConsumerState<FinanceScreen> createState() => _FinanceScreenState();
}

class _FinanceScreenState extends ConsumerState<FinanceScreen> {
  int _amount = 10;
  String _channel = 'M-Pesa';
  String _designation = 'Dîme régulière';
  List<Map<String, dynamic>> _contribs = <Map<String, dynamic>>[];
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final JwtSession? s = ref.read(sessionProvider);
    if (s?.bibleClubId == null) return;
    try {
      _contribs = await ref.read(apiClientProvider).listContributions(s!.bibleClubId!);
      if (mounted) setState(() {});
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BbcColors.bg,
      body: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          ScreenHeader(
            eyebrow: 'Finance · Mon compte',
            title: 'Contribuer',
            actions: <Widget>[
              RoundIcon(
                icon: Icons.arrow_back,
                onTap: () => Navigator.maybePop(context),
              ),
              const RoundIcon(icon: Icons.history),
            ],
          ),
          // Hero
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: BbcColors.ink,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('TOTAL CONTRIBUÉ · 2025/26',
                    style: BbcTypo.mono(
                        size: 10, color: Colors.white.withOpacity(0.55))),
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Text('284',
                        style: BbcTypo.serif(
                            size: 48,
                            color: Colors.white,
                            height: 0.95,
                            letterSpacing: -1.5)),
                    const SizedBox(width: 8),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text('USD',
                          style: BbcTypo.mono(
                              size: 13, color: Colors.white.withOpacity(0.6))),
                    ),
                    const Spacer(),
                    Text('· 12 dons',
                        style: BbcTypo.sans(
                            size: 11, color: Colors.white.withOpacity(0.5))),
                  ],
                ),
                const SizedBox(height: 16),
                Container(height: 1, color: Colors.white.withOpacity(0.1)),
                const SizedBox(height: 14),
                Row(
                  children: <Widget>[
                    Text('OBJECTIF ANNUEL · 480 USD',
                        style: BbcTypo.mono(
                            size: 9.5,
                            color: Colors.white.withOpacity(0.55))),
                    const Spacer(),
                    Text('59%',
                        style: BbcTypo.mono(
                            size: 10.5, color: Colors.white)),
                  ],
                ),
                const SizedBox(height: 8),
                ProgressBar(
                    value: 0.59,
                    color: Colors.white,
                    track: Colors.white.withOpacity(0.14),
                    height: 3),
              ],
            ),
          ),
          const SectionHeader('Faire un don', more: 'USD · CDF'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: <Widget>[
                for (final int v in const <int>[5, 10, 25, 50]) ...<Widget>[
                  Expanded(
                    child: InkWell(
                      onTap: () => setState(() => _amount = v),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: _amount == v ? BbcColors.ink : BbcColors.surface,
                          border: Border.all(
                              color:
                                  _amount == v ? BbcColors.ink : BbcColors.hair),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: <Widget>[
                            Text('$v',
                                style: BbcTypo.serif(
                                    size: 22,
                                    color: _amount == v
                                        ? Colors.white
                                        : BbcColors.ink,
                                    height: 1)),
                            const SizedBox(height: 4),
                            Text('USD',
                                style: BbcTypo.mono(
                                    size: 9,
                                    color: _amount == v
                                        ? Colors.white.withOpacity(0.7)
                                        : BbcColors.muted)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              decoration: BoxDecoration(
                color: BbcColors.surface,
                border: Border.all(color: BbcColors.hair),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: <Widget>[
                  for (final ({String l, String s}) d in const <({String l, String s})>[
                    (l: 'Dîme régulière', s: 'Fonctionnement du club'),
                    (l: 'Édifice Gospel', s: 'Collecte spéciale · 64% atteint'),
                    (l: 'Mission camp Goma', s: 'Frais de transport · 8 jeunes'),
                  ])
                    InkWell(
                      onTap: () => setState(() => _designation = d.l),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        decoration: const BoxDecoration(
                          border:
                              Border(bottom: BorderSide(color: BbcColors.hair2)),
                        ),
                        child: Row(
                          children: <Widget>[
                            Container(
                              width: 18,
                              height: 18,
                              decoration: BoxDecoration(
                                color: _designation == d.l
                                    ? BbcColors.ink
                                    : Colors.transparent,
                                border: Border.all(
                                    color: _designation == d.l
                                        ? BbcColors.ink
                                        : BbcColors.hair,
                                    width: 1.5),
                                shape: BoxShape.circle,
                              ),
                              child: _designation == d.l
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
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(d.l,
                                      style: BbcTypo.sans(
                                          size: 13,
                                          weight: FontWeight.w500)),
                                  Text(d.s, style: BbcTypo.meta()),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text('MODE DE PAIEMENT',
                style: BbcTypo.mono(size: 10, color: BbcColors.muted)),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: <Widget>[
                for (final String p in const <String>['M-Pesa', 'Orange', 'Carte']) ...<Widget>[
                  Expanded(
                    child: InkWell(
                      onTap: () => setState(() => _channel = p),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color:
                              _channel == p ? BbcColors.ink : BbcColors.surface,
                          border: Border.all(
                              color:
                                  _channel == p ? BbcColors.ink : BbcColors.hair),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(p,
                              style: BbcTypo.sans(
                                size: 12.5,
                                weight: FontWeight.w500,
                                color: _channel == p
                                    ? Colors.white
                                    : BbcColors.ink,
                              )),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SectionHeader('Mes dernières contributions'),
          Container(
            color: BbcColors.surface,
            child: Column(
              children: <Widget>[
                for (final ({String d, String t, String m}) r
                    in const <({String d, String t, String m})>[
                      (d: '02 mai', t: 'Dîme régulière', m: '25,00'),
                      (d: '15 avr.', t: 'Édifice Gospel', m: '50,00'),
                      (d: '04 avr.', t: 'Dîme régulière', m: '25,00'),
                    ])
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    decoration: const BoxDecoration(
                      border: Border(bottom: BorderSide(color: BbcColors.hair)),
                    ),
                    child: Row(
                      children: <Widget>[
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: BbcColors.surface2,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: const Icon(Icons.payments_outlined,
                              size: 16, color: BbcColors.muted),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(r.t,
                                  style: BbcTypo.sans(
                                      size: 13, weight: FontWeight.w500)),
                              Text('${r.d} · M-Pesa', style: BbcTypo.meta()),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            Text(r.m, style: BbcTypo.serif(size: 16, height: 1)),
                            Text('CONFIRMÉ',
                                style: BbcTypo.mono(
                                    size: 9, color: BbcColors.positive)),
                          ],
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 22),
            child: PrimaryButton(
              label: 'Confirmer ${_amount.toString()},00 USD',
              busy: _busy,
              trailing: const Icon(Icons.arrow_forward),
              onPressed: () async {
                final JwtSession? s = ref.read(sessionProvider);
                if (s == null || s.bibleClubId == null || _contribs.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Aucune campagne ouverte pour ce BBC')));
                  return;
                }
                final Map<String, dynamic> contrib = _contribs.first;
                setState(() => _busy = true);
                try {
                  await ref.read(apiClientProvider).recordPayment(
                    contrib['id'] as String,
                    <String, dynamic>{
                      'memberId': null,
                      'contributorName': s.email,
                      'amount': _amount,
                      'channel': _channel.toUpperCase(),
                    },
                  );
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Don enregistré')));
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Erreur: $e')));
                  }
                } finally {
                  if (mounted) setState(() => _busy = false);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
