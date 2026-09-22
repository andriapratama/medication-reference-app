import 'package:equatable/equatable.dart';

/// Full medication detail shown on the detail screen.
class MedicationDetail extends Equatable {
  final String id;
  final String? brandName;
  final String? genericName;
  final String? manufacturer;

  /// OTC drugs usually fill this field.
  final String? purpose;

  /// Prescription drugs usually fill this field instead of [purpose].
  final String? indicationsAndUsage;
  final String? dosageAndAdministration;
  final String? warnings;
  final List<String> activeIngredients;

  /// Whether this medication is currently in the user's favorites.
  final bool isFavorite;

  const MedicationDetail({
    required this.id,
    this.brandName,
    this.genericName,
    this.manufacturer,
    this.purpose,
    this.indicationsAndUsage,
    this.dosageAndAdministration,
    this.warnings,
    this.activeIngredients = const [],
    this.isFavorite = false,
  });

  @override
  List<Object?> get props => [
    id,
    brandName,
    genericName,
    manufacturer,
    purpose,
    indicationsAndUsage,
    dosageAndAdministration,
    warnings,
    activeIngredients,
    isFavorite,
  ];
}
