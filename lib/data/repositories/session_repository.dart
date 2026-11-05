import '../../core/constants.dart';
import '../../models/exercise.dart';
import '../../models/set_log.dart';
import '../../models/workout_session.dart';
import '../database_helper.dart';

class SetLogDetail {
  final SetLog setLog;
  final Exercise? exercise;

  const SetLogDetail({
    required this.setLog,
    this.exercise,
  });
}

class SessionRepository {
  final DatabaseHelper _dbHelper;

  SessionRepository({DatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? DatabaseHelper();

  Future<int> insertSession(WorkoutSession session) async {
    final db = await _dbHelper.database;
    return await db.insert(
      AppConstants.tableWorkoutSessions,
      session.toMap(),
    );
  }

  Future<int> insertSet(SetLog setLog) async {
    final db = await _dbHelper.database;
    return await db.insert(
      AppConstants.tableSetLogs,
      setLog.toMap(),
    );
  }

  Future<int> updateSet(SetLog setLog) async {
    if (setLog.id == null) {
      throw ArgumentError('SetLog must have an id to update.');
    }
    final db = await _dbHelper.database;
    return await db.update(
      AppConstants.tableSetLogs,
      setLog.toMap(),
      where: 'id = ?',
      whereArgs: [setLog.id],
    );
  }

  Future<int> deleteSet(int setId) async {
    final db = await _dbHelper.database;
    return await db.delete(
      AppConstants.tableSetLogs,
      where: 'id = ?',
      whereArgs: [setId],
    );
  }

  Future<void> finishSession({
    required int sessionId,
    required DateTime endedAt,
    required double totalVolume,
  }) async {
    final db = await _dbHelper.database;
    await db.update(
      AppConstants.tableWorkoutSessions,
      {
        'ended_at': endedAt.toIso8601String(),
        'total_volume': totalVolume,
      },
      where: 'id = ?',
      whereArgs: [sessionId],
    );
  }

  Future<List<WorkoutSession>> findByUser(int userId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      AppConstants.tableWorkoutSessions,
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'started_at DESC',
    );
    return maps.map((m) => WorkoutSession.fromMap(m)).toList();
  }

  /// Retrieves full workout history for a user, including sets and planDayName.
  /// Ordered newest first (started_at DESC).
  Future<List<WorkoutSession>> findHistoryByUser(int userId) async {
    final db = await _dbHelper.database;
    final sessionRows = await db.rawQuery('''
      SELECT s.*, pd.name AS plan_day_name
      FROM ${AppConstants.tableWorkoutSessions} s
      LEFT JOIN ${AppConstants.tablePlanDays} pd ON s.plan_day_id = pd.id
      WHERE s.user_id = ?
      ORDER BY s.started_at DESC
    ''', [userId]);

    final List<WorkoutSession> history = [];
    for (final sRow in sessionRows) {
      final sId = sRow['id'] as int;
      final setRows = await db.query(
        AppConstants.tableSetLogs,
        where: 'session_id = ?',
        whereArgs: [sId],
        orderBy: 'exercise_id ASC, set_index ASC',
      );
      final sets = setRows.map((r) => SetLog.fromMap(r)).toList();
      history.add(
        WorkoutSession.fromMap(
          sRow,
          sets: sets,
          planDayName: sRow['plan_day_name'] as String?,
        ),
      );
    }
    return history;
  }

  /// Retrieves a single workout session by id with its sets and planDayName.
  /// If plan was deleted, planDayName is null (due to ON DELETE SET NULL).
  Future<WorkoutSession?> getFull(int sessionId) async {
    final db = await _dbHelper.database;
    final sessionRows = await db.rawQuery('''
      SELECT s.*, pd.name AS plan_day_name
      FROM ${AppConstants.tableWorkoutSessions} s
      LEFT JOIN ${AppConstants.tablePlanDays} pd ON s.plan_day_id = pd.id
      WHERE s.id = ?
      LIMIT 1
    ''', [sessionId]);

    if (sessionRows.isEmpty) return null;
    final sessionRow = sessionRows.first;

    final setRows = await db.query(
      AppConstants.tableSetLogs,
      where: 'session_id = ?',
      whereArgs: [sessionId],
      orderBy: 'exercise_id ASC, set_index ASC',
    );

    final List<SetLog> sets = setRows.map((r) => SetLog.fromMap(r)).toList();

    return WorkoutSession.fromMap(
      sessionRow,
      sets: sets,
      planDayName: sessionRow['plan_day_name'] as String?,
    );
  }

  Future<int> deleteSession(int sessionId) async {
    final db = await _dbHelper.database;
    return await db.delete(
      AppConstants.tableWorkoutSessions,
      where: 'id = ?',
      whereArgs: [sessionId],
    );
  }
}
