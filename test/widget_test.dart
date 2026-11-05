import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:fit_track/app.dart';
import 'package:fit_track/core/constants.dart';
import 'package:fit_track/data/database_helper.dart';
import 'package:fit_track/data/local/prefs_store.dart';
import 'package:fit_track/data/repositories/user_repository.dart';
import 'package:fit_track/models/user.dart';
import 'package:fit_track/providers/auth_provider.dart';
import 'package:fit_track/providers/settings_provider.dart';

void main() {
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
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE ${AppConstants.tableUsers} (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              name TEXT NOT NULL,
              email TEXT UNIQUE NOT NULL,
              password_hash TEXT NOT NULL,
              salt TEXT NOT NULL,
              height_cm REAL,
              weight_kg REAL,
              age INTEGER,
              gender TEXT,
              goal TEXT,
              kcal_target INTEGER,
              created_at TEXT NOT NULL
            );
          ''');
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

  testWidgets('FitTrack smoke test - AuthGate displays LoginScreen when not authenticated', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final prefsStore = await PrefsStore.create();
    final authProvider = AuthProvider(
      userRepo: userRepo,
      prefsStore: prefsStore,
    );
    await authProvider.restoreSession();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<SettingsProvider>(
            create: (_) => SettingsProvider(prefsStore),
          ),
          ChangeNotifierProvider<AuthProvider>.value(
            value: authProvider,
          ),
        ],
        child: const FitTrackApp(),
      ),
    );

    await tester.pumpAndSettle();

    // Verify LoginScreen is displayed
    expect(find.text('FitTrack'), findsWidgets);
    expect(find.byType(TextFormField), findsNWidgets(2)); // Email & Password
    expect(find.text('Đăng nhập'), findsOneWidget);
    expect(find.text('Chưa có tài khoản? Đăng ký ngay'), findsOneWidget);
  });

  testWidgets('FitTrack smoke test - AuthGate displays MainShell when authenticated', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final prefsStore = await PrefsStore.create();

    // Insert user into test DB first
    const testUser = User(
      name: 'Thanh Nguyen',
      email: 'thanh@example.com',
      passwordHash: 'hash',
      salt: 'salt',
      createdAt: '2026-11-05T00:00:00.000Z',
    );
    final userId = await userRepo.insert(testUser);
    await prefsStore.setUserId(userId);

    final authProvider = AuthProvider(
      userRepo: userRepo,
      prefsStore: prefsStore,
    );
    await authProvider.restoreSession();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<SettingsProvider>(
            create: (_) => SettingsProvider(prefsStore),
          ),
          ChangeNotifierProvider<AuthProvider>.value(
            value: authProvider,
          ),
        ],
        child: const FitTrackApp(),
      ),
    );

    await tester.pumpAndSettle();

    // Verify MainShell is displayed with NavigationBar
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('Trang chủ'), findsOneWidget);
    expect(find.text('Tập luyện'), findsOneWidget);
    expect(find.text('Tiến độ'), findsOneWidget);
    expect(find.text('Dinh dưỡng'), findsOneWidget);
    expect(find.text('Cài đặt'), findsOneWidget);
  });
}

