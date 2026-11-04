import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'data/local/prefs_store.dart';
import 'providers/settings_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefsStore = await PrefsStore.create();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<SettingsProvider>(
          create: (_) => SettingsProvider(prefsStore),
        ),
      ],
      child: const FitTrackApp(),
    ),
  );
}
