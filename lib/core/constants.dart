class AppConstants {
  // Database table names
  static const String tableUsers = 'users';
  static const String tableExercises = 'exercises';
  static const String tableWorkoutPlans = 'workout_plans';
  static const String tablePlanDays = 'plan_days';
  static const String tablePlanExercises = 'plan_exercises';
  static const String tableWorkoutSessions = 'workout_sessions';
  static const String tableSetLogs = 'set_logs';
  static const String tableWeightEntries = 'weight_entries';
  static const String tableFoods = 'foods';
  static const String tableFoodLogEntries = 'food_log_entries';

  // API constants
  static const String offApiBaseUrl = 'https://world.openfoodfacts.org/api/v2/product/';
  static const Duration apiTimeout = Duration(seconds: 10);
  static const String appUserAgent = 'FitTrack - Android - Version 1.0.0';

  // Shared Preferences keys
  static const String prefKeyLocale = 'pref_locale';
  static const String prefKeyThemeMode = 'pref_theme_mode';
  static const String prefKeyUserId = 'pref_user_id';
}

