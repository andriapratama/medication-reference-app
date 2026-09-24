import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../l10n/app_localizations.dart';

/// Wraps each tab screen with a shared bottom navigation bar.
class MainShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        height: 60,
        indicatorColor: Colors.transparent,
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) =>
            navigationShell.goBranch(index, initialLocation: index == navigationShell.currentIndex),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.medication_outlined),
            selectedIcon: const Icon(Icons.medication),
            label: l10n.bottomNavMedications,
          ),
          NavigationDestination(
            icon: const Icon(Icons.star_border),
            selectedIcon: const Icon(Icons.star),
            label: l10n.bottomNavFavorites,
          ),
        ],
      ),
    );
  }
}
