import 'package:flutter/material.dart';

import '../../core/error/failure.dart';
import '../../l10n/app_localizations.dart';

/// Centered error message with a retry button.
class ErrorStateWidget extends StatelessWidget {
  final Failure failure;
  final VoidCallback onRetry;

  const ErrorStateWidget({super.key, required this.failure, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(failure.localizedMessage(l10n), textAlign: TextAlign.center),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: onRetry,
            child: Text(l10n.errorRetryButton),
          ),
        ],
      ),
    );
  }
}

/// Maps each Failure type to its translated user-facing message.
extension FailureLocalization on Failure {
  String localizedMessage(AppLocalizations l10n) => switch (this) {
    NetworkFailure() => l10n.errorNetwork,
    ServerFailure() => l10n.errorServer,
    RateLimitFailure() => l10n.errorRateLimit,
    InvalidDataFailure() => l10n.errorInvalidData,
    UnknownFailure() => l10n.errorUnknown,
  };
}
