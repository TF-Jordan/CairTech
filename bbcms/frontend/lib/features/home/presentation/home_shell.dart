import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../core/theme/app_colors.dart';

class HomeShell extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final loc = GoRouterState.of(context).matchedLocation;
    final idx = _indexFor(loc);
    return Scaffold(
      body: child,
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
