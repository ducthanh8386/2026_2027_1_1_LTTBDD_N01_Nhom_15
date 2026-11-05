import 'package:flutter_test/flutter_test.dart';
import 'package:fit_track/models/exercise.dart';
import 'package:fit_track/models/food.dart';
import 'package:fit_track/models/food_log_entry.dart';
import 'package:fit_track/models/plan_day.dart';
import 'package:fit_track/models/plan_exercise.dart';
import 'package:fit_track/models/set_log.dart';
import 'package:fit_track/models/user.dart';
import 'package:fit_track/models/weight_entry.dart';
import 'package:fit_track/models/workout_plan.dart';
import 'package:fit_track/models/workout_session.dart';

void main() {
  group('Models Serialization and Logic Tests', () {
    test('User toMap and fromMap', () {
      final user = User(
        id: 1,
        name: 'Nguyen Van A',
        email: 'test@example.com',
        passwordHash: 'hash123',
        salt: 'salt123',
        heightCm: 175.5,
        weightKg: 70.0,
        age: 25,
        gender: 'male',
        goal: 'build_muscle',
        kcalTarget: 2500,
        createdAt: '2026-11-05T00:00:00.000Z',
      );

      final map = user.toMap();
      expect(map['email'], 'test@example.com');
      expect(map['height_cm'], 175.5);
      expect(map['password_hash'], 'hash123');

      final deserialized = User.fromMap(map);
      expect(deserialized, equals(user));

      final updated = user.copyWith(weightKg: 71.5);
      expect(updated.weightKg, 71.5);
      expect(updated.name, user.name);
    });

    test('Exercise localization and secondaryMuscles handling', () {
      final exercise = Exercise(
        id: 10,
        sourceId: '0025',
        nameEn: 'Barbell Bench Press',
        nameVi: 'Đẩy ngực với tạ đòn',
        bodyPart: 'chest',
        target: 'pectorals',
        equipment: 'barbell',
        secondaryMuscles: const ['triceps', 'shoulders'],
        instructionsEn: 'Step 1: Lie on bench.\nStep 2: Press bar up.',
        instructionsVi: 'Bước 1: Nằm trên ghế.\nBước 2: Đẩy tạ lên.',
        imageAsset: 'assets/exercises/images/0025.jpg',
        gifAsset: 'assets/exercises/gifs/0025.gif',
      );

      expect(exercise.localizedName('vi'), 'Đẩy ngực với tạ đòn');
      expect(exercise.localizedName('en'), 'Barbell Bench Press');
      expect(exercise.localizedInstructions('vi'), 'Bước 1: Nằm trên ghế.\nBước 2: Đẩy tạ lên.');
      expect(exercise.localizedInstructions('en'), 'Step 1: Lie on bench.\nStep 2: Press bar up.');

      // Test fallback when instructionsVi is missing
      const noViExercise = Exercise(
        sourceId: '0026',
        nameEn: 'Barbell Bench Press',
        nameVi: 'Đẩy ngực với tạ đòn',
        bodyPart: 'chest',
        instructionsEn: 'Step 1: Lie on bench.\nStep 2: Press bar up.',
        instructionsVi: null,
      );
      expect(noViExercise.localizedInstructions('vi'), 'Step 1: Lie on bench.\nStep 2: Press bar up.');

      // Test map serialization with secondary_muscles as JSON string
      final map = exercise.toMap();
      expect(map['secondary_muscles'], '["triceps","shoulders"]');

      final fromMapEx = Exercise.fromMap(map);
      expect(fromMapEx.secondaryMuscles, ['triceps', 'shoulders']);
      expect(fromMapEx.nameVi, 'Đẩy ngực với tạ đòn');
    });

    test('WorkoutPlan and PlanDay and PlanExercise', () {
      final plan = WorkoutPlan(
        id: 1,
        userId: 2,
        name: 'Push Pull Legs',
        createdAt: '2026-11-05',
      );
      final planMap = plan.toMap();
      expect(WorkoutPlan.fromMap(planMap), equals(plan));

      final day = PlanDay(
        id: 10,
        planId: 1,
        dayIndex: 0,
        name: 'Push Day',
      );
      final dayMap = day.toMap();
      expect(PlanDay.fromMap(dayMap), equals(day));

      final planEx = PlanExercise(
        id: 100,
        planDayId: 10,
        exerciseId: 5,
        orderIndex: 0,
        targetSets: 4,
        targetReps: 10,
      );
      final planExMap = planEx.toMap();
      expect(PlanExercise.fromMap(planExMap), equals(planEx));
    });

    test('WorkoutSession and SetLog', () {
      final session = WorkoutSession(
        id: 1,
        userId: 2,
        planDayId: 10,
        startedAt: '2026-11-05T08:00:00Z',
        endedAt: '2026-11-05T09:00:00Z',
        totalVolume: 5200.0,
      );
      final sessionMap = session.toMap();
      expect(WorkoutSession.fromMap(sessionMap), equals(session));

      final setLog = SetLog(
        id: 50,
        sessionId: 1,
        exerciseId: 5,
        setIndex: 1,
        reps: 10,
        weightKg: 60.0,
      );
      final setMap = setLog.toMap();
      expect(SetLog.fromMap(setMap), equals(setLog));
    });

    test('WeightEntry', () {
      final entry = WeightEntry(
        id: 1,
        userId: 2,
        date: '2026-11-05',
        weightKg: 72.5,
      );
      final map = entry.toMap();
      expect(WeightEntry.fromMap(map), equals(entry));
    });

    test('Food and FoodLogEntry', () {
      final food = Food(
        id: 1,
        barcode: '8936036020012',
        name: 'Greek Yogurt',
        brand: 'Vinamilk',
        kcal100g: 97.0,
        protein100g: 9.0,
        carbs100g: 4.5,
        fat100g: 5.0,
        imageUrl: 'https://example.com/yogurt.jpg',
        source: 'off',
      );
      final foodMap = food.toMap();
      expect(Food.fromMap(foodMap), equals(food));

      final log = FoodLogEntry(
        id: 1,
        userId: 2,
        foodId: 1,
        date: '2026-11-05',
        mealType: 'breakfast',
        grams: 200.0,
        kcal: 194.0,
        protein: 18.0,
        carbs: 9.0,
        fat: 10.0,
      );
      final logMap = log.toMap();
      expect(FoodLogEntry.fromMap(logMap), equals(log));
    });
  });
}

