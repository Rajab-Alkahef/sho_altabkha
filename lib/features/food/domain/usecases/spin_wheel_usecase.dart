import 'dart:math';

import '../entities/food.dart';

/// Picks a random winner from the visible wheel list.
class SpinWheelUseCase {
  Food? call(List<Food> candidates) {
    if (candidates.isEmpty) return null;
    final i = Random().nextInt(candidates.length);
    return candidates[i];
  }
}
