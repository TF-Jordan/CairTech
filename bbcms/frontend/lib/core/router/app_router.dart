import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/auth_controller.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/onboarding_screen.dart';
import '../../features/auth/activation_screen.dart';
import '../../features/dashboard/member_dashboard_screen.dart';
import '../../features/dashboard/leader_dashboard_screen.dart';
import '../../features/dashboard/national_dashboard_screen.dart';
import '../../features/meeting/meetings_list_screen.dart';
import '../../features/meeting/meeting_create_screen.dart';
import '../../features/meeting/meeting_attendance_screen.dart';
import '../../features/publication/verse_screen.dart';
import '../../features/intercession/prayer_chain_screen.dart';
import '../../features/finance/finance_screen.dart';
import '../../features/people/members_list_screen.dart';
import '../../features/people/member_detail_screen.dart';
import '../../features/evangelism/evangelism_screen.dart';
import '../../features/discipleship/discipleship_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/admin/admin_overview_screen.dart';
import '../../features/admin/membership_requests_screen.dart';
import '../../features/admin/bible_clubs_admin_screen.dart';
import '../../features/admin/levels_admin_screen.dart';
import '../../features/event/events_screen.dart';
import '../../shell/main_shell.dart';

final GlobalKey<NavigatorState> _rootKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellKey = GlobalKey<NavigatorState>();

final Provider<GoRouter> routerProvider = Provider<GoRouter>((Ref ref) {
  final AuthState auth = ref.watch(authControllerProvider);
  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: '/login',
    refreshListenable: _AuthListenable(ref),
    redirect: (BuildContext context, GoRouterState state) {
      final bool loggedIn = auth.isAuthenticated;
      final String loc = state.matchedLocation;
      final bool atAuth = loc == '/login' ||
          loc.startsWith('/onboarding') ||
          loc.startsWith('/activate');
      if (!loggedIn && !atAuth) return '/login';
      if (loggedIn && atAuth) return '/home';
      return null;
    },
    routes: <RouteBase>[
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/onboarding', builder: (_, __) => const OnboardingScreen()),
      GoRoute(
        path: '/activate',
        builder: (BuildContext c, GoRouterState s) =>
            ActivationScreen(token: s.uri.queryParameters['token']),
      ),

      // Bottom tab shell
      ShellRoute(
        navigatorKey: _shellKey,
        builder: (BuildContext c, GoRouterState s, Widget child) =>
            MainShell(child: child),
        routes: <RouteBase>[
          GoRoute(path: '/home', builder: (_, __) => const MemberDashboardScreen()),
          GoRoute(path: '/meetings', builder: (_, __) => const MeetingsListScreen()),
          GoRoute(path: '/members', builder: (_, __) => const MembersListScreen()),
          GoRoute(path: '/spiritual', builder: (_, __) => const VerseScreen()),
          GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
        ],
      ),

      // Modal full-screen routes
      GoRoute(
        path: '/meetings/new',
        parentNavigatorKey: _rootKey,
        builder: (_, __) => const MeetingCreateScreen(),
      ),
      GoRoute(
        path: '/meetings/:id',
        parentNavigatorKey: _rootKey,
        builder: (BuildContext c, GoRouterState s) =>
            MeetingAttendanceScreen(meetingId: s.pathParameters['id']!),
      ),
      GoRoute(
        path: '/members/:id',
        parentNavigatorKey: _rootKey,
        builder: (BuildContext c, GoRouterState s) =>
            MemberDetailScreen(memberId: s.pathParameters['id']!),
      ),

      // Cross-tab feature routes
      GoRoute(
        path: '/dashboard/leader',
        parentNavigatorKey: _rootKey,
        builder: (_, __) => const LeaderDashboardScreen(),
      ),
      GoRoute(
        path: '/dashboard/national',
        parentNavigatorKey: _rootKey,
        builder: (_, __) => const NationalDashboardScreen(),
      ),
      GoRoute(
        path: '/finance',
        parentNavigatorKey: _rootKey,
        builder: (_, __) => const FinanceScreen(),
      ),
      GoRoute(
        path: '/prayer-chain',
        parentNavigatorKey: _rootKey,
        builder: (_, __) => const PrayerChainScreen(),
      ),
      GoRoute(
        path: '/evangelism',
        parentNavigatorKey: _rootKey,
        builder: (_, __) => const EvangelismScreen(),
      ),
      GoRoute(
        path: '/discipleship',
        parentNavigatorKey: _rootKey,
        builder: (_, __) => const DiscipleshipScreen(),
      ),
      GoRoute(
        path: '/events',
        parentNavigatorKey: _rootKey,
        builder: (_, __) => const EventsScreen(),
      ),

      // Admin (super-admin god-mode)
      GoRoute(
        path: '/admin',
        parentNavigatorKey: _rootKey,
        builder: (_, __) => const AdminOverviewScreen(),
      ),
      GoRoute(
        path: '/admin/membership-requests',
        parentNavigatorKey: _rootKey,
        builder: (_, __) => const MembershipRequestsScreen(),
      ),
      GoRoute(
        path: '/admin/bible-clubs',
        parentNavigatorKey: _rootKey,
        builder: (_, __) => const BibleClubsAdminScreen(),
      ),
      GoRoute(
        path: '/admin/bible-clubs/:id/levels',
        parentNavigatorKey: _rootKey,
        builder: (BuildContext c, GoRouterState s) =>
            LevelsAdminScreen(bibleClubId: s.pathParameters['id']!),
      ),
    ],
  );
});

class _AuthListenable extends ChangeNotifier {
  _AuthListenable(this._ref) {
    _ref.listen<AuthState>(authControllerProvider, (_, __) => notifyListeners());
  }

  final Ref _ref;
}
