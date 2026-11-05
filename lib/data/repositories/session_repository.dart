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

class WorkoutSessionFull {
  final WorkoutSession session;
  final List<SetLogDetail> sets;

  const WorkoutSessionFull({
    required this.session,
    required this.sets,
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

  Future<WorkoutSessionFull?> getFull(int sessionId) async {
    final db = await _dbHelper.database;
    final sessionMaps = await db.query(
      AppConstants.tableWorkoutSessions,
      where: 'id = ?',
      whereArgs: [sessionId],
      limit: 1,
    );

    if (sessionMaps.isEmpty) return null;
    final session = WorkoutSession.fromMap(sessionMaps.first);

    final setRows = await db.rawQuery('''
      SELECT s.*,
             e.source_id AS e_source_id,
             e.name_en AS e_name_en,
             e.name_vi AS e_name_vi,
             e.body_part AS e_body_part,
             e.target AS e_target,
             e.equipment AS e_equipment,
             e.instructions_en AS e_instructions_en,
             e.instructions_vi AS e_instructions_vi,
             e.image_asset AS e_image_asset,
             e.gif_asset AS e_gif_asset
      FROM ${AppConstants.tableSetLogs} s
      LEFT JOIN ${AppConstants.tableExercises} e ON s.exercise_id = e.id
      WHERE s.session_id = ?
      ORDER BY s.exercise_id ASC, s.set_index ASC
    ''', [sessionId]);

    final List<SetLogDetail> setDetails = [];
    for (final row in setRows) {
      final setLog = SetLog.fromMap(row);
      Exercise? exercise;
      if (row['e_source_id'] != null) {
        exercise = Exercise(
          id: row['exercise_id'] as int?,
          sourceId: row['e_source_id'] as String? ?? '',
          nameEn: row['e_name_en'] as String? ?? '',
          nameVi: row['e_name_vi'] as String? ?? '',
          bodyPart: row['e_body_part'] as String? ?? '',
          target: row['e_target'] as String?,
          equipment: row['e_equipment'] as String?,
          instructionsEn: row['e_instructions_en'] as String?,
          instructionsVi: row['e_instructions_vi'] as String?,
          imageAsset: row['e_image_asset'] as String?,
          gifAsset: row['e_gif_asset'] as String?,
        );
      }
      setDetails.add(SetLogDetail(setLog: setLog, exercise: exercise));
    }

    return WorkoutSessionFull(session: session, sets: setDetails);
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
