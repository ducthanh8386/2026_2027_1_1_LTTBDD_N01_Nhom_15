import 'package:sqflite/sqflite.dart';

import '../../core/constants.dart';
import '../../models/food.dart';
import '../database_helper.dart';

class FoodRepository {
  final DatabaseHelper _dbHelper;

  FoodRepository({DatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? DatabaseHelper();

  Future<Food?> findByBarcode(String barcode) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      AppConstants.tableFoods,
      where: 'barcode = ?',
      whereArgs: [barcode.trim()],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return Food.fromMap(maps.first);
    }
    return null;
  }

  Future<Food?> findById(int id) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      AppConstants.tableFoods,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return Food.fromMap(maps.first);
    }
    return null;
  }

  Future<int> insert(Food food) async {
    final db = await _dbHelper.database;
    return await db.insert(
      AppConstants.tableFoods,
      food.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> update(Food food) async {
    if (food.id == null) {
      throw ArgumentError('Food must have an id to update.');
    }
    final db = await _dbHelper.database;
    return await db.update(
      AppConstants.tableFoods,
      food.toMap(),
      where: 'id = ?',
      whereArgs: [food.id],
    );
  }

  Future<List<Food>> search(String query) async {
    final db = await _dbHelper.database;
    final cleanQuery = '%${query.trim().toLowerCase()}%';
    final maps = await db.query(
      AppConstants.tableFoods,
      where: 'LOWER(name) LIKE ? OR LOWER(brand) LIKE ?',
      whereArgs: [cleanQuery, cleanQuery],
      orderBy: 'name ASC',
      limit: 50,
    );
    return maps.map((m) => Food.fromMap(m)).toList();
  }
}
