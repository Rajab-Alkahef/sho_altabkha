import '../repositories/food_repository.dart';

class ToggleFavoriteUseCase {
  ToggleFavoriteUseCase(this._repository);

  final FoodRepository _repository;

  Future<void> call(String id) async {
    final all = await _repository.getAllFoods();
    final food = all.firstWhere((f) => f.id == id);
    await _repository.upsertFood(food.copyWith(isFavorite: !food.isFavorite));
  }
}
