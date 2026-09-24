import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/utils/result.dart';
import '../../../domain/usecases/get_medications.dart';
import 'medication_list_state.dart';

/// Drives the medication list screen: initial load, refresh, and pagination.
class MedicationListCubit extends Cubit<MedicationListState> {
  final GetMedications getMedications;

  int _skip = 0;
  bool _isFetchingMore = false;

  MedicationListCubit(this.getMedications) : super(MedicationListInitial());

  /// Loads the first page. Used on screen open and pull-to-refresh.
  Future<void> fetchMedications() async {
    emit(MedicationListLoading());
    _skip = 0;

    final result = await getMedications(
      limit: ApiConstants.defaultLimit,
      skip: _skip,
    );

    switch (result) {
      case Ok(value: final items):
        if (items.isEmpty) {
          emit(MedicationListEmpty());
          return;
        }
        _skip += items.length;
        emit(
          MedicationListLoaded(
            items: items,
            hasReachedMax: items.length < ApiConstants.defaultLimit,
          ),
        );
      case Err(failure: final failure):
        emit(MedicationListError(failure));
    }
  }

  /// Loads the next page and appends it to the current list.
  Future<void> fetchMore() async {
    final currentState = state;
    if (currentState is! MedicationListLoaded ||
        currentState.hasReachedMax ||
        currentState.loadMoreError != null ||
        _isFetchingMore) {
      return;
    }

    _isFetchingMore = true;
    final result = await getMedications(
      limit: ApiConstants.defaultLimit,
      skip: _skip,
    );
    _isFetchingMore = false;

    // Ignore a stale page if a refresh replaced the list meanwhile.
    if (!identical(state, currentState)) return;

    switch (result) {
      case Ok(value: final items):
        _skip += items.length;
        emit(
          MedicationListLoaded(
            items: [...currentState.items, ...items],
            hasReachedMax: items.length < ApiConstants.defaultLimit,
          ),
        );
      case Err(failure: final failure):
        emit(
          MedicationListLoaded(
            items: currentState.items,
            hasReachedMax: currentState.hasReachedMax,
            loadMoreError: failure,
          ),
        );
    }
  }

  /// Clears the next-page error and tries loading that page again.
  Future<void> retryFetchMore() async {
    final currentState = state;
    if (currentState is! MedicationListLoaded) return;

    emit(
      MedicationListLoaded(
        items: currentState.items,
        hasReachedMax: currentState.hasReachedMax,
      ),
    );
    await fetchMore();
  }
}
