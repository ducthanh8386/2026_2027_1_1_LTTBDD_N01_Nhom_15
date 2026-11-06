enum ActivityLevel {
  sedentary,
  light,
  moderate,
  veryActive,
  extraActive,
}

extension ActivityLevelX on ActivityLevel {
  double get multiplier {
    switch (this) {
      case ActivityLevel.sedentary:
        return 1.2;
      case ActivityLevel.light:
        return 1.375;
      case ActivityLevel.moderate:
        return 1.55;
      case ActivityLevel.veryActive:
        return 1.725;
      case ActivityLevel.extraActive:
        return 1.9;
    }
  }

  String label(String langCode) {
    final isVi = langCode.toLowerCase() == 'vi';
    switch (this) {
      case ActivityLevel.sedentary:
        return isVi ? 'Ít vận động (văn phòng)' : 'Sedentary (desk job)';
      case ActivityLevel.light:
        return isVi ? 'Vận động nhẹ (1-3 ngày/tuần)' : 'Light exercise (1-3 days/wk)';
      case ActivityLevel.moderate:
        return isVi ? 'Vừa phải (3-5 ngày/tuần)' : 'Moderate exercise (3-5 days/wk)';
      case ActivityLevel.veryActive:
        return isVi ? 'Vận động nhiều (6-7 ngày/tuần)' : 'Very active (6-7 days/wk)';
      case ActivityLevel.extraActive:
        return isVi ? 'Cường độ cao / Vận động viên' : 'Extra active / Athlete';
    }
  }
}

/// Pure calculation utilities for user nutritional goals and body metrics.
/// Owned by Partner B (Module B3).
///
/// Scientific Citation:
/// Mifflin MD, St Jeor ST, Hill LA, Scott BJ, Daugherty SA, Koh YO.
/// "A new predictive equation for resting energy expenditure in healthy individuals."
/// Am J Clin Nutr. 1990 Feb;51(2):241-7. doi: 10.1093/ajcn/51.2.241.
class ProfileCalc {
  /// Computes BMR using the Mifflin-St Jeor equation:
  /// - Men: 10 * weight(kg) + 6.25 * height(cm) - 5 * age(y) + 5
  /// - Women: 10 * weight(kg) + 6.25 * height(cm) - 5 * age(y) - 161
  static double calculateBmr({
    required double weightKg,
    required double heightCm,
    required int age,
    required String gender,
  }) {
    if (weightKg <= 0 || heightCm <= 0 || age <= 0) return 0.0;

    final base = (10 * weightKg) + (6.25 * heightCm) - (5 * age);
    final isMale = gender.toLowerCase() == 'male';

    return isMale ? (base + 5) : (base - 161);
  }

  /// Calculates TDEE = BMR * Activity Multiplier
  static double calculateTdee({
    required double bmr,
    required ActivityLevel activityLevel,
  }) {
    return bmr * activityLevel.multiplier;
  }

  /// Calculates Daily Calorie Target based on fitness goal:
  /// - lose_fat: deficit of 500 kcal (clamped to at least 1200 kcal for safety)
  /// - build_muscle: surplus of 300 kcal
  /// - maintain: maintenance TDEE
  static int calculateKcalTarget({
    required double tdee,
    required String goal,
  }) {
    double target = tdee;
    switch (goal.toLowerCase()) {
      case 'lose_fat':
        target -= 500;
        break;
      case 'build_muscle':
        target += 300;
        break;
      case 'maintain':
      default:
        break;
    }

    // Minimum safe threshold recommendation: 1200 kcal
    if (target < 1200) target = 1200;
    return target.round();
  }

  /// Calculates BMI (Body Mass Index) = weight(kg) / (height(m) ^ 2)
  static double calculateBmi({
    required double weightKg,
    required double heightCm,
  }) {
    if (heightCm <= 0 || weightKg <= 0) return 0.0;
    final heightM = heightCm / 100.0;
    return weightKg / (heightM * heightM);
  }

  /// Returns localized BMI category description
  static String bmiCategory(double bmi, String langCode) {
    final isVi = langCode.toLowerCase() == 'vi';
    if (bmi <= 0) return isVi ? 'Chưa xác định' : 'Unknown';
    if (bmi < 18.5) return isVi ? 'Gầy (Thiếu cân)' : 'Underweight';
    if (bmi < 24.9) return isVi ? 'Bình thường' : 'Normal weight';
    if (bmi < 29.9) return isVi ? 'Thừa cân' : 'Overweight';
    return isVi ? 'Béo phì' : 'Obese';
  }
}
