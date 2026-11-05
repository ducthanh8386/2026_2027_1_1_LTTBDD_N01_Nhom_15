import '../../core/constants.dart';
import '../../models/food.dart';
import '../../models/food_log_entry.dart';
import '../database_helper.dart';

class NutritionTotals {
  final double kcal;
  final double protein;
  final double carbs;
  final double fat;

  const NutritionTotals({
    this.kcal = 0.0,
    this.protein = 0.0,
    this.carbs = 0.0,
    this.fat = 0.0,
  });

  @override
  String toString() {
    return 'NutritionTotals(kcal: $kcal, protein: $protein, carbs: $carbs, fat: $fat)';
  }
}

class FoodLogWithFood {
  final FoodLogEntry entry;
  final Food? food;

  const FoodLogWithFood({
    required this.entry,
    this.food,
  });
}

class FoodLogRepository {
  final DatabaseHelper _dbHelper;

  FoodLogRepository({DatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? DatabaseHelper();

  Future<int> insert(FoodLogEntry entry) async {
    final db = await _dbHelper.database;
    return await db.insert(
      AppConstants.tableFoodLogEntries,
      entry.toMap(),
    );
  }

  Future<int> update(FoodLogEntry entry) async {
    if (entry.id == null) {
      throw ArgumentError('FoodLogEntry must have an id to update.');
    }
    final db = await _dbHelper.database;
    return await db.update(
      AppConstants.tableFoodLogEntries,
      entry.toMap(),
      where: 'id = ?',
      whereArgs: [entry.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      AppConstants.tableFoodLogEntries,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<FoodLogWithFood>> findByDate(int userId, String date) async {
    final db = await _dbHelper.database;
    final rows = await db.rawQuery('''
      SELECT fle.*,
             f.barcode AS f_barcode,
             f.name AS f_name,
             f.brand AS f_brand,
             f.kcal_100g AS f_kcal_100g,
             f.protein_100g AS f_protein_100g,
             f.carbs_100g AS f_carbs_100g,
             f.fat_100g AS f_fat_100g,
             f.image_url AS f_image_url,
             f.source AS f_source
      FROM ${AppConstants.tableFoodLogEntries} fle
      LEFT JOIN ${AppConstants.tableFoods} f ON fle.food_id = f.id
      WHERE fle.user_id = ? AND fle.date = ?
      ORDER BY fle.id ASC
    ''', [userId, date]);

    final List<FoodLogWithFood> results = [];
    for (final row in rows) {
      final entry = FoodLogEntry.fromMap(row);
      Food? food;
      if (row['f_name'] != null) {
        food = Food(
          id: row['food_id'] as int?,
          barcode: row['f_barcode'] as String?,
          name: row['f_name'] as String? ?? '',
          brand: row['f_brand'] as String?,
          kcal100g: (row['f_kcal_100g'] as num?)?.toDouble() ?? 0.0,
          protein100g: (row['f_protein_100g'] as num?)?.toDouble() ?? 0.0,
          carbs100g: (row['f_carbs_100g'] as num?)?.toDouble() ?? 0.0,
          fat100g: (row['f_fat_100g'] as num?)?.toDouble() ?? 0.0,
          imageUrl: row['f_image_url'] as String?,
          source: row['f_source'] as String? ?? 'manual',
        );
      }
      results.add(FoodLogWithFood(entry: entry, food: food));
    }
    return results;
  }

  Future<NutritionTotals> totalsByDate(int userId, String date) async {
    final db = await _dbHelper.database;
    final rows = await db.rawQuery('''
      SELECT COALESCE(SUM(kcal), 0.0) AS total_kcal,
             COALESCE(SUM(protein), 0.0) AS total_protein,
             COALESCE(SUM(carbs), 0.0) AS total_carbs,
             COALESCE(SUM(fat), 0.0) AS total_fat
      FROM ${AppConstants.tableFoodLogEntries}
      WHERE user_id = ? AND date = ?
    ''', [userId, date]);

    if (rows.isNotEmpty) {
      final row = rows.first;
      return NutritionTotals(
        kcal: (row['total_kcal'] as num?)?.toDouble() ?? 0.0,
        protein: (row['total_protein'] as num?)?.toDouble() ?? 0.0,
        carbs: (row['total_carbs'] as num?)?.toDouble() ?? 0.0,
        fat: (row['total_fat'] as num?)?.toDouble() ?? 0.0,
      );
    }
    return const NutritionTotals();
  }
}
