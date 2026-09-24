import 'package:equatable/equatable.dart';

import '../../../core/error/failure.dart';
import '../../../domain/entities/medication.dart';

/// States for the medication list screen.
sealed class MedicationListState extends Equatable {
  const MedicationListState();

  @override
  List<Object?> get props => [];
}

/// Nothing fetched yet.
class MedicationListInitial extends MedicationListState {}

/// A fetch (first page or refresh) is in flight.
class MedicationListLoading extends MedicationListState {}

/// Page(s) loaded successfully.
class MedicationListLoaded extends MedicationListState {
  final List<Medication> items;
  final bool hasReachedMax;
  // Error from loading the next page; existing items stay visible.
  final Failure? loadMoreError;

  const MedicationListLoaded({
    required this.items,
    required this.hasReachedMax,
    this.loadMoreError,
  });

  @override
  List<Object?> get props => [items, hasReachedMax, loadMoreError];
}

/// Fetch succeeded but returned no results.
class MedicationListEmpty extends MedicationListState {}

/// Fetch failed.
class MedicationListError extends MedicationListState {
  final Failure failure;

  const MedicationListError(this.failure);

  @override
  List<Object?> get props => [failure];
}
