import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import '../../core/constants.dart';
import '../../models/exercise.dart';

/// ExerciseSeeder owned by Partner B (Module B1).
///
/// Seeds the initial exercise dataset into SQLite database from assets/data/exercises_seed.json.
/// Operation is idempotent and batch-inserted in a single transaction.
class ExerciseSeeder {
  static Future<void> seedIfEmpty(
    Database db, {
    String? jsonString,
    bool force = false,
  }) async {
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM ${AppConstants.tableExercises}'),
    ) ?? 0;

    // If database already contains the full dataset (1300+ items) and force is false, skip
    if (!force && count >= 1000) {
      // Auto-update outdated jsdelivr URLs if present
      await db.execute('''
        UPDATE ${AppConstants.tableExercises}
        SET image_asset = REPLACE(image_asset, 'https://cdn.jsdelivr.net/gh/Johnson-Jia/exercises-dataset@master/media/', 'https://raw.githubusercontent.com/Johnson-Jia/exercises-dataset/master/media/'),
            gif_asset = REPLACE(gif_asset, 'https://cdn.jsdelivr.net/gh/Johnson-Jia/exercises-dataset@master/media/', 'https://raw.githubusercontent.com/Johnson-Jia/exercises-dataset/master/media/')
        WHERE image_asset LIKE '%jsdelivr%';
      ''');

      if (kDebugMode) {
        print('ExerciseSeeder: ${AppConstants.tableExercises} already contains $count records. Skipping.');
      }
      return;
    }

    if (count > 0 && (force || count < 1000)) {
      // Clear outdated seed
      await db.delete(AppConstants.tableExercises);
    }

    String data = jsonString ?? '';
    if (data.isEmpty) {
      try {
        data = await rootBundle.loadString('assets/data/exercises_seed.json');
      } catch (e) {
        if (kDebugMode) {
          print('ExerciseSeeder: rootBundle failed ($e), falling back to file system.');
        }
        try {
          final file = File('assets/data/exercises_seed.json');
          if (await file.exists()) {
            data = await file.readAsString();
          }
        } catch (_) {}
      }
    }

    if (data.trim().isEmpty) {
      if (kDebugMode) {
        print('ExerciseSeeder: No seed data found.');
      }
      return;
    }

    final List<dynamic> decoded = jsonDecode(data);
    await db.transaction((txn) async {
      final batch = txn.batch();
      for (final item in decoded) {
        final exercise = Exercise.fromMap(Map<String, dynamic>.from(item));
        final map = exercise.toMap()..remove('id');
        batch.insert(
          AppConstants.tableExercises,
          map,
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
      }
      await batch.commit(noResult: true);
    });

    if (kDebugMode) {
      print('ExerciseSeeder: Successfully seeded ${decoded.length} exercises into ${AppConstants.tableExercises}');
    }
  }
}
