import '../../core/constants.dart';
import '../../models/exercise.dart';
import '../../models/plan_day.dart';
import '../../models/plan_exercise.dart';
import '../../models/workout_plan.dart';
import '../database_helper.dart';

class PlanExerciseDetail {
  final PlanExercise planExercise;
  final Exercise? exercise;

  const PlanExerciseDetail({
    required this.planExercise,
    this.exercise,
  });
}

class PlanDayFull {
  final PlanDay day;
  final List<PlanExerciseDetail> exercises;

  const PlanDayFull({
    required this.day,
    required this.exercises,
  });
}

class WorkoutPlanFull {
  final WorkoutPlan plan;
  final List<PlanDayFull> days;

  const WorkoutPlanFull({
    required this.plan,
    required this.days,
  });
}

/// Input helper for creating/updating a full plan with its days and exercises.
class PlanDayInput {
  final String name;
  final int dayIndex;
  final List<PlanExerciseInput> exercises;

  const PlanDayInput({
    required this.name,
    required this.dayIndex,
    this.exercises = const [],
  });
}

class PlanExerciseInput {
  final int exerciseId;
  final int orderIndex;
  final int targetSets;
  final int targetReps;

  const PlanExerciseInput({
    required this.exerciseId,
    required this.orderIndex,
    required this.targetSets,
    required this.targetReps,
  });
}

class PlanRepository {
  final DatabaseHelper _dbHelper;

  PlanRepository({DatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? DatabaseHelper();

  /// Creates a plan with days and exercises atomically in a single transaction.
  Future<int> createPlan({
    required WorkoutPlan plan,
    required List<PlanDayInput> days,
  }) async {
    final db = await _dbHelper.database;
    return await db.transaction<int>((txn) async {
      final planId = await txn.insert(
        AppConstants.tableWorkoutPlans,
        plan.toMap(),
      );

      for (final dayInput in days) {
        final day = PlanDay(
          planId: planId,
          dayIndex: dayInput.dayIndex,
          name: dayInput.name,
        );
        final dayId = await txn.insert(
          AppConstants.tablePlanDays,
          day.toMap(),
        );

        for (final exInput in dayInput.exercises) {
          final planExercise = PlanExercise(
            planDayId: dayId,
            exerciseId: exInput.exerciseId,
            orderIndex: exInput.orderIndex,
            targetSets: exInput.targetSets,
            targetReps: exInput.targetReps,
          );
          await txn.insert(
            AppConstants.tablePlanExercises,
            planExercise.toMap(),
          );
        }
      }

      return planId;
    });
  }

  /// Updates a plan and replaces all its days and exercises atomically in a transaction.
  Future<void> updatePlan({
    required WorkoutPlan plan,
    required List<PlanDayInput> days,
  }) async {
    if (plan.id == null) {
      throw ArgumentError('WorkoutPlan must have an id to update.');
    }
    final db = await _dbHelper.database;
    await db.transaction((txn) async {
      await txn.update(
        AppConstants.tableWorkoutPlans,
        plan.toMap(),
        where: 'id = ?',
        whereArgs: [plan.id],
      );

      // Deleting plan_days triggers CASCADE delete on plan_exercises
      await txn.delete(
        AppConstants.tablePlanDays,
        where: 'plan_id = ?',
        whereArgs: [plan.id],
      );

      // Re-insert days and exercises
      for (final dayInput in days) {
        final day = PlanDay(
          planId: plan.id!,
          dayIndex: dayInput.dayIndex,
          name: dayInput.name,
        );
        final dayId = await txn.insert(
          AppConstants.tablePlanDays,
          day.toMap(),
        );

        for (final exInput in dayInput.exercises) {
          final planExercise = PlanExercise(
            planDayId: dayId,
            exerciseId: exInput.exerciseId,
            orderIndex: exInput.orderIndex,
            targetSets: exInput.targetSets,
            targetReps: exInput.targetReps,
          );
          await txn.insert(
            AppConstants.tablePlanExercises,
            planExercise.toMap(),
          );
        }
      }
    });
  }

  /// Deletes a plan by id. CASCADE automatically removes plan_days and plan_exercises.
  /// Any workout_sessions referring to plan_days will have plan_day_id SET NULL.
  Future<int> deletePlan(int planId) async {
    final db = await _dbHelper.database;
    return await db.delete(
      AppConstants.tableWorkoutPlans,
      where: 'id = ?',
      whereArgs: [planId],
    );
  }

  /// Finds all workout plans for a given user.
  Future<List<WorkoutPlan>> findByUser(int userId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      AppConstants.tableWorkoutPlans,
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );
    return maps.map((m) => WorkoutPlan.fromMap(m)).toList();
  }

  /// Loads the full plan structure: plan + its days + each day's exercises (with details).
  Future<WorkoutPlanFull?> getFull(int planId) async {
    final db = await _dbHelper.database;
    final planMaps = await db.query(
      AppConstants.tableWorkoutPlans,
      where: 'id = ?',
      whereArgs: [planId],
      limit: 1,
    );

    if (planMaps.isEmpty) return null;
    final plan = WorkoutPlan.fromMap(planMaps.first);

    // Fetch days
    final dayMaps = await db.query(
      AppConstants.tablePlanDays,
      where: 'plan_id = ?',
      whereArgs: [planId],
      orderBy: 'day_index ASC',
    );

    final List<PlanDayFull> daysFull = [];

    for (final dMap in dayMaps) {
      final day = PlanDay.fromMap(dMap);

      // Join plan_exercises with exercises
      final exerciseRows = await db.rawQuery('''
        SELECT pe.*,
               e.source_id AS e_source_id,
               e.name_en AS e_name_en,
               e.name_vi AS e_name_vi,
               e.body_part AS e_body_part,
               e.target AS e_target,
               e.equipment AS e_equipment,
               e.secondary_muscles AS e_secondary_muscles,
               e.instructions_en AS e_instructions_en,
               e.instructions_vi AS e_instructions_vi,
               e.image_asset AS e_image_asset,
               e.gif_asset AS e_gif_asset
        FROM ${AppConstants.tablePlanExercises} pe
        LEFT JOIN ${AppConstants.tableExercises} e ON pe.exercise_id = e.id
        WHERE pe.plan_day_id = ?
        ORDER BY pe.order_index ASC
      ''', [day.id]);

      final List<PlanExerciseDetail> exerciseDetails = [];
      for (final row in exerciseRows) {
        final planExercise = PlanExercise.fromMap(row);
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
        exerciseDetails.add(PlanExerciseDetail(
          planExercise: planExercise,
          exercise: exercise,
        ));
      }

      daysFull.add(PlanDayFull(day: day, exercises: exerciseDetails));
    }

    return WorkoutPlanFull(plan: plan, days: daysFull);
  }
}
