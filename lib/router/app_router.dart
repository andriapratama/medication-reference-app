import 'package:go_router/go_router.dart';

import '../presentation/favorites/view/favorites_screen.dart';
import '../presentation/medication_detail/view/medication_detail_screen.dart';
import '../presentation/medication_list/view/medication_list_screen.dart';
import 'main_shell.dart';

/// App-wide route configuration with a bottom-nav shell (Medications/Favorites).
final appRouter = GoRouter(
  initialLocation: '/medications',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) => MainShell(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/medications',
              builder: (context, state) => const MedicationListScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
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
      path: '/medications/:id',
      builder: (context, state) =>
          MedicationDetailScreen(id: state.pathParameters['id']!),
    ),
  ],
);
