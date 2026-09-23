import 'package:hive/hive.dart';

import '../../models/medication_model.dart';

/// Persists favorited medications in a Hive box, keyed by medication id.
abstract class FavoriteLocalDataSource {
  Future<List<MedicationModel>> getFavorites();
  Future<bool> isFavorite(String id);
  Future<void> addFavorite(MedicationModel medication);
  Future<void> removeFavorite(String id);
}

class FavoriteLocalDataSourceImpl implements FavoriteLocalDataSource {
  static const String boxName = 'favorites_box';

  final Box<MedicationModel> box;

  FavoriteLocalDataSourceImpl(this.box);

  @override
  Future<List<MedicationModel>> getFavorites() async {
    return box.values.toList();
  }

  @override
  Future<bool> isFavorite(String id) async {
    return box.containsKey(id);
  }

  @override
  Future<void> addFavorite(MedicationModel medication) async {
    await box.put(medication.id, medication);
  }

  @override
  Future<void> removeFavorite(String id) async {
    await box.delete(id);
  }
}
