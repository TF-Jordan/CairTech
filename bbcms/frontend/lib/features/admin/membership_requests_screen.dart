import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_client.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../core/widgets/avatar.dart';
import '../../core/widgets/chip_selector.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/pill_tag.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/round_icon.dart';
import '../../core/widgets/screen_header.dart';

class MembershipRequestsScreen extends ConsumerStatefulWidget {
  const MembershipRequestsScreen({super.key});

  @override
  ConsumerState<MembershipRequestsScreen> createState() =>
      _MembershipRequestsScreenState();
}

class _MembershipRequestsScreenState
    extends ConsumerState<MembershipRequestsScreen> {
  String _filter = 'PENDING';
  List<Map<String, dynamic>>? _requests;
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      _requests = await ref.read(apiClientProvider)
          .listMembershipRequests(status: _filter);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _approve(Map<String, dynamic> r) async {
    try {
      await ref.read(apiClientProvider).approveMembershipRequest(
        r['id'] as String,
        <String, dynamic>{
          'assignedBibleClubId': r['requestedBibleClubId'],
          'assignedLevelId': r['requestedLevelId'],
          'comment': null,
        },
      );
      _load();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Demande approuvée')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Erreur: $e')));
      }
    }
  }

  Future<void> _reject(Map<String, dynamic> r) async {
    final String? comment = await showDialog<String>(
      context: context,
      builder: (BuildContext c) {
        final TextEditingController ctrl = TextEditingController();
        return AlertDialog(
          backgroundColor: BbcColors.surface,
          title: Text('Motif du rejet', style: BbcTypo.serif(size: 18)),
          content: TextField(
            controller: ctrl,
            decoration: const InputDecoration(hintText: 'Motif (optionnel)'),
            maxLines: 3,
          ),
          actions: <Widget>[
            TextButton(
                onPressed: () => Navigator.of(c).pop(),
                child: const Text('Annuler')),
            TextButton(
                onPressed: () => Navigator.of(c).pop(ctrl.text),
                child: const Text('Rejeter')),
          ],
        );
      },
    );
    if (comment == null) return;
    try {
      await ref.read(apiClientProvider).rejectMembershipRequest(
            r['id'] as String,
            <String, dynamic>{'comment': comment},
          );
      _load();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Demande rejetée')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Erreur: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BbcColors.bg,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            ScreenHeader(
              eyebrow: 'Admin · Identité',
              title: 'Demandes d\'adhésion',
              actions: <Widget>[
                RoundIcon(
                  icon: Icons.arrow_back,
                  onTap: () => Navigator.maybePop(context),
                ),
                RoundIcon(icon: Icons.refresh, onTap: _load),
              ],
            ),
            ChipSelector(
              options: const <String>['PENDING', 'APPROVED', 'REJECTED'],
              selected: _filter,
              onChanged: (String v) {
                setState(() => _filter = v);
                _load();
              },
            ),
            const SizedBox(height: 14),
            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(color: BbcColors.ink))
                  : _error != null
                      ? EmptyState(title: 'Indisponible', message: _error)
                      : (_requests == null || _requests!.isEmpty)
                          ? const EmptyState(
                              title: 'Aucune demande',
                              message: 'Rien à traiter dans cette catégorie.',
                            )
                          : ListView.separated(
                              padding: EdgeInsets.zero,
                              itemCount: _requests!.length,
                              separatorBuilder: (_, __) => const Divider(
                                  height: 1, color: BbcColors.hair),
                              itemBuilder: (BuildContext c, int i) {
                                final Map<String, dynamic> r = _requests![i];
                                return Container(
                                  color: BbcColors.surface,
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Row(
                                        children: <Widget>[
                                          Avatar(
                                              name: (r['fullName'] as String?) ??
                                                  'Demandeur'),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Text(
                                                    (r['fullName']
                                                            as String?) ??
                                                        'Demandeur',
                                                    style: BbcTypo.sans(
                                                        size: 14,
                                                        weight:
                                                            FontWeight.w500)),
                                                Text(
                                                    'Type demandé: ${(r['requestedType'] as String?) ?? '?'}',
                                                    style: BbcTypo.meta()),
                                              ],
                                            ),
                                          ),
                                          PillTag(
                                            (r['status'] as String?) ?? '?',
                                            kind: switch (r['status']) {
                                              'APPROVED' => PillKind.success,
                                              'REJECTED' => PillKind.defaultKind,
                                              _ => PillKind.warn,
                                            },
                                          ),
                                        ],
                                      ),
                                      if (_filter == 'PENDING') ...<Widget>[
                                        const SizedBox(height: 12),
                                        Row(
                                          children: <Widget>[
                                            Expanded(
                                              child: PrimaryButton(
                                                label: 'Rejeter',
                                                style: BbcButtonStyle.ghost,
                                                onPressed: () => _reject(r),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              flex: 2,
                                              child: PrimaryButton(
                                                label: 'Approuver',
                                                trailing:
                                                    const Icon(Icons.check),
                                                onPressed: () => _approve(r),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ],
                                  ),
                                );
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }
}
