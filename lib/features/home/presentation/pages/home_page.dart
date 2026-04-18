import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/router/app_router.dart';
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

  @override
  Widget build(BuildContext context) {
    final wheel = ref.watch(wheelFoodsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('app_title'.tr()),
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
          IconButton(
            tooltip: 'manage_foods'.tr(),
            onPressed: () => context.push(AppRoutes.foods),
            icon: const Icon(Icons.restaurant_menu_rounded),
          ),
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
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => showFilterSheet(context, ref),
                        icon: const Icon(Icons.tune_rounded),
                        label: Text('filters'.tr()),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: FilledButton.icon(
                        onPressed: _busy ? null : _onSpin,
                        icon: const Icon(Icons.casino_rounded),
                        label: Text('spin'.tr()),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
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
