import '../repositories/food_repository.dart';

class DeleteFoodUseCase {
  DeleteFoodUseCase(this._repository);

  final FoodRepository _repository;

  Future<void> call(String id) => _repository.deleteFood(id);
}
