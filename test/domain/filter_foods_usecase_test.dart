import 'package:flutter_test/flutter_test.dart';
import 'package:sho_altabkha/features/food/domain/entities/food.dart';
import 'package:sho_altabkha/features/food/domain/entities/food_filter.dart';
import 'package:sho_altabkha/features/food/domain/entities/meal_category.dart';
import 'package:sho_altabkha/features/food/domain/usecases/filter_foods_usecase.dart';

void main() {
  final foods = [
    Food(
      id: '1',
      name: 'Eggs',
      category: MealCategory.breakfast,
      tags: const ['ramadan'],
    ),
    Food(
      id: '2',
      name: 'Pasta',
      category: MealCategory.lunch,
      tags: const ['quick'],
      isFavorite: true,
    ),
    Food(
      id: '3',
      name: 'Soup',
      category: MealCategory.dinner,
      tags: const ['ramadan', 'healthy'],
    ),
  ];

  test('FilterFoodsUseCase keeps all when filter is empty', () {
    final out = FilterFoodsUseCase()(foods, const FoodFilter());
    expect(out.length, 3);
  });

  test('FilterFoodsUseCase filters meal type', () {
    final out = FilterFoodsUseCase()(
      foods,
      const FoodFilter(mealType: MealCategory.lunch),
    );
    expect(out.length, 1);
    expect(out.single.name, 'Pasta');
  });

  test('FilterFoodsUseCase filters favorites', () {
    final out = FilterFoodsUseCase()(
      foods,
      const FoodFilter(favoritesOnly: true),
    );
    expect(out.length, 1);
    expect(out.single.name, 'Pasta');
  });

  test('FilterFoodsUseCase filters ramadan tag', () {
    final out = FilterFoodsUseCase()(
      foods,
      const FoodFilter(ramadanOnly: true),
    );
    expect(out.length, 2);
  });
}
