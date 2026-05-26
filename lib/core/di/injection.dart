import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../features/food/data/datasources/food_local_datasource.dart';
import '../../features/food/data/datasources/preferences_local_datasource.dart';
import '../../features/food/data/repositories/food_repository_impl.dart';
import '../../features/food/domain/repositories/food_repository.dart';
import '../../features/food/domain/usecases/add_food_usecase.dart';
import '../../features/food/domain/usecases/delete_food_usecase.dart';
import '../../features/food/domain/usecases/filter_foods_usecase.dart';
import '../../features/food/domain/usecases/spin_wheel_usecase.dart';
import '../../features/food/domain/usecases/toggle_favorite_usecase.dart';
import '../../features/food/domain/usecases/toggle_visibility_usecase.dart';
import '../storage/image_storage.dart';

final sl = GetIt.instance;

const String kHiveBoxName = 'sho_altabkha_box';

Future<void> configureDependencies() async {
  await Hive.initFlutter();
  final box = await Hive.openBox<dynamic>(kHiveBoxName);

  sl.registerSingleton<Box<dynamic>>(box);

  sl.registerLazySingleton<FoodLocalDataSource>(
    () => FoodLocalDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<PreferencesLocalDataSource>(
    () => PreferencesLocalDataSourceImpl(sl()),
  );

  sl.registerLazySingleton<FoodRepository>(
    () => FoodRepositoryImpl(sl(), sl()),
  );

  sl.registerLazySingleton(() => FilterFoodsUseCase());
  sl.registerLazySingleton(() => SpinWheelUseCase());
  sl.registerLazySingleton(() => AddFoodUseCase(sl()));
  sl.registerLazySingleton(() => DeleteFoodUseCase(sl()));
  sl.registerLazySingleton(() => ToggleFavoriteUseCase(sl()));
  sl.registerLazySingleton(() => ToggleVisibilityUseCase(sl()));
  sl.registerLazySingleton(() => ImageStorage());
}
