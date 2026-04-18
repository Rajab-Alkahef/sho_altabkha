/// JSON DTO for persisted foods (offline storage).
class FoodModel {
  const FoodModel({
    required this.id,
    required this.name,
    required this.category,
    this.tags = const [],
    this.imagePath,
    this.isFavorite = false,
  });

  final String id;
  final String name;
  final String category;
  final List<String> tags;
  final String? imagePath;
  final bool isFavorite;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'category': category,
        'tags': tags,
        'imagePath': imagePath,
        'isFavorite': isFavorite,
      };

  factory FoodModel.fromJson(Map<String, dynamic> json) {
    return FoodModel(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      tags: (json['tags'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      imagePath: json['imagePath'] as String?,
      isFavorite: json['isFavorite'] as bool? ?? false,
    );
  }

  FoodModel copyWith({
    String? id,
    String? name,
    String? category,
    List<String>? tags,
    String? imagePath,
    bool? isFavorite,
    bool clearImage = false,
  }) {
    return FoodModel(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      imagePath: clearImage ? null : (imagePath ?? this.imagePath),
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
