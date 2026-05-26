import 'dart:io';

import 'package:collection/collection.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/storage/image_storage.dart';
import '../../../food/domain/entities/food.dart';
import '../../../food/domain/entities/meal_category.dart';
import '../../../food/domain/usecases/add_food_usecase.dart';
import '../../../food/presentation/providers/food_providers.dart';

class FoodFormPage extends ConsumerStatefulWidget {
  const FoodFormPage({super.key, this.foodId});

  /// When null, creates a new food.
  final String? foodId;

  @override
  ConsumerState<FoodFormPage> createState() => _FoodFormPageState();
}

class _FoodFormPageState extends ConsumerState<FoodFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _name;
  late TextEditingController _tags;
  late TextEditingController _description;
  MealCategory _category = MealCategory.lunch;
  String? _imagePath;
  String? _initialImagePath;
  bool _removeImage = false;
  bool _isRamadan = false;
  bool _isDiet = false;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController();
    _tags = TextEditingController();
    _description = TextEditingController();
    if (widget.foodId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadExisting());
    } else {
      _loaded = true;
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _tags.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _loadExisting() async {
    if (widget.foodId == null || _loaded) return;
    final foods = await ref.read(foodRepositoryProvider).getAllFoods();
    final f = foods.firstWhereOrNull((e) => e.id == widget.foodId);
    if (f == null || !mounted) return;
    _name.text = f.name;
    _category = f.category;
    _tags.text = f.tags.join(', ');
    _description.text = f.description ?? '';
    _isRamadan = f.isRamadan;
    _isDiet = f.isDiet;
    _imagePath = f.imagePath;
    _initialImagePath = f.imagePath;
    setState(() => _loaded = true);
  }

  Future<void> _pickImage() async {
    final x = await ImagePicker().pickImage(source: ImageSource.gallery);
    final storage = sl<ImageStorage>();
    final previous = _imagePath;
    final path = await storage.persistGalleryImage(x);
    if (!mounted) return;
    if (path != null && previous != null && previous != path) {
      await storage.deleteIfExists(previous);
    }
    setState(() {
      _imagePath = path;
      if (path != null) {
        _initialImagePath = path;
      }
      _removeImage = false;
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final id = widget.foodId ?? Uuid().v4();
    final tagList = _tags.text
        .split(',')
        .map((e) => e.trim().toLowerCase())
        .where((e) => e.isNotEmpty)
        .toList();

    final storage = sl<ImageStorage>();
    if (_removeImage && _initialImagePath != null) {
      await storage.deleteIfExists(_initialImagePath);
    }

    final all = await ref.read(foodRepositoryProvider).getAllFoods();
    final existing = all.firstWhereOrNull((e) => e.id == id);

    final descriptionText = _description.text.trim();

    final food = Food(
      id: id,
      name: _name.text.trim(),
      category: _category,
      tags: tagList,
      imagePath: _removeImage ? null : _imagePath,
      isFavorite: existing?.isFavorite ?? false,
      isRamadan: _isRamadan,
      isDiet: _isDiet,
      description: descriptionText.isEmpty ? null : descriptionText,
      isVisible: existing?.isVisible ?? true,
    );

    await sl<AddFoodUseCase>()(food);
    if (!mounted) return;
    ref.invalidate(foodsProvider);
    ref.invalidate(wheelFoodsProvider);
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.foodId != null;
    if (isEdit && !_loaded) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'edit_food'.tr() : 'add_food'.tr())),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: _name,
              decoration: InputDecoration(labelText: 'name'.tr()),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'validation_name'.tr();
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<MealCategory>(
              value: _category, // ignore: deprecated_member_use
              decoration: InputDecoration(labelText: 'category'.tr()),
              items: MealCategory.values
                  .map(
                    (c) => DropdownMenuItem(
                      value: c,
                      child: Text(_categoryLabel(c)),
                    ),
                  )
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _category = v);
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _description,
              decoration: InputDecoration(
                labelText: 'description'.tr(),
                hintText: 'description_hint'.tr(),
                alignLabelWithHint: true,
              ),
              minLines: 2,
              maxLines: 4,
              textInputAction: TextInputAction.newline,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _tags,
              decoration: InputDecoration(
                labelText: 'tags'.tr(),
                hintText: 'tags_hint'.tr(),
              ),
            ),
            const SizedBox(height: 8),
            CheckboxListTile(
              value: _isRamadan,
              onChanged: (v) => setState(() => _isRamadan = v ?? false),
              title: Text('ramadan_meal'.tr()),
              secondary: const Icon(Icons.nightlight_round),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),
            CheckboxListTile(
              value: _isDiet,
              onChanged: (v) => setState(() => _isDiet = v ?? false),
              title: Text('diet_meal'.tr()),
              secondary: const Icon(Icons.spa_outlined),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Material(
                      borderRadius: BorderRadius.circular(16),
                      color: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                      child:
                          _imagePath != null && File(_imagePath!).existsSync()
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.file(
                                File(_imagePath!),
                                fit: BoxFit.cover,
                              ),
                            )
                          : Center(
                              child: Icon(
                                Icons.image_outlined,
                                size: 48,
                                color: Theme.of(context).colorScheme.outline,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                FilledButton.tonalIcon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.photo_library_outlined),
                  label: Text('pick_image'.tr()),
                ),
                const SizedBox(width: 12),
                if (_imagePath != null)
                  TextButton(
                    onPressed: () => setState(() {
                      _removeImage = true;
                      _imagePath = null;
                    }),
                    child: Text('remove_image'.tr()),
                  ),
              ],
            ),
            const SizedBox(height: 28),
            FilledButton(onPressed: _save, child: Text('save'.tr())),
          ],
        ),
      ),
    );
  }

  String _categoryLabel(MealCategory c) {
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
