import 'package:uuid/uuid.dart';

import '../../domain/entities/meal_category.dart';
import '../models/food_model.dart';

/// Preloaded suggestions when the database is empty.
List<FoodModel> buildDefaultFoodModels() {
  final uuid = Uuid();
  String id() => uuid.v4();

  return [
    FoodModel(
      id: id(),
      name: 'Oatmeal bowl',
      category: MealCategory.breakfast.name,
      tags: const ['healthy', 'quick'],
    ),
    FoodModel(
      id: id(),
      name: 'Eggs & toast',
      category: MealCategory.breakfast.name,
      tags: const ['quick'],
    ),
    FoodModel(
      id: id(),
      name: 'Vegetable salad',
      category: MealCategory.lunch.name,
      tags: const ['healthy'],
    ),
    FoodModel(
      id: id(),
      name: 'Lentil soup',
      category: MealCategory.dinner.name,
      tags: const ['ramadan', 'healthy'],
    ),
    FoodModel(
      id: id(),
      name: 'Grilled chicken',
      category: MealCategory.dinner.name,
      tags: const [],
    ),
    FoodModel(
      id: id(),
      name: 'Pasta',
      category: MealCategory.lunch.name,
      tags: const ['quick'],
    ),
    FoodModel(
      id: id(),
      name: 'Fruit bowl',
      category: MealCategory.breakfast.name,
      tags: const ['healthy', 'ramadan'],
    ),
    FoodModel(
      id: id(),
      name: 'Rice & stew',
      category: MealCategory.dinner.name,
      tags: const ['ramadan'],
    ),
  ];
}
