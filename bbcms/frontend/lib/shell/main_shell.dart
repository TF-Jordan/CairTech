import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/theme/colors.dart';
import '../core/theme/typography.dart';
import '../core/utils/jwt_session.dart';
import '../features/auth/auth_controller.dart';

class MainShell extends ConsumerWidget {
  const MainShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final JwtSession? session = ref.watch(sessionProvider);
    final String loc = GoRouterState.of(context).matchedLocation;
    final List<_Tab> tabs = _tabsFor(session);
    final int idx = tabs.indexWhere((_Tab t) => loc.startsWith(t.path)).clamp(0, tabs.length - 1);

    return Scaffold(
      body: SafeArea(bottom: false, child: child),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: BbcColors.surface,
          border: Border(top: BorderSide(color: BbcColors.hair)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                for (int i = 0; i < tabs.length; i++)
                  Expanded(
                    child: _TabButton(
                      tab: tabs[i],
                      active: i == idx,
                      onTap: () => context.go(tabs[i].path),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<_Tab> _tabsFor(JwtSession? s) {
    final List<_Tab> base = <_Tab>[
      const _Tab(icon: Icons.home_outlined, label: 'Accueil', path: '/home'),
      const _Tab(icon: Icons.event_outlined, label: 'Réunions', path: '/meetings'),
      const _Tab(icon: Icons.people_outline, label: 'Membres', path: '/members'),
      const _Tab(icon: Icons.menu_book_outlined, label: 'Spirituel', path: '/spiritual'),
      const _Tab(icon: Icons.person_outline, label: 'Profil', path: '/profile'),
    ];
    return base;
  }
}

class _Tab {
  const _Tab({required this.icon, required this.label, required this.path});

  final IconData icon;
  final String label;
  final String path;
}

class _TabButton extends StatelessWidget {
  const _TabButton({required this.tab, required this.active, required this.onTap});

  final _Tab tab;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color color = active ? BbcColors.ink : BbcColors.muted2;
    return InkResponse(
      onTap: onTap,
      radius: 36,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(tab.icon, size: 22, color: color),
            const SizedBox(height: 3),
            Text(tab.label,
                style: BbcTypo.sans(size: 10, weight: FontWeight.w500, color: color)),
          ],
        ),
      ),
    );
  }
}
