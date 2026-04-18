import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../food/domain/entities/food.dart';

class ResultPage extends StatelessWidget {
  const ResultPage({super.key, required this.food});

  final Food food;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('result_title'.tr()),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: food.imagePath != null &&
                          File(food.imagePath!).existsSync()
                      ? Image.file(
                          File(food.imagePath!),
                          fit: BoxFit.cover,
                        )
                      : ColoredBox(
                          color: scheme.surfaceContainerHighest,
                          child: Icon(
                            Icons.restaurant,
                            size: 96,
                            color: scheme.outline,
                          ),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              food.name,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () {
                context.pop();
              },
              icon: const Icon(Icons.casino_rounded),
              label: Text('spin_again'.tr()),
            ),
            TextButton(
              onPressed: () => context.go(AppRoutes.home),
              child: Text('back_home'.tr()),
            ),
          ],
        ),
      ),
    );
  }
}
