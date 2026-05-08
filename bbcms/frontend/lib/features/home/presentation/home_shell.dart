import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../core/rbac/auth_session.dart';
import '../../../core/rbac/permissions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/connectivity_banner.dart';

class HomeShell extends ConsumerWidget {
  const HomeShell({required this.child, super.key});

  final Widget child;

  static const _tabs = [
    (route: AppRoutes.home, icon: Icons.auto_awesome_outlined,
        active: Icons.auto_awesome, label: 'Info'),
    (route: AppRoutes.clubs, icon: Icons.account_tree_outlined,
        active: Icons.account_tree, label: 'Clubs'),
    (route: AppRoutes.meetings, icon: Icons.event_outlined,
        active: Icons.event, label: 'Réunions'),
    (route: AppRoutes.publications, icon: Icons.menu_book_outlined,
        active: Icons.menu_book, label: 'Pubs'),
    (route: AppRoutes.profile, icon: Icons.person_outline,
        active: Icons.person, label: 'Profil'),
  ];

  int _indexFor(String location) {
    for (var i = 0; i < _tabs.length; i++) {
      if (location.startsWith(_tabs[i].route) &&
          (i != 0 || location == AppRoutes.home)) {
        return i;
      }
    }
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = GoRouterState.of(context).matchedLocation;
    final idx = _indexFor(loc);
    final session = ref.watch(authSessionProvider).value;

    return Scaffold(
      drawer: _AdminDrawer(session: session),
      body: ConnectivityBanner(child: child),
      bottomNavigationBar: NavigationBar(
        selectedIndex: idx,
        onDestinationSelected: (i) => context.go(_tabs[i].route),
        destinations: [
          for (final t in _tabs)
            NavigationDestination(
              icon: Icon(t.icon, color: AppColors.textSecondary),
              selectedIcon: Icon(t.active, color: AppColors.primary),
              label: t.label,
            ),
        ],
      ),
    );
  }
}

class _AdminDrawer extends StatelessWidget {
  const _AdminDrawer({required this.session});
  final AuthSession? session;

  @override
  Widget build(BuildContext context) {
    final s = session;
    return Drawer(
      backgroundColor: AppColors.surface,
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('BBCMS',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 22,
                        letterSpacing: 2,
                      )),
                  const SizedBox(height: 4),
                  Text(s?.email ?? '—',
                      style: const TextStyle(color: Colors.white70)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _DrawerLink(
              icon: Icons.dashboard_outlined,
              label: 'Dashboard national',
              perm: Perm.dashboardNational,
              session: s,
              onTap: () => context.go('/dashboard/national'),
            ),
            _DrawerLink(
              icon: Icons.assignment_ind_outlined,
              label: 'Demandes d\'adhésion',
              perm: Perm.membershipRequestRead,
              session: s,
              onTap: () => context.go('/membership-requests'),
            ),
            _DrawerLink(
              icon: Icons.event_note_outlined,
              label: 'Événements',
              perm: Perm.eventRead,
              session: s,
              onTap: () => context.go('/events'),
            ),
            _DrawerLink(
              icon: Icons.campaign_outlined,
              label: 'Évangélisation',
              perm: Perm.evangelismRead,
              session: s,
              onTap: () => context.go('/evangelism'),
            ),
            _DrawerLink(
              icon: Icons.diversity_3_outlined,
              label: 'Discipleship',
              perm: Perm.discipleshipRead,
              session: s,
              onTap: () => context.go('/discipleship'),
            ),
            _DrawerLink(
              icon: Icons.favorite_outline,
              label: 'Intercession',
              perm: Perm.intercessionRead,
              session: s,
              onTap: () => context.go('/intercession'),
            ),
            _DrawerLink(
              icon: Icons.payments_outlined,
              label: 'Finance',
              perm: Perm.financialContribRead,
              session: s,
              onTap: () => context.go('/finance'),
            ),
            const Divider(height: 32),
            ListTile(
              leading: const Icon(Icons.sync_outlined),
              title: const Text('Synchronisation'),
              onTap: () => context.go('/sync'),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerLink extends StatelessWidget {
  const _DrawerLink({
    required this.icon,
    required this.label,
    required this.perm,
    required this.session,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String perm;
  final AuthSession? session;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    if (session == null || !session!.can(perm)) {
      return const SizedBox.shrink();
    }
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(label),
      onTap: onTap,
    );
  }
}
