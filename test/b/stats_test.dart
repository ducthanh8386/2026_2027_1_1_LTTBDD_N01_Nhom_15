import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:fit_track/core/constants.dart';
import 'package:fit_track/data/database_helper.dart';
import 'package:fit_track/data/repositories/stats_repository.dart';
import 'package:fit_track/models/workout_session.dart';
import 'package:fit_track/providers/progress_provider.dart';
import 'package:fit_track/services/stats_service.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late Database db;
  late DatabaseHelper dbHelper;
  late StatsRepository statsRepo;
  late StatsService statsService;

  setUp(() async {
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

    dbHelper = DatabaseHelper();
    dbHelper.setDatabaseForTesting(db);
    statsRepo = StatsRepository(dbHelper: dbHelper);
    statsService = StatsService(stats: statsRepo);

    // Insert dummy user
    await db.insert(
      AppConstants.tableUsers,
      {
        'id': 1,
        'name': 'Test User',
        'email': 'test@example.com',
        'password_hash': 'hash',
        'salt': 'salt',
        'created_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    // Insert dummy exercises
    await db.insert(
      AppConstants.tableExercises,
      {
        'id': 1,
        'source_id': 'ex_1',
        'name_en': 'Bench Press',
        'name_vi': 'Đẩy ngực ngang',
        'body_part': 'chest',
        'target': 'pectorals',
        'equipment': 'barbell',
        'instructions_en': 'Push bar up',
        'instructions_vi': 'Đẩy tạ lên',
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    await db.insert(
      AppConstants.tableExercises,
      {
        'id': 2,
        'source_id': 'ex_2',
        'name_en': 'Squat',
        'name_vi': 'Gánh tạ',
        'body_part': 'legs',
        'target': 'quads',
        'equipment': 'barbell',
        'instructions_en': 'Squat down',
        'instructions_vi': 'Ngồi xổm xuống',
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  });

  tearDown(() async {
    await db.close();
  });

  group('StatsRepository Volume Tests', () {
    test(
      'getVolumeByDateRange returns aggregated volume from set_logs',
      () async {
        // Session 1: completed
        final s1 = await db.insert(AppConstants.tableWorkoutSessions, {
          'user_id': 1,
          'started_at': '2026-11-01T10:00:00.000',
          'ended_at': '2026-11-01T11:00:00.000',
          'total_volume': 1000.0,
        });

        // Sets for Session 1: 10 reps * 50kg = 500, 10 reps * 60kg = 600 -> total 1100
        await db.insert(AppConstants.tableSetLogs, {
          'session_id': s1,
          'exercise_id': 1,
          'set_index': 1,
          'reps': 10,
          'weight_kg': 50.0,
        });
        await db.insert(AppConstants.tableSetLogs, {
          'session_id': s1,
          'exercise_id': 1,
          'set_index': 2,
          'reps': 10,
          'weight_kg': 60.0,
        });

        // Session 2: NOT ended (ongoing) -> should NOT be included
        final s2 = await db.insert(AppConstants.tableWorkoutSessions, {
          'user_id': 1,
          'started_at': '2026-11-02T10:00:00.000',
          'ended_at': null,
          'total_volume': 500.0,
        });
        await db.insert(AppConstants.tableSetLogs, {
          'session_id': s2,
          'exercise_id': 1,
          'set_index': 1,
          'reps': 10,
          'weight_kg': 50.0,
        });

        final records = await statsRepo.getVolumeByDateRange(
          userId: 1,
          from: DateTime(2026, 11, 1),
          to: DateTime(2026, 11, 5),
        );

        expect(records.length, equals(1));
        expect(records.first.date, equals('2026-11-01'));
        expect(records.first.volume, equals(1100.0));
      },
    );

    test('getMaxWeightByExercise returns max weight grouped by date', () async {
      final s1 = await db.insert(AppConstants.tableWorkoutSessions, {
        'user_id': 1,
        'started_at': '2026-11-01T10:00:00.000',
        'ended_at': '2026-11-01T11:00:00.000',
        'total_volume': 0.0,
      });

      // Sets for exercise 1
      await db.insert(AppConstants.tableSetLogs, {
        'session_id': s1,
        'exercise_id': 1,
        'set_index': 1,
        'reps': 10,
        'weight_kg': 50.0,
      });
      await db.insert(AppConstants.tableSetLogs, {
        'session_id': s1,
        'exercise_id': 1,
        'set_index': 2,
        'reps': 8,
        'weight_kg': 75.0, // max is 75
      });
      // Sets for exercise 2 (should be ignored)
      await db.insert(AppConstants.tableSetLogs, {
        'session_id': s1,
        'exercise_id': 2,
        'set_index': 1,
        'reps': 5,
        'weight_kg': 100.0,
      });

      final maxRecords = await statsRepo.getMaxWeightByExercise(
        userId: 1,
        exerciseId: 1,
        from: DateTime(2026, 11, 1),
        to: DateTime(2026, 11, 5),
      );

      expect(maxRecords.length, equals(1));
      expect(maxRecords.first.maxWeight, equals(75.0));
    });

    test('getWeeklyWorkoutStats and getWeeklyTotalKcal', () async {
      final now = DateTime.now();
      final monday = DateTime(
        now.year,
        now.month,
        now.day,
      ).subtract(Duration(days: now.weekday - 1));

      // Completed session this week
      final s1 = await db.insert(AppConstants.tableWorkoutSessions, {
        'user_id': 1,
        'started_at': monday.add(const Duration(hours: 9)).toIso8601String(),
        'ended_at': monday.add(const Duration(hours: 10)).toIso8601String(),
        'total_volume': 800.0,
      });
      await db.insert(AppConstants.tableSetLogs, {
        'session_id': s1,
        'exercise_id': 1,
        'set_index': 1,
        'reps': 10,
        'weight_kg': 80.0,
      });

      // Add food log entry
      final foodId = await db.insert(AppConstants.tableFoods, {
        'name': 'Chicken Breast',
        'kcal_100g': 165.0,
        'protein_100g': 31.0,
        'carbs_100g': 0.0,
        'fat_100g': 3.6,
        'source': 'custom',
      });

      final dateStr =
          '${monday.year.toString().padLeft(4, '0')}-${monday.month.toString().padLeft(2, '0')}-${monday.day.toString().padLeft(2, '0')}';

      await db.insert(AppConstants.tableFoodLogEntries, {
        'user_id': 1,
        'food_id': foodId,
        'date': dateStr,
        'meal_type': 'lunch',
        'grams': 200.0,
        'kcal': 330.0,
        'protein': 62.0,
        'carbs': 0.0,
        'fat': 7.2,
      });

      final weeklyStats = await statsRepo.getWeeklyWorkoutStats(
        userId: 1,
        monday: monday,
      );
      expect(weeklyStats['session_count'], equals(1));
      expect(weeklyStats['total_vol'], equals(800.0));

      final weeklyKcal = await statsRepo.getWeeklyTotalKcal(
        userId: 1,
        monday: monday,
      );
      expect(weeklyKcal, equals(330.0));

      final summary = await statsService.weeklySummary(1);
      expect(summary.sessions, equals(1));
      expect(summary.totalVolume, equals(800.0));
      expect(summary.totalKcal, equals(330.0));
    });
  });

  group('ProgressProvider Integration', () {
    test('loads volumePoints and weeklySummary upon reload', () async {
      final provider = ProgressProvider(service: statsService);
      provider.updateUser(1);

      // Wait microtask
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(provider.isLoading, isFalse);
      expect(provider.weeklySummary, isNotNull);
    });
  });
}
