import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/router/app_router.dart';
import '../../../food/domain/entities/food.dart';
import '../../../food/domain/entities/meal_category.dart';
import '../../../food/domain/usecases/delete_food_usecase.dart';
import '../../../food/domain/usecases/toggle_favorite_usecase.dart';
import '../../../food/domain/usecases/toggle_visibility_usecase.dart';
import '../../../food/presentation/providers/food_providers.dart';

class FoodListPage extends ConsumerWidget {
  const FoodListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncFoods = ref.watch(foodsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('food_list_title'.tr()),
      ),
      body: asyncFoods.when(
        data: (foods) {
          if (foods.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.fastfood_outlined,
                      size: 88,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'empty_list'.tr(),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: foods.length,
            separatorBuilder: (context, index) =>
                const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final food = foods[i];
              return _FoodTile(
                food: food,
                onEdit: () async {
                  await context.push('${AppRoutes.foodEdit}/${food.id}');
                  ref.invalidate(foodsProvider);
                  ref.invalidate(wheelFoodsProvider);
                },
                onDelete: () async {
                  await sl<DeleteFoodUseCase>()(food.id);
                  ref.invalidate(foodsProvider);
                  ref.invalidate(wheelFoodsProvider);
                },
                onFavorite: () async {
                  await sl<ToggleFavoriteUseCase>()(food.id);
                  ref.invalidate(foodsProvider);
                  ref.invalidate(wheelFoodsProvider);
                },
                onToggleVisibility: () async {
                  await sl<ToggleVisibilityUseCase>()(food.id);
                  ref.invalidate(foodsProvider);
                  ref.invalidate(wheelFoodsProvider);
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await context.push(AppRoutes.foodNew);
          ref.invalidate(foodsProvider);
          ref.invalidate(wheelFoodsProvider);
        },
        icon: const Icon(Icons.add),
        label: Text('add_food'.tr()),
      ),
    );
  }
}

class _FoodTile extends StatelessWidget {
  const _FoodTile({
    required this.food,
    required this.onEdit,
    required this.onDelete,
    required this.onFavorite,
    required this.onToggleVisibility,
  });

  final Food food;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onFavorite;
  final VoidCallback onToggleVisibility;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tile = Material(
      color: scheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onEdit,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 64,
                  height: 64,
                  child: food.imagePath != null &&
                          File(food.imagePath!).existsSync()
                      ? Image.file(
                          File(food.imagePath!),
                          fit: BoxFit.cover,
                        )
                      : ColoredBox(
                          color: scheme.surfaceContainerHigh,
                          child: Icon(Icons.fastfood, color: scheme.outline),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            food.name,
                            style: Theme.of(context).textTheme.titleMedium,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (!food.isVisible) ...[
                          const SizedBox(width: 6),
                          Icon(
                            Icons.visibility_off_outlined,
                            size: 16,
                            color: scheme.onSurfaceVariant,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _mealLabel(food.category),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                    ),
                    if (food.tags.isNotEmpty)
                      Text(
                        food.tags.join(', '),
                        style: Theme.of(context).textTheme.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              IconButton(
                tooltip: food.isVisible
                    ? 'hide_from_wheel'.tr()
                    : 'show_in_wheel'.tr(),
                onPressed: onToggleVisibility,
                icon: Icon(
                  food.isVisible
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color:
                      food.isVisible ? scheme.primary : scheme.onSurfaceVariant,
                ),
              ),
              IconButton(
                tooltip: 'favorite'.tr(),
                onPressed: onFavorite,
                icon: Icon(
                  food.isFavorite ? Icons.star : Icons.star_border,
                  color: food.isFavorite ? scheme.primary : scheme.outline,
                ),
              ),
              IconButton(
                tooltip: 'delete'.tr(),
                onPressed: () async {
                  final ok = await showDialog<bool>(
                    context: context,
                    builder: (c) => AlertDialog(
                      title: Text('delete'.tr()),
                      content: Text('delete_confirm'.tr()),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(c, false),
                          child: Text('cancel'.tr()),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.pop(c, true),
                          child: Text('delete'.tr()),
                        ),
                      ],
                    ),
                  );
                  if (ok == true && context.mounted) onDelete();
                },
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ),
        ),
      ),
    );

    if (food.isVisible) return tile;
    return Opacity(opacity: 0.55, child: tile);
  }
}

String _mealLabel(MealCategory c) {
  switch (c) {
    case MealCategory.breakfast:
      return 'breakfast'.tr();
    case MealCategory.lunch:
      return 'lunch'.tr();
    case MealCategory.dinner:
      return 'dinner'.tr();
  }
}
