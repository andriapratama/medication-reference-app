import '../../core/utils/result.dart';
import '../entities/medication.dart';
import '../repositories/medication_repository.dart';

/// Fetches one page of medications for the list screen.
class GetMedications {
  final MedicationRepository repository;

  const GetMedications(this.repository);

  Future<Result<List<Medication>>> call({
    required int limit,
    required int skip,
  }) {
    return repository.getMedications(limit: limit, skip: skip);
  }
}
