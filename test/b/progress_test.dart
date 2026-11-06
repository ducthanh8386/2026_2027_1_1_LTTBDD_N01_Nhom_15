import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:fit_track/core/constants.dart';
import 'package:fit_track/data/database_helper.dart';
import 'package:fit_track/data/repositories/weight_repository.dart';
import 'package:fit_track/models/weight_entry.dart';
import 'package:fit_track/providers/progress_provider.dart';
import 'package:fit_track/services/stats_service.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late Database db;
  late WeightRepository weightRepo;
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
          await database.execute('''
            CREATE TABLE ${AppConstants.tableWeightEntries} (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              user_id INTEGER NOT NULL,
              date TEXT NOT NULL,
              weight_kg REAL NOT NULL,
              UNIQUE(user_id, date)
            );
          ''');
        },
      ),
    );

    final mockHelper = DatabaseHelper();
    mockHelper.setDatabaseForTesting(db);
    weightRepo = WeightRepository(dbHelper: mockHelper);
    statsService = StatsService(weights: weightRepo);
  });

  tearDown(() async {
    await db.close();
  });

  group('WeightRepository Tests', () {
    test('upsert and latest', () async {
      await weightRepo.upsert(const WeightEntry(
        userId: 1,
        date: '2026-11-01',
        weightKg: 70.0,
      ));

      final latest = await weightRepo.latest(1);
      expect(latest, isNotNull);
      expect(latest!.weightKg, equals(70.0));
      expect(latest.date, equals('2026-11-01'));
    });

    test('upsert on same date replaces existing entry', () async {
      await weightRepo.upsert(const WeightEntry(
        userId: 1,
        date: '2026-11-01',
        weightKg: 70.0,
      ));

      // Overwrite with 71.5 kg
      await weightRepo.upsert(const WeightEntry(
        userId: 1,
        date: '2026-11-01',
        weightKg: 71.5,
      ));

      final all = await weightRepo.findRange(
        1,
        DateTime(2026, 11, 1),
        DateTime(2026, 11, 2),
      );
      expect(all.length, equals(1));
      expect(all.first.weightKg, equals(71.5));
    });

    test('findRange filters correctly by date range', () async {
      await weightRepo.upsert(const WeightEntry(userId: 1, date: '2026-10-01', weightKg: 68.0));
      await weightRepo.upsert(const WeightEntry(userId: 1, date: '2026-10-15', weightKg: 69.0));
      await weightRepo.upsert(const WeightEntry(userId: 1, date: '2026-11-01', weightKg: 70.0));

      final filtered = await weightRepo.findRange(
        1,
        DateTime(2026, 10, 10),
        DateTime(2026, 10, 31),
      );
      expect(filtered.length, equals(1));
      expect(filtered.first.date, equals('2026-10-15'));
    });

    test('delete removes entry', () async {
      await weightRepo.upsert(const WeightEntry(userId: 1, date: '2026-11-01', weightKg: 70.0));
      final entry = await weightRepo.latest(1);
      expect(entry, isNotNull);

      await weightRepo.delete(entry!.id!);
      final after = await weightRepo.latest(1);
      expect(after, isNull);
    });
  });

  group('StatsService Tests', () {
    test('upsertWeight and weightSeries', () async {
      final today = DateTime.now();
      await statsService.upsertWeight(1, today.subtract(const Duration(days: 3)), 70.0);
      await statsService.upsertWeight(1, today, 69.5);

      final series7 = await statsService.weightSeries(1, StatsRange.days7);
      expect(series7.length, equals(2));
      expect(series7.last.kg, equals(69.5));

      final seriesAll = await statsService.weightSeries(1, StatsRange.all);
      expect(seriesAll.length, equals(2));
    });
  });

  group('ProgressProvider Tests', () {
    test('updateUser reloads and stores weight points', () async {
      final provider = ProgressProvider(service: statsService);
      final today = DateTime.now();

      await statsService.upsertWeight(1, today, 72.0);

      provider.updateUser(1);
      await Future.delayed(const Duration(milliseconds: 50));

      expect(provider.weightPoints.length, equals(1));
      expect(provider.weightPoints.first.kg, equals(72.0));
    });

    test('addWeight adds entry and updates provider state', () async {
      final provider = ProgressProvider(service: statsService);
      provider.updateUser(1);
      await Future.delayed(const Duration(milliseconds: 50));

      final now = DateTime.now();
      await provider.addWeight(now, 73.0);

      expect(provider.weightPoints.length, equals(1));
      expect(provider.weightPoints.first.kg, equals(73.0));
    });
  });
}

