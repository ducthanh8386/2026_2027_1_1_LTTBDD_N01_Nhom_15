import 'package:flutter/foundation.dart';

import '../data/remote/off_api_client.dart';
import '../data/repositories/food_log_repository.dart';
import '../models/food.dart';
import '../models/user.dart';
import '../services/nutrition_service.dart';

class NutritionProvider extends ChangeNotifier {
  final NutritionService _service;
  bool _disposed = false;

  NutritionProvider({NutritionService? service})
      : _service = service ?? NutritionService();

  NutritionService get service => _service;

  int? _userId;
  double? _userKcalTarget;
  DateTime _selectedDate = DateTime.now();

  Map<String, List<FoodLogWithFood>> _entriesByMeal = {
    'breakfast': [],
    'lunch': [],
    'dinner': [],
    'snack': [],
  };

  NutritionTotals _dailyTotals = const NutritionTotals();
  bool _isLoading = false;
  String? _error;

  // Barcode / Food lookup state
  bool _isLookingUp = false;
  Food? _lookupFood;
  OffExceptionType? _lookupErrorType;
  String? _lookupErrorMessage;

  // Getters
  int? get userId => _userId;
  DateTime get selectedDate => _selectedDate;
  String get selectedDateString =>
      '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';

  Map<String, List<FoodLogWithFood>> get entriesByMeal => _entriesByMeal;
  NutritionTotals get dailyTotals => _dailyTotals;
  double get dailyTarget => _userKcalTarget ?? 2000.0;
  double get remainingKcal {
    final rem = dailyTarget - _dailyTotals.kcal;
    return rem < 0 ? 0.0 : rem;
  }

  bool get isLoading => _isLoading;
  String? get error => _error;

  bool get isLookingUp => _isLookingUp;
  Food? get lookupFood => _lookupFood;
  OffExceptionType? get lookupErrorType => _lookupErrorType;
  String? get lookupErrorMessage => _lookupErrorMessage;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_disposed) {
      super.notifyListeners();
    }
  }

  /// Updates authenticated user context and loads food diary for selected date.
  void updateUser(User? user) {
    final newId = user?.id;
    final newTarget = user?.kcalTarget?.toDouble();

    if (_userId != newId || _userKcalTarget != newTarget) {
      _userId = newId;
      _userKcalTarget = newTarget;
      if (_userId != null) {
        loadDiary();
      } else {
        _entriesByMeal = {
          'breakfast': [],
          'lunch': [],
          'dinner': [],
          'snack': [],
        };
        _dailyTotals = const NutritionTotals();
        notifyListeners();
      }
    }
  }

  /// Sets the currently active date and reloads diary data.
  void setDate(DateTime date) {
    _selectedDate = DateTime(date.year, date.month, date.day);
    loadDiary();
  }

  /// Navigates to previous day.
  void previousDay() {
    setDate(_selectedDate.subtract(const Duration(days: 1)));
  }

  /// Navigates to next day.
  void nextDay() {
    setDate(_selectedDate.add(const Duration(days: 1)));
  }

  /// Loads food diary entries and calculates totals for currently selected date.
  Future<void> loadDiary() async {
    if (_userId == null) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final dateStr = selectedDateString;
      final entries = await _service.getDailyEntries(_userId!, dateStr);

      final Map<String, List<FoodLogWithFood>> grouped = {
        'breakfast': [],
        'lunch': [],
        'dinner': [],
        'snack': [],
      };

      for (final item in entries) {
        final meal = item.entry.mealType.toLowerCase();
        if (grouped.containsKey(meal)) {
          grouped[meal]!.add(item);
        } else {
          grouped['snack']!.add(item);
        }
      }

      _entriesByMeal = grouped;
      _dailyTotals = await _service.dailyTotals(_userId!, dateStr);
    } catch (e) {
      _error = 'Lỗi tải nhật ký dinh dưỡng: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Looks up a food product by barcode and sets lookup state.
  Future<Food?> lookupBarcode(String barcode) async {
    _isLookingUp = true;
    _lookupFood = null;
    _lookupErrorType = null;
    _lookupErrorMessage = null;
    notifyListeners();

    try {
      final food = await _service.lookupBarcode(barcode);
      _lookupFood = food;
      return food;
    } on OffApiException catch (e) {
      _lookupErrorType = e.type;
      _lookupErrorMessage = e.message;
      return null;
    } catch (e) {
      _lookupErrorType = OffExceptionType.unknown;
      _lookupErrorMessage = e.toString();
      return null;
    } finally {
      _isLookingUp = false;
      notifyListeners();
    }
  }

  /// Clears current barcode lookup state.
  void clearLookup() {
    _lookupFood = null;
    _lookupErrorType = null;
    _lookupErrorMessage = null;
    _isLookingUp = false;
    notifyListeners();
  }

  /// Adds a food item to user's food diary for selected date.
  Future<void> addFoodEntry({
    required Food food,
    required String mealType,
    required double grams,
  }) async {
    if (_userId == null) {
      throw StateError('Người dùng chưa đăng nhập.');
    }

    await _service.addEntry(
      userId: _userId!,
      food: food,
      mealType: mealType,
      grams: grams,
      date: selectedDateString,
    );

    await loadDiary();
  }

  /// Updates grams of an existing entry.
  Future<void> updateEntryGrams({
    required FoodLogWithFood item,
    required double newGrams,
  }) async {
    if (_userId == null || item.entry.id == null || item.food == null) return;

    await _service.updateEntry(
      entryId: item.entry.id!,
      newGrams: newGrams,
      food: item.food!,
      userId: _userId!,
      mealType: item.entry.mealType,
      date: item.entry.date,
    );

    await loadDiary();
  }

  /// Deletes a food log entry.
  Future<void> deleteEntry(int entryId) async {
    await _service.deleteEntry(entryId);
    await loadDiary();
  }

  /// Creates and saves a manual food item to database.
  Future<Food> createManualFood({
    required String name,
    String? brand,
    required double kcal100g,
    required double protein100g,
    required double carbs100g,
    required double fat100g,
    String? barcode,
    String? imageUrl,
  }) async {
    return await _service.addManualFood(
      name: name,
      brand: brand,
      kcal100g: kcal100g,
      protein100g: protein100g,
      carbs100g: carbs100g,
      fat100g: fat100g,
      barcode: barcode,
      imageUrl: imageUrl,
    );
  }
}
