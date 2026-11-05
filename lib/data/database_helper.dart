import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../core/constants.dart';
import 'seed/exercise_seed.dart';

class DatabaseHelper {
  static const int _dbVersion = 1;
  static const String _dbName = 'fit_track.db';

  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null && _database!.isOpen) {
      return _database!;
    }
    _database = await _initDatabase();
    return _database!;
  }

  /// Optional injector for testing or custom paths.
  void setDatabaseForTesting(Database? db) {
    _database = db;
  }

  Future<Database> _initDatabase() async {
    final dbDir = await getDatabasesPath();
    final dbPath = p.join(dbDir, _dbName);

    return await openDatabase(
      dbPath,
      version: _dbVersion,
      onConfigure: _onConfigure,
      onCreate: _onCreate,
    );
  }

  static Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON;');
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.transaction((txn) async {
      // 1. users
      await txn.execute('''
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

      // 2. exercises (updated schema according to team_split_prompts 0.1)
      await txn.execute('''
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

      // 3. workout_plans
      await txn.execute('''
        CREATE TABLE ${AppConstants.tableWorkoutPlans} (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id INTEGER NOT NULL,
          name TEXT NOT NULL,
          created_at TEXT NOT NULL,
          FOREIGN KEY (user_id) REFERENCES ${AppConstants.tableUsers} (id) ON DELETE CASCADE
        );
      ''');

      // 4. plan_days
      await txn.execute('''
        CREATE TABLE ${AppConstants.tablePlanDays} (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          plan_id INTEGER NOT NULL,
          day_index INTEGER NOT NULL,
          name TEXT NOT NULL,
          FOREIGN KEY (plan_id) REFERENCES ${AppConstants.tableWorkoutPlans} (id) ON DELETE CASCADE
        );
      ''');

      // 5. plan_exercises
      await txn.execute('''
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

      // 6. workout_sessions (plan_day_id ON DELETE SET NULL to preserve history)
      await txn.execute('''
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

      // 7. set_logs
      await txn.execute('''
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

      // 8. weight_entries (UNIQUE user_id, date)
      await txn.execute('''
        CREATE TABLE ${AppConstants.tableWeightEntries} (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id INTEGER NOT NULL,
          date TEXT NOT NULL,
          weight_kg REAL NOT NULL,
          FOREIGN KEY (user_id) REFERENCES ${AppConstants.tableUsers} (id) ON DELETE CASCADE,
          UNIQUE (user_id, date)
        );
      ''');

      // 9. foods (barcode nullable UNIQUE)
      await txn.execute('''
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

      // 10. food_log_entries
      await txn.execute('''
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
    });

    // Seed initial exercises if table is empty
    await ExerciseSeeder.seedIfEmpty(db);
  }

  Future<void> close() async {
    if (_database != null && _database!.isOpen) {
      await _database!.close();
      _database = null;
    }
  }
}
