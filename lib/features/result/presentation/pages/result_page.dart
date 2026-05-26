import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../food/domain/entities/food.dart';
import '../../../food/domain/entities/meal_category.dart';

class ResultPage extends StatelessWidget {
  const ResultPage({super.key, required this.food});

  final Food food;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    ThemeData theme = Theme.of(context);
    final textTheme = theme.textTheme;

    final hasImage =
        food.imagePath != null && File(food.imagePath!).existsSync();
    final description = food.description?.trim();
    final hasDescription = description != null && description.isNotEmpty;
    return Scaffold(
      appBar: AppBar(title: Text('result_title'.tr())),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: AspectRatio(
              aspectRatio: 16 / 10,
              child: hasImage
                  ? Image.file(File(food.imagePath!), fit: BoxFit.cover)
                  : ColoredBox(
                      color: scheme.surfaceContainerHighest,
                      child: Icon(
                        Icons.restaurant_rounded,
                        size: 96,
                        color: scheme.outline,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            food.name,
            textAlign: TextAlign.center,
            style: textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              _mealLabel(food.category),
              style: textTheme.titleMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              if (food.isFavorite)
                _Badge(
                  icon: Icons.star_rounded,
                  label: 'favorite'.tr(),
                  background: scheme.tertiaryContainer,
                  foreground: scheme.onTertiaryContainer,
                ),
              if (food.isRamadan)
                _Badge(
                  icon: Icons.nightlight_round,
                  label: 'ramadan_meal'.tr(),
                  background: scheme.secondaryContainer,
                  foreground: scheme.onSecondaryContainer,
                ),
              if (food.isDiet)
                _Badge(
                  icon: Icons.spa_outlined,
                  label: 'diet_meal'.tr(),
                  background: scheme.primaryContainer,
                  foreground: scheme.onPrimaryContainer,
                ),
            ],
          ),
          if (hasDescription) ...[
            const SizedBox(height: 24),
            _SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'description'.tr(),
                    style: textTheme.titleSmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                      letterSpacing: 0.4,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(description, style: textTheme.bodyLarge),
                ],
              ),
            ),
          ],
          if (food.tags.isNotEmpty) ...[
            const SizedBox(height: 16),
            _SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'tags_show'.tr(),
                    style: textTheme.titleSmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                      letterSpacing: 0.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: food.tags
                        .map(
                          (t) => Chip(
                            label: Text(t),
                            visualDensity: VisualDensity.compact,
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 28),
          FilledButton.icon(
            onPressed: () => context.pop(),
            icon: Icon(
              Icons.casino_rounded,
              color: theme.colorScheme.onSurface,
            ),
            label: Text('spin_again'.tr(), style: textTheme.bodyLarge),
            style: FilledButton.styleFrom(
              backgroundColor: theme.colorScheme.primaryContainer,
              padding: const EdgeInsets.symmetric(vertical: 10),
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => context.go(AppRoutes.home),
            child: Text('back_home'.tr()),
          ),
        ],
      ),
    );
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
}

class _Badge extends StatelessWidget {
  const _Badge({
    required this.icon,
    required this.label,
    required this.background,
    required this.foreground,
  });

  final IconData icon;
  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: foreground),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(color: foreground, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }
}
