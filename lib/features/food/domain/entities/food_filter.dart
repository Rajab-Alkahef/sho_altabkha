import 'meal_category.dart';

/// Filters applied before spinning the wheel.
class FoodFilter {
  const FoodFilter({
    this.mealType,
    this.ramadanOnly = false,
    this.dietOnly = false,
    this.favoritesOnly = false,
  });

  /// `null` means all meal types.
  final MealCategory? mealType;
  final bool ramadanOnly;
  final bool dietOnly;
  final bool favoritesOnly;

  FoodFilter copyWith({
    MealCategory? mealType,
    bool? clearMealType,
    bool? ramadanOnly,
    bool? dietOnly,
    bool? favoritesOnly,
  }) {
    return FoodFilter(
      mealType: clearMealType == true ? null : (mealType ?? this.mealType),
      ramadanOnly: ramadanOnly ?? this.ramadanOnly,
      dietOnly: dietOnly ?? this.dietOnly,
      favoritesOnly: favoritesOnly ?? this.favoritesOnly,
    );
  }
}
