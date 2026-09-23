import '../../core/utils/result.dart';
import '../entities/medication.dart';
import '../repositories/medication_repository.dart';

/// Lists all favorited medications.
class GetFavorites {
  final MedicationRepository repository;

  const GetFavorites(this.repository);

  Future<Result<List<Medication>>> call() {
    return repository.getFavorites();
  }
}
