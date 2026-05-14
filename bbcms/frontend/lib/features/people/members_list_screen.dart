import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/network/api_client.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../core/utils/jwt_session.dart';
import '../../core/widgets/avatar.dart';
import '../../core/widgets/chip_selector.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/round_icon.dart';
import '../../core/widgets/screen_header.dart';
import '../auth/auth_controller.dart';

class MembersListScreen extends ConsumerStatefulWidget {
  const MembersListScreen({super.key});

  @override
  ConsumerState<MembersListScreen> createState() => _MembersListScreenState();
}

class _MembersListScreenState extends ConsumerState<MembersListScreen> {
  List<Map<String, dynamic>>? _members;
  String? _error;
  bool _loading = true;
  String _filter = 'Tous';
  String _query = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final JwtSession? s = ref.read(sessionProvider);
    if (s?.bibleClubId == null) {
      setState(() {
        _loading = false;
        _error = 'Aucun BBC associé à ce compte';
      });
      return;
    }
    try {
      _members = await ref.read(apiClientProvider).listMembers(s!.bibleClubId!);
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Map<String, List<Map<String, dynamic>>> _grouped() {
    final List<Map<String, dynamic>> base = (_members ?? <Map<String, dynamic>>[])
        .where((Map<String, dynamic> m) {
      if (_query.isEmpty) return true;
      final String name = (m['fullName'] as String? ?? '').toLowerCase();
      return name.contains(_query.toLowerCase());
    }).toList();
    final Map<String, List<Map<String, dynamic>>> groups =
        <String, List<Map<String, dynamic>>>{};
    for (final Map<String, dynamic> m in base) {
      final String name = (m['fullName'] as String? ?? 'Z');
      final String letter =
          name.isEmpty ? 'Z' : name.substring(0, 1).toUpperCase();
      groups.putIfAbsent(letter, () => <Map<String, dynamic>>[]).add(m);
    }
    return Map<String, List<Map<String, dynamic>>>.fromEntries(
      groups.entries.toList()
        ..sort((MapEntry<String, List<Map<String, dynamic>>> a,
                MapEntry<String, List<Map<String, dynamic>>> b) =>
            a.key.compareTo(b.key)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final int total = _members?.length ?? 0;
    final Map<String, List<Map<String, dynamic>>> grouped = _grouped();
    return Scaffold(
      backgroundColor: BbcColors.bg,
      body: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          ScreenHeader(
            eyebrow: 'BBC · $total membres',
            title: 'Annuaire',
            actions: const <Widget>[
              RoundIcon(icon: Icons.filter_list),
              RoundIcon(icon: Icons.add),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              onChanged: (String v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: 'Rechercher un membre…',
                prefixIcon: const Padding(
                  padding: EdgeInsets.only(left: 12, right: 8),
                  child: Icon(Icons.search, size: 16, color: BbcColors.muted),
                ),
                prefixIconConstraints:
                    const BoxConstraints(minWidth: 36, minHeight: 18),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(999),
                  borderSide: const BorderSide(color: BbcColors.hair),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(999),
                  borderSide: const BorderSide(color: BbcColors.hair),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          ChipSelector(
            options: <String>[
              'Tous · $total',
              'Actifs',
              'Étudiants',
              'Pros',
              'Inactifs',
              'Visiteurs'
            ],
            selected: _filter,
            onChanged: (String v) => setState(() => _filter = v),
          ),
          const SizedBox(height: 14),
          if (_loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 60),
              child: Center(child: CircularProgressIndicator(color: BbcColors.ink)),
            )
          else if (_error != null)
            EmptyState(title: 'Indisponible', message: _error)
          else if (grouped.isEmpty)
            const EmptyState(title: 'Aucun membre')
          else
            for (final MapEntry<String, List<Map<String, dynamic>>> entry
                in grouped.entries) ...<Widget>[
              Container(
                color: BbcColors.bg,
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 8),
                child: Row(
                  children: <Widget>[
                    Text(entry.key,
                        style: BbcTypo.mono(
                            size: 11, weight: FontWeight.w600)),
                    const SizedBox(width: 10),
                    Expanded(child: Container(height: 1, color: BbcColors.hair)),
                  ],
                ),
              ),
              for (final Map<String, dynamic> m in entry.value)
                InkWell(
                  onTap: () => context.push('/members/${m['id']}'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 14),
                    decoration: const BoxDecoration(
                      color: BbcColors.surface,
                      border:
                          Border(bottom: BorderSide(color: BbcColors.hair)),
                    ),
                    child: Row(
                      children: <Widget>[
                        Avatar(
                            name: (m['fullName'] as String?) ?? '?',
                            size: AvatarSize.sm),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text((m['fullName'] as String?) ?? 'Membre',
                                  style: BbcTypo.sans(
                                      size: 13.5, weight: FontWeight.w500)),
                              Text(
                                  '${(m['kind'] as String?) ?? ''} · ${(m['profession'] as String?) ?? ''}',
                                  style: BbcTypo.meta()),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            Text(
                                '${((m['faithfulPercentage'] as num?) ?? 0).round()}',
                                style: BbcTypo.serif(size: 16, height: 1)),
                            Text('FIDÉLITÉ',
                                style: BbcTypo.mono(
                                    size: 8.5, color: BbcColors.muted2)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
