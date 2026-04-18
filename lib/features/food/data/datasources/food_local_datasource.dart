import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

import '../defaults/default_foods.dart';
import '../models/food_model.dart';

abstract class FoodLocalDataSource {
  Future<List<FoodModel>> loadFoods();

  Future<void> saveFoods(List<FoodModel> foods);
}

class FoodLocalDataSourceImpl implements FoodLocalDataSource {
  FoodLocalDataSourceImpl(this._box);

  final Box<dynamic> _box;

  static const _key = 'foods_json_v1';

  @override
  Future<List<FoodModel>> loadFoods() async {
    final raw = _box.get(_key);
    if (raw == null) {
      final defaults = buildDefaultFoodModels();
      await saveFoods(defaults);
      return defaults;
    }
    final decoded = jsonDecode(raw as String) as List<dynamic>;
    return decoded
        .map((e) => FoodModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  @override
  Future<void> saveFoods(List<FoodModel> foods) async {
    final encoded = jsonEncode(foods.map((e) => e.toJson()).toList());
    await _box.put(_key, encoded);
  }
}
