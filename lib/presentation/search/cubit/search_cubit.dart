import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/utils/debouncer.dart';
import '../../../core/utils/result.dart';
import '../../../domain/usecases/search_medications.dart';
import 'search_state.dart';

/// Debounces query changes so we don't hit the API on every keystroke.
class SearchCubit extends Cubit<SearchState> {
  final SearchMedications searchMedications;
  final Debouncer _debouncer = Debouncer();
  String _lastQuery = '';

  SearchCubit(this.searchMedications) : super(SearchInitial());

  /// Called on every search field change; the actual request is debounced.
  void onQueryChanged(String query) {
    final trimmed = query.trim();
    _lastQuery = trimmed;
    if (trimmed.isEmpty) {
      _debouncer.cancel();
      emit(SearchInitial());
      return;
    }

    emit(SearchLoading());
    _debouncer.run(() => _search(trimmed));
  }

  /// Re-runs the last query immediately, e.g. after tapping "Retry".
  void retry() {
    if (_lastQuery.isEmpty) return;
    emit(SearchLoading());
    _search(_lastQuery);
  }

  Future<void> _search(String query) async {
    final result = await searchMedications(
      query: query,
      limit: ApiConstants.defaultLimit,
      skip: 0,
    );

    // Drop results for an outdated query (user kept typing or cleared the field).
    if (query != _lastQuery) return;

    switch (result) {
      case Ok(value: final items):
        emit(items.isEmpty ? SearchEmpty() : SearchLoaded(items));
      case Err(failure: final failure):
        emit(SearchError(failure));
    }
  }

  @override
  Future<void> close() {
    _debouncer.dispose();
    return super.close();
  }
}
