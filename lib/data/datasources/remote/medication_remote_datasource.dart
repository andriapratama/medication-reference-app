import 'package:dio/dio.dart';

import '../../../core/constants/api_constants.dart';
import '../../models/medication_model.dart';

/// Talks to the openFDA API. Throws raw exceptions; the repository maps them.
abstract class MedicationRemoteDataSource {
  Future<List<MedicationModel>> getMedications({
    required int limit,
    required int skip,
  });

  Future<List<MedicationModel>> searchMedications({
    required String query,
    required int limit,
    required int skip,
  });

  Future<MedicationModel> getMedicationById(String id);
}

class MedicationRemoteDataSourceImpl implements MedicationRemoteDataSource {
  final Dio dio;

  MedicationRemoteDataSourceImpl(this.dio);

  @override
  Future<List<MedicationModel>> getMedications({
    required int limit,
    required int skip,
  }) async {
    final response = await dio.get(
      ApiConstants.baseUrl,
      queryParameters: {'limit': limit, 'skip': skip},
    );
    return _parseResults(response.data);
  }

  @override
  Future<List<MedicationModel>> searchMedications({
    required String query,
    required int limit,
    required int skip,
  }) async {
    // Keep only letters/digits so user input can't break the openFDA query syntax.
    final words = query
        .toLowerCase()
        .split(RegExp(r'[^a-z0-9]+'))
        .where((w) => w.isNotEmpty)
        .toList();
    if (words.isEmpty) return [];

    // Prefix match on every word, e.g. "advil liqui" -> (advil* AND liqui*).
    final terms = '(${words.map((w) => '$w*').join(' AND ')})';
    try {
      final response = await dio.get(
        ApiConstants.baseUrl,
        queryParameters: {
          'search': 'openfda.brand_name:$terms '
              'openfda.generic_name:$terms '
              'openfda.substance_name:$terms',
          'limit': limit,
          'skip': skip,
        },
      );
      return _parseResults(response.data);
    } on DioException catch (e) {
      // openFDA answers 404 when nothing matches; treat it as an empty result.
      if (e.response?.statusCode == 404) return [];
      rethrow;
    }
  }

  @override
  Future<MedicationModel> getMedicationById(String id) async {
    final response = await dio.get(
      ApiConstants.baseUrl,
      queryParameters: {'search': 'id:"$id"', 'limit': 1},
    );
    final results = _parseResults(response.data);
    if (results.isEmpty) {
      throw const FormatException('Medication not found');
    }
    return results.first;
  }

  List<MedicationModel> _parseResults(dynamic data) {
    final results = (data as Map<String, dynamic>)['results'] as List?;
    if (results == null) return [];
    return results
        .map((e) => MedicationModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
