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
  static Future<void> seedIfEmpty(Database db, {String? jsonString}) async {
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM ${AppConstants.tableExercises}'),
    ) ?? 0;

    if (count > 0) {
      if (kDebugMode) {
        print('ExerciseSeeder: ${AppConstants.tableExercises} already contains $count records. Skipping.');
      }
      return;
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
