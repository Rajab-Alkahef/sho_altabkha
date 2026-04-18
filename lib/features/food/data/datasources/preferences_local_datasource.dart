import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

import '../models/food_filter_model.dart';

abstract class PreferencesLocalDataSource {
  Future<FoodFilterModel> loadFilter();

  Future<void> saveFilter(FoodFilterModel model);
}

class PreferencesLocalDataSourceImpl implements PreferencesLocalDataSource {
  PreferencesLocalDataSourceImpl(this._box);

  final Box<dynamic> _box;

  static const _key = 'filter_json_v1';

  @override
  Future<FoodFilterModel> loadFilter() async {
    final raw = _box.get(_key);
    if (raw == null) return const FoodFilterModel();
    return FoodFilterModel.fromJson(
      jsonDecode(raw as String) as Map<String, dynamic>,
    );
  }

  @override
  Future<void> saveFilter(FoodFilterModel model) async {
    await _box.put(_key, jsonEncode(model.toJson()));
  }
}
