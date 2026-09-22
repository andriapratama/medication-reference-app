import '../../core/utils/result.dart';
import '../entities/medication.dart';
import '../entities/medication_detail.dart';

/// Combines the remote (medication data) and local (favorite status) sources.
abstract class MedicationRepository {
  /// Fetches a page of medications for the main list.
  Future<Result<List<Medication>>> getMedications({
    required int limit,
    required int skip,
  });

  /// Fetches a page of medications matching [query].
  Future<Result<List<Medication>>> searchMedications({
    required String query,
    required int limit,
    required int skip,
  });

  /// Fetches full detail for one medication, including favorite status.
  Future<Result<MedicationDetail>> getMedicationDetail(String id);

  /// Lists all favorited medications.
  Future<Result<List<Medication>>> getFavorites();

  /// Saves [medication] as a favorite.
  Future<Result<void>> addFavorite(MedicationDetail medication);

  /// Removes the medication with [id] from favorites.
  Future<Result<void>> removeFavorite(String id);
}
