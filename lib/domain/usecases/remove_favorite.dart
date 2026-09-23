import '../../core/utils/result.dart';
import '../repositories/medication_repository.dart';

/// Removes a medication from favorites.
class RemoveFavorite {
  final MedicationRepository repository;

  const RemoveFavorite(this.repository);

  Future<Result<void>> call(String id) {
    return repository.removeFavorite(id);
  }
}
