import '../entities/food.dart';
import '../repositories/food_repository.dart';

class AddFoodUseCase {
  AddFoodUseCase(this._repository);

  final FoodRepository _repository;

  Future<void> call(Food food) => _repository.upsertFood(food);
}
