import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';

/// Placeholder until the full Favorites feature (cubit + Hive-backed list) is built.
class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(title: Text(l10n.favoritesScreenTitle)),
      body: Center(child: Text(l10n.favoritesComingSoon)),
    );
  }
}
