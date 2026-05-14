import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_client.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../core/widgets/avatar.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/round_icon.dart';

class MemberDetailScreen extends ConsumerStatefulWidget {
  const MemberDetailScreen({super.key, required this.memberId});

  final String memberId;

  @override
  ConsumerState<MemberDetailScreen> createState() => _MemberDetailScreenState();
}

class _MemberDetailScreenState extends ConsumerState<MemberDetailScreen> {
  Map<String, dynamic>? _member;
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    try {
      _member = await ref.read(apiClientProvider).getMember(widget.memberId);
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
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: BbcColors.ink))
          : _error != null
              ? EmptyState(title: 'Indisponible', message: _error)
              : _buildBody(),
    );
  }

  Widget _buildBody() {
    final Map<String, dynamic> m = _member!;
    final num faith = (m['faithfulPercentage'] as num?) ?? 0;
    final String level = (m['levelId'] as String?) ?? 'L?';
    final String name = (m['fullName'] as String?) ?? 'Membre';
    return ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        Container(
          color: BbcColors.ink,
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 26),
          child: SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    RoundIcon(
                      icon: Icons.arrow_back,
                      dark: true,
                      onTap: () => Navigator.maybePop(context),
                    ),
                    const Spacer(),
                    const RoundIcon(icon: Icons.phone_outlined, dark: true),
                    const SizedBox(width: 6),
                    const RoundIcon(icon: Icons.mail_outline, dark: true),
                  ],
                ),
                const SizedBox(height: 22),
                Row(
                  children: <Widget>[
                    Avatar(name: name, size: AvatarSize.lg),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(level.toUpperCase(),
                              style: BbcTypo.mono(
                                  size: 10,
                                  color: Colors.white.withOpacity(0.55))),
                          const SizedBox(height: 4),
                          Text(name,
                              style: BbcTypo.serif(
                                  size: 26, color: Colors.white, height: 1.05)),
                          const SizedBox(height: 4),
                          Text(
                              (m['profession'] as String?) ??
                                  ((m['kind'] as String?) ?? '—'),
                              style: BbcTypo.sans(
                                  size: 12.5,
                                  color: Colors.white.withOpacity(0.7))),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(height: 1, color: Colors.white.withOpacity(0.12)),
                const SizedBox(height: 16),
                Row(
                  children: <Widget>[
                    Expanded(child: _stat('FIDÉLITÉ', faith.toStringAsFixed(0))),
                    Expanded(
                        child: _stat('PARTICIPATIONS',
                            '${(m['participationScore'] as int?) ?? 0}')),
                    Expanded(
                        child: _stat('DÉPARTEMENTS',
                            '${(m['departments'] as List<dynamic>?)?.length ?? 0}')),
                    Expanded(child: _stat('STATUT', (m['status'] as String?) ?? '')),
                  ],
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          child: Wrap(
            spacing: 6,
            runSpacing: 6,
            children: <Widget>[
              for (final dynamic dept
                  in (m['departments'] as List<dynamic>?) ?? <dynamic>[])
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: BbcColors.surface,
                    border: Border.all(color: BbcColors.hair),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(dept.toString(),
                      style: BbcTypo.sans(size: 12, color: BbcColors.ink2)),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _stat(String label, String value) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(value,
              style: BbcTypo.serif(
                  size: 18, color: Colors.white, height: 1, letterSpacing: -0.4)),
          const SizedBox(height: 3),
          Text(label,
              style: BbcTypo.mono(
                  size: 8.5, color: Colors.white.withOpacity(0.5))),
        ],
      );
}
