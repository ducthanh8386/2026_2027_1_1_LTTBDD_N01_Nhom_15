import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:fit_track/core/constants.dart';
import 'package:fit_track/data/database_helper.dart';
import 'package:fit_track/data/repositories/exercise_repository.dart';
import 'package:fit_track/data/seed/exercise_seed.dart';
import 'package:fit_track/models/exercise.dart';
import 'package:fit_track/providers/exercise_provider.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late Database db;
  late ExerciseRepository repository;

  const testSeedJson = '''
  [
    {
      "source_id": "0025",
      "name_en": "Barbell Bench Press",
      "name_vi": "Nằm đẩy ngực tạ đòn",
      "body_part": "chest",
      "target": "pectorals",
      "equipment": "barbell",
      "secondary_muscles": ["triceps", "shoulders"],
      "instructions_en": "Step 1",
      "instructions_vi": "Bước 1",
      "image_asset": "assets/exercises/images/0025.jpg",
      "gif_asset": "assets/exercises/gifs/0025.gif"
    },
    {
      "source_id": "0027",
      "name_en": "Dumbbell Bench Press",
      "name_vi": "Nằm đẩy ngực tạ đơn",
      "body_part": "chest",
      "target": "pectorals",
      "equipment": "dumbbell",
      "secondary_muscles": ["triceps"],
      "instructions_en": "Step 1",
      "instructions_vi": "Bước 1",
      "image_asset": "assets/exercises/images/0027.jpg",
      "gif_asset": "assets/exercises/gifs/0027.gif"
    },
    {
      "source_id": "0040",
      "name_en": "Barbell Deadlift",
      "name_vi": "Kéo tạ đòn từ sàn",
      "body_part": "back",
      "target": "lower back",
      "equipment": "barbell",
      "secondary_muscles": ["hamstrings"],
      "instructions_en": "Step 1",
      "instructions_vi": "Bước 1",
      "image_asset": "assets/exercises/images/0040.jpg",
      "gif_asset": "assets/exercises/gifs/0040.gif"
    }
  ]
  ''';

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
        },
      ),
    );

    // Seed database
    await ExerciseSeeder.seedIfEmpty(db, jsonString: testSeedJson);

    final mockHelper = DatabaseHelper();
    mockHelper.setDatabaseForTesting(db);
    repository = ExerciseRepository(dbHelper: mockHelper);
  });

  tearDown(() async {
    await db.close();
  });

  group('ExerciseSeeder Tests', () {
    test('seeds data accurately into SQLite', () async {
      final results = await db.query(AppConstants.tableExercises);
      expect(results.length, equals(3));
    });

    test('seed operation is idempotent', () async {
      // Calling seedIfEmpty a second time should not duplicate records
      await ExerciseSeeder.seedIfEmpty(db, jsonString: testSeedJson);
      final results = await db.query(AppConstants.tableExercises);
      expect(results.length, equals(3));
    });
  });

  group('ExerciseRepository Tests', () {
    test('findAll returns all exercises ordered by name_en', () async {
      final all = await repository.findAll();
      expect(all.length, equals(3));
      expect(all.first.nameEn, equals('Barbell Bench Press'));
    });

    test('findAll filters by bodyPart correctly', () async {
      final chest = await repository.findAll(bodyPart: 'chest');
      expect(chest.length, equals(2));
      for (final ex in chest) {
        expect(ex.bodyPart, equals('chest'));
      }

      final back = await repository.findAll(bodyPart: 'back');
      expect(back.length, equals(1));
      expect(back.first.nameEn, equals('Barbell Deadlift'));
    });

    test('findAll filters by equipment correctly', () async {
      final barbells = await repository.findAll(equipment: 'barbell');
      expect(barbells.length, equals(2));

      final dumbbells = await repository.findAll(equipment: 'dumbbell');
      expect(dumbbells.length, equals(1));
      expect(dumbbells.first.nameEn, equals('Dumbbell Bench Press'));
    });

    test('findAll searches with query case-insensitively and diacritic-insensitively', () async {
      // Search in English
      final searchEn = await repository.findAll(query: 'bench');
      expect(searchEn.length, equals(2));

      // Search in Vietnamese with diacritics
      final searchVi = await repository.findAll(query: 'đẩy ngực');
      expect(searchVi.length, equals(2));

      // Search in Vietnamese without diacritics
      final searchNoAccent = await repository.findAll(query: 'day nguc');
      expect(searchNoAccent.length, equals(2));

      // Search by target
      final searchTarget = await repository.findAll(query: 'lower back');
      expect(searchTarget.length, equals(1));
      expect(searchTarget.first.sourceId, equals('0040'));
    });

    test('findById and findBySourceId', () async {
      final bySource = await repository.findBySourceId('0025');
      expect(bySource, isNotNull);
      expect(bySource!.nameEn, equals('Barbell Bench Press'));

      final byId = await repository.findById(bySource.id!);
      expect(byId, isNotNull);
      expect(byId!.sourceId, equals('0025'));

      final notFound = await repository.findById(9999);
      expect(notFound, isNull);
    });

    test('distinctBodyParts and distinctEquipment', () async {
      final parts = await repository.distinctBodyParts();
      expect(parts, containsAll(['chest', 'back']));

      final equips = await repository.distinctEquipment();
      expect(equips, containsAll(['barbell', 'dumbbell']));
    });
  });

  group('ExerciseProvider Tests', () {
    test('loads exercises and caches byId', () async {
      final provider = ExerciseProvider(repository: repository);
      await provider.load();

      expect(provider.exercises.length, equals(3));
      expect(provider.bodyParts, containsAll(['chest', 'back']));

      final ex = provider.exercises.first;
      expect(provider.byId(ex.id!), equals(ex));
    });

    test('filters by body part', () async {
      final provider = ExerciseProvider(repository: repository);
      await provider.load();

      provider.setBodyPart('back');
      expect(provider.exercises.length, equals(1));
      expect(provider.exercises.first.bodyPart, equals('back'));

      provider.setBodyPart(null);
      expect(provider.exercises.length, equals(3));
    });
  });
}
