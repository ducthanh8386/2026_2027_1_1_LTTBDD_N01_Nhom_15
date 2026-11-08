import '../data/remote/off_api_client.dart';
import '../data/repositories/food_log_repository.dart';
import '../data/repositories/food_repository.dart';
import '../models/food.dart';
import '../models/food_log_entry.dart';
import '../models/user.dart';

class NutritionService {
  final FoodRepository _foodRepo;
  final FoodLogRepository _foodLogRepo;
  final OffApiClient _offClient;

  NutritionService({
    FoodRepository? foodRepo,
    FoodLogRepository? foodLogRepo,
    OffApiClient? offClient,
  })  : _foodRepo = foodRepo ?? FoodRepository(),
        _foodLogRepo = foodLogRepo ?? FoodLogRepository(),
        _offClient = offClient ?? OffApiClient();

  FoodRepository get foodRepo => _foodRepo;
  FoodLogRepository get foodLogRepo => _foodLogRepo;
  OffApiClient get offClient => _offClient;

  /// Looks up a food product by barcode.
  /// 1. Searches local database first.
  /// 2. If not found locally, queries Open Food Facts API and caches into local DB.
  Future<Food> lookupBarcode(String barcode) async {
    final cleanBarcode = barcode.trim();
    if (cleanBarcode.isEmpty) {
      throw const OffApiException(
        OffExceptionType.notFound,
        'Mã vạch không được để trống',
      );
    }

    // 1. Check local cache
    final localFood = await _foodRepo.findByBarcode(cleanBarcode);
    if (localFood != null) {
      return localFood;
    }

    // 2. Fetch from Open Food Facts API
    final apiFood = await _offClient.fetchProduct(cleanBarcode);

    // 3. Cache into local database
    final newId = await _foodRepo.insert(apiFood);
    return apiFood.copyWith(id: newId);
  }

  /// Adds a manually created food to the local database.
  Future<Food> addManualFood({
    required String name,
    String? brand,
    required double kcal100g,
    required double protein100g,
    required double carbs100g,
    required double fat100g,
    String? barcode,
    String? imageUrl,
  }) async {
    final cleanName = name.trim();
    if (cleanName.isEmpty) {
      throw ArgumentError('Tên thực phẩm không được để trống.');
    }
    if (kcal100g < 0 || protein100g < 0 || carbs100g < 0 || fat100g < 0) {
      throw ArgumentError('Giá trị dinh dưỡng không được là số âm.');
    }

    final food = Food(
      name: cleanName,
      brand: brand?.trim().isEmpty ?? true ? null : brand!.trim(),
      barcode: barcode?.trim().isEmpty ?? true ? null : barcode!.trim(),
      kcal100g: kcal100g,
      protein100g: protein100g,
      carbs100g: carbs100g,
      fat100g: fat100g,
      imageUrl: imageUrl?.trim().isEmpty ?? true ? null : imageUrl!.trim(),
      source: 'manual',
    );

    final id = await _foodRepo.insert(food);
    return food.copyWith(id: id);
  }

  /// Adds a food log entry to the user's food diary.
  /// Validates grams > 0 and calculates macros: (value_100g * grams / 100).
  Future<FoodLogEntry> addEntry({
    required int userId,
    required Food food,
    required String mealType,
    required double grams,
    required String date,
  }) async {
    if (grams <= 0) {
      throw ArgumentError('Khối lượng gram phải lớn hơn 0.');
    }

    int foodId = food.id ?? 0;
    if (foodId <= 0) {
      foodId = await _foodRepo.insert(food);
    }

    final ratio = grams / 100.0;
    final kcal = (food.kcal100g * ratio * 10).roundToDouble() / 10;
    final protein = (food.protein100g * ratio * 10).roundToDouble() / 10;
    final carbs = (food.carbs100g * ratio * 10).roundToDouble() / 10;
    final fat = (food.fat100g * ratio * 10).roundToDouble() / 10;

    final entry = FoodLogEntry(
      userId: userId,
      foodId: foodId,
      date: date,
      mealType: mealType,
      grams: grams,
      kcal: kcal,
      protein: protein,
      carbs: carbs,
      fat: fat,
    );

    final id = await _foodLogRepo.insert(entry);
    return entry.copyWith(id: id);
  }

  /// Updates grams and recalculates macros for an existing food log entry.
  Future<void> updateEntry({
    required int entryId,
    required double newGrams,
    required Food food,
    required int userId,
    required String mealType,
    required String date,
  }) async {
    if (newGrams <= 0) {
      throw ArgumentError('Khối lượng gram phải lớn hơn 0.');
    }

    final ratio = newGrams / 100.0;
    final kcal = (food.kcal100g * ratio * 10).roundToDouble() / 10;
    final protein = (food.protein100g * ratio * 10).roundToDouble() / 10;
    final carbs = (food.carbs100g * ratio * 10).roundToDouble() / 10;
    final fat = (food.fat100g * ratio * 10).roundToDouble() / 10;

    final updated = FoodLogEntry(
      id: entryId,
      userId: userId,
      foodId: food.id!,
      date: date,
      mealType: mealType,
      grams: newGrams,
      kcal: kcal,
      protein: protein,
      carbs: carbs,
      fat: fat,
    );

    await _foodLogRepo.update(updated);
  }

  /// Deletes a food log entry by id.
  Future<void> deleteEntry(int id) async {
    await _foodLogRepo.delete(id);
  }

  /// Returns all food log entries with associated Food for a given user and date.
  Future<List<FoodLogWithFood>> getDailyEntries(int userId, String date) async {
    return await _foodLogRepo.findByDate(userId, date);
  }

  /// Calculates total calories and macronutrients for a given user and date.
  Future<NutritionTotals> dailyTotals(int userId, String date) async {
    return await _foodLogRepo.totalsByDate(userId, date);
  }

  /// Returns user's daily calorie target from profile, or default 2000 kcal.
  double getDailyTarget(User? user) {
    if (user != null && user.kcalTarget != null && user.kcalTarget! > 0) {
      return user.kcalTarget!.toDouble();
    }
    return 2000.0;
  }
}
