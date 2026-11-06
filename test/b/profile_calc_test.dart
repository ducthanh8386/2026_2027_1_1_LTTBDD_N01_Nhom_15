import 'package:flutter_test/flutter_test.dart';
import 'package:fit_track/services/profile_calc.dart';

void main() {
  group('ProfileCalc Tests (Mifflin-St Jeor & Body Metrics)', () {
    test('calculateBmr for men matches Mifflin-St Jeor equation', () {
      // 10*70 + 6.25*175 - 5*25 + 5 = 700 + 1093.75 - 125 + 5 = 1673.75
      final bmr = ProfileCalc.calculateBmr(
        weightKg: 70.0,
        heightCm: 175.0,
        age: 25,
        gender: 'male',
      );
      expect(bmr, closeTo(1673.75, 0.01));
    });

    test('calculateBmr for women matches Mifflin-St Jeor equation', () {
      // 10*55 + 6.25*160 - 5*28 - 161 = 550 + 1000 - 140 - 161 = 1249.0
      final bmr = ProfileCalc.calculateBmr(
        weightKg: 55.0,
        heightCm: 160.0,
        age: 28,
        gender: 'female',
      );
      expect(bmr, closeTo(1249.0, 0.01));
    });

    test('calculateTdee scales BMR with activity levels', () {
      const bmr = 1500.0;
      expect(
        ProfileCalc.calculateTdee(bmr: bmr, activityLevel: ActivityLevel.sedentary),
        closeTo(1800.0, 0.01),
      );
      expect(
        ProfileCalc.calculateTdee(bmr: bmr, activityLevel: ActivityLevel.moderate),
        closeTo(2325.0, 0.01),
      );
    });

    test('calculateKcalTarget adjusts based on goal', () {
      const tdee = 2200.0;
      expect(ProfileCalc.calculateKcalTarget(tdee: tdee, goal: 'lose_fat'), equals(1700));
      expect(ProfileCalc.calculateKcalTarget(tdee: tdee, goal: 'build_muscle'), equals(2500));
      expect(ProfileCalc.calculateKcalTarget(tdee: tdee, goal: 'maintain'), equals(2200));
    });

    test('calculateBmi computes ratio and categorizes correctly', () {
      // 70 / (1.75 * 1.75) = 22.86 (Normal)
      final bmi = ProfileCalc.calculateBmi(weightKg: 70.0, heightCm: 175.0);
      expect(bmi, closeTo(22.86, 0.05));
      expect(ProfileCalc.bmiCategory(bmi, 'vi'), equals('Bình thường'));
      expect(ProfileCalc.bmiCategory(bmi, 'en'), equals('Normal weight'));

      // 85 / (1.70 * 1.70) = 29.41 (Overweight)
      final bmiOverweight = ProfileCalc.calculateBmi(weightKg: 85.0, heightCm: 170.0);
      expect(ProfileCalc.bmiCategory(bmiOverweight, 'vi'), equals('Thừa cân'));
    });
  });
}
