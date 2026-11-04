import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fit_track/app.dart';
import 'package:fit_track/data/local/prefs_store.dart';
import 'package:fit_track/providers/settings_provider.dart';

void main() {
  testWidgets('FitTrack smoke test and language toggle', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final prefsStore = await PrefsStore.create();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<SettingsProvider>(
            create: (_) => SettingsProvider(prefsStore),
          ),
        ],
        child: const FitTrackApp(),
      ),
    );

    await tester.pumpAndSettle();

    // Verify initial Vietnamese texts are present
    expect(find.text('FitTrack'), findsOneWidget);
    expect(find.text('Chào mừng đến với FitTrack'), findsOneWidget);
    expect(find.text('Ngôn ngữ hiện tại: Tiếng Việt'), findsOneWidget);

    // Tap switch language button
    await tester.tap(find.text('Chuyển sang Tiếng Anh'));
    await tester.pumpAndSettle();

    // Verify English texts are displayed
    expect(find.text('Welcome to FitTrack'), findsOneWidget);
    expect(find.text('Current language: English'), findsOneWidget);
  });
}
