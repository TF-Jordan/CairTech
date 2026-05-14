import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_client.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/pill_tag.dart';
import '../../core/widgets/round_icon.dart';
import '../../core/widgets/screen_header.dart';

class EventsScreen extends ConsumerStatefulWidget {
  const EventsScreen({super.key});

  @override
  ConsumerState<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends ConsumerState<EventsScreen> {
  List<Map<String, dynamic>>? _events;
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    try {
      _events = await ref.read(apiClientProvider).listEvents();
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
      body: SafeArea(
        child: Column(
          children: <Widget>[
            ScreenHeader(
              eyebrow: 'CHF · Événements nationaux',
              title: 'Événements',
              actions: <Widget>[
                RoundIcon(
                  icon: Icons.arrow_back,
                  onTap: () => Navigator.maybePop(context),
                ),
              ],
            ),
            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(color: BbcColors.ink))
                  : _error != null
                      ? EmptyState(
                          title: 'Impossible de charger', message: _error)
                      : _events == null || _events!.isEmpty
                          ? const EmptyState(
                              title: 'Aucun événement',
                              message:
                                  'Aucun événement national n\'est planifié.')
                          : ListView.separated(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              itemCount: _events!.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 8),
                              itemBuilder: (BuildContext c, int i) =>
                                  _EventCard(event: _events![i]),
                            ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  const _EventCard({required this.event});

  final Map<String, dynamic> event;

  @override
  Widget build(BuildContext context) {
    final String title = (event['title'] as String?) ?? 'Événement';
    final String status = (event['status'] as String?) ?? 'PLANNED';
    final String type = (event['type'] as String?) ?? '';
    return Container(
      padding: const EdgeInsets.all(16),
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
                  child: Text(title,
                      style: BbcTypo.serif(size: 18, height: 1.1))),
              PillTag(status, kind: _kindFor(status)),
            ],
          ),
          const SizedBox(height: 8),
          Text(type, style: BbcTypo.meta()),
        ],
      ),
    );
  }

  PillKind _kindFor(String s) {
    switch (s) {
      case 'ONGOING':
        return PillKind.accent;
      case 'CLOSED':
      case 'CANCELLED':
        return PillKind.defaultKind;
      case 'REGISTRATION_OPEN':
        return PillKind.success;
      default:
        return PillKind.defaultKind;
    }
  }
}
