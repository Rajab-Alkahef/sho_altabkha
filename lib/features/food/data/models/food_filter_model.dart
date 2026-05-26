import '../../domain/entities/food_filter.dart';
import '../../domain/entities/meal_category.dart';

/// JSON DTO for persisted wheel filters.
class FoodFilterModel {
  const FoodFilterModel({
    this.mealType,
    this.ramadanOnly = false,
    this.dietOnly = false,
    this.favoritesOnly = false,
  });

  final String? mealType;
  final bool ramadanOnly;
  final bool dietOnly;
  final bool favoritesOnly;

  Map<String, dynamic> toJson() => {
        'mealType': mealType,
        'ramadanOnly': ramadanOnly,
        'dietOnly': dietOnly,
        'favoritesOnly': favoritesOnly,
      };

  factory FoodFilterModel.fromJson(Map<String, dynamic> json) {
    return FoodFilterModel(
      mealType: json['mealType'] as String?,
      ramadanOnly: json['ramadanOnly'] as bool? ?? false,
      dietOnly: json['dietOnly'] as bool? ?? false,
      favoritesOnly: json['favoritesOnly'] as bool? ?? false,
    );
  }
}

extension FoodFilterModelMapper on FoodFilterModel {
  FoodFilter toEntity() {
    return FoodFilter(
      mealType: mealType == null ? null : MealCategory.fromKey(mealType!),
      ramadanOnly: ramadanOnly,
      dietOnly: dietOnly,
      favoritesOnly: favoritesOnly,
    );
  }
}

extension FoodFilterEntityMapper on FoodFilter {
  FoodFilterModel toModel() {
    return FoodFilterModel(
      mealType: mealType?.name,
      ramadanOnly: ramadanOnly,
      dietOnly: dietOnly,
      favoritesOnly: favoritesOnly,
    );
  }
}
