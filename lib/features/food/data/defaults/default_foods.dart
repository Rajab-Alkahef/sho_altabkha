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
      isDiet: true,
      description: 'Warm oats topped with fruit and nuts.',
    ),
    FoodModel(
      id: id(),
      name: 'Eggs & toast',
      category: MealCategory.breakfast.name,
      tags: const ['quick'],
      description: 'Classic breakfast with eggs and toasted bread.',
    ),
    FoodModel(
      id: id(),
      name: 'Vegetable salad',
      category: MealCategory.lunch.name,
      tags: const ['healthy'],
      isDiet: true,
      description: 'Crunchy mixed greens with a light dressing.',
    ),
    FoodModel(
      id: id(),
      name: 'Lentil soup',
      category: MealCategory.dinner.name,
      tags: const ['healthy'],
      isRamadan: true,
      description: 'A staple Ramadan iftar soup, light and filling.',
    ),
    FoodModel(
      id: id(),
      name: 'Grilled chicken',
      category: MealCategory.dinner.name,
      tags: const [],
      isDiet: true,
      description: 'Lean grilled chicken with herbs.',
    ),
    FoodModel(
      id: id(),
      name: 'Pasta',
      category: MealCategory.lunch.name,
      tags: const ['quick'],
      description: 'Pasta with tomato sauce.',
    ),
    FoodModel(
      id: id(),
      name: 'Fruit bowl',
      category: MealCategory.breakfast.name,
      tags: const ['healthy'],
      isRamadan: true,
      isDiet: true,
      description: 'Fresh seasonal fruit, great for suhoor.',
    ),
    FoodModel(
      id: id(),
      name: 'Rice & stew',
      category: MealCategory.dinner.name,
      tags: const [],
      isRamadan: true,
      description: 'Hearty rice with slow-cooked stew.',
    ),
  ];
}
