import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection.dart';
import '../../domain/entities/food.dart';
import '../../domain/entities/food_filter.dart';
import '../../domain/repositories/food_repository.dart';
import '../../domain/usecases/filter_foods_usecase.dart';

final foodRepositoryProvider = Provider<FoodRepository>(
  (ref) => sl<FoodRepository>(),
);

final foodsProvider = FutureProvider<List<Food>>((ref) {
  return ref.watch(foodRepositoryProvider).getAllFoods();
});

class FoodFilterNotifier extends AsyncNotifier<FoodFilter> {
  @override
  Future<FoodFilter> build() async {
    return ref.read(foodRepositoryProvider).getFilter();
  }

  Future<void> setFilter(FoodFilter filter) async {
    state = const AsyncLoading();
    await ref.read(foodRepositoryProvider).saveFilter(filter);
    state = AsyncData(filter);
  }
}

final foodFilterProvider =
    AsyncNotifierProvider<FoodFilterNotifier, FoodFilter>(FoodFilterNotifier.new);

final wheelFoodsProvider = FutureProvider<List<Food>>((ref) async {
  final foods = await ref.watch(foodsProvider.future);
  final filter = await ref.watch(foodFilterProvider.future);
  return sl<FilterFoodsUseCase>()(foods, filter);
});
