import 'dart:async';
import 'package:flutter/foundation.dart';

import '../data/repositories/plan_repository.dart';
import '../models/exercise.dart';
import '../models/plan_day.dart';
import '../models/plan_exercise.dart';
import '../models/set_log.dart';
import '../models/workout_session.dart';
import '../services/workout_service.dart';

/// WorkoutProvider manages ongoing workout sessions (sets, exercises, timers)
/// as well as workout history required by Partner B (Module B4).
class WorkoutProvider extends ChangeNotifier {
  final WorkoutService _workoutService;

  bool _isLoading = false;
  String? _error;
  bool _disposed = false;

  // ==================== B4 API / HISTORY ====================
  List<WorkoutSession> _history = [];

  List<WorkoutSession> get history => _history;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // ==================== ACTIVE SESSION STATE ====================
  WorkoutSession? _activeSession;
  WorkoutPlanFull? _activePlanFull;
  PlanDayFull? _activeDayFull;
  int _currentExerciseIndex = 0;
  List<SetLog> _activeSets = [];
  WorkoutSession? _lastCompletedSession;

  WorkoutSession? get activeSession => _activeSession;
  bool get isSessionActive => _activeSession != null;
  WorkoutPlanFull? get activePlanFull => _activePlanFull;
  PlanDayFull? get activeDayFull => _activeDayFull;
  int get currentExerciseIndex => _currentExerciseIndex;
  List<SetLog> get activeSets => _activeSets;
  WorkoutSession? get lastCompletedSession => _lastCompletedSession;

  // ==================== TIMERS ====================
  Timer? _sessionTimer;
  int _elapsedSeconds = 0;
  int get elapsedSeconds => _elapsedSeconds;

  Timer? _restTimer;
  int _restSecondsRemaining = 0;
  int _restTotalSeconds = 60;
  bool _isResting = false;

  bool get isResting => _isResting;
  int get restSecondsRemaining => _restSecondsRemaining;
  int get restTotalSeconds => _restTotalSeconds;
  double get restProgress =>
      _restTotalSeconds > 0 ? _restSecondsRemaining / _restTotalSeconds : 0.0;

  WorkoutProvider({WorkoutService? workoutService})
      : _workoutService = workoutService ?? WorkoutService();

  @override
  void dispose() {
    _sessionTimer?.cancel();
    _sessionTimer = null;
    _restTimer?.cancel();
    _restTimer = null;
    _disposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_disposed) {
      super.notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // ==================== B4 API IMPLEMENTATION ====================

  /// Loads workout history for a user (ordered newest first, including sets).
  Future<void> loadHistory(int userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _history = await _workoutService.getSessionHistory(userId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Gets a single workout session with full details.
  Future<WorkoutSession?> getSession(int id) async {
    try {
      return await _workoutService.getSession(id);
    } catch (e) {
      _error = e.toString();
      return null;
    }
  }

  /// Deletes a session and its associated set logs (ON DELETE CASCADE).
  Future<void> deleteSession(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _workoutService.deleteSession(id);
      _history.removeWhere((s) => s.id == id);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ==================== ACTIVE SESSION METHODS ====================

  /// Returns sets logged for a specific exercise in the active session.
  List<SetLog> setsForExercise(int exerciseId) {
    return _activeSets.where((s) => s.exerciseId == exerciseId).toList();
  }

  /// Starts a new active workout session.
  Future<void> startWorkoutSession({
    required int userId,
    PlanDayFull? planDayFull,
    WorkoutPlanFull? planFull,
    DateTime? startedAt,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final startTime = startedAt ?? DateTime.now();
      final sessionId = await _workoutService.startSession(
        userId: userId,
        planDayId: planDayFull?.day.id,
        startedAt: startTime,
      );

      _activeSession = WorkoutSession(
        id: sessionId,
        userId: userId,
        planDayId: planDayFull?.day.id,
        planDayName: planDayFull?.day.name,
        startedAt: startTime.toIso8601String(),
        totalVolume: 0.0,
      );

      _activePlanFull = planFull;
      _activeDayFull = planDayFull;
      _currentExerciseIndex = 0;
      _activeSets = [];
      _elapsedSeconds = 0;

      _startSessionTimer();
      _stopRestTimer();
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Starts a free workout session with a user-selected list of exercises.
  Future<void> startFreeWorkoutSession({
    required int userId,
    required List<Exercise> exercises,
    String? sessionName,
    DateTime? startedAt,
  }) async {
    final freeDay = PlanDayFull(
      day: PlanDay(
        id: null,
        planId: 0,
        dayIndex: 0,
        name: sessionName ?? 'Buổi tập tự do',
      ),
      exercises: exercises.asMap().entries.map((entry) {
        final idx = entry.key;
        final ex = entry.value;
        return PlanExerciseDetail(
          planExercise: PlanExercise(
            id: null,
            planDayId: 0,
            exerciseId: ex.id ?? 1,
            orderIndex: idx,
            targetSets: 3,
            targetReps: 10,
          ),
          exercise: ex,
        );
      }).toList(),
    );

    await startWorkoutSession(
      userId: userId,
      planDayFull: freeDay,
      startedAt: startedAt,
    );
  }

  /// Dynamically adds an exercise to the active workout session.
  void addExerciseToActiveSession(
    Exercise exercise, {
    int targetSets = 3,
    int targetReps = 10,
  }) {
    if (_activeSession == null) return;

    final currentExercises = _activeDayFull?.exercises ?? <PlanExerciseDetail>[];
    final newIndex = currentExercises.length;
    final newDetail = PlanExerciseDetail(
      planExercise: PlanExercise(
        id: null,
        planDayId: _activeDayFull?.day.id ?? 0,
        exerciseId: exercise.id ?? 1,
        orderIndex: newIndex,
        targetSets: targetSets,
        targetReps: targetReps,
      ),
      exercise: exercise,
    );

    final updatedList = List<PlanExerciseDetail>.from(currentExercises)..add(newDetail);
    final currentDay = _activeDayFull?.day ??
        PlanDay(
          id: null,
          planId: 0,
          dayIndex: 0,
          name: _activeSession?.planDayName ?? 'Buổi tập tự do',
        );

    _activeDayFull = PlanDayFull(
      day: currentDay,
      exercises: updatedList,
    );

    _currentExerciseIndex = newIndex;
    notifyListeners();
  }

  void setCurrentExerciseIndex(int index) {
    _currentExerciseIndex = index;
    notifyListeners();
  }

  /// Records a performed set for the active session and starts rest timer.
  Future<void> recordSet({
    required int exerciseId,
    required int reps,
    required double weightKg,
    int restDurationSeconds = 60,
  }) async {
    if (_activeSession == null || _activeSession!.id == null) return;

    try {
      final currentSets = setsForExercise(exerciseId);
      final setIndex = currentSets.length + 1;

      final setId = await _workoutService.addSet(
        sessionId: _activeSession!.id!,
        exerciseId: exerciseId,
        setIndex: setIndex,
        reps: reps,
        weightKg: weightKg,
      );

      final newSet = SetLog(
        id: setId,
        sessionId: _activeSession!.id!,
        exerciseId: exerciseId,
        setIndex: setIndex,
        reps: reps,
        weightKg: weightKg,
      );

      _activeSets.add(newSet);

      // Start rest countdown timer
      startRestTimer(restDurationSeconds);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Removes a recorded set from the active session.
  Future<void> removeSet(int setId) async {
    try {
      await _workoutService.deleteSet(setId);
      _activeSets.removeWhere((s) => s.id == setId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Finishes the current session, computes volume, and stops timers.
  Future<WorkoutSession?> finishCurrentSession() async {
    if (_activeSession == null || _activeSession!.id == null) return null;

    _isLoading = true;
    notifyListeners();

    try {
      _stopSessionTimer();
      _stopRestTimer();

      final finished = await _workoutService.finishSession(_activeSession!.id!);
      _lastCompletedSession = finished;

      // Reload history if user exists
      if (_activeSession?.userId != null) {
        _history = await _workoutService.getSessionHistory(_activeSession!.userId);
      }

      _activeSession = null;
      _activePlanFull = null;
      _activeDayFull = null;
      _activeSets = [];

      return finished;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Cancels the current session completely (deleting from DB).
  Future<void> cancelCurrentSession() async {
    if (_activeSession == null || _activeSession!.id == null) return;

    _stopSessionTimer();
    _stopRestTimer();

    try {
      await _workoutService.cancelSession(_activeSession!.id!);
    } finally {
      _activeSession = null;
      _activePlanFull = null;
      _activeDayFull = null;
      _activeSets = [];
      _elapsedSeconds = 0;
      notifyListeners();
    }
  }

  // ==================== TIMERS MANAGEMENT ====================

  void _startSessionTimer() {
    _sessionTimer?.cancel();
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _elapsedSeconds++;
      notifyListeners();
    });
  }

  void _stopSessionTimer() {
    _sessionTimer?.cancel();
    _sessionTimer = null;
  }

  /// Formatted duration in mm:ss or hh:mm:ss.
  String get formattedDuration {
    final hours = _elapsedSeconds ~/ 3600;
    final minutes = (_elapsedSeconds % 3600) ~/ 60;
    final seconds = _elapsedSeconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Starts or restarts the rest timer with the given duration.
  void startRestTimer([int durationSeconds = 60]) {
    _restTimer?.cancel();
    _restTotalSeconds = durationSeconds > 0 ? durationSeconds : 60;
    _restSecondsRemaining = _restTotalSeconds;
    _isResting = true;
    notifyListeners();

    _restTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_restSecondsRemaining > 1) {
        _restSecondsRemaining--;
        notifyListeners();
      } else {
        _stopRestTimer();
      }
    });
  }

  /// Adjusts remaining rest time by a delta in seconds (e.g. +15 or -15).
  void adjustRestTimer(int deltaSeconds) {
    if (!_isResting) return;
    _restSecondsRemaining += deltaSeconds;
    if (_restSecondsRemaining <= 0) {
      _stopRestTimer();
    } else {
      if (_restSecondsRemaining > _restTotalSeconds) {
        _restTotalSeconds = _restSecondsRemaining;
      }
      notifyListeners();
    }
  }

  /// Skips the rest timer immediately.
  void skipRestTimer() {
    _stopRestTimer();
  }

  void _stopRestTimer() {
    _restTimer?.cancel();
    _restTimer = null;
    _restSecondsRemaining = 0;
    _isResting = false;
    notifyListeners();
  }
}
