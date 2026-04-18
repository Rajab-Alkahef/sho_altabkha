import 'package:flutter_test/flutter_test.dart';
import 'package:sho_altabkha/features/food/domain/entities/food.dart';
import 'package:sho_altabkha/features/food/domain/entities/meal_category.dart';
import 'package:sho_altabkha/features/food/domain/usecases/spin_wheel_usecase.dart';

void main() {
  test('SpinWheelUseCase returns null for empty list', () {
    final r = SpinWheelUseCase()(<Food>[]);
    expect(r, isNull);
  });

  test('SpinWheelUseCase returns item from list', () {
    final a = Food(
      id: 'a',
      name: 'A',
      category: MealCategory.lunch,
    );
    final picked = SpinWheelUseCase()([a]);
    expect(picked, isNotNull);
    expect(picked!.id, 'a');
  });
}
