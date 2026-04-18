import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../food/domain/entities/food_filter.dart';
import '../../../food/domain/entities/meal_category.dart';
import '../../../food/presentation/providers/food_providers.dart';

Future<void> showFilterSheet(BuildContext context, WidgetRef ref) async {
  final current = await ref.read(foodFilterProvider.future);
  if (!context.mounted) return;

  MealCategory? meal = current.mealType;
  var ramadan = current.ramadanOnly;
  var fav = current.favoritesOnly;

  await showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (ctx) {
      return Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          bottom: MediaQuery.paddingOf(ctx).bottom + 16,
          top: 8,
        ),
        child: StatefulBuilder(
          builder: (context, setLocal) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'filters_title'.tr(),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String?>(
                  value: meal?.name, // ignore: deprecated_member_use
                  decoration: InputDecoration(labelText: 'meal_type'.tr()),
                  items: [
                    DropdownMenuItem(value: null, child: Text('all_meals'.tr())),
                    DropdownMenuItem(
                      value: MealCategory.breakfast.name,
                      child: Text('breakfast'.tr()),
                    ),
                    DropdownMenuItem(
                      value: MealCategory.lunch.name,
                      child: Text('lunch'.tr()),
                    ),
                    DropdownMenuItem(
                      value: MealCategory.dinner.name,
                      child: Text('dinner'.tr()),
                    ),
                  ],
                  onChanged: (v) {
                    setLocal(() {
                      meal = v == null ? null : MealCategory.fromKey(v);
                    });
                  },
                ),
                const SizedBox(height: 8),
                CheckboxListTile(
                  value: ramadan,
                  onChanged: (v) =>
                      setLocal(() => ramadan = v ?? false),
                  title: Text('ramadan_only'.tr()),
                  secondary: const Icon(Icons.nightlight_round),
                  controlAffinity: ListTileControlAffinity.leading,
                ),
                CheckboxListTile(
                  value: fav,
                  onChanged: (v) => setLocal(() => fav = v ?? false),
                  title: Text('favorites_only'.tr()),
                  secondary: const Icon(Icons.star_rounded),
                  controlAffinity: ListTileControlAffinity.leading,
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () async {
                    final next = FoodFilter(
                      mealType: meal,
                      ramadanOnly: ramadan,
                      favoritesOnly: fav,
                    );
                    await ref.read(foodFilterProvider.notifier).setFilter(next);
                    if (ctx.mounted) Navigator.of(ctx).pop();
                  },
                  child: Text('apply'.tr()),
                ),
              ],
            );
          },
        ),
      );
    },
  );
}
