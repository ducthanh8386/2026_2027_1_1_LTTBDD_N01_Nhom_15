import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:fit_track/core/constants.dart';
import 'package:fit_track/data/database_helper.dart';
import 'package:fit_track/data/remote/off_api_client.dart';
import 'package:fit_track/data/repositories/food_repository.dart';
import 'package:fit_track/data/repositories/stats_repository.dart';
import 'package:fit_track/models/food.dart';
import 'package:fit_track/services/auth_service.dart';
import 'package:fit_track/services/nutrition_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late Database db;
  late DatabaseHelper dbHelper;

  setUp(() async {
    dbHelper = DatabaseHelper();
    db = await databaseFactory.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: 1,
        onConfigure: (db) async {
          await db.execute('PRAGMA foreign_keys = ON;');
        },
        onCreate: (db, version) async {
          await DatabaseHelper.onCreate(db, version);
        },
      ),
    );
    dbHelper.setDatabaseForTesting(db);
  });

  tearDown(() async {
    await db.close();
    dbHelper.setDatabaseForTesting(null);
  });

  group('NFR Performance & Non-Functional Verification Tests', () {
    test('TC-NFR-02: SQLite query performance is under 300ms for 1000 records', () async {
      // 1. Setup session for user 1
      await db.insert(AppConstants.tableUsers, {
        'id': 1,
        'name': 'Perf Test User',
        'email': 'perf@test.com',
        'password_hash': 'hash',
        'salt': 'salt',
        'created_at': DateTime.now().toIso8601String(),
      });

      final sessionId = await db.insert(AppConstants.tableWorkoutSessions, {
        'id': 1,
        'user_id': 1,
        'started_at': '2026-11-01T08:00:00.000',
        'ended_at': '2026-11-01T09:30:00.000',
        'total_volume': 50000.0,
      });

      // 2. Batch insert 1000 set logs
      final batch = db.batch();
      for (int i = 1; i <= 1000; i++) {
        batch.insert(AppConstants.tableSetLogs, {
          'session_id': sessionId,
          'exercise_id': (i % 20) + 1, // across 20 exercises
          'set_index': i,
          'reps': 10,
          'weight_kg': 50.0 + (i % 50),
        });
      }
      await batch.commit(noResult: true);

      // 3. Measure query execution time with Stopwatch
      final statsRepo = StatsRepository(dbHelper: dbHelper);
      final stopwatch = Stopwatch()..start();

      final volumeRecords = await statsRepo.getVolumeByDateRange(
        userId: 1,
        from: DateTime(2026, 11, 1),
        to: DateTime(2026, 11, 30),
      );

      final maxWeights = await statsRepo.getMaxWeightByExercise(
        userId: 1,
        exerciseId: 1,
        from: DateTime(2026, 11, 1),
        to: DateTime(2026, 11, 30),
      );

      stopwatch.stop();
      final elapsedMs = stopwatch.elapsedMilliseconds;

      // Verify correctness
      expect(volumeRecords, isNotEmpty);
      expect(maxWeights, isNotEmpty);

      // Verify NFR constraint: Execution time must be strictly < 300 ms
      expect(
        elapsedMs,
        lessThan(300),
        reason: 'Complex SQLite aggregation queries on 1000 records must execute in < 300ms (Actual: ${elapsedMs}ms)',
      );
    });

    test('TC-NFR-03: API client enforces 10s timeout and structured exception', () async {
      // Mock client that simulates a hanging connection that exceeds timeout
      final mockClient = MockClient((request) async {
        await Future.delayed(const Duration(milliseconds: 1500));
        return http.Response('{}', 200);
      });

      // Custom timeout client with 500ms timeout to simulate timeout in test
      final apiClient = OffApiClient(
        client: mockClient,
        timeoutDuration: const Duration(milliseconds: 500),
      );

      OffApiException? caughtException;
      try {
        await apiClient.fetchProduct('8934563138164');
      } on OffApiException catch (e) {
        caughtException = e;
      }

      expect(caughtException, isNotNull);
      expect(caughtException!.type, equals(OffExceptionType.timeout));
      expect(caughtException.message.toLowerCase().contains('timed out'), isTrue);
    });

    test('TC-NFR-04: Password security - passwords are hashed with SHA-256 and unique salt, never plain text', () {
      const rawPassword = 'MySecretPassword123!';
      final salt1 = AuthService.generateSalt();
      final salt2 = AuthService.generateSalt();

      expect(salt1, isNot(equals(salt2)), reason: 'Salt must be randomly generated via Random.secure()');

      final hash1 = AuthService.hashPassword(rawPassword, salt1);
      final hash2 = AuthService.hashPassword(rawPassword, salt2);

      // Verify hashes are different for the same password due to salt
      expect(hash1, isNot(equals(hash2)));

      // Verify hash is valid SHA-256 (64 hex characters)
      expect(hash1.length, equals(64));
      expect(hash2.length, equals(64));
      expect(RegExp(r'^[a-f0-9]{64}$').hasMatch(hash1), isTrue);

      // Verify raw password is never present in hash
      expect(hash1.contains(rawPassword), isFalse);
      expect(hash2.contains(rawPassword), isFalse);
    });

    test('TC-NFR-05: Privacy verification - API calls send only the barcode, no user PII', () async {
      String? capturedUrl;
      Map<String, String>? capturedHeaders;

      final mockClient = MockClient((request) async {
        capturedUrl = request.url.toString();
        capturedHeaders = request.headers;
        return http.Response(
          jsonEncode({
            'status': 1,
            'product': {
              'product_name': 'Test Food',
              'nutriments': {'energy-kcal_100g': 100},
            },
          }),
          200,
        );
      });

      final apiClient = OffApiClient(client: mockClient);
      await apiClient.fetchProduct('1234567890');

      expect(capturedUrl, equals('https://world.openfoodfacts.org/api/v2/product/1234567890.json'));
      expect(capturedHeaders?['User-Agent'], equals(OffApiClient.userAgent));

      // Ensure no Authorization header or sensitive user cookies/tokens are sent
      expect(capturedHeaders?['Authorization'], isNull);
      expect(capturedHeaders?['Cookie'], isNull);
    });

    test('TC-NFR-06: Offline capability - NutritionService uses local cache when food already exists in SQLite', () async {
      final foodRepo = FoodRepository(dbHelper: dbHelper);
      const cachedFood = Food(
        id: 1,
        barcode: '8936036010015',
        name: 'Mì Hảo Hảo Tôm Chua Cay',
        brand: 'Acecook',
        kcal100g: 450.0,
        protein100g: 9.0,
        carbs100g: 65.0,
        fat100g: 17.0,
        source: 'off',
      );
      await foodRepo.insert(cachedFood);

      // Mock client that throws error if internet were accessed
      final mockClient = MockClient((request) async {
        throw Exception('Network should not be touched for cached foods!');
      });

      final apiClient = OffApiClient(client: mockClient);
      final nutritionService = NutritionService(
        foodRepo: foodRepo,
        offClient: apiClient,
      );

      // Lookup barcode should return local food without calling API
      final result = await nutritionService.lookupBarcode('8936036010015');

      expect(result, isNotNull);
      expect(result.name, equals('Mì Hảo Hảo Tôm Chua Cay'));
      expect(result.brand, equals('Acecook'));
      expect(result.kcal100g, equals(450.0));
    });
  });
}
