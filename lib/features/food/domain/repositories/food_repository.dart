import '../entities/food.dart';
import '../entities/food_filter.dart';

abstract class FoodRepository {
  Future<List<Food>> getAllFoods();

  Future<void> upsertFood(Food food);

  Future<void> deleteFood(String id);

  Future<FoodFilter> getFilter();

  Future<void> saveFilter(FoodFilter filter);
}
