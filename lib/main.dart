import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

import 'app.dart';
import 'data/local/prefs_store.dart';
import 'providers/auth_provider.dart';
import 'providers/exercise_provider.dart';
import 'providers/nutrition_provider.dart';
import 'providers/plan_provider.dart';
import 'providers/progress_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/workout_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SQLite database factory across all supported platforms
  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  } else if (Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  final prefsStore = await PrefsStore.create();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<SettingsProvider>(
          create: (_) => SettingsProvider(prefsStore),
        ),
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(prefsStore: prefsStore)..restoreSession(),
        ),
        ChangeNotifierProvider<ExerciseProvider>(
          create: (_) => ExerciseProvider()..load(),
        ),
        ChangeNotifierProxyProvider<AuthProvider, ProgressProvider>(
          create: (_) => ProgressProvider(),
          update: (_, auth, progress) => (progress ?? ProgressProvider())
            ..updateUser(auth.currentUser?.id),
        ),
        ChangeNotifierProvider<PlanProvider>(
          create: (_) => PlanProvider(),
        ),
        ChangeNotifierProvider<WorkoutProvider>(
          create: (_) => WorkoutProvider(),
        ),
        ChangeNotifierProxyProvider<AuthProvider, NutritionProvider>(
          create: (_) => NutritionProvider(),
          update: (_, auth, nutrition) => (nutrition ?? NutritionProvider())
            ..updateUser(auth.currentUser),
        ),
      ],
      child: const FitTrackApp(),
    ),
  );
}
