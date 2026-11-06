import 'package:sqflite/sqflite.dart';

import '../../core/constants.dart';
import '../database_helper.dart';

/// Aggregation SQL data models for stats
class DayVolumeRecord {
  final String date; // YYYY-MM-DD
  final double volume;

  const DayVolumeRecord({required this.date, required this.volume});
}

class MaxWeightRecord {
  final String date; // YYYY-MM-DD
  final double maxWeight;

  const MaxWeightRecord({required this.date, required this.maxWeight});
}

/// StatsRepository owned by Partner B (Module B2/B4).
///
/// Implements aggregate read-only SQL queries with GROUP BY.
class StatsRepository {
  final DatabaseHelper _dbHelper;

  StatsRepository({DatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? DatabaseHelper();

  Future<Database> get _db => _dbHelper.database;

  /// Returns aggregated total workout volume grouped by date (YYYY-MM-DD).
  /// Uses SUM(reps * weight_kg) with join on set_logs, with fallback to total_volume.
  Future<List<DayVolumeRecord>> getVolumeByDateRange({
    required int userId,
    required DateTime from,
    required DateTime to,
  }) async {
    final db = await _db;
    final fromIso = from.toIso8601String();
    final toIso = to.toIso8601String();

    // Query 1: Join set_logs to aggregate actual reps * weight_kg
    final setResults = await db.rawQuery(
      '''
      SELECT substr(s.started_at, 1, 10) as session_date, SUM(l.reps * l.weight_kg) as total_vol
      FROM ${AppConstants.tableWorkoutSessions} s
      INNER JOIN ${AppConstants.tableSetLogs} l ON s.id = l.session_id
      WHERE s.user_id = ? AND s.ended_at IS NOT NULL AND s.started_at >= ? AND s.started_at <= ?
      GROUP BY substr(s.started_at, 1, 10)
      ORDER BY session_date ASC
      ''',
      [userId, fromIso, toIso],
    );

    if (setResults.isNotEmpty) {
      return setResults.map((row) {
        return DayVolumeRecord(
          date: row['session_date'] as String,
          volume: (row['total_vol'] as num?)?.toDouble() ?? 0.0,
        );
      }).toList();
    }

    // Fallback if sets are not present or total_volume was stored directly
    final sessionResults = await db.rawQuery(
      '''
      SELECT substr(started_at, 1, 10) as session_date, SUM(total_volume) as total_vol
      FROM ${AppConstants.tableWorkoutSessions}
      WHERE user_id = ? AND ended_at IS NOT NULL AND started_at >= ? AND started_at <= ?
      GROUP BY substr(started_at, 1, 10)
      ORDER BY session_date ASC
      ''',
      [userId, fromIso, toIso],
    );

    return sessionResults.map((row) {
      return DayVolumeRecord(
        date: row['session_date'] as String,
        volume: (row['total_vol'] as num?)?.toDouble() ?? 0.0,
      );
    }).toList();
  }

  /// Returns max lifted weight for a specific exercise grouped by date.
  Future<List<MaxWeightRecord>> getMaxWeightByExercise({
    required int userId,
    required int exerciseId,
    required DateTime from,
    required DateTime to,
  }) async {
    final db = await _db;
    final fromIso = from.toIso8601String();
    final toIso = to.toIso8601String();

    final results = await db.rawQuery(
      '''
      SELECT substr(s.started_at, 1, 10) as session_date, MAX(l.weight_kg) as max_kg
      FROM ${AppConstants.tableWorkoutSessions} s
      INNER JOIN ${AppConstants.tableSetLogs} l ON s.id = l.session_id
      WHERE s.user_id = ? AND l.exercise_id = ? AND s.ended_at IS NOT NULL
        AND s.started_at >= ? AND s.started_at <= ?
      GROUP BY substr(s.started_at, 1, 10)
      ORDER BY session_date ASC
      ''',
      [userId, exerciseId, fromIso, toIso],
    );

    return results.map((row) {
      return MaxWeightRecord(
        date: row['session_date'] as String,
        maxWeight: (row['max_kg'] as num?)?.toDouble() ?? 0.0,
      );
    }).toList();
  }

  /// Returns the number of completed sessions and total volume for the week starting on [monday].
  Future<Map<String, dynamic>> getWeeklyWorkoutStats({
    required int userId,
    required DateTime monday,
  }) async {
    final db = await _db;
    final mondayIso = DateTime(monday.year, monday.month, monday.day).toIso8601String();

    // Query 1: Join set_logs for volume
    final setResults = await db.rawQuery(
      '''
      SELECT COUNT(DISTINCT s.id) as session_count, SUM(l.reps * l.weight_kg) as total_vol
      FROM ${AppConstants.tableWorkoutSessions} s
      INNER JOIN ${AppConstants.tableSetLogs} l ON s.id = l.session_id
      WHERE s.user_id = ? AND s.ended_at IS NOT NULL AND s.started_at >= ?
      ''',
      [userId, mondayIso],
    );

    if (setResults.isNotEmpty && (setResults.first['session_count'] as int? ?? 0) > 0) {
      final first = setResults.first;
      return {
        'session_count': (first['session_count'] as int?) ?? 0,
        'total_vol': (first['total_vol'] as num?)?.toDouble() ?? 0.0,
      };
    }

    final results = await db.rawQuery(
      '''
      SELECT COUNT(*) as session_count, SUM(total_volume) as total_vol
      FROM ${AppConstants.tableWorkoutSessions}
      WHERE user_id = ? AND ended_at IS NOT NULL AND started_at >= ?
      ''',
      [userId, mondayIso],
    );

    if (results.isEmpty) {
      return {'session_count': 0, 'total_vol': 0.0};
    }

    final first = results.first;
    return {
      'session_count': (first['session_count'] as int?) ?? 0,
      'total_vol': (first['total_vol'] as num?)?.toDouble() ?? 0.0,
    };
  }

  /// Returns total calorie intake from food_log_entries for the week starting on [monday].
  Future<double> getWeeklyTotalKcal({
    required int userId,
    required DateTime monday,
  }) async {
    final db = await _db;
    final y = monday.year.toString().padLeft(4, '0');
    final m = monday.month.toString().padLeft(2, '0');
    final d = monday.day.toString().padLeft(2, '0');
    final mondayDateStr = '$y-$m-$d';

    try {
      final results = await db.rawQuery(
        '''
        SELECT SUM(kcal) as total_kcal
        FROM ${AppConstants.tableFoodLogEntries}
        WHERE user_id = ? AND date >= ?
        ''',
        [userId, mondayDateStr],
      );

      if (results.isEmpty) return 0.0;
      return (results.first['total_kcal'] as num?)?.toDouble() ?? 0.0;
    } catch (_) {
      return 0.0;
    }
  }
}
