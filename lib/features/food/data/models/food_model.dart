/// JSON DTO for persisted foods (offline storage).
class FoodModel {
  const FoodModel({
    required this.id,
    required this.name,
    required this.category,
    this.tags = const [],
    this.imagePath,
    this.isFavorite = false,
    this.isRamadan = false,
    this.isDiet = false,
    this.description,
  });

  final String id;
  final String name;
  final String category;
  final List<String> tags;
  final String? imagePath;
  final bool isFavorite;
  final bool isRamadan;
  final bool isDiet;
  final String? description;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'category': category,
        'tags': tags,
        'imagePath': imagePath,
        'isFavorite': isFavorite,
        'isRamadan': isRamadan,
        'isDiet': isDiet,
        'description': description,
      };

  factory FoodModel.fromJson(Map<String, dynamic> json) {
    final tags = (json['tags'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList() ??
        const <String>[];
    // Backward-compat: older records flagged Ramadan/diet via tags.
    final isRamadan = json['isRamadan'] as bool? ??
        tags.any((t) => t.toLowerCase() == 'ramadan');
    final isDiet = json['isDiet'] as bool? ??
        tags.any((t) => t.toLowerCase() == 'diet');
    return FoodModel(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      tags: tags,
      imagePath: json['imagePath'] as String?,
      isFavorite: json['isFavorite'] as bool? ?? false,
      isRamadan: isRamadan,
      isDiet: isDiet,
      description: json['description'] as String?,
    );
  }

  FoodModel copyWith({
    String? id,
    String? name,
    String? category,
    List<String>? tags,
    String? imagePath,
    bool? isFavorite,
    bool? isRamadan,
    bool? isDiet,
    String? description,
    bool clearImage = false,
    bool clearDescription = false,
  }) {
    return FoodModel(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      imagePath: clearImage ? null : (imagePath ?? this.imagePath),
      isFavorite: isFavorite ?? this.isFavorite,
      isRamadan: isRamadan ?? this.isRamadan,
      isDiet: isDiet ?? this.isDiet,
      description:
          clearDescription ? null : (description ?? this.description),
    );
  }
}
