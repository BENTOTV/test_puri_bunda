import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../data/models/medication_summary.dart';
import '../features/detail/view/detail_screen.dart';
import '../features/favorites/view/favorites_screen.dart';
import '../features/medications/view/list_screen.dart';
import 'app_shell.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();
final _medicationsNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'medications',
);
final _favoritesNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'favorites',
);

/// Two tabs, each keeping its own navigation stack and scroll position via
/// [StatefulShellRoute]; the detail screen pushes over the root navigator
/// so the tab bar hides while it's open, but pops back to whichever tab
/// opened it.
GoRouter buildAppRouter() {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/medications',
    routes: [
      StatefulShellRoute.indexedStack(
        builder:
            (context, state, navigationShell) =>
                AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            navigatorKey: _medicationsNavigatorKey,
            routes: [
              GoRoute(
                path: '/medications',
                builder: (context, state) => const ListScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _favoritesNavigatorKey,
            routes: [
              GoRoute(
                path: '/favorites',
                builder: (context, state) => const FavoritesScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/medication/:setId',
        parentNavigatorKey: rootNavigatorKey,
        builder:
            (context, state) => DetailScreen(
              setId: state.pathParameters['setId']!,
              seed: state.extra as MedicationSummary?,
            ),
      ),
    ],
  );
}
