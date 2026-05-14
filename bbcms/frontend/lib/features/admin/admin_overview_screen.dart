import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/network/api_client.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../core/utils/jwt_session.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/pill_tag.dart';
import '../../core/widgets/round_icon.dart';
import '../../core/widgets/screen_header.dart';
import '../../core/widgets/section_header.dart';
import '../auth/auth_controller.dart';

class AdminOverviewScreen extends ConsumerStatefulWidget {
  const AdminOverviewScreen({super.key});

  @override
  ConsumerState<AdminOverviewScreen> createState() => _AdminOverviewScreenState();
}

class _AdminOverviewScreenState extends ConsumerState<AdminOverviewScreen> {
  int? _bbcCount;
  int? _pendingRequests;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    try {
      final ApiClient api = ref.read(apiClientProvider);
      final List<Map<String, dynamic>> bbcs = await api.listBibleClubs();
      List<Map<String, dynamic>> pending = <Map<String, dynamic>>[];
      try {
        pending = await api.listMembershipRequests(status: 'PENDING');
      } catch (_) {}
      if (mounted) {
        setState(() {
          _bbcCount = bbcs.length;
          _pendingRequests = pending.length;
        });
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final JwtSession? s = ref.watch(sessionProvider);
    if (s == null || !s.isSuperAdmin) {
      return Scaffold(
        backgroundColor: BbcColors.bg,
        body: const SafeArea(
          child: EmptyState(
            title: 'Accès réservé',
            message: 'Cette section est réservée au super-administrateur.',
          ),
        ),
      );
    }
    return Scaffold(
      backgroundColor: BbcColors.bg,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            ScreenHeader(
              eyebrow: 'God-mode · SYSTEM_ADMIN',
              title: 'Administration',
              subtitle: 'Toutes les ressources CHF',
              actions: <Widget>[
                RoundIcon(
                  icon: Icons.arrow_back,
                  onTap: () => Navigator.maybePop(context),
                ),
              ],
            ),
            if (_error != null) EmptyState(title: 'Indisponible', message: _error),
            if (_loading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(
                    child: CircularProgressIndicator(color: BbcColors.ink)),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 1.4,
                  children: <Widget>[
                    _Kpi(
                      label: 'Bible Clubs',
                      value: '${_bbcCount ?? '—'}',
                      sub: 'Actifs CHF',
                      icon: Icons.school_outlined,
                      onTap: () => context.push('/admin/bible-clubs'),
                    ),
                    _Kpi(
                      label: 'Demandes',
                      value: '${_pendingRequests ?? '—'}',
                      sub: 'En attente',
                      icon: Icons.how_to_reg_outlined,
                      onTap: () => context.push('/admin/membership-requests'),
                      accent: (_pendingRequests ?? 0) > 0
                          ? BbcColors.warn
                          : BbcColors.muted,
                    ),
                  ],
                ),
              ),
            const SectionHeader('Modules accessibles'),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: BbcColors.surface,
                border: Border.all(color: BbcColors.hair),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: <Widget>[
                  _Module(
                    icon: Icons.public,
                    label: 'Dashboard national',
                    sub: 'Pilotage CHF · classements · trends',
                    onTap: () => context.push('/dashboard/national'),
                  ),
                  _Module(
                    icon: Icons.bar_chart_rounded,
                    label: 'Dashboard BBC',
                    sub: 'KPIs club',
                    onTap: () => context.push('/dashboard/leader'),
                  ),
                  _Module(
                    icon: Icons.how_to_reg_outlined,
                    label: 'Demandes d\'adhésion',
                    sub: 'Approuver / Rejeter',
                    badge: (_pendingRequests ?? 0) > 0
                        ? '${_pendingRequests ?? 0}'
                        : null,
                    onTap: () => context.push('/admin/membership-requests'),
                  ),
                  _Module(
                    icon: Icons.school_outlined,
                    label: 'Bible Clubs',
                    sub: 'CRUD · objectif · triumvirat · reset annuel',
                    onTap: () => context.push('/admin/bible-clubs'),
                  ),
                  _Module(
                    icon: Icons.event_outlined,
                    label: 'Événements nationaux',
                    sub: 'Planifier · participations',
                    onTap: () => context.push('/events'),
                  ),
                  _Module(
                    icon: Icons.favorite_outline,
                    label: 'Chaînes de prière',
                    sub: 'Planifier · slots · sujets',
                    onTap: () => context.push('/prayer-chain'),
                  ),
                  _Module(
                    icon: Icons.send_outlined,
                    label: 'Évangélisation',
                    sub: 'Programmes · enregistrements',
                    onTap: () => context.push('/evangelism'),
                  ),
                  _Module(
                    icon: Icons.layers_outlined,
                    label: 'Discipulat',
                    sub: 'Liens mentor↔disciple · sessions',
                    onTap: () => context.push('/discipleship'),
                  ),
                  _Module(
                    icon: Icons.payments_outlined,
                    label: 'Finance',
                    sub: 'Contributions · paiements',
                    onTap: () => context.push('/finance'),
                    last: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _Kpi extends StatelessWidget {
  const _Kpi({
    required this.label,
    required this.value,
    required this.sub,
    required this.icon,
    this.onTap,
    this.accent = BbcColors.positive,
  });

  final String label;
  final String value;
  final String sub;
  final IconData icon;
  final VoidCallback? onTap;
  final Color accent;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
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
                      child: Text(label.toUpperCase(),
                          style: BbcTypo.mono(
                              size: 9, color: BbcColors.muted))),
                  Icon(icon, size: 14, color: accent),
                ],
              ),
              const SizedBox(height: 8),
              Text(value,
                  style:
                      BbcTypo.serif(size: 30, height: 1, letterSpacing: -0.6)),
              const SizedBox(height: 4),
              Text(sub, style: BbcTypo.sans(size: 10.5, color: accent)),
            ],
          ),
        ),
      );
}

class _Module extends StatelessWidget {
  const _Module({
    required this.icon,
    required this.label,
    required this.sub,
    this.onTap,
    this.badge,
    this.last = false,
  });

  final IconData icon;
  final String label;
  final String sub;
  final VoidCallback? onTap;
  final String? badge;
  final bool last;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                  color: last ? Colors.transparent : BbcColors.hair2),
            ),
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: BbcColors.surface2,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Icon(icon, size: 14, color: BbcColors.ink),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(label,
                        style: BbcTypo.sans(
                            size: 13.5, weight: FontWeight.w500)),
                    Text(sub, style: BbcTypo.meta()),
                  ],
                ),
              ),
              if (badge != null) PillTag(badge!, kind: PillKind.warn),
              const SizedBox(width: 6),
              const Icon(Icons.chevron_right, size: 14, color: BbcColors.muted2),
            ],
          ),
        ),
      );
}
