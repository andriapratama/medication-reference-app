import 'package:dio/dio.dart';

import '../../core/constants/api_constants.dart';
import '../../core/error/failure.dart';
import '../../core/utils/result.dart';
import '../../domain/entities/medication.dart';
import '../../domain/entities/medication_detail.dart';
import '../../domain/repositories/medication_repository.dart';
import '../datasources/local/favorite_local_datasource.dart';
import '../datasources/remote/medication_remote_datasource.dart';
import '../models/medication_model.dart';

/// Combines the remote (medication data) and local (favorite status) sources.
class MedicationRepositoryImpl implements MedicationRepository {
  final MedicationRemoteDataSource remoteDataSource;
  final FavoriteLocalDataSource localDataSource;

  MedicationRepositoryImpl(this.remoteDataSource, this.localDataSource);

  @override
  Future<Result<List<Medication>>> getMedications({
    required int limit,
    required int skip,
  }) async {
    try {
      final models = await remoteDataSource.getMedications(
        limit: limit,
        skip: skip,
      );
      return Ok(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Err(_mapException(e));
    }
  }

  @override
  Future<Result<List<Medication>>> searchMedications({
    required String query,
    required int limit,
    required int skip,
  }) async {
    try {
      final models = await remoteDataSource.searchMedications(
        query: query,
        limit: limit,
        skip: skip,
      );
      return Ok(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Err(_mapException(e));
    }
  }

  @override
  Future<Result<MedicationDetail>> getMedicationDetail(String id) async {
    try {
      final model = await remoteDataSource.getMedicationById(id);
      final isFavorite = await localDataSource.isFavorite(model.id);
      return Ok(model.toDetailEntity(isFavorite: isFavorite));
    } catch (e) {
      return Err(_mapException(e));
    }
  }

  @override
  Future<Result<List<Medication>>> getFavorites() async {
    try {
      final models = await localDataSource.getFavorites();
      return Ok(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Err(_mapException(e));
    }
  }

  @override
  Future<Result<void>> addFavorite(MedicationDetail medication) async {
    try {
      await localDataSource.addFavorite(
        MedicationModel.fromDetailEntity(medication),
      );
      return const Ok(null);
    } catch (e) {
      return Err(_mapException(e));
    }
  }

  @override
  Future<Result<void>> removeFavorite(String id) async {
    try {
      await localDataSource.removeFavorite(id);
      return const Ok(null);
    } catch (e) {
      return Err(_mapException(e));
    }
  }

  /// Maps a raw exception into the Failure hierarchy the UI understands.
  Failure _mapException(Object e) {
    if (e is DioException) {
      final statusCode = e.response?.statusCode;
      if (statusCode == ApiConstants.rateLimitStatusCode) {
        return const RateLimitFailure('Too many requests, please try again later.');
      }
      if (statusCode != null && statusCode >= 500) {
        return ServerFailure('Server error ($statusCode).');
      }
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout) {
        return const NetworkFailure('No internet connection.');
      }
      return UnknownFailure(e.message ?? 'Unknown network error.');
    }
    if (e is FormatException) {
      return InvalidDataFailure(e.message);
    }
    return UnknownFailure(e.toString());
  }
}
