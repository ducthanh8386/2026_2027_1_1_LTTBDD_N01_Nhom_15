import 'package:sqflite/sqflite.dart';

import '../../core/constants.dart';
import '../../models/weight_entry.dart';
import '../database_helper.dart';

/// WeightRepository owned by Partner B (Module B2).
///
/// Handles CRUD operations for weight entries with upsert support
/// on UNIQUE(user_id, date).
class WeightRepository {
  final DatabaseHelper _dbHelper;

  WeightRepository({DatabaseHelper? dbHelper})
    : _dbHelper = dbHelper ?? DatabaseHelper();

  Future<Database> get _db => _dbHelper.database;

  Future<void> upsert(WeightEntry entry) async {
    final db = await _db;
    await db.insert(
      AppConstants.tableWeightEntries,
      entry.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<WeightEntry>> findRange(
    int userId,
    DateTime from,
    DateTime to,
  ) async {
    final db = await _db;
    final fromStr = _formatDate(from);
    final toStr = _formatDate(to);

    final results = await db.query(
      AppConstants.tableWeightEntries,
      where: 'user_id = ? AND date >= ? AND date <= ?',
      whereArgs: [userId, fromStr, toStr],
      orderBy: 'date ASC',
    );

    return results.map((m) => WeightEntry.fromMap(m)).toList();
  }

  Future<WeightEntry?> latest(int userId) async {
    final db = await _db;
    final results = await db.query(
      AppConstants.tableWeightEntries,
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'date DESC, id DESC',
      limit: 1,
    );

    if (results.isEmpty) return null;
    return WeightEntry.fromMap(results.first);
  }

  Future<int> delete(int id) async {
    final db = await _db;
    return await db.delete(
      AppConstants.tableWeightEntries,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteByUserAndDate(int userId, String date) async {
    final db = await _db;
    return await db.delete(
      AppConstants.tableWeightEntries,
      where: 'user_id = ? AND date = ?',
      whereArgs: [userId, date],
    );
  }

  static String _formatDate(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}
