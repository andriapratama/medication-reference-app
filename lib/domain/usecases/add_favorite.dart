import '../../core/utils/result.dart';
import '../entities/medication_detail.dart';
import '../repositories/medication_repository.dart';

/// Saves a medication as a favorite.
class AddFavorite {
  final MedicationRepository repository;

  const AddFavorite(this.repository);

  Future<Result<void>> call(MedicationDetail medication) {
    return repository.addFavorite(medication);
  }
}
