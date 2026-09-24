import 'package:equatable/equatable.dart';

import '../../../core/error/failure.dart';
import '../../../domain/entities/medication.dart';

/// States for the search bar embedded in the medication list screen.
sealed class SearchState extends Equatable {
  const SearchState();

  @override
  List<Object?> get props => [];
}

/// Query is empty; the normal medication list should be shown instead.
class SearchInitial extends SearchState {}

/// A debounced search request is in flight.
class SearchLoading extends SearchState {}

/// Search succeeded with results.
class SearchLoaded extends SearchState {
  final List<Medication> items;

  const SearchLoaded(this.items);

  @override
  List<Object?> get props => [items];
}

/// Search succeeded but returned no results.
class SearchEmpty extends SearchState {}

/// Search failed.
class SearchError extends SearchState {
  final Failure failure;

  const SearchError(this.failure);

  @override
  List<Object?> get props => [failure];
}
