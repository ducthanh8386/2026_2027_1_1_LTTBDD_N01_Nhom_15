import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:fit_track/core/constants.dart';
import 'package:fit_track/data/database_helper.dart';
import 'package:fit_track/data/repositories/exercise_repository.dart';
import 'package:fit_track/data/repositories/plan_repository.dart';
import 'package:fit_track/data/repositories/user_repository.dart';
import 'package:fit_track/models/exercise.dart';
import 'package:fit_track/models/user.dart';
import 'package:fit_track/providers/plan_provider.dart';
import 'package:fit_track/services/workout_service.dart';

class MockExerciseRepository extends ExerciseRepository {
  final Map<String, Exercise> _exercisesBySourceId = {};

  void addMockExercise(Exercise exercise) {
    _exercisesBySourceId[exercise.sourceId] = exercise;
  }

  @override
  Future<Exercise?> findBySourceId(String sourceId) async {
    return _exercisesBySourceId[sourceId];
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late Database db;
  late DatabaseHelper dbHelper;
  late UserRepository userRepo;
  late PlanRepository planRepo;
  late MockExerciseRepository mockExerciseRepo;
  late WorkoutService workoutService;
  late PlanProvider planProvider;

  final testUser = User(
    email: 'plan_test@example.com',
    passwordHash: 'hash',
    salt: 'salt',
    name: 'Plan Tester',
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
          await database.execute('''
            CREATE TABLE ${AppConstants.tableUsers} (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              email TEXT UNIQUE NOT NULL,
              password_hash TEXT NOT NULL,
              salt TEXT NOT NULL,
              name TEXT NOT NULL,
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
              FOREIGN KEY (user_id) REFERENCES ${AppConstants.tableUsers}(id) ON DELETE CASCADE
            );
          ''');
          await database.execute('''
            CREATE TABLE ${AppConstants.tablePlanDays} (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              plan_id INTEGER NOT NULL,
              day_index INTEGER NOT NULL,
              name TEXT NOT NULL,
              FOREIGN KEY (plan_id) REFERENCES ${AppConstants.tableWorkoutPlans}(id) ON DELETE CASCADE
            );
          ''');
          await database.execute('''
            CREATE TABLE ${AppConstants.tablePlanExercises} (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              plan_day_id INTEGER NOT NULL,
              exercise_id INTEGER NOT NULL,
              order_index INTEGER NOT NULL,
              target_sets INTEGER NOT NULL DEFAULT 3,
              target_reps INTEGER NOT NULL DEFAULT 10,
              FOREIGN KEY (plan_day_id) REFERENCES ${AppConstants.tablePlanDays}(id) ON DELETE CASCADE,
              FOREIGN KEY (exercise_id) REFERENCES ${AppConstants.tableExercises}(id)
            );
          ''');
        },
      ),
    );

    dbHelper.setDatabaseForTesting(db);
    userRepo = UserRepository(dbHelper: dbHelper);
    planRepo = PlanRepository(dbHelper: dbHelper);
    mockExerciseRepo = MockExerciseRepository();
    workoutService = WorkoutService(
      planRepository: planRepo,
      exerciseRepository: mockExerciseRepo,
    );
    planProvider = PlanProvider(workoutService: workoutService);

    testUserId = await userRepo.insert(testUser);

    // Seed mock exercises into DB
    final ex1Id = await db.insert(AppConstants.tableExercises, {
      'source_id': '0025',
      'name_en': 'barbell bench press',
      'name_vi': 'Đẩy ngực với tạ đòn',
      'body_part': 'chest',
      'target': 'pectorals',
      'equipment': 'barbell',
      'secondary_muscles': '["triceps", "shoulders"]',
    });
    mockExerciseRepo.addMockExercise(
      Exercise(
        id: ex1Id,
        sourceId: '0025',
        nameEn: 'barbell bench press',
        nameVi: 'Đẩy ngực với tạ đòn',
        bodyPart: 'chest',
      ),
    );

    final ex2Id = await db.insert(AppConstants.tableExercises, {
      'source_id': '0026',
      'name_en': 'barbell squat',
      'name_vi': 'Gánh đùi tạ đòn',
      'body_part': 'legs',
      'target': 'quads',
      'equipment': 'barbell',
      'secondary_muscles': '["glutes", "hamstrings"]',
    });
    mockExerciseRepo.addMockExercise(
      Exercise(
        id: ex2Id,
        sourceId: '0026',
        nameEn: 'barbell squat',
        nameVi: 'Gánh đùi tạ đòn',
        bodyPart: 'legs',
      ),
    );
  });

  tearDown(() async {
    await db.close();
  });

  group('A05 - Validation Rules', () {
    test('Plan with empty name throws ValidationException', () {
      expect(
        () => workoutService.validatePlan(
          name: '   ',
          days: [
            const PlanDayInput(
              name: 'Day 1',
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
        ),
        throwsA(isA<ValidationException>().having(
          (e) => e.message,
          'message',
          contains('Tên kế hoạch không được để trống'),
        )),
      );
    });

    test('Plan with 0 days throws ValidationException', () {
      expect(
        () => workoutService.validatePlan(name: 'Valid Name', days: []),
        throwsA(isA<ValidationException>().having(
          (e) => e.message,
          'message',
          contains('Kế hoạch phải có ít nhất một ngày tập'),
        )),
      );
    });

    test('Plan day with 0 exercises is blocked with clear message', () {
      expect(
        () => workoutService.validatePlan(
          name: 'Valid Plan',
          days: [
            const PlanDayInput(name: 'Day 1', dayIndex: 0, exercises: []),
          ],
        ),
        throwsA(isA<ValidationException>().having(
          (e) => e.message,
          'message',
          contains('phải có ít nhất một bài tập'),
        )),
      );
    });

    test('Plan exercise with sets or reps <= 0 is blocked', () {
      expect(
        () => workoutService.validatePlan(
          name: 'Valid Plan',
          days: [
            const PlanDayInput(
              name: 'Day 1',
              dayIndex: 0,
              exercises: [
                PlanExerciseInput(
                  exerciseId: 1,
                  orderIndex: 0,
                  targetSets: 0,
                  targetReps: 10,
                ),
              ],
            ),
          ],
        ),
        throwsA(isA<ValidationException>().having(
          (e) => e.message,
          'message',
          contains('lớn hơn 0'),
        )),
      );
    });
  });

  group('A05 - CRUD & Persistence', () {
    test('Create plan 3 days x multiple exercises persists correctly', () async {
      final days = [
        const PlanDayInput(
          name: 'Ngày 1 - Ngực',
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
        const PlanDayInput(
          name: 'Ngày 2 - Chân',
          dayIndex: 1,
          exercises: [
            PlanExerciseInput(
              exerciseId: 2,
              orderIndex: 0,
              targetSets: 4,
              targetReps: 8,
            ),
          ],
        ),
        const PlanDayInput(
          name: 'Ngày 3 - Toàn thân',
          dayIndex: 2,
          exercises: [
            PlanExerciseInput(
              exerciseId: 1,
              orderIndex: 0,
              targetSets: 3,
              targetReps: 12,
            ),
            PlanExerciseInput(
              exerciseId: 2,
              orderIndex: 1,
              targetSets: 3,
              targetReps: 12,
            ),
          ],
        ),
      ];

      final planId = await workoutService.createPlan(
        userId: testUserId,
        name: 'Giáo án 3 ngày',
        days: days,
      );

      // Re-read from DB
      final fullPlan = await workoutService.getFullPlan(planId);
      expect(fullPlan, isNotNull);
      expect(fullPlan!.plan.name, 'Giáo án 3 ngày');
      expect(fullPlan.days.length, 3);
      expect(fullPlan.days[0].day.name, 'Ngày 1 - Ngực');
      expect(fullPlan.days[0].exercises.length, 1);
      expect(fullPlan.days[0].exercises[0].planExercise.targetSets, 3);

      expect(fullPlan.days[2].day.name, 'Ngày 3 - Toàn thân');
      expect(fullPlan.days[2].exercises.length, 2);
      expect(fullPlan.days[2].exercises[1].exercise?.nameEn, 'barbell squat');
    });

    test('Update plan and delete plan with CASCADE work properly', () async {
      final planId = await workoutService.createPlan(
        userId: testUserId,
        name: 'Original Plan',
        days: [
          const PlanDayInput(
            name: 'Day A',
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

      // Update plan
      final initial = await workoutService.getFullPlan(planId);
      await workoutService.updatePlan(
        plan: initial!.plan.copyWith(name: 'Updated Plan Name'),
        days: [
          const PlanDayInput(
            name: 'Day Modified',
            dayIndex: 0,
            exercises: [
              PlanExerciseInput(
                exerciseId: 2,
                orderIndex: 0,
                targetSets: 5,
                targetReps: 5,
              ),
            ],
          ),
        ],
      );

      final updated = await workoutService.getFullPlan(planId);
      expect(updated!.plan.name, 'Updated Plan Name');
      expect(updated.days[0].day.name, 'Day Modified');
      expect(updated.days[0].exercises[0].planExercise.targetSets, 5);

      // Delete plan
      final deletedCount = await workoutService.deletePlan(planId);
      expect(deletedCount, 1);

      final checkDeleted = await workoutService.getFullPlan(planId);
      expect(checkDeleted, isNull);

      // Verify CASCADE deleted days and plan exercises
      final remainingDays = await db.query(
        AppConstants.tablePlanDays,
        where: 'plan_id = ?',
        whereArgs: [planId],
      );
      expect(remainingDays, isEmpty);
    });
  });

  group('A05 - Sample Plans and Localization', () {
    test('Seeding sample plan creates a copy belonging to current user', () async {
      final createdIds = await workoutService.seedSamplePlans(
        testUserId,
        locale: 'vi',
      );
      expect(createdIds, isNotEmpty);

      final userPlans = await workoutService.getPlansByUser(testUserId);
      expect(userPlans.length, equals(createdIds.length));
      expect(userPlans.every((p) => p.userId == testUserId), isTrue);
      expect(userPlans.any((p) => p.name.contains('Toàn thân')), isTrue);

      final fullSample = await workoutService.getFullPlan(
        userPlans.firstWhere((p) => p.name.contains('Toàn thân')).id!,
      );
      expect(fullSample, isNotNull);
      expect(
        fullSample!.days.first.exercises.any(
          (e) => e.exercise?.sourceId == '0025',
        ),
        isTrue,
      );
    });

    test('Exercise localizedName changes correctly by locale', () {
      final ex = Exercise(
        id: 1,
        sourceId: '0025',
        nameEn: 'barbell bench press',
        nameVi: 'Đẩy ngực với tạ đòn',
        bodyPart: 'chest',
      );

      expect(ex.localizedName('vi'), 'Đẩy ngực với tạ đòn');
      expect(ex.localizedName('en'), 'barbell bench press');
      // Fallback to EN if locale is different
      expect(ex.localizedName('fr'), 'barbell bench press');
    });

    test('PlanProvider draft management operations', () async {
      planProvider.initDraft();
      expect(planProvider.draft, isNotNull);
      expect(planProvider.draft!.days.length, 1);

      planProvider.updateDraftName('Draft My Plan');
      expect(planProvider.draft!.name, 'Draft My Plan');

      planProvider.addDraftDay('Ngày 2');
      expect(planProvider.draft!.days.length, 2);

      final sampleEx = Exercise(
        id: 1,
        sourceId: '0025',
        nameEn: 'barbell bench press',
        nameVi: 'Đẩy ngực với tạ đòn',
        bodyPart: 'chest',
      );

      planProvider.addExercisesToDay(0, [sampleEx]);
      expect(planProvider.draft!.days[0].exercises.length, 1);
      expect(planProvider.draft!.days[0].exercises[0].targetSets, 3);
      expect(planProvider.draft!.days[0].exercises[0].targetReps, 10);

      planProvider.updateExerciseSetsReps(0, 0, 4, 12);
      expect(planProvider.draft!.days[0].exercises[0].targetSets, 4);
      expect(planProvider.draft!.days[0].exercises[0].targetReps, 12);

      // Reorder with 2 exercises
      final sampleEx2 = Exercise(
        id: 2,
        sourceId: '0026',
        nameEn: 'barbell squat',
        nameVi: 'Gánh đùi tạ đòn',
        bodyPart: 'legs',
      );
      planProvider.addExercisesToDay(0, [sampleEx2]);
      expect(planProvider.draft!.days[0].exercises.length, 2);

      planProvider.reorderDraftExercises(0, 0, 2);
      expect(planProvider.draft!.days[0].exercises[0].exerciseId, 2);
      expect(planProvider.draft!.days[0].exercises[1].exerciseId, 1);
    });
  });
}
