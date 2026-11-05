import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:fit_track/core/constants.dart';
import 'package:fit_track/data/database_helper.dart';
import 'package:fit_track/data/local/prefs_store.dart';
import 'package:fit_track/data/repositories/user_repository.dart';
import 'package:fit_track/providers/auth_provider.dart';
import 'package:fit_track/services/auth_service.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late Database db;
  late DatabaseHelper dbHelper;
  late UserRepository userRepo;
  late AuthService authService;
  late PrefsStore prefsStore;

  setUp(() async {
    dbHelper = DatabaseHelper();
    db = await databaseFactory.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: 1,
        onConfigure: (db) async => await db.execute('PRAGMA foreign_keys = ON;'),
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE ${AppConstants.tableUsers} (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              name TEXT NOT NULL,
              email TEXT NOT NULL UNIQUE,
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
            CREATE TABLE ${AppConstants.tableWorkoutPlans} (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              user_id INTEGER NOT NULL,
              name TEXT NOT NULL,
              is_active INTEGER NOT NULL DEFAULT 0,
              created_at TEXT NOT NULL,
              FOREIGN KEY (user_id) REFERENCES ${AppConstants.tableUsers}(id) ON DELETE CASCADE
            );
          ''');
          await db.execute('''
            CREATE TABLE ${AppConstants.tableWorkoutSessions} (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              user_id INTEGER NOT NULL,
              plan_day_id INTEGER,
              started_at TEXT NOT NULL,
              ended_at TEXT,
              notes TEXT,
              FOREIGN KEY (user_id) REFERENCES ${AppConstants.tableUsers}(id) ON DELETE CASCADE
            );
          ''');
          await db.execute('''
            CREATE TABLE ${AppConstants.tableWeightEntries} (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              user_id INTEGER NOT NULL,
              date TEXT NOT NULL,
              weight_kg REAL NOT NULL,
              created_at TEXT NOT NULL,
              UNIQUE(user_id, date),
              FOREIGN KEY (user_id) REFERENCES ${AppConstants.tableUsers}(id) ON DELETE CASCADE
            );
          ''');
          await db.execute('''
            CREATE TABLE ${AppConstants.tableFoodLogEntries} (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              user_id INTEGER NOT NULL,
              food_id INTEGER,
              date TEXT NOT NULL,
              meal_type TEXT NOT NULL,
              serving_size REAL NOT NULL,
              kcal REAL NOT NULL,
              protein REAL NOT NULL,
              carbs REAL NOT NULL,
              fat REAL NOT NULL,
              FOREIGN KEY (user_id) REFERENCES ${AppConstants.tableUsers}(id) ON DELETE CASCADE
            );
          ''');
        },
      ),
    );
    dbHelper.setDatabaseForTesting(db);
    userRepo = UserRepository(dbHelper: dbHelper);
    authService = AuthService(userRepo: userRepo);

    SharedPreferences.setMockInitialValues({});
    final sharedPrefs = await SharedPreferences.getInstance();
    prefsStore = PrefsStore(sharedPrefs);
  });

  tearDown(() async {
    await db.close();
    dbHelper.setDatabaseForTesting(null);
  });

  group('AuthService Tests', () {
    test('Password hashing produces SHA-256 and salt is random', () {
      final salt1 = AuthService.generateSalt();
      final salt2 = AuthService.generateSalt();
      expect(salt1, isNot(equals(salt2)));

      final hash1 = AuthService.hashPassword('secret123', salt1);
      final hash2 = AuthService.hashPassword('secret123', salt1);
      final hash3 = AuthService.hashPassword('secret123', salt2);

      expect(hash1, equals(hash2));
      expect(hash1, isNot(equals('secret123')));
      expect(hash1, isNot(equals(hash3)));
      expect(hash1.length, equals(64)); // 32 bytes hex = 64 chars
    });

    test('Register user successfully stores hashed password, not plain text', () async {
      final user = await authService.register(
        name: 'Thanh Nguyen',
        email: 'test@example.com',
        password: 'password123',
      );

      expect(user.id, isNotNull);
      expect(user.name, equals('Thanh Nguyen'));
      expect(user.email, equals('test@example.com'));
      expect(user.passwordHash, isNot(contains('password123')));

      // Direct DB inspection
      final maps = await db.query(AppConstants.tableUsers, where: 'id = ?', whereArgs: [user.id]);
      expect(maps.first['password_hash'], isNot(equals('password123')));
      expect(maps.first['password_hash'], equals(user.passwordHash));
    });

    test('Register duplicate email throws DuplicateEmailException', () async {
      await authService.register(
        name: 'User 1',
        email: 'dup@example.com',
        password: 'password123',
      );

      expect(
        () => authService.register(
          name: 'User 2',
          email: 'dup@example.com',
          password: 'password456',
        ),
        throwsA(isA<DuplicateEmailException>()),
      );
    });

    test('Login with valid credentials returns user', () async {
      await authService.register(
        name: 'Login User',
        email: 'login@example.com',
        password: 'mypassword',
      );

      final loggedIn = await authService.login(
        email: 'login@example.com',
        password: 'mypassword',
      );

      expect(loggedIn.name, equals('Login User'));
      expect(loggedIn.email, equals('login@example.com'));
    });

    test('Login with incorrect password throws AuthException', () async {
      await authService.register(
        name: 'User',
        email: 'wrongpass@example.com',
        password: 'correctpassword',
      );

      expect(
        () => authService.login(
          email: 'wrongpass@example.com',
          password: 'wrongpassword',
        ),
        throwsA(isA<AuthException>()),
      );
    });

    test('Login with non-existent email throws AuthException', () async {
      expect(
        () => authService.login(
          email: 'nonexistent@example.com',
          password: 'somepassword',
        ),
        throwsA(isA<AuthException>()),
      );
    });
  });

  group('AuthProvider Tests', () {
    test('Register, restore session, update profile, and logout flow', () async {
      final provider = AuthProvider(
        authService: authService,
        userRepo: userRepo,
        prefsStore: prefsStore,
      );

      expect(provider.isAuthenticated, isFalse);

      // 1. Register
      final regSuccess = await provider.register(
        name: 'Flow User',
        email: 'flow@example.com',
        password: 'flowpassword',
      );
      expect(regSuccess, isTrue);
      expect(provider.isAuthenticated, isTrue);
      expect(provider.currentUser?.name, equals('Flow User'));
      expect(prefsStore.getUserId(), equals(provider.currentUser?.id));

      // 2. Simulate fresh app restart: restoreSession
      final newProvider = AuthProvider(
        authService: authService,
        userRepo: userRepo,
        prefsStore: prefsStore,
      );
      await newProvider.restoreSession();
      expect(newProvider.isAuthenticated, isTrue);
      expect(newProvider.currentUser?.email, equals('flow@example.com'));

      // 3. Update profile
      final updated = newProvider.currentUser!.copyWith(heightCm: 175.0, weightKg: 70.0);
      await newProvider.updateProfile(updated);
      expect(newProvider.currentUser?.heightCm, equals(175.0));
      expect(newProvider.currentUser?.weightKg, equals(70.0));

      // 4. Logout
      await newProvider.logout();
      expect(newProvider.isAuthenticated, isFalse);
      expect(prefsStore.getUserId(), isNull);
    });

    test('deleteMyData deletes user related data while keeping the user account', () async {
      final provider = AuthProvider(
        authService: authService,
        userRepo: userRepo,
        prefsStore: prefsStore,
      );

      await provider.register(
        name: 'Delete Data User',
        email: 'del@example.com',
        password: 'delpassword',
      );
      final userId = provider.currentUser!.id!;

      // Insert plan, weight, food log for user
      await db.insert(AppConstants.tableWorkoutPlans, {
        'user_id': userId,
        'name': 'Test Plan',
        'is_active': 1,
        'created_at': DateTime.now().toIso8601String(),
      });
      await db.insert(AppConstants.tableWeightEntries, {
        'user_id': userId,
        'date': '2026-11-05',
        'weight_kg': 72.5,
        'created_at': DateTime.now().toIso8601String(),
      });
      await db.insert(AppConstants.tableFoodLogEntries, {
        'user_id': userId,
        'date': '2026-11-05',
        'meal_type': 'breakfast',
        'serving_size': 100.0,
        'kcal': 300.0,
        'protein': 20.0,
        'carbs': 30.0,
        'fat': 10.0,
      });

      // Verify records exist
      var plans = await db.query(AppConstants.tableWorkoutPlans, where: 'user_id = ?', whereArgs: [userId]);
      var weights = await db.query(AppConstants.tableWeightEntries, where: 'user_id = ?', whereArgs: [userId]);
      expect(plans.length, equals(1));
      expect(weights.length, equals(1));

      // Delete my data
      await provider.deleteMyData();

      // Verify user data is gone, but user account remains
      plans = await db.query(AppConstants.tableWorkoutPlans, where: 'user_id = ?', whereArgs: [userId]);
      weights = await db.query(AppConstants.tableWeightEntries, where: 'user_id = ?', whereArgs: [userId]);
      final foods = await db.query(AppConstants.tableFoodLogEntries, where: 'user_id = ?', whereArgs: [userId]);
      final userAccount = await userRepo.findById(userId);

      expect(plans, isEmpty);
      expect(weights, isEmpty);
      expect(foods, isEmpty);
      expect(userAccount, isNotNull);
      expect(userAccount?.id, equals(userId));
    });
  });
}



