import 'package:hive/hive.dart';

import '../../domain/entities/medication.dart';
import '../../domain/entities/medication_detail.dart';

part 'medication_model.g.dart';

/// Data model mapping openFDA JSON to/from the domain entities and Hive.
@HiveType(typeId: 0)
class MedicationModel {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String? brandName;
  @HiveField(2)
  final String? genericName;
  @HiveField(3)
  final String? manufacturer;
  @HiveField(4)
  final String? purpose;
  @HiveField(5)
  final String? indicationsAndUsage;
  @HiveField(6)
  final String? dosageAndAdministration;
  @HiveField(7)
  final String? warnings;
  @HiveField(8)
  final List<String> activeIngredients;

  const MedicationModel({
    required this.id,
    this.brandName,
    this.genericName,
    this.manufacturer,
    this.purpose,
    this.indicationsAndUsage,
    this.dosageAndAdministration,
    this.warnings,
    this.activeIngredients = const [],
  });

  /// Parses one openFDA drug label entry, tolerating missing `openfda` fields.
  factory MedicationModel.fromJson(Map<String, dynamic> json) {
    final openfda = (json['openfda'] as Map?)?.cast<String, dynamic>() ?? {};

    final splId = _firstString(openfda['spl_id']);

    return MedicationModel(
      id: (json['id'] as String?) ?? splId ?? '',
      brandName: _firstString(openfda['brand_name']),
      genericName: _firstString(openfda['generic_name']),
      manufacturer: _firstString(openfda['manufacturer_name']),
      purpose: _firstString(json['purpose']),
      indicationsAndUsage: _firstString(json['indications_and_usage']),
      dosageAndAdministration: _firstString(json['dosage_and_administration']),
      warnings: _firstString(json['warnings']),
      activeIngredients:
          (json['active_ingredient'] as List?)?.whereType<String>().toList() ??
          const [],
    );
  }

  /// openFDA fields are almost always a single-item array of strings.
  static String? _firstString(dynamic value) {
    if (value is List && value.isNotEmpty && value.first is String) {
      return value.first as String;
    }
    return null;
  }

  Medication toEntity() {
    return Medication(
      id: id,
      brandName: brandName,
      genericName: genericName,
      manufacturer: manufacturer,
    );
  }

  MedicationDetail toDetailEntity({bool isFavorite = false}) {
    return MedicationDetail(
      id: id,
      brandName: brandName,
      genericName: genericName,
      manufacturer: manufacturer,
      purpose: purpose,
      indicationsAndUsage: indicationsAndUsage,
      dosageAndAdministration: dosageAndAdministration,
      warnings: warnings,
      activeIngredients: activeIngredients,
      isFavorite: isFavorite,
    );
  }

  /// Builds a model from a detail entity so it can be stored as a favorite.
  factory MedicationModel.fromDetailEntity(MedicationDetail detail) {
    return MedicationModel(
      id: detail.id,
      brandName: detail.brandName,
      genericName: detail.genericName,
      manufacturer: detail.manufacturer,
      purpose: detail.purpose,
      indicationsAndUsage: detail.indicationsAndUsage,
      dosageAndAdministration: detail.dosageAndAdministration,
      warnings: detail.warnings,
      activeIngredients: detail.activeIngredients,
    );
  }
}
