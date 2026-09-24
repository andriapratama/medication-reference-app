import 'package:equatable/equatable.dart';

enum MedicationType { otc, prescription }

/// Full medication detail shown on the detail screen.
class MedicationDetail extends Equatable {
  final String id;
  final String? brandName;
  final String? genericName;
  final String? manufacturer;
  final MedicationType? type;

  /// OTC drugs usually fill this field.
  final String? purpose;

  /// Prescription drugs usually fill this field instead of [purpose].
  final String? indicationsAndUsage;
  final String? dosageAndAdministration;
  final String? warnings;
  final List<String> activeIngredients;
  final List<String> inactiveIngredients;

  /// Whether this medication is currently in the user's favorites.
  final bool isFavorite;

  const MedicationDetail({
    required this.id,
    this.brandName,
    this.genericName,
    this.manufacturer,
    this.type,
    this.purpose,
    this.indicationsAndUsage,
    this.dosageAndAdministration,
    this.warnings,
    this.activeIngredients = const [],
    this.inactiveIngredients = const [],
    this.isFavorite = false,
  });

  /// Returns a copy with a different favorite status (used after toggling).
  MedicationDetail copyWith({bool? isFavorite}) {
    return MedicationDetail(
      id: id,
      brandName: brandName,
      genericName: genericName,
      manufacturer: manufacturer,
      type: type,
      purpose: purpose,
      indicationsAndUsage: indicationsAndUsage,
      dosageAndAdministration: dosageAndAdministration,
      warnings: warnings,
      activeIngredients: activeIngredients,
      inactiveIngredients: inactiveIngredients,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  @override
  List<Object?> get props => [
    id,
    brandName,
    genericName,
    manufacturer,
    type,
    purpose,
    indicationsAndUsage,
    dosageAndAdministration,
    warnings,
    activeIngredients,
    inactiveIngredients,
    isFavorite,
  ];
}
