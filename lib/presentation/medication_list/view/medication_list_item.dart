import 'package:flutter/material.dart';

import '../../../domain/entities/medication.dart';
import '../../../l10n/app_localizations.dart';

/// One row in the medication list.
class MedicationListItem extends StatelessWidget {
  final Medication medication;
  final VoidCallback onTap;

  const MedicationListItem({
    super.key,
    required this.medication,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final hasBrandName = medication.brandName != null;

    final nameStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.bold,
      fontStyle: hasBrandName ? FontStyle.normal : FontStyle.italic,
      color: hasBrandName ? null : Colors.grey.shade600,
    );
    final subtitleStyle = TextStyle(color: Colors.grey.shade600);
    final manufacturerStyle = TextStyle(
      color: Colors.grey.shade500,
      fontSize: 12,
      fontStyle: medication.manufacturer != null
          ? FontStyle.normal
          : FontStyle.italic,
    );

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      title: Text(
        medication.brandName ?? l10n.medicationNameUnavailable,
        style: nameStyle,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          // Skip the generic line when missing so the placeholder isn't shown twice.
          if (medication.genericName != null)
            Text(medication.genericName!, style: subtitleStyle),
          Text(
            medication.manufacturer ?? l10n.manufacturerUnavailable,
            style: manufacturerStyle,
          ),
        ],
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }
}
