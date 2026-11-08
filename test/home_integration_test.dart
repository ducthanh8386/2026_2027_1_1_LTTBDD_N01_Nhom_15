import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:fit_track/core/constants.dart';
import 'package:fit_track/data/database_helper.dart';
import 'package:fit_track/data/local/prefs_store.dart';
import 'package:fit_track/data/repositories/user_repository.dart';
import 'package:fit_track/l10n/app_localizations.dart';
import 'package:fit_track/models/user.dart';
import 'package:fit_track/providers/auth_provider.dart';
import 'package:fit_track/providers/exercise_provider.dart';
import 'package:fit_track/providers/nutrition_provider.dart';
import 'package:fit_track/providers/plan_provider.dart';
import 'package:fit_track/providers/progress_provider.dart';
import 'package:fit_track/providers/settings_provider.dart';
import 'package:fit_track/providers/workout_provider.dart';
import 'package:fit_track/screens/home/home_screen.dart';
import 'package:fit_track/screens/home/main_shell.dart';
import 'package:fit_track/widgets/stat_card.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late Database db;
  late DatabaseHelper dbHelper;
  late UserRepository userRepo;

  setUp(() async {
    dbHelper = DatabaseHelper();
    db = await databaseFactory.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: 1,
        onConfigure: (db) async {
          await db.execute('PRAGMA foreign_keys = ON;');
        },
        onCreate: (db, version) async {
          await DatabaseHelper.onCreate(db, version);
        },
      ),
    );
    dbHelper.setDatabaseForTesting(db);
    userRepo = UserRepository(dbHelper: dbHelper);
  });

  tearDown(() async {
    await db.close();
    dbHelper.setDatabaseForTesting(null);
  });

  Widget createTestWidget({
    required PrefsStore prefsStore,
    required AuthProvider authProvider,
    required ProgressProvider progressProvider,
    required NutritionProvider nutritionProvider,
    required WorkoutProvider workoutProvider,
    required PlanProvider planProvider,
    Widget? home,
  }) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<SettingsProvider>(
          create: (_) => SettingsProvider(prefsStore),
        ),
        ChangeNotifierProvider<AuthProvider>.value(
          value: authProvider,
        ),
        ChangeNotifierProvider<ExerciseProvider>(
          create: (_) => ExerciseProvider(),
        ),
        ChangeNotifierProvider<ProgressProvider>.value(
          value: progressProvider,
        ),
        ChangeNotifierProvider<PlanProvider>.value(
          value: planProvider,
        ),
        ChangeNotifierProvider<WorkoutProvider>.value(
          value: workoutProvider,
        ),
        ChangeNotifierProvider<NutritionProvider>.value(
          value: nutritionProvider,
        ),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('vi'),
        home: home ?? const MainShell(),
      ),
    );
  }

  testWidgets('HomeScreen renders greeting, 3 StatCards, and Quick Actions', (
    WidgetTester tester,
  ) async {
    late PrefsStore prefsStore;
    late AuthProvider authProvider;
    late ProgressProvider progressProvider;
    late NutritionProvider nutritionProvider;
    late WorkoutProvider workoutProvider;
    late PlanProvider planProvider;

    await tester.runAsync(() async {
      SharedPreferences.setMockInitialValues({AppConstants.prefKeyUserId: 1});
      prefsStore = await PrefsStore.create();

      const testUser = User(
        id: 1,
        name: 'Đức Thanh',
        email: 'ducthanh@example.com',
        passwordHash: 'hash',
        salt: 'salt',
        kcalTarget: 2200,
        createdAt: '2026-11-08T00:00:00.000Z',
      );
      await userRepo.insert(testUser);

      authProvider = AuthProvider(userRepo: userRepo, prefsStore: prefsStore);
      await authProvider.restoreSession();

      progressProvider = ProgressProvider();
      nutritionProvider = NutritionProvider();
      nutritionProvider.updateUser(authProvider.currentUser);
      workoutProvider = WorkoutProvider();
      planProvider = PlanProvider();
    });

    await tester.pumpWidget(
      createTestWidget(
        prefsStore: prefsStore,
        authProvider: authProvider,
        progressProvider: progressProvider,
        nutritionProvider: nutritionProvider,
        workoutProvider: workoutProvider,
        planProvider: planProvider,
        home: const Scaffold(body: HomeScreen()),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Verify Greeting with user name
    expect(find.textContaining('Đức Thanh'), findsOneWidget);

    // Verify 3 StatCards exist
    expect(find.byType(StatCard), findsNWidgets(3));
    expect(find.text('Số buổi tập'), findsOneWidget);
    expect(find.text('Khối lượng'), findsOneWidget);
    expect(find.text('Calo hôm nay'), findsOneWidget);

    // Verify Quick Actions exist
    expect(find.text('Quét mã thực phẩm'), findsOneWidget);
    expect(find.text('Ghi cân nặng'), findsOneWidget);

    // Verify Today Workout card exists (no plan -> free workout prompt)
    expect(find.text('Buổi tập hôm nay'), findsOneWidget);
    expect(find.text('Chưa có kế hoạch tập'), findsOneWidget);
    expect(find.text('Tập tự do ngay'), findsOneWidget);

    // Advance past any timers
    await tester.pump(const Duration(seconds: 11));
  });

  testWidgets('MainShell tab switching works via MainShell.switchTab', (
    WidgetTester tester,
  ) async {
    late PrefsStore prefsStore;
    late AuthProvider authProvider;
    late ProgressProvider progressProvider;
    late NutritionProvider nutritionProvider;
    late WorkoutProvider workoutProvider;
    late PlanProvider planProvider;

    await tester.runAsync(() async {
      SharedPreferences.setMockInitialValues({AppConstants.prefKeyUserId: 1});
      prefsStore = await PrefsStore.create();

      const testUser = User(
        id: 1,
        name: 'Đức Thanh',
        email: 'ducthanh@example.com',
        passwordHash: 'hash',
        salt: 'salt',
        createdAt: '2026-11-08T00:00:00.000Z',
      );
      await userRepo.insert(testUser);

      authProvider = AuthProvider(userRepo: userRepo, prefsStore: prefsStore);
      await authProvider.restoreSession();

      progressProvider = ProgressProvider();
      nutritionProvider = NutritionProvider();
      nutritionProvider.updateUser(authProvider.currentUser);
      workoutProvider = WorkoutProvider();
      planProvider = PlanProvider();
    });

    await tester.pumpWidget(
      createTestWidget(
        prefsStore: prefsStore,
        authProvider: authProvider,
        progressProvider: progressProvider,
        nutritionProvider: nutritionProvider,
        workoutProvider: workoutProvider,
        planProvider: planProvider,
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Initially at HomeScreen (tab 0)
    expect(find.text('Buổi tập hôm nay'), findsOneWidget);

    // Tap Nutrition StatCard (calls MainShell.switchTab(context, 3))
    final nutritionCard = find.ancestor(
      of: find.text('Calo hôm nay'),
      matching: find.byType(StatCard),
    );
    await tester.tap(nutritionCard);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Now in Nutrition tab (FoodDiaryScreen)
    expect(find.text('Nhật ký dinh dưỡng'), findsOneWidget);

    // Tap Workout Plans nav item
    await tester.tap(find.text('Tập luyện'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Now in Plan tab
    expect(find.textContaining('Kế hoạch'), findsWidgets);

    // Clean up timer
    await tester.pump(const Duration(seconds: 11));
  });

  testWidgets('deleteMyData clears user records while keeping account', (
    WidgetTester tester,
  ) async {
    late PrefsStore prefsStore;
    late AuthProvider authProvider;

    await tester.runAsync(() async {
      SharedPreferences.setMockInitialValues({AppConstants.prefKeyUserId: 1});
      prefsStore = await PrefsStore.create();

      const testUser = User(
        id: 1,
        name: 'Thanh Test',
        email: 'thanh.test@example.com',
        passwordHash: 'hash',
        salt: 'salt',
        createdAt: '2026-11-08T00:00:00.000Z',
      );
      await userRepo.insert(testUser);

      // Insert some mock data for user 1
      await db.insert('workout_plans', {
        'id': 1,
        'user_id': 1,
        'name': 'Test Plan',
        'created_at': DateTime.now().toIso8601String(),
      });

      await db.insert('weight_entries', {
        'user_id': 1,
        'date': '2026-11-08',
        'weight_kg': 70.5,
      });

      authProvider = AuthProvider(userRepo: userRepo, prefsStore: prefsStore);
      await authProvider.restoreSession();

      // Execute deleteMyData
      await authProvider.deleteMyData();

      // Check DB: plans and weights for user 1 should be gone
      final plans = await db.query('workout_plans', where: 'user_id = 1');
      expect(plans.isEmpty, isTrue);

      final weights = await db.query('weight_entries', where: 'user_id = 1');
      expect(weights.isEmpty, isTrue);

      // User account should still exist
      final user = await userRepo.findById(1);
      expect(user, isNotNull);
      expect(user?.name, 'Thanh Test');
    });
  });

  testWidgets('Profile update propagates new kcalTarget to NutritionProvider', (
    WidgetTester tester,
  ) async {
    late PrefsStore prefsStore;
    late AuthProvider authProvider;
    late NutritionProvider nutritionProvider;

    await tester.runAsync(() async {
      SharedPreferences.setMockInitialValues({AppConstants.prefKeyUserId: 1});
      prefsStore = await PrefsStore.create();

      const testUser = User(
        id: 1,
        name: 'Thanh Test',
        email: 'thanh.test@example.com',
        passwordHash: 'hash',
        salt: 'salt',
        kcalTarget: 1800,
        createdAt: '2026-11-08T00:00:00.000Z',
      );
      await userRepo.insert(testUser);

      authProvider = AuthProvider(userRepo: userRepo, prefsStore: prefsStore);
      await authProvider.restoreSession();

      nutritionProvider = NutritionProvider();
      nutritionProvider.updateUser(authProvider.currentUser);
      expect(nutritionProvider.dailyTarget, 1800.0);

      // Update profile with new kcal target
      final updatedUser = testUser.copyWith(kcalTarget: 2400);
      await authProvider.updateProfile(updatedUser);

      // NutritionProvider receives updated user
      nutritionProvider.updateUser(authProvider.currentUser);
      expect(nutritionProvider.dailyTarget, 2400.0);
    });
  });
}
