import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

/// Centered message shown when a request succeeds with no results.
class EmptyStateWidget extends StatelessWidget {
  const EmptyStateWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(AppLocalizations.of(context)!.emptyStateMessage),
    );
  }
}
