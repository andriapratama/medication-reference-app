import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../data/datasources/local/favorite_local_datasource.dart';
import '../../data/datasources/remote/medication_remote_datasource.dart';
import '../../data/models/medication_model.dart';
import '../../data/repositories/medication_repository_impl.dart';
import '../../domain/repositories/medication_repository.dart';
import '../../domain/usecases/add_favorite.dart';
import '../../domain/usecases/get_favorites.dart';
import '../../domain/usecases/get_medication_detail.dart';
import '../../domain/usecases/get_medications.dart';
import '../../domain/usecases/remove_favorite.dart';
import '../../domain/usecases/search_medications.dart';
import '../network/dio_client.dart';

/// Global service locator instance.
final sl = GetIt.instance;

/// Registers every dependency; must be awaited before `runApp`.
Future<void> initDependencies() async {
  await Hive.initFlutter();
  Hive.registerAdapter(MedicationModelAdapter());
  final favoritesBox = await Hive.openBox<MedicationModel>(
    FavoriteLocalDataSourceImpl.boxName,
  );
  sl.registerLazySingleton<Box<MedicationModel>>(() => favoritesBox);

  sl.registerLazySingleton<Dio>(() => DioClient.create());

  sl.registerLazySingleton<MedicationRemoteDataSource>(
    () => MedicationRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<FavoriteLocalDataSource>(
    () => FavoriteLocalDataSourceImpl(sl()),
  );

  sl.registerLazySingleton<MedicationRepository>(
    () => MedicationRepositoryImpl(sl(), sl()),
  );

  sl.registerLazySingleton(() => GetMedications(sl()));
  sl.registerLazySingleton(() => SearchMedications(sl()));
  sl.registerLazySingleton(() => GetMedicationDetail(sl()));
  sl.registerLazySingleton(() => GetFavorites(sl()));
  sl.registerLazySingleton(() => AddFavorite(sl()));
  sl.registerLazySingleton(() => RemoveFavorite(sl()));
}
