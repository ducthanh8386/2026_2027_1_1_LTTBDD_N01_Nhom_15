import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/nutrition_provider.dart';

class ManualFoodScreen extends StatefulWidget {
  final String? initialBarcode;
  final String? initialMealType;

  const ManualFoodScreen({
    super.key,
    this.initialBarcode,
    this.initialMealType,
  });

  @override
  State<ManualFoodScreen> createState() => _ManualFoodScreenState();
}

class _ManualFoodScreenState extends State<ManualFoodScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _brandController;
  late final TextEditingController _barcodeController;
  late final TextEditingController _kcalController;
  late final TextEditingController _proteinController;
  late final TextEditingController _carbsController;
  late final TextEditingController _fatController;
  late final TextEditingController _gramsController;

  late String _selectedMeal;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _selectedMeal = widget.initialMealType ?? 'breakfast';
    _nameController = TextEditingController();
    _brandController = TextEditingController();
    _barcodeController = TextEditingController(text: widget.initialBarcode ?? '');
    _kcalController = TextEditingController();
    _proteinController = TextEditingController();
    _carbsController = TextEditingController();
    _fatController = TextEditingController();
    _gramsController = TextEditingController(text: '100');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _barcodeController.dispose();
    _kcalController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    _gramsController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    final l10n = AppLocalizations.of(context)!;
    final provider = context.read<NutritionProvider>();

    final name = _nameController.text.trim();
    final brand = _brandController.text.trim();
    final barcode = _barcodeController.text.trim();
    final kcal = double.parse(_kcalController.text.replaceAll(',', '.'));
    final protein = double.parse(_proteinController.text.replaceAll(',', '.'));
    final carbs = double.parse(_carbsController.text.replaceAll(',', '.'));
    final fat = double.parse(_fatController.text.replaceAll(',', '.'));
    final grams = double.parse(_gramsController.text.replaceAll(',', '.'));

    try {
      final food = await provider.createManualFood(
        name: name,
        brand: brand.isNotEmpty ? brand : null,
        barcode: barcode.isNotEmpty ? barcode : null,
        kcal100g: kcal,
        protein100g: protein,
        carbs100g: carbs,
        fat100g: fat,
      );

      await provider.addFoodEntry(
        food: food,
        mealType: _selectedMeal,
        grams: grams,
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

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.createManualFood),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Basic Information
              Text(
                'Thông tin cơ bản',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: '${l10n.foodName} *',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.restaurant),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return l10n.fieldRequired;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _brandController,
                decoration: InputDecoration(
                  labelText: l10n.foodBrand,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.business),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _barcodeController,
                decoration: InputDecoration(
                  labelText: l10n.barcodeOptional,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.qr_code),
                ),
              ),

              const SizedBox(height: 24),

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

              const SizedBox(height: 24),

              // Nutrition per 100g
              Text(
                '${l10n.per100g} *',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _kcalController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: '${l10n.nutritionCalories} *',
                        suffixText: 'kcal',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return l10n.fieldRequired;
                        }
                        final p = double.tryParse(val.replaceAll(',', '.'));
                        if (p == null || p < 0) {
                          return l10n.positiveNumberRequired;
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _proteinController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: '${l10n.nutritionProtein} *',
                        suffixText: 'g',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return l10n.fieldRequired;
                        }
                        final p = double.tryParse(val.replaceAll(',', '.'));
                        if (p == null || p < 0) {
                          return l10n.positiveNumberRequired;
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _carbsController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: '${l10n.nutritionCarbs} *',
                        suffixText: 'g',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return l10n.fieldRequired;
                        }
                        final p = double.tryParse(val.replaceAll(',', '.'));
                        if (p == null || p < 0) {
                          return l10n.positiveNumberRequired;
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _fatController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: '${l10n.nutritionFat} *',
                        suffixText: 'g',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return l10n.fieldRequired;
                        }
                        final p = double.tryParse(val.replaceAll(',', '.'));
                        if (p == null || p < 0) {
                          return l10n.positiveNumberRequired;
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Portion Grams
              Text(
                '${l10n.servingSize} *',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
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
                  final p = double.tryParse(val.replaceAll(',', '.'));
                  if (p == null || p <= 0) {
                    return l10n.gramsPositiveRequired;
                  }
                  return null;
                },
              ),

              const SizedBox(height: 32),

              FilledButton.icon(
                onPressed: _isSaving ? null : _submit,
                icon: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save),
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
}
