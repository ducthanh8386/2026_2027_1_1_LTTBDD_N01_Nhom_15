import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/food.dart';
import '../../providers/nutrition_provider.dart';

class FoodDetailScreen extends StatefulWidget {
  final Food food;
  final String? initialMealType;

  const FoodDetailScreen({
    super.key,
    required this.food,
    this.initialMealType,
  });

  @override
  State<FoodDetailScreen> createState() => _FoodDetailScreenState();
}

class _FoodDetailScreenState extends State<FoodDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _gramsController;
  late final TextEditingController _kcalController;
  late final TextEditingController _proteinController;
  late final TextEditingController _carbsController;
  late final TextEditingController _fatController;

  late String _selectedMeal;
  double _grams = 100.0;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _selectedMeal = widget.initialMealType ?? 'breakfast';
    _gramsController = TextEditingController(text: '100');
    _kcalController = TextEditingController(
      text: widget.food.kcal100g.toStringAsFixed(1),
    );
    _proteinController = TextEditingController(
      text: widget.food.protein100g.toStringAsFixed(1),
    );
    _carbsController = TextEditingController(
      text: widget.food.carbs100g.toStringAsFixed(1),
    );
    _fatController = TextEditingController(
      text: widget.food.fat100g.toStringAsFixed(1),
    );
  }

  @override
  void dispose() {
    _gramsController.dispose();
    _kcalController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    super.dispose();
  }

  double get _currentKcal100g => double.tryParse(_kcalController.text) ?? widget.food.kcal100g;
  double get _currentProtein100g => double.tryParse(_proteinController.text) ?? widget.food.protein100g;
  double get _currentCarbs100g => double.tryParse(_carbsController.text) ?? widget.food.carbs100g;
  double get _currentFat100g => double.tryParse(_fatController.text) ?? widget.food.fat100g;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    final l10n = AppLocalizations.of(context)!;
    final updatedFood = widget.food.copyWith(
      kcal100g: _currentKcal100g,
      protein100g: _currentProtein100g,
      carbs100g: _currentCarbs100g,
      fat100g: _currentFat100g,
    );

    try {
      await context.read<NutritionProvider>().addFoodEntry(
            food: updatedFood,
            mealType: _selectedMeal,
            grams: _grams,
          );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.foodAddedSuccess),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  String _mealLabel(String mealKey, AppLocalizations l10n) {
    switch (mealKey) {
      case 'breakfast':
        return l10n.mealBreakfast;
      case 'lunch':
        return l10n.mealLunch;
      case 'dinner':
        return l10n.mealDinner;
      case 'snack':
      default:
        return l10n.mealSnack;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final ratio = _grams / 100.0;

    final calcKcal = (_currentKcal100g * ratio).toStringAsFixed(1);
    final calcProtein = (_currentProtein100g * ratio).toStringAsFixed(1);
    final calcCarbs = (_currentCarbs100g * ratio).toStringAsFixed(1);
    final calcFat = (_currentFat100g * ratio).toStringAsFixed(1);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.foodDetails),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Food Image & Header Card
              Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      if (widget.food.imageUrl != null &&
                          widget.food.imageUrl!.isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            widget.food.imageUrl!,
                            height: 160,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(
                              Icons.fastfood,
                              size: 80,
                              color: Colors.grey,
                            ),
                          ),
                        )
                      else
                        const Icon(
                          Icons.fastfood_outlined,
                          size: 80,
                          color: Colors.grey,
                        ),
                      const SizedBox(height: 12),
                      Text(
                        widget.food.name,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (widget.food.brand != null &&
                          widget.food.brand!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          widget.food.brand!,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 15,
                          ),
                        ),
                      ],
                      if (widget.food.barcode != null) ...[
                        const SizedBox(height: 8),
                        Chip(
                          avatar: const Icon(Icons.qr_code, size: 16),
                          label: Text(widget.food.barcode!),
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Meal Selection
              Text(
                l10n.selectMeal,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: ['breakfast', 'lunch', 'dinner', 'snack'].map((meal) {
                  final isSelected = _selectedMeal == meal;
                  return ChoiceChip(
                    label: Text(_mealLabel(meal, l10n)),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedMeal = meal;
                        });
                      }
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),

              // Serving Size Input (Grams)
              Text(
                l10n.servingSize,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _gramsController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: l10n.servingSize,
                  suffixText: 'g',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.scale),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return l10n.fieldRequired;
                  }
                  final parsed = double.tryParse(val.replaceAll(',', '.'));
                  if (parsed == null || parsed <= 0) {
                    return l10n.gramsPositiveRequired;
                  }
                  return null;
                },
                onChanged: (val) {
                  final parsed = double.tryParse(val.replaceAll(',', '.'));
                  if (parsed != null && parsed > 0) {
                    setState(() {
                      _grams = parsed;
                    });
                  }
                },
              ),

              const SizedBox(height: 20),

              // Live Calculation Portion Card
              Card(
                color: theme.colorScheme.primaryContainer.withAlpha(80),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dinh dưỡng phần ăn ($_grams g)',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildMacroItem(l10n.nutritionCalories, '$calcKcal kcal', Colors.orange),
                          _buildMacroItem(l10n.nutritionProtein, '$calcProtein g', Colors.blue),
                          _buildMacroItem(l10n.nutritionCarbs, '$calcCarbs g', Colors.green),
                          _buildMacroItem(l10n.nutritionFat, '$calcFat g', Colors.red),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Nutritional Information per 100g (Editable)
              ExpansionTile(
                title: Text(
                  l10n.per100g,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(l10n.nutritionStandardFromOff),
                initiallyExpanded: false,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _kcalController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            labelText: l10n.caloriesPer100g,
                            border: const OutlineInputBorder(),
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _proteinController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            labelText: l10n.proteinPer100g,
                            border: const OutlineInputBorder(),
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _carbsController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            labelText: l10n.carbsPer100g,
                            border: const OutlineInputBorder(),
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _fatController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            labelText: l10n.fatPer100g,
                            border: const OutlineInputBorder(),
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Add to Diary Button
              FilledButton.icon(
                onPressed: _isSaving ? null : _submit,
                icon: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.add_circle_outline),
                label: Text(
                  l10n.addToDiary,
                  style: const TextStyle(fontSize: 16),
                ),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMacroItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }
}
