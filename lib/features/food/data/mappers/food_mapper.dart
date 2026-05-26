import '../../domain/entities/food.dart';
import '../../domain/entities/meal_category.dart';
import '../models/food_model.dart';

extension FoodModelMapper on FoodModel {
  Food toEntity() {
    return Food(
      id: id,
      name: name,
      category: MealCategory.fromKey(category),
      tags: tags,
      imagePath: imagePath,
      isFavorite: isFavorite,
      isRamadan: isRamadan,
      isDiet: isDiet,
      description: description,
      isVisible: isVisible,
    );
  }
}

extension FoodEntityMapper on Food {
  FoodModel toModel() {
    return FoodModel(
      id: id,
      name: name,
      category: category.name,
      tags: tags,
      imagePath: imagePath,
      isFavorite: isFavorite,
      isRamadan: isRamadan,
      isDiet: isDiet,
      description: description,
      isVisible: isVisible,
    );
  }
}
