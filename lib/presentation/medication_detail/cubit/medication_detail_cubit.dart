import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils/result.dart';
import '../../../domain/usecases/add_favorite.dart';
import '../../../domain/usecases/get_medication_detail.dart';
import '../../../domain/usecases/remove_favorite.dart';
import 'medication_detail_state.dart';

/// Loads one medication's detail and toggles its favorite status.
class MedicationDetailCubit extends Cubit<MedicationDetailState> {
  final GetMedicationDetail getMedicationDetail;
  final AddFavorite addFavorite;
  final RemoveFavorite removeFavorite;

  // Ignores extra star taps while a save/remove is still running.
  bool _isTogglingFavorite = false;

  MedicationDetailCubit({
    required this.getMedicationDetail,
    required this.addFavorite,
    required this.removeFavorite,
  }) : super(MedicationDetailInitial());

  /// Fetches the detail for [id]. Used on screen open and on Retry.
  Future<void> fetchDetail(String id) async {
    emit(MedicationDetailLoading());

    final result = await getMedicationDetail(id);
    // The user may have left the screen while the request was running.
    if (isClosed) return;

    switch (result) {
      case Ok(value: final detail):
        emit(MedicationDetailLoaded(detail));
      case Err(failure: final failure):
        emit(MedicationDetailError(failure));
    }
  }

  /// Flips the favorite flag immediately, then persists it; reverts if saving fails.
  Future<void> toggleFavorite() async {
    final currentState = state;
    if (currentState is! MedicationDetailLoaded || _isTogglingFavorite) return;

    _isTogglingFavorite = true;
    final original = currentState.detail;
    final updated = original.copyWith(isFavorite: !original.isFavorite);
    emit(MedicationDetailLoaded(updated));

    final result = original.isFavorite
        ? await removeFavorite(original.id)
        : await addFavorite(updated);
    _isTogglingFavorite = false;
    if (isClosed) return;

    if (result is Err) {
      emit(MedicationDetailLoaded(original));
    }
  }
}
