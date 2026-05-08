import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/rbac/auth_session.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/register_screen.dart';
import '../features/auth/presentation/activate_screen.dart';
import '../features/onboarding/presentation/splash_screen.dart';
import '../features/onboarding/presentation/standby_screen.dart';
import '../features/home/presentation/home_shell.dart';
import '../features/home/presentation/info_page.dart';
import '../features/bible_club/presentation/bible_club_create_screen.dart';
import '../features/bible_club/presentation/bible_club_detail_screen.dart';
import '../features/bible_club/presentation/bible_club_list_screen.dart';
import '../features/members/presentation/member_detail_screen.dart';
import '../features/members/presentation/members_list_screen.dart';
import '../features/membership/presentation/membership_requests_screen.dart';
import '../features/meetings/presentation/meeting_live_screen.dart';
import '../features/meetings/presentation/meeting_plan_screen.dart';
import '../features/meetings/presentation/meetings_screen.dart';
import '../features/events/presentation/event_detail_screen.dart';
import '../features/events/presentation/event_plan_screen.dart';
import '../features/events/presentation/events_list_screen.dart';
import '../features/evangelism/presentation/evangelism_screen.dart';
import '../features/discipleship/presentation/discipleship_screen.dart';
import '../features/intercession/presentation/intercession_screen.dart';
import '../features/finance/presentation/finance_screen.dart';
import '../features/dashboards/presentation/dashboard_screen.dart';
import '../features/publications/presentation/publications_screen.dart';
import '../features/profile/presentation/profile_screen.dart';

class AppRoutes {
  const AppRoutes._();
  static const splash = '/splash';
  static const login = '/login';
  static const register = '/register';
  static const activate = '/activate';
  static const standby = '/standby';
  static const home = '/';
  static const clubs = '/clubs';
  static const meetings = '/meetings';
  static const publications = '/publications';
  static const profile = '/profile';
}

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: _AuthListenable(ref),
    redirect: (context, state) {
      final session = ref.read(authSessionProvider).valueOrNull;
      final loggedIn = session != null;
      final loc = state.matchedLocation;
      final isAuthRoute = loc == AppRoutes.login ||
          loc == AppRoutes.register ||
          loc == AppRoutes.activate ||
          loc == AppRoutes.splash;

      if (!loggedIn && !isAuthRoute) return AppRoutes.login;
      if (loggedIn && isAuthRoute && loc != AppRoutes.splash) {
        return AppRoutes.home;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(path: AppRoutes.login, builder: (_, __) => const LoginScreen()),
      GoRoute(
        path: AppRoutes.register,
        builder: (_, __) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.activate,
        builder: (_, state) => ActivateScreen(
          token: state.uri.queryParameters['token'] ?? '',
        ),
      ),
      GoRoute(
        path: AppRoutes.standby,
        builder: (_, __) => const StandbyScreen(),
      ),
      GoRoute(
        path: '/members/:id',
        builder: (_, state) =>
            MemberDetailScreen(id: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/clubs/:id/members',
        builder: (_, state) =>
            MembersListScreen(bibleClubId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/membership-requests',
        builder: (_, __) => const MembershipRequestsScreen(),
      ),
      GoRoute(
        path: '/events',
        builder: (_, __) => const EventsListScreen(),
        routes: [
          GoRoute(
            path: 'new',
            builder: (_, __) => const EventPlanScreen(),
          ),
          GoRoute(
            path: ':id',
            builder: (_, state) =>
                EventDetailScreen(id: state.pathParameters['id']!),
          ),
        ],
      ),
      GoRoute(
        path: '/evangelism',
        builder: (_, __) => const EvangelismScreen(),
      ),
      GoRoute(
        path: '/discipleship',
        builder: (_, __) => const DiscipleshipScreen(),
      ),
      GoRoute(
        path: '/intercession',
        builder: (_, __) => const IntercessionScreen(),
      ),
      GoRoute(
        path: '/finance',
        builder: (_, __) => const FinanceScreen(),
      ),
      GoRoute(
        path: '/dashboard/national',
        builder: (_, __) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/dashboard/bbc/:id',
        builder: (_, state) =>
            DashboardScreen(bibleClubId: state.pathParameters['id']),
      ),
      ShellRoute(
        builder: (context, state, child) => HomeShell(child: child),
        routes: [
          GoRoute(path: AppRoutes.home, builder: (_, __) => const InfoPage()),
          GoRoute(
            path: AppRoutes.clubs,
            builder: (_, __) => const BibleClubListScreen(),
            routes: [
              GoRoute(
                path: 'new',
                parentNavigatorKey: null,
                builder: (_, __) => const BibleClubCreateScreen(),
              ),
              GoRoute(
                path: ':id',
                builder: (_, state) =>
                    BibleClubDetailScreen(id: state.pathParameters['id']!),
              ),
            ],
          ),
          GoRoute(
            path: AppRoutes.meetings,
            builder: (_, __) => const MeetingsScreen(),
            routes: [
              GoRoute(
                path: 'new',
                builder: (_, __) => const MeetingPlanScreen(),
              ),
              GoRoute(
                path: ':id',
                builder: (_, state) =>
                    MeetingLiveScreen(id: state.pathParameters['id']!),
              ),
            ],
          ),
          GoRoute(
            path: AppRoutes.publications,
            builder: (_, __) => const PublicationsScreen(),
          ),
          GoRoute(
            path: AppRoutes.profile,
            builder: (_, __) => const ProfileScreen(),
          ),
        ],
      ),
    ],
  );
});

class _AuthListenable extends ChangeNotifier {
  _AuthListenable(this._ref) {
    _ref.listen(authSessionProvider, (_, __) => notifyListeners());
  }
  final Ref _ref;
}
