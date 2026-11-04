import 'package:flutter/material.dart';
import '../screens/placeholder_screen.dart';

class AppRoutes {
  static const String initial = '/';
  static const String placeholder = '/placeholder';

  // Auth routes
  static const String login = '/login';
  static const String register = '/register';

  // Home / Shell routes
  static const String home = '/home';

  // Workout & Plan routes
  static const String planList = '/plan_list';
  static const String planEdit = '/plan_edit';
  static const String exerciseLibrary = '/exercise_library';
  static const String exerciseDetail = '/exercise_detail';
  static const String workoutSession = '/workout_session';
  static const String workoutSummary = '/workout_summary';
  static const String history = '/history';

  // Progress routes
  static const String progress = '/progress';

  // Nutrition routes
  static const String foodDiary = '/food_diary';
  static const String barcodeScan = '/barcode_scan';
  static const String foodDetail = '/food_detail';
  static const String manualFood = '/manual_food';

  // Settings routes
  static const String settings = '/settings';
  static const String profile = '/profile';
  static const String teamInfo = '/team_info';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case initial:
      case placeholder:
        return MaterialPageRoute(
          builder: (_) => const PlaceholderScreen(),
          settings: settings,
        );
      default:
        return MaterialPageRoute(
          builder: (_) => const PlaceholderScreen(),
          settings: settings,
        );
    }
  }
}

