import 'package:flutter/foundation.dart';

import '../data/repositories/plan_repository.dart';
import '../models/exercise.dart';
import '../models/workout_plan.dart';
import '../services/workout_service.dart';

/// Represents an exercise item currently being drafted in a plan day.
class DraftExercise {
  final int exerciseId;
  final Exercise exercise;
  int targetSets;
  int targetReps;

  DraftExercise({
    required this.exerciseId,
    required this.exercise,
    this.targetSets = 3,
    this.targetReps = 10,
  });
}

/// Represents a day currently being drafted in a workout plan.
class DraftDay {
  String name;
  List<DraftExercise> exercises;

  DraftDay({
    required this.name,
    List<DraftExercise>? exercises,
  }) : exercises = exercises ?? [];
}

/// Represents the in-progress draft for creating or editing a plan.
class PlanDraft {
  int? id;
  int? userId;
  String name;
  List<DraftDay> days;

  PlanDraft({
    this.id,
    this.userId,
    this.name = '',
    List<DraftDay>? days,
  }) : days = days ?? [];

  bool get isEditing => id != null;
}

/// PlanProvider manages the list of workout plans and the active plan editing draft.
/// Note: Exercise catalog and search filtering are kept separately in ExerciseProvider (Partner B).
class PlanProvider extends ChangeNotifier {
  final WorkoutService _workoutService;

  List<WorkoutPlan> _plans = [];
  WorkoutPlanFull? _currentPlanFull;
  PlanDraft? _draft;
  bool _isLoading = false;
  String? _error;
  bool _disposed = false;

  PlanProvider({WorkoutService? workoutService})
      : _workoutService = workoutService ?? WorkoutService();

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

  List<WorkoutPlan> get plans => _plans;
  WorkoutPlanFull? get currentPlanFull => _currentPlanFull;
  PlanDraft? get draft => _draft;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Loads all plans for the given user.
  Future<void> loadPlans(int userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _plans = await _workoutService.getPlansByUser(userId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Loads detailed information of a plan.
  Future<WorkoutPlanFull?> loadPlanDetails(int planId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentPlanFull = await _workoutService.getFullPlan(planId);
      return _currentPlanFull;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Deletes a plan and reloads the plan list.
  Future<bool> deletePlan(int planId, int userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _workoutService.deletePlan(planId);
      _plans = await _workoutService.getPlansByUser(userId);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Applies sample plans from assets for the given user.
  Future<bool> applySamplePlan(int userId, {String locale = 'vi'}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final createdIds = await _workoutService.seedSamplePlans(userId, locale: locale);
      _plans = await _workoutService.getPlansByUser(userId);
      return createdIds.isNotEmpty;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ==================== DRAFT METHODS ====================

  /// Initializes a new draft, optionally pre-populated from an existing plan.
  void initDraft([WorkoutPlanFull? existing]) {
    if (existing != null) {
      final draftDays = existing.days.map((dayFull) {
        final draftExercises = dayFull.exercises.map((exDetail) {
          final fallbackExercise = exDetail.exercise ??
              Exercise(
                id: exDetail.planExercise.exerciseId,
                sourceId: '',
                nameEn: 'Exercise #${exDetail.planExercise.exerciseId}',
                nameVi: 'Bài tập #${exDetail.planExercise.exerciseId}',
                bodyPart: '',
              );
          return DraftExercise(
            exerciseId: exDetail.planExercise.exerciseId,
            exercise: fallbackExercise,
            targetSets: exDetail.planExercise.targetSets,
            targetReps: exDetail.planExercise.targetReps,
          );
        }).toList();

        return DraftDay(
          name: dayFull.day.name,
          exercises: draftExercises,
        );
      }).toList();

      _draft = PlanDraft(
        id: existing.plan.id,
        userId: existing.plan.userId,
        name: existing.plan.name,
        days: draftDays,
      );
    } else {
      _draft = PlanDraft(
        days: [
          DraftDay(name: 'Ngày 1'),
        ],
      );
    }
    _error = null;
    notifyListeners();
  }

  void updateDraftName(String name) {
    if (_draft != null) {
      _draft!.name = name;
    }
  }

  void addDraftDay([String? name]) {
    if (_draft == null) return;
    final dayNum = _draft!.days.length + 1;
    _draft!.days.add(DraftDay(name: name ?? 'Ngày $dayNum'));
    notifyListeners();
  }

  void removeDraftDay(int index) {
    if (_draft == null || index < 0 || index >= _draft!.days.length) return;
    _draft!.days.removeAt(index);
    notifyListeners();
  }

  void updateDraftDayName(int index, String newName) {
    if (_draft == null || index < 0 || index >= _draft!.days.length) return;
    _draft!.days[index].name = newName;
    notifyListeners();
  }

  void addExercisesToDay(
    int dayIndex,
    List<Exercise> exercises, {
    int defaultSets = 3,
    int defaultReps = 10,
  }) {
    if (_draft == null || dayIndex < 0 || dayIndex >= _draft!.days.length) return;
    final day = _draft!.days[dayIndex];
    for (final ex in exercises) {
      if (ex.id == null) continue;
      day.exercises.add(
        DraftExercise(
          exerciseId: ex.id!,
          exercise: ex,
          targetSets: defaultSets,
          targetReps: defaultReps,
        ),
      );
    }
    notifyListeners();
  }

  void removeExerciseFromDay(int dayIndex, int exerciseIndex) {
    if (_draft == null || dayIndex < 0 || dayIndex >= _draft!.days.length) return;
    final day = _draft!.days[dayIndex];
    if (exerciseIndex < 0 || exerciseIndex >= day.exercises.length) return;
    day.exercises.removeAt(exerciseIndex);
    notifyListeners();
  }

  void updateExerciseSetsReps(
    int dayIndex,
    int exerciseIndex,
    int sets,
    int reps,
  ) {
    if (_draft == null || dayIndex < 0 || dayIndex >= _draft!.days.length) return;
    final day = _draft!.days[dayIndex];
    if (exerciseIndex < 0 || exerciseIndex >= day.exercises.length) return;
    day.exercises[exerciseIndex].targetSets = sets;
    day.exercises[exerciseIndex].targetReps = reps;
    notifyListeners();
  }

  void reorderDraftExercises(int dayIndex, int oldIndex, int newIndex) {
    if (_draft == null || dayIndex < 0 || dayIndex >= _draft!.days.length) return;
    final exercises = _draft!.days[dayIndex].exercises;
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final item = exercises.removeAt(oldIndex);
    exercises.insert(newIndex, item);
    notifyListeners();
  }

  /// Validates and saves the current draft to the database.
  /// Throws [ValidationException] or returns true on success.
  Future<bool> saveDraft(int userId) async {
    if (_draft == null) return false;

    // Convert draft days to PlanDayInput
    final planDayInputs = <PlanDayInput>[];
    for (var d = 0; d < _draft!.days.length; d++) {
      final day = _draft!.days[d];
      final exInputs = <PlanExerciseInput>[];
      for (var e = 0; e < day.exercises.length; e++) {
        final dex = day.exercises[e];
        exInputs.add(
          PlanExerciseInput(
            exerciseId: dex.exerciseId,
            orderIndex: e,
            targetSets: dex.targetSets,
            targetReps: dex.targetReps,
          ),
        );
      }
      planDayInputs.add(
        PlanDayInput(
          name: day.name,
          dayIndex: d,
          exercises: exInputs,
        ),
      );
    }

    // Validate before setting loading
    _workoutService.validatePlan(name: _draft!.name, days: planDayInputs);

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (_draft!.isEditing) {
        final plan = WorkoutPlan(
          id: _draft!.id,
          userId: userId,
          name: _draft!.name,
          createdAt: DateTime.now().toIso8601String(),
        );
        await _workoutService.updatePlan(plan: plan, days: planDayInputs);
      } else {
        await _workoutService.createPlan(
          userId: userId,
          name: _draft!.name,
          days: planDayInputs,
        );
      }

      _plans = await _workoutService.getPlansByUser(userId);
      _draft = null;
      return true;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearDraft() {
    _draft = null;
    _error = null;
    notifyListeners();
  }
}
