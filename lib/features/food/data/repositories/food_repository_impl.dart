import '../../domain/entities/food.dart';
import '../../domain/entities/food_filter.dart';
import '../../domain/repositories/food_repository.dart';
import '../datasources/food_local_datasource.dart';
import '../datasources/preferences_local_datasource.dart';
import '../mappers/food_mapper.dart';
import '../models/food_filter_model.dart';

class FoodRepositoryImpl implements FoodRepository {
  FoodRepositoryImpl(this._foods, this._prefs);

  final FoodLocalDataSource _foods;
  final PreferencesLocalDataSource _prefs;

  @override
  Future<List<Food>> getAllFoods() async {
    final models = await _foods.loadFoods();
    return models.map((m) => m.toEntity()).toList(growable: false);
  }

  @override
  Future<void> upsertFood(Food food) async {
    final models = await _foods.loadFoods();
    final next = List<Food>.from(models.map((m) => m.toEntity()));
    final idx = next.indexWhere((f) => f.id == food.id);
    if (idx >= 0) {
      next[idx] = food;
    } else {
      next.add(food);
    }
    await _foods.saveFoods(next.map((e) => e.toModel()).toList());
  }

  @override
  Future<void> deleteFood(String id) async {
    final models = await _foods.loadFoods();
    final next = models.where((m) => m.id != id).toList(growable: false);
    await _foods.saveFoods(next);
  }

  @override
  Future<FoodFilter> getFilter() async {
    final m = await _prefs.loadFilter();
    return m.toEntity();
  }

  @override
  Future<void> saveFilter(FoodFilter filter) async {
    await _prefs.saveFilter(filter.toModel());
  }
}
