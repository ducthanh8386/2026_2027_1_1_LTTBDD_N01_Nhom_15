import 'package:flutter/material.dart';

import '../screens/placeholder_screen.dart';
import '../screens/plan/exercise_detail_screen.dart';
import '../screens/plan/exercise_library_screen.dart';
import '../screens/progress/progress_screen.dart';
import '../screens/settings/profile_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/settings/team_info_screen.dart';
import '../screens/workout/history_screen.dart';

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
  static const String exerciseLibrary = '/exercises';
  static const String exerciseDetail = '/exercise-detail';
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
  static const String teamInfo = '/team-info';

  static Route<dynamic> onGenerateRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case initial:
      case placeholder:
        return MaterialPageRoute(
          builder: (_) => const PlaceholderScreen(),
          settings: routeSettings,
        );

      case exerciseLibrary:
        final bool selectMode = (routeSettings.arguments as bool?) ?? false;
        return MaterialPageRoute(
          builder: (_) => ExerciseLibraryScreen(selectMode: selectMode),
          settings: routeSettings,
        );

      case exerciseDetail:
        final int exerciseId = (routeSettings.arguments as int?) ?? 1;
        return MaterialPageRoute(
          builder: (_) => ExerciseDetailScreen(exerciseId: exerciseId),
          settings: routeSettings,
        );

      case progress:
        return MaterialPageRoute(
          builder: (_) => const ProgressScreen(),
          settings: routeSettings,
        );

      case history:
        return MaterialPageRoute(
          builder: (_) => const HistoryScreen(),
          settings: routeSettings,
        );

      case settings:
        return MaterialPageRoute(
          builder: (_) => const SettingsScreen(),
          settings: routeSettings,
        );

      case profile:
        return MaterialPageRoute(
          builder: (_) => const ProfileScreen(),
          settings: routeSettings,
        );

      case teamInfo:
        return MaterialPageRoute(
          builder: (_) => const TeamInfoScreen(),
          settings: routeSettings,
        );

      default:
        return MaterialPageRoute(
          builder: (_) => const PlaceholderScreen(),
          settings: routeSettings,
        );
    }
  }
}
