import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:fit_track/core/constants.dart';
import 'package:fit_track/data/database_helper.dart';
import 'package:fit_track/data/repositories/plan_repository.dart';
import 'package:fit_track/data/repositories/session_repository.dart';
import 'package:fit_track/data/repositories/user_repository.dart';
import 'package:fit_track/models/user.dart';
import 'package:fit_track/models/workout_plan.dart';
import 'package:fit_track/providers/workout_provider.dart';
import 'package:fit_track/services/workout_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late Database db;
  late DatabaseHelper dbHelper;
  late UserRepository userRepo;
  late PlanRepository planRepo;
  late SessionRepository sessionRepo;
  late WorkoutService workoutService;
  late WorkoutProvider workoutProvider;

  final testUser = User(
    email: 'workout_test@example.com',
    passwordHash: 'hash',
    salt: 'salt',
    name: 'Workout Tester',
    createdAt: DateTime.now().toIso8601String(),
  );
  late int testUserId;

  setUp(() async {
    dbHelper = DatabaseHelper();
    db = await databaseFactory.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: 1,
        onConfigure: (database) async {
          await database.execute('PRAGMA foreign_keys = ON;');
        },
        onCreate: (database, version) async {
          await DatabaseHelper.onCreate(database, version);
        },
      ),
    );

    dbHelper.setDatabaseForTesting(db);
    userRepo = UserRepository(dbHelper: dbHelper);
    planRepo = PlanRepository(dbHelper: dbHelper);
    sessionRepo = SessionRepository(dbHelper: dbHelper);
    workoutService = WorkoutService(
      planRepository: planRepo,
      sessionRepository: sessionRepo,
    );
    workoutProvider = WorkoutProvider(workoutService: workoutService);

    testUserId = await userRepo.insert(testUser);

    // Seed mock exercises into DB for foreign key constraints
    await db.insert(
      AppConstants.tableExercises,
      {
        'id': 1,
        'source_id': '0025',
        'name_en': 'barbell bench press',
        'name_vi': 'Đẩy ngực với tạ đòn',
        'body_part': 'chest',
        'target': 'pectorals',
        'equipment': 'barbell',
        'secondary_muscles': '["triceps", "shoulders"]',
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    await db.insert(
      AppConstants.tableExercises,
      {
        'id': 2,
        'source_id': '0026',
        'name_en': 'barbell squat',
        'name_vi': 'Gánh đùi tạ đòn',
        'body_part': 'legs',
        'target': 'quads',
        'equipment': 'barbell',
        'secondary_muscles': '["glutes", "hamstrings"]',
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  });

  tearDown(() async {
    workoutProvider.dispose();
    await db.close();
    dbHelper.setDatabaseForTesting(null);
  });

  group('A06 - Set Validation', () {
    test('Set with reps <= 0 throws ValidationException', () {
      expect(
        () => workoutService.validateSet(reps: 0, weightKg: 20.0),
        throwsA(isA<ValidationException>().having(
          (e) => e.message,
          'message',
          contains('lớn hơn 0'),
        )),
      );

      expect(
        () => workoutService.validateSet(reps: -5, weightKg: 20.0),
        throwsA(isA<ValidationException>()),
      );
    });

    test('Set with negative weight throws ValidationException', () {
      expect(
        () => workoutService.validateSet(reps: 10, weightKg: -1.0),
        throwsA(isA<ValidationException>().having(
          (e) => e.message,
          'message',
          contains('nhỏ hơn 0'),
        )),
      );
    });

    test('Set with valid reps and weight passes validation', () {
      expect(
        () => workoutService.validateSet(reps: 10, weightKg: 0.0),
        returnsNormally,
      );
      expect(
        () => workoutService.validateSet(reps: 12, weightKg: 50.5),
        returnsNormally,
      );
    });
  });

  group('A06 - Session Execution & Volume Computation', () {
    test('Start session, record 3 sets, finish and verify total volume and duration', () async {
      final sessionId = await workoutService.startSession(
        userId: testUserId,
        startedAt: DateTime.now().subtract(const Duration(minutes: 30)),
      );

      // Record 3 sets:
      // Set 1: 10 reps * 50 kg = 500 kg
      await workoutService.addSet(
        sessionId: sessionId,
        exerciseId: 1,
        setIndex: 1,
        reps: 10,
        weightKg: 50.0,
      );

      // Set 2: 8 reps * 60 kg = 480 kg
      await workoutService.addSet(
        sessionId: sessionId,
        exerciseId: 1,
        setIndex: 2,
        reps: 8,
        weightKg: 60.0,
      );

      // Set 3: 5 reps * 70 kg = 350 kg
      await workoutService.addSet(
        sessionId: sessionId,
        exerciseId: 2,
        setIndex: 1,
        reps: 5,
        weightKg: 70.0,
      );

      final finished = await workoutService.finishSession(
        sessionId,
        endedAt: DateTime.now(),
      );

      expect(finished, isNotNull);
      expect(finished!.totalVolume, 500.0 + 480.0 + 350.0); // 1330.0 kg
      expect(finished.setCount, 3);
      expect(finished.endedAt, isNotNull);
      expect(finished.duration, isNotNull);
      expect(finished.duration!.inMinutes >= 29, isTrue);

      // Verify DB persistence
      final loadedSession = await workoutService.getSession(sessionId);
      expect(loadedSession, isNotNull);
      expect(loadedSession!.totalVolume, 1330.0);
      expect(loadedSession.sets.length, 3);
    });

    test('Cancel session deletes the session completely', () async {
      final sessionId = await workoutService.startSession(userId: testUserId);
      await workoutService.addSet(
        sessionId: sessionId,
        exerciseId: 1,
        setIndex: 1,
        reps: 10,
        weightKg: 20.0,
      );

      await workoutService.cancelSession(sessionId);

      final check = await workoutService.getSession(sessionId);
      expect(check, isNull);

      final setsInDb = await db.query(
        AppConstants.tableSetLogs,
        where: 'session_id = ?',
        whereArgs: [sessionId],
      );
      expect(setsInDb, isEmpty);
    });
  });

  group('A06 - Timers & Rest Countdown', () {
    test('Rest timer countdown, adjustment and skipping', () {
      workoutProvider.startRestTimer(60);
      expect(workoutProvider.isResting, isTrue);
      expect(workoutProvider.restSecondsRemaining, 60);

      // Add 15 seconds
      workoutProvider.adjustRestTimer(15);
      expect(workoutProvider.restSecondsRemaining, 75);

      // Subtract 15 seconds
      workoutProvider.adjustRestTimer(-15);
      expect(workoutProvider.restSecondsRemaining, 60);

      // Skip rest timer
      workoutProvider.skipRestTimer();
      expect(workoutProvider.isResting, isFalse);
      expect(workoutProvider.restSecondsRemaining, 0);
    });

    test('Disposing WorkoutProvider cancels timers cleanly', () {
      final tempProvider = WorkoutProvider(workoutService: workoutService);
      tempProvider.startRestTimer(90);
      expect(tempProvider.isResting, isTrue);

      tempProvider.dispose();
      // Verifies no exception thrown and timers cancelled
    });
  });

  group('A06 - Relational Integrity (CASCADE & SET NULL)', () {
    test('Deleting plan sets plan_day_id to NULL but preserves workout session and set logs', () async {
      // 1. Create a plan with 1 day
      final planId = await planRepo.createPlan(
        plan: WorkoutPlan(
          userId: testUserId,
          name: 'Hypertrophy Plan',
          createdAt: DateTime.now().toIso8601String(),
        ),
        days: [
          const PlanDayInput(
            name: 'Day 1 - Chest',
            dayIndex: 0,
            exercises: [
              PlanExerciseInput(
                exerciseId: 1,
                orderIndex: 0,
                targetSets: 3,
                targetReps: 10,
              ),
            ],
          ),
        ],
      );

      final fullPlan = await planRepo.getFull(planId);
      final dayId = fullPlan!.days.first.day.id!;

      // 2. Start and finish a session linked to this plan day
      final sessionId = await workoutService.startSession(
        userId: testUserId,
        planDayId: dayId,
      );
      await workoutService.addSet(
        sessionId: sessionId,
        exerciseId: 1,
        setIndex: 1,
        reps: 10,
        weightKg: 60.0,
      );
      await workoutService.finishSession(sessionId);

      final sessionBefore = await workoutService.getSession(sessionId);
      expect(sessionBefore!.planDayId, dayId);
      expect(sessionBefore.planDayName, 'Day 1 - Chest');
      expect(sessionBefore.sets.length, 1);

      // 3. Delete the plan (ON DELETE SET NULL on workout_sessions.plan_day_id)
      await planRepo.deletePlan(planId);

      // 4. Session must remain in history, plan_day_id and planDayName become null
      final sessionAfter = await workoutService.getSession(sessionId);
      expect(sessionAfter, isNotNull);
      expect(sessionAfter!.planDayId, isNull);
      expect(sessionAfter.planDayName, isNull);
      expect(sessionAfter.sets.length, 1);
      expect(sessionAfter.totalVolume, 600.0);
    });

    test('Deleting a session CASCADE deletes all its set_logs', () async {
      final sessionId = await workoutService.startSession(userId: testUserId);
      await workoutService.addSet(
        sessionId: sessionId,
        exerciseId: 1,
        setIndex: 1,
        reps: 10,
        weightKg: 50.0,
      );
      await workoutService.addSet(
        sessionId: sessionId,
        exerciseId: 1,
        setIndex: 2,
        reps: 10,
        weightKg: 50.0,
      );

      final session = await workoutService.getSession(sessionId);
      expect(session!.sets.length, 2);

      // Delete session
      await workoutService.deleteSession(sessionId);

      final checkSession = await workoutService.getSession(sessionId);
      expect(checkSession, isNull);

      final remainingSets = await db.query(
        AppConstants.tableSetLogs,
        where: 'session_id = ?',
        whereArgs: [sessionId],
      );
      expect(remainingSets, isEmpty);
    });
  });

  group('A06 - Partner B (B4) History API Contract', () {
    test('loadHistory, getSession, deleteSession match B4 contract specification', () async {
      final s1Id = await workoutService.startSession(
        userId: testUserId,
        startedAt: DateTime.now().subtract(const Duration(days: 2)),
      );
      await workoutService.addSet(
        sessionId: s1Id,
        exerciseId: 1,
        setIndex: 1,
        reps: 10,
        weightKg: 40.0,
      );
      await workoutService.finishSession(s1Id);

      final s2Id = await workoutService.startSession(
        userId: testUserId,
        startedAt: DateTime.now().subtract(const Duration(days: 1)),
      );
      await workoutService.addSet(
        sessionId: s2Id,
        exerciseId: 2,
        setIndex: 1,
        reps: 12,
        weightKg: 50.0,
      );
      await workoutService.finishSession(s2Id);

      // Load history via WorkoutProvider
      await workoutProvider.loadHistory(testUserId);
      expect(workoutProvider.history.length, 2);

      // History must be ordered newest first (s2 before s1)
      expect(workoutProvider.history[0].id, s2Id);
      expect(workoutProvider.history[1].id, s1Id);
      expect(workoutProvider.history[0].sets.length, 1);
      expect(workoutProvider.history[1].sets.length, 1);

      // getSession
      final fetched = await workoutProvider.getSession(s2Id);
      expect(fetched, isNotNull);
      expect(fetched!.id, s2Id);

      // deleteSession
      await workoutProvider.deleteSession(s1Id);
      expect(workoutProvider.history.length, 1);
      expect(workoutProvider.history.any((s) => s.id == s1Id), isFalse);
    });
  });
}
