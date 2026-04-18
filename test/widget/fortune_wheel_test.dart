import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sho_altabkha/features/food/domain/entities/food.dart';
import 'package:sho_altabkha/features/food/domain/entities/meal_category.dart';
import 'package:sho_altabkha/features/home/presentation/widgets/fortune_wheel.dart';

void main() {
  testWidgets('FortuneWheel paints segments for items', (tester) async {
    final items = [
      Food(id: '1', name: 'One', category: MealCategory.lunch),
      Food(id: '2', name: 'Two', category: MealCategory.lunch),
    ];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FortuneWheel(
            items: items,
            onSpinComplete: (_) {},
          ),
        ),
      ),
    );
    expect(find.byType(FortuneWheel), findsOneWidget);
    expect(find.byType(CustomPaint), findsWidgets);
  });
}
