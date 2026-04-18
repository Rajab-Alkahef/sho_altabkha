/// Meal slot for a food item (Breakfast / Lunch / Dinner).
enum MealCategory {
  breakfast,
  lunch,
  dinner;

  static MealCategory fromKey(String key) {
    for (final c in MealCategory.values) {
      if (c.name == key) return c;
    }
    return MealCategory.lunch;
  }
}
