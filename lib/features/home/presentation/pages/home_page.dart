import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/theme_mode_provider.dart';
import '../../../food/domain/entities/food.dart';
import '../../../food/domain/entities/food_filter.dart';
import '../../../food/domain/usecases/spin_wheel_usecase.dart';
import '../../../food/presentation/providers/food_providers.dart';
import '../widgets/filter_bottom_sheet.dart';
import '../widgets/fortune_wheel.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final GlobalKey<FortuneWheelState> _wheelKey = GlobalKey<FortuneWheelState>();
  bool _busy = false;

  void _onSpin() {
    final items = ref.read(wheelFoodsProvider).valueOrNull ?? [];
    if (items.isEmpty || _busy) return;
    final winner = sl<SpinWheelUseCase>()(items);
    if (winner == null) return;
    final idx = items.indexWhere((f) => f.id == winner.id);
    if (idx < 0) return;
    _wheelKey.currentState?.spinToWinner(idx);
  }

  bool _hasActiveFilter(FoodFilter f) {
    return f.mealType != null || f.ramadanOnly || f.dietOnly || f.favoritesOnly;
  }

  void _maybeAutoResetFilters() {
    final wheelItems =
        ref.read(wheelFoodsProvider).valueOrNull ?? const <Food>[];
    if (wheelItems.isNotEmpty) return;
    final allFoods = ref.read(foodsProvider).valueOrNull ?? const <Food>[];
    if (allFoods.isEmpty) return;
    final filter = ref.read(foodFilterProvider).valueOrNull;
    if (filter == null || !_hasActiveFilter(filter)) return;

    ref.read(foodFilterProvider.notifier).setFilter(const FoodFilter());
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('filters_reset_message'.tr())));
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<List<Food>>>(wheelFoodsProvider, (prev, next) {
      next.whenData((_) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _maybeAutoResetFilters();
        });
      });
    });

    final wheel = ref.watch(wheelFoodsProvider);

    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;
    ThemeData theme = Theme.of(context);
    TextTheme textTheme = theme.textTheme;
    return Scaffold(
      appBar: AppBar(
        title: Text('app_title'.tr()),
        leading: IconButton(
          tooltip: 'manage_foods'.tr(),
          onPressed: () => context.push(AppRoutes.foods),
          icon: const Icon(Icons.restaurant_menu_rounded),
        ),
        actions: [
          IconButton(
            tooltip: 'language'.tr(),
            onPressed: () {
              final next = context.locale.languageCode == 'en'
                  ? const Locale('ar')
                  : const Locale('en');
              context.setLocale(next);
            },
            icon: const Icon(Icons.language_rounded),
          ),
          // IconButton(
          //   tooltip: isDark ? 'theme_light'.tr() : 'theme_dark'.tr(),
          //   onPressed: () => ref.read(themeModeProvider.notifier).toggle(),
          //   icon: Icon(
          //     isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
          //   ),
          // ),
        ],
      ),
      body: wheel.when(
        data: (items) {
          if (items.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.emoji_food_beverage_outlined,
                      size: 96,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'empty_wheel'.tr(),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: () => context.push(AppRoutes.foods),
                      icon: const Icon(Icons.add),
                      label: Text('add_food'.tr()),
                    ),
                  ],
                ),
              ),
            );
          }
          return Column(
            children: [
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: FortuneWheel(
                      key: _wheelKey,
                      items: items,
                      onSpinStatusChanged: (v) => setState(() => _busy = v),
                      onSpinComplete: (food) {
                        context.push(AppRoutes.result, extra: food);
                      },
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => showFilterSheet(context, ref),
                        icon: const Icon(Icons.tune_rounded),
                        label: Text(
                          'filters'.tr(),
                          style: textTheme.bodyMedium,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: FilledButton.icon(
                        onPressed: _busy ? null : _onSpin,
                        icon: Icon(
                          Icons.casino_rounded,
                          color: theme.colorScheme.onSurface,
                        ),
                        label: Text('spin'.tr(), style: textTheme.bodyLarge),
                        style: FilledButton.styleFrom(
                          backgroundColor: theme.colorScheme.primaryContainer,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
      ),
    );
  }
}
