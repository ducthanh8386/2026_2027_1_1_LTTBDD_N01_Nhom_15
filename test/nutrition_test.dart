import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:fit_track/data/database_helper.dart';
import 'package:fit_track/data/remote/off_api_client.dart';
import 'package:fit_track/data/repositories/food_log_repository.dart';
import 'package:fit_track/data/repositories/food_repository.dart';
import 'package:fit_track/data/repositories/user_repository.dart';
import 'package:fit_track/models/food.dart';
import 'package:fit_track/models/user.dart';
import 'package:fit_track/providers/nutrition_provider.dart';
import 'package:fit_track/services/nutrition_service.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('OffApiClient Tests', () {
    test('successfully parses Open Food Facts v2 product response', () async {
      final mockJson = jsonEncode({
        'status': 1,
        'code': '8934567890123',
        'product': {
          'product_name': 'Sữa tươi tiệt trùng',
          'brands': 'Vinamilk',
          'image_front_url': 'https://example.com/milk.jpg',
          'nutriments': {
            'energy-kcal_100g': 70.0,
            'proteins_100g': 3.0,
            'carbohydrates_100g': 8.5,
            'fat_100g': 3.2,
          },
        },
      });

      final mockClient = MockClient((request) async {
        expect(request.url.path, contains('8934567890123.json'));
        expect(request.headers['User-Agent'], isNotEmpty);
        return http.Response.bytes(
          utf8.encode(mockJson),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      });

      final client = OffApiClient(client: mockClient);
      final food = await client.fetchProduct('8934567890123');

      expect(food.barcode, '8934567890123');
      expect(food.name, 'Sữa tươi tiệt trùng');
      expect(food.brand, 'Vinamilk');
      expect(food.kcal100g, 70.0);
      expect(food.protein100g, 3.0);
      expect(food.carbs100g, 8.5);
      expect(food.fat100g, 3.2);
      expect(food.source, 'off');
    });

    test('converts energy from kJ to kcal when energy-kcal is missing', () async {
      final mockJson = jsonEncode({
        'status': 1,
        'product': {
          'product_name': 'Bánh mì sandwich',
          'nutriments': {
            'energy_100g': 1046.0, // 1046 kJ / 4.184 ≈ 250 kcal
            'proteins_100g': 8.0,
            'carbohydrates_100g': 45.0,
            'fat_100g': 2.5,
          },
        },
      });

      final mockClient = MockClient((request) async {
        return http.Response.bytes(
          utf8.encode(mockJson),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      });

      final client = OffApiClient(client: mockClient);
      final food = await client.fetchProduct('123456');

      expect(food.kcal100g, 250.0);
      expect(food.name, 'Bánh mì sandwich');
    });

    test('throws notFound when status is 0 or product not found', () async {
      final mockJson = jsonEncode({
        'status': 0,
        'status_verbose': 'product not found',
      });

      final mockClient = MockClient((request) async {
        return http.Response.bytes(
          utf8.encode(mockJson),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      });

      final client = OffApiClient(client: mockClient);

      expect(
        () => client.fetchProduct('0000000000'),
        throwsA(predicate((e) =>
            e is OffApiException && e.type == OffExceptionType.notFound)),
      );
    });

    test('throws notFound when response is 404', () async {
      final mockClient = MockClient((request) async {
        return http.Response('Not Found', 404);
      });

      final client = OffApiClient(client: mockClient);

      expect(
        () => client.fetchProduct('999999'),
        throwsA(predicate((e) =>
            e is OffApiException && e.type == OffExceptionType.notFound)),
      );
    });

    test('throws noInternet when SocketException occurs', () async {
      final mockClient = MockClient((request) async {
        throw const SocketException('Failed host lookup');
      });

      final client = OffApiClient(client: mockClient);

      expect(
        () => client.fetchProduct('123456'),
        throwsA(predicate((e) =>
            e is OffApiException && e.type == OffExceptionType.noInternet)),
      );
    });
  });

  group('NutritionService Database & Logic Tests', () {
    late DatabaseHelper dbHelper;
    late FoodRepository foodRepo;
    late FoodLogRepository foodLogRepo;
    late UserRepository userRepo;
    late NutritionService service;
    late int testUserId;

    setUp(() async {
      dbHelper = DatabaseHelper();
      final db = await openDatabase(
        inMemoryDatabasePath,
        version: 1,
        onConfigure: (db) async => await db.execute('PRAGMA foreign_keys = ON;'),
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE users (
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
          await db.execute('''
            CREATE TABLE foods (
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
          await db.execute('''
            CREATE TABLE food_log_entries (
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
              FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
              FOREIGN KEY (food_id) REFERENCES foods(id) ON DELETE CASCADE
            );
          ''');
        },
      );
      dbHelper.setDatabaseForTesting(db);

      foodRepo = FoodRepository(dbHelper: dbHelper);
      foodLogRepo = FoodLogRepository(dbHelper: dbHelper);
      userRepo = UserRepository(dbHelper: dbHelper);

      testUserId = await userRepo.insert(User(
        name: 'Thanh Nguyen',
        email: 'test@example.com',
        passwordHash: 'hash',
        salt: 'salt',
        kcalTarget: 2200,
        createdAt: DateTime.now().toIso8601String(),
      ));
    });

    tearDown(() async {
      await dbHelper.close();
    });

    test('addManualFood creates food item in SQLite and returns with id', () async {
      service = NutritionService(foodRepo: foodRepo, foodLogRepo: foodLogRepo);

      final food = await service.addManualFood(
        name: 'Trứng gà luộc',
        brand: 'Ba Huân',
        kcal100g: 155.0,
        protein100g: 13.0,
        carbs100g: 1.1,
        fat100g: 11.0,
      );

      expect(food.id, isNotNull);
      expect(food.name, 'Trứng gà luộc');
      expect(food.source, 'manual');

      final found = await foodRepo.findById(food.id!);
      expect(found?.name, 'Trứng gà luộc');
    });

    test('lookupBarcode uses local cache when already present in database', () async {
      // Pre-insert cached food
      await foodRepo.insert(const Food(
        barcode: '111222333',
        name: 'Cà phê đen đá',
        kcal100g: 10.0,
        protein100g: 0.5,
        carbs100g: 1.0,
        fat100g: 0.0,
        source: 'manual',
      ));

      // Mock client should NEVER be called
      final mockClient = MockClient((req) async {
        throw Exception('API should not be called for cached food');
      });

      final offClient = OffApiClient(client: mockClient);
      service = NutritionService(
        foodRepo: foodRepo,
        foodLogRepo: foodLogRepo,
        offClient: offClient,
      );

      final result = await service.lookupBarcode('111222333');
      expect(result.name, 'Cà phê đen đá');
      expect(result.barcode, '111222333');
    });

    test('lookupBarcode queries API and caches into database when not local', () async {
      final mockJson = jsonEncode({
        'status': 1,
        'product': {
          'product_name': 'Yến mạch Quaker',
          'nutriments': {
            'energy-kcal_100g': 389.0,
            'proteins_100g': 16.9,
            'carbohydrates_100g': 66.3,
            'fat_100g': 6.9,
          },
        },
      });

      final mockClient = MockClient((req) async {
        return http.Response.bytes(
          utf8.encode(mockJson),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      });

      final offClient = OffApiClient(client: mockClient);
      service = NutritionService(
        foodRepo: foodRepo,
        foodLogRepo: foodLogRepo,
        offClient: offClient,
      );

      final result = await service.lookupBarcode('987654321');
      expect(result.name, 'Yến mạch Quaker');
      expect(result.kcal100g, 389.0);

      // Verify that it is now cached in DB
      final cached = await foodRepo.findByBarcode('987654321');
      expect(cached, isNotNull);
      expect(cached?.name, 'Yến mạch Quaker');
    });

    test('addEntry validates grams > 0 and calculates macros correctly', () async {
      service = NutritionService(foodRepo: foodRepo, foodLogRepo: foodLogRepo);

      final food = await service.addManualFood(
        name: 'Ức gà áp chảo',
        kcal100g: 165.0,
        protein100g: 31.0,
        carbs100g: 0.0,
        fat100g: 3.6,
      );

      // Rejects grams <= 0
      expect(
        () => service.addEntry(
          userId: testUserId,
          food: food,
          mealType: 'lunch',
          grams: 0,
          date: '2026-11-08',
        ),
        throwsArgumentError,
      );

      expect(
        () => service.addEntry(
          userId: testUserId,
          food: food,
          mealType: 'lunch',
          grams: -50,
          date: '2026-11-08',
        ),
        throwsArgumentError,
      );

      // 200g ức gà -> ratio = 2.0 -> 330 kcal, 62g protein, 0g carbs, 7.2g fat
      final entry = await service.addEntry(
        userId: testUserId,
        food: food,
        mealType: 'lunch',
        grams: 200,
        date: '2026-11-08',
      );

      expect(entry.id, isNotNull);
      expect(entry.grams, 200);
      expect(entry.kcal, 330.0);
      expect(entry.protein, 62.0);
      expect(entry.carbs, 0.0);
      expect(entry.fat, 7.2);
    });

    test('dailyTotals and getDailyEntries calculate correct totals and relations', () async {
      service = NutritionService(foodRepo: foodRepo, foodLogRepo: foodLogRepo);

      final food1 = await service.addManualFood(
        name: 'Cơm trắng',
        kcal100g: 130.0,
        protein100g: 2.7,
        carbs100g: 28.0,
        fat100g: 0.3,
      );
      final food2 = await service.addManualFood(
        name: 'Thịt bò xào',
        kcal100g: 200.0,
        protein100g: 25.0,
        carbs100g: 2.0,
        fat100g: 10.0,
      );

      // Lunch: 200g cơm (260 kcal) + 150g thịt bò (300 kcal)
      await service.addEntry(
        userId: testUserId,
        food: food1,
        mealType: 'lunch',
        grams: 200,
        date: '2026-11-08',
      );
      await service.addEntry(
        userId: testUserId,
        food: food2,
        mealType: 'lunch',
        grams: 150,
        date: '2026-11-08',
      );

      final entries = await service.getDailyEntries(testUserId, '2026-11-08');
      expect(entries.length, 2);
      expect(entries.first.food?.name, 'Cơm trắng');

      final totals = await service.dailyTotals(testUserId, '2026-11-08');
      expect(totals.kcal, closeTo(560.0, 0.1));
      expect(totals.protein, closeTo(2.7 * 2 + 25.0 * 1.5, 0.1));
    });

    test('updateEntry updates grams and recalculates macros', () async {
      service = NutritionService(foodRepo: foodRepo, foodLogRepo: foodLogRepo);

      final food = await service.addManualFood(
        name: 'Táo Envy',
        kcal100g: 52.0,
        protein100g: 0.3,
        carbs100g: 14.0,
        fat100g: 0.2,
      );

      final entry = await service.addEntry(
        userId: testUserId,
        food: food,
        mealType: 'snack',
        grams: 100,
        date: '2026-11-08',
      );

      expect(entry.kcal, 52.0);

      // Update to 200g
      await service.updateEntry(
        entryId: entry.id!,
        newGrams: 200,
        food: food,
        userId: testUserId,
        mealType: 'snack',
        date: '2026-11-08',
      );

      final totals = await service.dailyTotals(testUserId, '2026-11-08');
      expect(totals.kcal, 104.0);
    });

    test('deleteEntry removes the log entry from daily totals', () async {
      service = NutritionService(foodRepo: foodRepo, foodLogRepo: foodLogRepo);

      final food = await service.addManualFood(
        name: 'Bánh ngọt',
        kcal100g: 400.0,
        protein100g: 5.0,
        carbs100g: 55.0,
        fat100g: 20.0,
      );

      final entry = await service.addEntry(
        userId: testUserId,
        food: food,
        mealType: 'snack',
        grams: 100,
        date: '2026-11-08',
      );

      var entries = await service.getDailyEntries(testUserId, '2026-11-08');
      expect(entries.length, 1);

      await service.deleteEntry(entry.id!);

      entries = await service.getDailyEntries(testUserId, '2026-11-08');
      expect(entries.isEmpty, true);

      final totals = await service.dailyTotals(testUserId, '2026-11-08');
      expect(totals.kcal, 0.0);
    });
  });

  group('NutritionProvider State Tests', () {
    late DatabaseHelper dbHelper;
    late FoodRepository foodRepo;
    late FoodLogRepository foodLogRepo;
    late UserRepository userRepo;
    late NutritionService service;
    late NutritionProvider provider;
    late int testUserId;

    setUp(() async {
      dbHelper = DatabaseHelper();
      final db = await openDatabase(
        inMemoryDatabasePath,
        version: 1,
        onConfigure: (db) async => await db.execute('PRAGMA foreign_keys = ON;'),
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE users (
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
          await db.execute('''
            CREATE TABLE foods (
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
          await db.execute('''
            CREATE TABLE food_log_entries (
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
              FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
              FOREIGN KEY (food_id) REFERENCES foods(id) ON DELETE CASCADE
            );
          ''');
        },
      );
      dbHelper.setDatabaseForTesting(db);

      foodRepo = FoodRepository(dbHelper: dbHelper);
      foodLogRepo = FoodLogRepository(dbHelper: dbHelper);
      userRepo = UserRepository(dbHelper: dbHelper);
      service = NutritionService(foodRepo: foodRepo, foodLogRepo: foodLogRepo);
      provider = NutritionProvider(service: service);

      testUserId = await userRepo.insert(User(
        name: 'User 1',
        email: 'user1@example.com',
        passwordHash: 'hash',
        salt: 'salt',
        kcalTarget: 2500,
        createdAt: DateTime.now().toIso8601String(),
      ));
    });

    tearDown(() async {
      provider.dispose();
      await dbHelper.close();
    });

    test('updateUser updates target and diary', () async {
      final user = await userRepo.findById(testUserId);
      provider.updateUser(user);

      expect(provider.userId, testUserId);
      expect(provider.dailyTarget, 2500.0);
      expect(provider.remainingKcal, 2500.0);
    });

    test('addFoodEntry, updateEntryGrams and deleteEntry update diary state reactively', () async {
      final user = await userRepo.findById(testUserId);
      provider.updateUser(user);

      final food = await service.addManualFood(
        name: 'Phở bò',
        kcal100g: 110.0,
        protein100g: 8.0,
        carbs100g: 15.0,
        fat100g: 2.5,
      );

      // Add 400g phở -> 440 kcal
      await provider.addFoodEntry(food: food, mealType: 'breakfast', grams: 400);

      expect(provider.entriesByMeal['breakfast']?.length, 1);
      expect(provider.dailyTotals.kcal, 440.0);
      expect(provider.remainingKcal, 2500.0 - 440.0);

      final entryItem = provider.entriesByMeal['breakfast']!.first;

      // Update to 500g -> 550 kcal
      await provider.updateEntryGrams(item: entryItem, newGrams: 500);
      expect(provider.dailyTotals.kcal, 550.0);

      // Delete entry
      await provider.deleteEntry(entryItem.entry.id!);
      expect(provider.entriesByMeal['breakfast']?.isEmpty, true);
      expect(provider.dailyTotals.kcal, 0.0);
    });
  });
}
