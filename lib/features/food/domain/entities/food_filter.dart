import 'meal_category.dart';

/// Filters applied before spinning the wheel.
class FoodFilter {
  const FoodFilter({
    this.mealType,
    this.ramadanOnly = false,
    this.favoritesOnly = false,
  });

  /// `null` means all meal types.
  final MealCategory? mealType;
  final bool ramadanOnly;
  final bool favoritesOnly;

  FoodFilter copyWith({
    MealCategory? mealType,
    bool? clearMealType,
    bool? ramadanOnly,
    bool? favoritesOnly,
  }) {
    return FoodFilter(
      mealType: clearMealType == true ? null : (mealType ?? this.mealType),
      ramadanOnly: ramadanOnly ?? this.ramadanOnly,
      favoritesOnly: favoritesOnly ?? this.favoritesOnly,
    );
  }
}
