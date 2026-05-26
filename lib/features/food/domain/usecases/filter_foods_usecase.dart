import '../entities/food.dart';
import '../entities/food_filter.dart';

/// Applies UI filters before the wheel is built.
class FilterFoodsUseCase {
  List<Food> call(List<Food> all, FoodFilter filter) {
    var list = List<Food>.from(all);

    if (filter.mealType != null) {
      list = list
          .where((f) => f.category == filter.mealType)
          .toList(growable: false);
    }
    if (filter.favoritesOnly) {
      list = list.where((f) => f.isFavorite).toList(growable: false);
    }
    if (filter.ramadanOnly) {
      list = list.where((f) => f.isRamadan).toList(growable: false);
    }
    if (filter.dietOnly) {
      list = list.where((f) => f.isDiet).toList(growable: false);
    }

    return list;
  }
}
