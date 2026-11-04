import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

import 'package:provider/provider.dart';

import '../providers/settings_provider.dart';
import '../widgets/empty_state.dart';
import '../widgets/primary_button.dart';

class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settingsProvider = context.watch<SettingsProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appName),
        actions: [
          IconButton(
            tooltip: l10n.themeMode,
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
              settingsProvider.toggleThemeMode();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.fitness_center,
                        size: 48,
                        color: Color(0xFF2E7D32),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        l10n.welcome,
                        style: Theme.of(context).textTheme.titleLarge
                            ?.copyWith(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.currentLanguage,
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                text: l10n.switchLanguage,
                icon: Icons.language,
                onPressed: () {
                  settingsProvider.toggleLocale();
                },
              ),
              const SizedBox(height: 32),
              EmptyState(
                title: l10n.emptyStateTitle,
                message: l10n.emptyStateMessage,
                icon: Icons.flag_outlined,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
