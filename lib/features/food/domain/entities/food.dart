import 'meal_category.dart';

/// Domain entity for a single food item stored offline.
class Food {
  const Food({
    required this.id,
    required this.name,
    required this.category,
    this.tags = const [],
    this.imagePath,
    this.isFavorite = false,
    this.isRamadan = false,
    this.isDiet = false,
    this.description,
    this.isVisible = true,
  });

  final String id;
  final String name;
  final MealCategory category;
  final List<String> tags;
  final String? imagePath;
  final bool isFavorite;
  final bool isRamadan;
  final bool isDiet;
  final String? description;

  /// When false, the food stays in the user's list but is excluded from the wheel.
  final bool isVisible;

  Food copyWith({
    String? id,
    String? name,
    MealCategory? category,
    List<String>? tags,
    String? imagePath,
    bool? isFavorite,
    bool? isRamadan,
    bool? isDiet,
    String? description,
    bool? isVisible,
    bool clearImage = false,
    bool clearDescription = false,
  }) {
    return Food(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      imagePath: clearImage ? null : (imagePath ?? this.imagePath),
      isFavorite: isFavorite ?? this.isFavorite,
      isRamadan: isRamadan ?? this.isRamadan,
      isDiet: isDiet ?? this.isDiet,
      description: clearDescription ? null : (description ?? this.description),
      isVisible: isVisible ?? this.isVisible,
    );
  }
}
