import 'package:equatable/equatable.dart';

import '../../../core/error/failure.dart';
import '../../../domain/entities/medication_detail.dart';

/// States for the medication detail screen.
sealed class MedicationDetailState extends Equatable {
  const MedicationDetailState();

  @override
  List<Object?> get props => [];
}

/// Nothing fetched yet.
class MedicationDetailInitial extends MedicationDetailState {}

/// Detail request is in flight.
class MedicationDetailLoading extends MedicationDetailState {}

/// Detail loaded; [detail.isFavorite] drives the star icon.
class MedicationDetailLoaded extends MedicationDetailState {
  final MedicationDetail detail;

  const MedicationDetailLoaded(this.detail);

  @override
  List<Object?> get props => [detail];
}

/// Detail request failed.
class MedicationDetailError extends MedicationDetailState {
  final Failure failure;

  const MedicationDetailError(this.failure);

  @override
  List<Object?> get props => [failure];
}
