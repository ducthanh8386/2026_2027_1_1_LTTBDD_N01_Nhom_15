import 'package:flutter/material.dart';
import 'l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import 'core/routes.dart';
import 'core/theme.dart';
import 'providers/settings_provider.dart';

class FitTrackApp extends StatelessWidget {
  const FitTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsProvider = context.watch<SettingsProvider>();

    return MaterialApp(
      title: 'FitTrack',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: settingsProvider.themeMode,
      locale: settingsProvider.locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      initialRoute: AppRoutes.initial,
      onGenerateRoute: AppRoutes.onGenerateRoute,
    );
  }
}
