import 'dart:convert';
import 'package:flutter/services.dart';

import '../data/repositories/exercise_repository.dart';
import '../data/repositories/plan_repository.dart';
import '../data/repositories/session_repository.dart';
import '../models/set_log.dart';
import '../models/workout_plan.dart';
import '../models/workout_session.dart';

class ValidationException implements Exception {
  final String message;
  const ValidationException(this.message);

  @override
  String toString() => message;
}

/// WorkoutService handles workout plan management, workout sessions, validation, and sample data seeding.
class WorkoutService {
  final PlanRepository _planRepository;
  final ExerciseRepository _exerciseRepository;
  final SessionRepository _sessionRepository;

  WorkoutService({
    PlanRepository? planRepository,
    ExerciseRepository? exerciseRepository,
    SessionRepository? sessionRepository,
  })  : _planRepository = planRepository ?? PlanRepository(),
        _exerciseRepository = exerciseRepository ?? ExerciseRepository(),
        _sessionRepository = sessionRepository ?? SessionRepository();

  // ==================== WORKOUT PLAN METHODS ====================

  /// Validates a plan before creation or update.
  /// Throws [ValidationException] if validation fails.
  void validatePlan({
    required String name,
    required List<PlanDayInput> days,
  }) {
    if (name.trim().isEmpty) {
      throw const ValidationException('Tên kế hoạch không được để trống');
    }

    if (days.isEmpty) {
      throw const ValidationException('Kế hoạch phải có ít nhất một ngày tập');
    }

    for (var i = 0; i < days.length; i++) {
      final day = days[i];
      if (day.name.trim().isEmpty) {
        throw ValidationException('Tên ngày thứ ${i + 1} không được để trống');
      }

      if (day.exercises.isEmpty) {
        throw ValidationException(
          'Ngày "${day.name}" phải có ít nhất một bài tập',
        );
      }

      for (var j = 0; j < day.exercises.length; j++) {
        final ex = day.exercises[j];
        if (ex.targetSets <= 0 || ex.targetReps <= 0) {
          throw ValidationException(
            'Số hiệp và số lần lặp ở bài tập thứ ${j + 1} phải lớn hơn 0',
          );
        }
      }
    }
  }

  /// Creates a new workout plan with days and exercises.
  Future<int> createPlan({
    required int userId,
    required String name,
    required List<PlanDayInput> days,
  }) async {
    validatePlan(name: name, days: days);

    final plan = WorkoutPlan(
      userId: userId,
      name: name.trim(),
      createdAt: DateTime.now().toIso8601String(),
    );

    return await _planRepository.createPlan(
      plan: plan,
      days: days,
    );
  }

  /// Updates an existing workout plan with days and exercises.
  Future<void> updatePlan({
    required WorkoutPlan plan,
    required List<PlanDayInput> days,
  }) async {
    validatePlan(name: plan.name, days: days);

    final updatedPlan = plan.copyWith(
      name: plan.name.trim(),
    );

    await _planRepository.updatePlan(
      plan: updatedPlan,
      days: days,
    );
  }

  /// Deletes a workout plan by id.
  Future<int> deletePlan(int planId) async {
    return await _planRepository.deletePlan(planId);
  }

  /// Gets all plans belonging to a user.
  Future<List<WorkoutPlan>> getPlansByUser(int userId) async {
    return await _planRepository.findByUser(userId);
  }

  /// Gets the complete plan with days and exercises details.
  Future<WorkoutPlanFull?> getFullPlan(int planId) async {
    return await _planRepository.getFull(planId);
  }

  /// Seeds sample plans from assets/data/sample_plans.json for the specified user.
  /// Maps `source_id` -> `exercises.id` using [ExerciseRepository.findBySourceId].
  Future<List<int>> seedSamplePlans(
    int userId, {
    String locale = 'vi',
  }) async {
    String jsonString;
    try {
      jsonString = await rootBundle.loadString('assets/data/sample_plans.json');
    } catch (_) {
      jsonString = '''
      [
        {
          "name_en": "Full Body Starter",
          "name_vi": "Khởi động Toàn thân",
          "days": [
            {
              "name_en": "Day 1 - Push & Core",
              "name_vi": "Ngày 1 - Ngực & Bụng",
              "items": [
                { "source_id": "0025", "sets": 3, "reps": 10 }
              ]
            }
          ]
        }
      ]
      ''';
    }

    final dynamic decoded = jsonDecode(jsonString);
    if (decoded is! List) return [];

    final createdPlanIds = <int>[];

    for (final planRaw in decoded) {
      if (planRaw is! Map<String, dynamic>) continue;

      final nameEn = planRaw['name_en'] as String? ?? 'Sample Plan';
      final nameVi = planRaw['name_vi'] as String? ?? nameEn;
      final planName = locale.toLowerCase().startsWith('vi') ? nameVi : nameEn;

      final rawDays = planRaw['days'];
      if (rawDays is! List) continue;

      final planDays = <PlanDayInput>[];
      var dayIndex = 0;

      for (final dayRaw in rawDays) {
        if (dayRaw is! Map<String, dynamic>) continue;

        final dayNameEn = dayRaw['name_en'] as String? ?? 'Day ${dayIndex + 1}';
        final dayNameVi = dayRaw['name_vi'] as String? ?? dayNameEn;
        final dayName = locale.toLowerCase().startsWith('vi') ? dayNameVi : dayNameEn;

        final rawItems = dayRaw['items'];
        if (rawItems is! List) continue;

        final dayExercises = <PlanExerciseInput>[];
        var exOrder = 0;

        for (final itemRaw in rawItems) {
          if (itemRaw is! Map<String, dynamic>) continue;

          final sourceId = itemRaw['source_id']?.toString() ?? '';
          final sets = (itemRaw['sets'] as num?)?.toInt() ?? 3;
          final reps = (itemRaw['reps'] as num?)?.toInt() ?? 10;

          final exercise = await _exerciseRepository.findBySourceId(sourceId);
          if (exercise != null && exercise.id != null) {
            dayExercises.add(
              PlanExerciseInput(
                exerciseId: exercise.id!,
                orderIndex: exOrder++,
                targetSets: sets,
                targetReps: reps,
              ),
            );
          }
        }

        if (dayExercises.isNotEmpty) {
          planDays.add(
            PlanDayInput(
              name: dayName,
              dayIndex: dayIndex++,
              exercises: dayExercises,
            ),
          );
        }
      }

      if (planDays.isNotEmpty) {
        final planId = await createPlan(
          userId: userId,
          name: planName,
          days: planDays,
        );
        createdPlanIds.add(planId);
      }
    }

    return createdPlanIds;
  }

  // ==================== WORKOUT SESSION METHODS (S06) ====================

  /// Validates a workout set log before saving.
  void validateSet({
    required int reps,
    required double weightKg,
  }) {
    if (reps <= 0) {
      throw const ValidationException('Số lần lặp (reps) phải lớn hơn 0');
    }
    if (weightKg < 0) {
      throw const ValidationException('Khối lượng tạ (weight) không được nhỏ hơn 0');
    }
  }

  /// Starts a new workout session for a user.
  /// [planDayId] is optional (null for free workouts).
  Future<int> startSession({
    required int userId,
    int? planDayId,
    DateTime? startedAt,
  }) async {
    final session = WorkoutSession(
      userId: userId,
      planDayId: planDayId,
      startedAt: (startedAt ?? DateTime.now()).toIso8601String(),
      totalVolume: 0.0,
    );
    return await _sessionRepository.insertSession(session);
  }

  /// Adds a performed set into a session.
  /// Throws [ValidationException] if reps <= 0 or weightKg < 0.
  Future<int> addSet({
    required int sessionId,
    required int exerciseId,
    required int setIndex,
    required int reps,
    required double weightKg,
  }) async {
    validateSet(reps: reps, weightKg: weightKg);

    final setLog = SetLog(
      sessionId: sessionId,
      exerciseId: exerciseId,
      setIndex: setIndex,
      reps: reps,
      weightKg: weightKg,
    );
    return await _sessionRepository.insertSet(setLog);
  }

  /// Updates an existing set log.
  /// Throws [ValidationException] if reps <= 0 or weightKg < 0.
  Future<int> updateSet({
    required int setId,
    required int sessionId,
    required int exerciseId,
    required int setIndex,
    required int reps,
    required double weightKg,
  }) async {
    validateSet(reps: reps, weightKg: weightKg);

    final setLog = SetLog(
      id: setId,
      sessionId: sessionId,
      exerciseId: exerciseId,
      setIndex: setIndex,
      reps: reps,
      weightKg: weightKg,
    );
    return await _sessionRepository.updateSet(setLog);
  }

  /// Deletes a set by id.
  Future<int> deleteSet(int setId) async {
    return await _sessionRepository.deleteSet(setId);
  }

  /// Finishes a session: calculates total volume = Σ (reps * weightKg)
  /// and updates ended_at timestamp.
  Future<WorkoutSession?> finishSession(
    int sessionId, {
    DateTime? endedAt,
  }) async {
    final currentSession = await _sessionRepository.getFull(sessionId);
    if (currentSession == null) return null;

    final finishTime = endedAt ?? DateTime.now();

    // Calculate total volume: Σ (reps * weightKg)
    var totalVolume = 0.0;
    for (final s in currentSession.sets) {
      totalVolume += (s.reps * s.weightKg);
    }

    await _sessionRepository.finishSession(
      sessionId: sessionId,
      endedAt: finishTime,
      totalVolume: totalVolume,
    );

    return await _sessionRepository.getFull(sessionId);
  }

  /// Cancels an in-progress session by deleting it (set_logs CASCADE deleted).
  Future<int> cancelSession(int sessionId) async {
    return await _sessionRepository.deleteSession(sessionId);
  }

  /// Deletes a workout session by id (set_logs CASCADE deleted).
  Future<int> deleteSession(int sessionId) async {
    return await _sessionRepository.deleteSession(sessionId);
  }

  /// Loads full session history for a user (newest first).
  Future<List<WorkoutSession>> getSessionHistory(int userId) async {
    return await _sessionRepository.findHistoryByUser(userId);
  }

  /// Loads a single workout session with full details.
  Future<WorkoutSession?> getSession(int sessionId) async {
    return await _sessionRepository.getFull(sessionId);
  }
}
