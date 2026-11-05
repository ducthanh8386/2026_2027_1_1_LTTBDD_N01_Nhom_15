import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:fit_track/core/constants.dart';
import 'package:fit_track/data/database_helper.dart';
import 'package:fit_track/data/repositories/food_log_repository.dart';
import 'package:fit_track/data/repositories/food_repository.dart';
import 'package:fit_track/data/repositories/plan_repository.dart';
import 'package:fit_track/data/repositories/session_repository.dart';
import 'package:fit_track/data/repositories/user_repository.dart';
import 'package:fit_track/models/exercise.dart';
import 'package:fit_track/models/food.dart';
import 'package:fit_track/models/food_log_entry.dart';
import 'package:fit_track/models/set_log.dart';
import 'package:fit_track/models/user.dart';
import 'package:fit_track/models/workout_plan.dart';
import 'package:fit_track/models/workout_session.dart';

void main() {
  // Initialize FFI for running SQLite tests in test environment
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late Database db;
  late DatabaseHelper dbHelper;
  late UserRepository userRepo;
  late PlanRepository planRepo;
  late SessionRepository sessionRepo;
  late FoodRepository foodRepo;
  late FoodLogRepository foodLogRepo;

  setUp(() async {
    dbHelper = DatabaseHelper();
    // Open a fresh in-memory database with foreign keys enabled
    db = await databaseFactory.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: 1,
        onConfigure: (database) async {
          await database.execute('PRAGMA foreign_keys = ON;');
        },
        onCreate: (database, version) async {
          // Run table creation script by creating tables via helper
          await database.execute('''
            CREATE TABLE ${AppConstants.tableUsers} (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              name TEXT NOT NULL,
              email TEXT UNIQUE NOT NULL,
              password_hash TEXT NOT NULL,
              salt TEXT NOT NULL,
              height_cm REAL,
              weight_kg REAL,
              age INTEGER,
              gender TEXT,
              goal TEXT,
              kcal_target INTEGER,
              created_at TEXT NOT NULL
            );
          ''');

          await database.execute('''
            CREATE TABLE ${AppConstants.tableExercises} (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              source_id TEXT UNIQUE NOT NULL,
              name_en TEXT NOT NULL,
              name_vi TEXT NOT NULL,
              body_part TEXT NOT NULL,
              target TEXT,
              equipment TEXT,
              secondary_muscles TEXT,
              instructions_en TEXT,
              instructions_vi TEXT,
              image_asset TEXT,
              gif_asset TEXT
            );
          ''');

          await database.execute('''
            CREATE TABLE ${AppConstants.tableWorkoutPlans} (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              user_id INTEGER NOT NULL,
              name TEXT NOT NULL,
              created_at TEXT NOT NULL,
              FOREIGN KEY (user_id) REFERENCES ${AppConstants.tableUsers} (id) ON DELETE CASCADE
            );
          ''');

          await database.execute('''
            CREATE TABLE ${AppConstants.tablePlanDays} (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              plan_id INTEGER NOT NULL,
              day_index INTEGER NOT NULL,
              name TEXT NOT NULL,
              FOREIGN KEY (plan_id) REFERENCES ${AppConstants.tableWorkoutPlans} (id) ON DELETE CASCADE
            );
          ''');

          await database.execute('''
            CREATE TABLE ${AppConstants.tablePlanExercises} (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              plan_day_id INTEGER NOT NULL,
              exercise_id INTEGER NOT NULL,
              order_index INTEGER NOT NULL,
              target_sets INTEGER NOT NULL,
              target_reps INTEGER NOT NULL,
              FOREIGN KEY (plan_day_id) REFERENCES ${AppConstants.tablePlanDays} (id) ON DELETE CASCADE,
              FOREIGN KEY (exercise_id) REFERENCES ${AppConstants.tableExercises} (id)
            );
          ''');

          await database.execute('''
            CREATE TABLE ${AppConstants.tableWorkoutSessions} (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              user_id INTEGER NOT NULL,
              plan_day_id INTEGER,
              started_at TEXT NOT NULL,
              ended_at TEXT,
              total_volume REAL NOT NULL DEFAULT 0.0,
              FOREIGN KEY (user_id) REFERENCES ${AppConstants.tableUsers} (id) ON DELETE CASCADE,
              FOREIGN KEY (plan_day_id) REFERENCES ${AppConstants.tablePlanDays} (id) ON DELETE SET NULL
            );
          ''');

          await database.execute('''
            CREATE TABLE ${AppConstants.tableSetLogs} (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              session_id INTEGER NOT NULL,
              exercise_id INTEGER NOT NULL,
              set_index INTEGER NOT NULL,
              reps INTEGER NOT NULL,
              weight_kg REAL NOT NULL,
              FOREIGN KEY (session_id) REFERENCES ${AppConstants.tableWorkoutSessions} (id) ON DELETE CASCADE,
              FOREIGN KEY (exercise_id) REFERENCES ${AppConstants.tableExercises} (id)
            );
          ''');

          await database.execute('''
            CREATE TABLE ${AppConstants.tableWeightEntries} (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              user_id INTEGER NOT NULL,
              date TEXT NOT NULL,
              weight_kg REAL NOT NULL,
              FOREIGN KEY (user_id) REFERENCES ${AppConstants.tableUsers} (id) ON DELETE CASCADE,
              UNIQUE (user_id, date)
            );
          ''');

          await database.execute('''
            CREATE TABLE ${AppConstants.tableFoods} (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              barcode TEXT UNIQUE,
              name TEXT NOT NULL,
              brand TEXT,
              kcal_100g REAL NOT NULL,
              protein_100g REAL NOT NULL,
              carbs_100g REAL NOT NULL,
              fat_100g REAL NOT NULL,
              image_url TEXT,
              source TEXT NOT NULL
            );
          ''');

          await database.execute('''
            CREATE TABLE ${AppConstants.tableFoodLogEntries} (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              user_id INTEGER NOT NULL,
              food_id INTEGER NOT NULL,
              date TEXT NOT NULL,
              meal_type TEXT NOT NULL,
              grams REAL NOT NULL,
              kcal REAL NOT NULL,
              protein REAL NOT NULL,
              carbs REAL NOT NULL,
              fat REAL NOT NULL,
              FOREIGN KEY (user_id) REFERENCES ${AppConstants.tableUsers} (id) ON DELETE CASCADE,
              FOREIGN KEY (food_id) REFERENCES ${AppConstants.tableFoods} (id)
            );
          ''');
        },
      ),
    );

    dbHelper.setDatabaseForTesting(db);
    userRepo = UserRepository(dbHelper: dbHelper);
    planRepo = PlanRepository(dbHelper: dbHelper);
    sessionRepo = SessionRepository(dbHelper: dbHelper);
    foodRepo = FoodRepository(dbHelper: dbHelper);
    foodLogRepo = FoodLogRepository(dbHelper: dbHelper);
  });

  tearDown(() async {
    await db.close();
    dbHelper.setDatabaseForTesting(null);
  });

  group('UserRepository Tests', () {
    test('insert, findById, findByEmail and update', () async {
      final user = User(
        name: 'Nguyen Van A',
        email: 'userA@example.com',
        passwordHash: 'hash123',
        salt: 'salt123',
        createdAt: '2026-11-05T10:00:00Z',
      );

      final id = await userRepo.insert(user);
      expect(id, greaterThan(0));

      final byEmail = await userRepo.findByEmail('USERA@example.com');
      expect(byEmail, isNotNull);
      expect(byEmail!.id, id);
      expect(byEmail.name, 'Nguyen Van A');

      final byId = await userRepo.findById(id);
      expect(byId, isNotNull);
      expect(byId!.email, 'userA@example.com');

      final updated = byId.copyWith(weightKg: 75.0, goal: 'lose_fat');
      final rowsUpdated = await userRepo.update(updated);
      expect(rowsUpdated, 1);

      final reFetched = await userRepo.findById(id);
      expect(reFetched!.weightKg, 75.0);
      expect(reFetched.goal, 'lose_fat');
    });

    test('Duplicate email throws DuplicateEmailException (NFR-03, A01)', () async {
      final user1 = User(
        name: 'User One',
        email: 'duplicate@example.com',
        passwordHash: 'h1',
        salt: 's1',
        createdAt: '2026-11-05T10:00:00Z',
      );
      await userRepo.insert(user1);

      final user2 = User(
        name: 'User Two',
        email: 'duplicate@example.com',
        passwordHash: 'h2',
        salt: 's2',
        createdAt: '2026-11-05T11:00:00Z',
      );

      expect(
        () async => await userRepo.insert(user2),
        throwsA(isA<DuplicateEmailException>()),
      );
    });
  });

  group('PlanRepository and SessionRepository CASCADE / SET NULL Tests', () {
    test('Plan creation, getFull, update, cascade deletion, and session SET NULL preservation', () async {
      // 1. Create User
      final userId = await userRepo.insert(User(
        name: 'Athlete',
        email: 'athlete@example.com',
        passwordHash: 'h',
        salt: 's',
        createdAt: '2026-11-05',
      ));

      // 2. Insert sample exercises into tableExercises
      final ex1 = Exercise(
        sourceId: '0025',
        nameEn: 'Bench Press',
        nameVi: 'Đẩy ngực ngang',
        bodyPart: 'chest',
      );
      final ex2 = Exercise(
        sourceId: '0030',
        nameEn: 'Squat',
        nameVi: 'Gánh đùi',
        bodyPart: 'upper legs',
      );
      final ex1Id = await db.insert(AppConstants.tableExercises, ex1.toMap());
      final ex2Id = await db.insert(AppConstants.tableExercises, ex2.toMap());

      // 3. Create Plan with 2 Days
      final planId = await planRepo.createPlan(
        plan: WorkoutPlan(
          userId: userId,
          name: 'Split A/B',
          createdAt: '2026-11-05',
        ),
        days: [
          PlanDayInput(
            name: 'Chest Day',
            dayIndex: 0,
            exercises: [
              PlanExerciseInput(
                exerciseId: ex1Id,
                orderIndex: 0,
                targetSets: 4,
                targetReps: 10,
              ),
            ],
          ),
          PlanDayInput(
            name: 'Leg Day',
            dayIndex: 1,
            exercises: [
              PlanExerciseInput(
                exerciseId: ex2Id,
                orderIndex: 0,
                targetSets: 5,
                targetReps: 8,
              ),
            ],
          ),
        ],
      );

      // Verify getFull
      final fullPlan = await planRepo.getFull(planId);
      expect(fullPlan, isNotNull);
      expect(fullPlan!.plan.name, 'Split A/B');
      expect(fullPlan.days.length, 2);
      expect(fullPlan.days[0].exercises.length, 1);
      expect(fullPlan.days[0].exercises[0].exercise?.nameVi, 'Đẩy ngực ngang');

      final firstDayId = fullPlan.days[0].day.id!;

      // 4. Create a workout session linked to firstDayId
      final sessionId = await sessionRepo.insertSession(WorkoutSession(
        userId: userId,
        planDayId: firstDayId,
        startedAt: '2026-11-05T07:00:00Z',
      ));

      // Add sets
      final setId = await sessionRepo.insertSet(SetLog(
        sessionId: sessionId,
        exerciseId: ex1Id,
        setIndex: 1,
        reps: 10,
        weightKg: 80.0,
      ));
      expect(setId, greaterThan(0));

      await sessionRepo.finishSession(
        sessionId: sessionId,
        endedAt: DateTime.parse('2026-11-05T08:00:00Z'),
        totalVolume: 800.0,
      );

      final fullSessionBefore = await sessionRepo.getFull(sessionId);
      expect(fullSessionBefore, isNotNull);
      expect(fullSessionBefore!.session.planDayId, firstDayId);
      expect(fullSessionBefore.session.totalVolume, 800.0);
      expect(fullSessionBefore.sets.length, 1);

      // 5. TEST ON DELETE CASCADE & SET NULL:
      // Delete the Workout Plan
      await planRepo.deletePlan(planId);

      // Verify plan is deleted
      final plans = await planRepo.findByUser(userId);
      expect(plans.isEmpty, isTrue);

      // Verify plan_days and plan_exercises are cascaded deleted
      final daysLeft = await db.query(AppConstants.tablePlanDays, where: 'plan_id = ?', whereArgs: [planId]);
      expect(daysLeft.isEmpty, isTrue);

      final exercisesLeft = await db.query(AppConstants.tablePlanExercises, where: 'plan_day_id = ?', whereArgs: [firstDayId]);
      expect(exercisesLeft.isEmpty, isTrue);

      // CRITICAL REQUIREMENT:
      // workout_sessions.plan_day_id must be SET NULL, but session and set_logs remain!
      final sessionAfter = await sessionRepo.getFull(sessionId);
      expect(sessionAfter, isNotNull, reason: 'Session must NOT be deleted when plan is deleted!');
      expect(sessionAfter!.session.planDayId, isNull, reason: 'plan_day_id must be SET NULL!');
      expect(sessionAfter.sets.length, 1, reason: 'Set logs must be preserved!');
    });
  });

  group('FoodRepository and FoodLogRepository Tests', () {
    test('Food and FoodLog CRUD and nutrition totals calculation', () async {
      final userId = await userRepo.insert(User(
        name: 'Eater',
        email: 'eater@example.com',
        passwordHash: 'h',
        salt: 's',
        createdAt: '2026-11-05',
      ));

      final food = Food(
        barcode: '1234567890123',
        name: 'Oatmeal',
        brand: 'Quaker',
        kcal100g: 375.0,
        protein100g: 12.5,
        carbs100g: 65.0,
        fat100g: 7.0,
        source: 'manual',
      );

      final foodId = await foodRepo.insert(food);
      expect(foodId, greaterThan(0));

      final byBarcode = await foodRepo.findByBarcode('1234567890123');
      expect(byBarcode, isNotNull);
      expect(byBarcode!.name, 'Oatmeal');

      final searchResults = await foodRepo.search('oat');
      expect(searchResults.length, 1);

      // Insert FoodLogEntry
      final log1 = FoodLogEntry(
        userId: userId,
        foodId: foodId,
        date: '2026-11-05',
        mealType: 'breakfast',
        grams: 100.0,
        kcal: 375.0,
        protein: 12.5,
        carbs: 65.0,
        fat: 7.0,
      );
      final log1Id = await foodLogRepo.insert(log1);
      expect(log1Id, greaterThan(0));

      final log2 = FoodLogEntry(
        userId: userId,
        foodId: foodId,
        date: '2026-11-05',
        mealType: 'snack',
        grams: 50.0,
        kcal: 187.5,
        protein: 6.25,
        carbs: 32.5,
        fat: 3.5,
      );
      await foodLogRepo.insert(log2);

      // Query by date
      final logs = await foodLogRepo.findByDate(userId, '2026-11-05');
      expect(logs.length, 2);
      expect(logs[0].food?.name, 'Oatmeal');

      // Check totals
      final totals = await foodLogRepo.totalsByDate(userId, '2026-11-05');
      expect(totals.kcal, 375.0 + 187.5);
      expect(totals.protein, 12.5 + 6.25);
      expect(totals.carbs, 65.0 + 32.5);
      expect(totals.fat, 7.0 + 3.5);
    });
  });
}

