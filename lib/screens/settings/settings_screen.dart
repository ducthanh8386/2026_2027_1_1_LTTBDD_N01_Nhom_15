import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/routes.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../providers/settings_provider.dart';
import 'profile_screen.dart';
import 'team_info_screen.dart';

/// SettingsScreen owned by Partner B (Module B3).
///
/// Features:
/// - User profile summary header -> navigates to ProfileScreen.
/// - Language switcher (English / Tiếng Việt).
/// - Theme mode switcher (System / Light / Dark).
/// - Team Information & Dataset Credits.
/// - Two-step Delete My Data confirmation.
/// - Logout confirmation dialog.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _confirmDeleteMyData(BuildContext context) async {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    final confirmedFirst = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n?.settingsDeleteTitle ?? 'Delete Personal Data?'),
        content: Text(
          l10n?.settingsDeletePrompt ?? 'This will wipe all weight records, workout history, custom plans, and restore initial state.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n?.cancel ?? 'Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              l10n?.continueWorkout ?? 'Continue',
              style: TextStyle(color: theme.colorScheme.onError),
            ),
          ),
        ],
      ),
    );

    if (confirmedFirst == true && context.mounted) {
      final confirmedSecond = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l10n?.settingsDeleteConfirmTitle ?? 'Final Confirmation'),
          content: Text(
            l10n?.settingsDeleteConfirmPrompt ??
                'This action cannot be undone. Are you absolutely sure?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l10n?.cancel ?? 'Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(
                l10n?.deletePlan ?? 'Delete',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );

      if (confirmedSecond == true && context.mounted) {
        try {
          await context.read<AuthProvider>().deleteMyData();
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  l10n?.settingsDeleteSuccess ??
                      'All personal data has been wiped successfully.',
                ),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  l10n?.settingsDeleteError(e.toString()) ??
                      'Error clearing data: $e',
                ),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    }
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final l10n = AppLocalizations.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n?.logout ?? 'Logout'),
        content: Text(
          l10n?.settingsLogoutConfirm ?? 'Are you sure you want to log out?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n?.cancel ?? 'Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n?.logout ?? 'Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await context.read<AuthProvider>().logout();
      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.login,
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final user = context.watch<AuthProvider>().currentUser;
    final settings = context.watch<SettingsProvider>();

    final userName = user?.name ?? 'FitTrack User';
    final userEmail = user?.email ?? '';
    final initial = userName.isNotEmpty ? userName[0].toUpperCase() : 'U';

    return Scaffold(
      appBar: AppBar(title: Text(l10n?.navSettings ?? 'Cài đặt'), elevation: 0),
      body: ListView(
        children: [
          // 1. User Header Tile
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(20),
              color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    child: Text(
                      initial,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          userEmail,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.disabledColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n?.profileEditPrompt ??
                              'Edit profile & body metrics →',
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right),
                ],
              ),
            ),
          ),
          const Divider(height: 1),

          // 2. Preferences Section
          _buildSectionHeader(
            l10n?.settingsAppearanceLanguage ?? 'Appearance & Language',
            theme,
          ),

          // Language Selector
          ListTile(
            leading: const Icon(Icons.language_outlined),
            title: Text(l10n?.language ?? 'Ngôn ngữ'),
            subtitle: Text(
              settings.locale.languageCode == 'vi' ? 'Tiếng Việt' : 'English',
            ),
            trailing: SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'vi', label: Text('VI')),
                ButtonSegment(value: 'en', label: Text('EN')),
              ],
              selected: {settings.locale.languageCode},
              onSelectionChanged: (set) {
                settings.setLocale(Locale(set.first));
              },
            ),
          ),

          // Theme Mode Selector
          ListTile(
            leading: const Icon(Icons.brightness_6_outlined),
            title: Text(l10n?.themeMode ?? 'Giao diện sáng / tối'),
            subtitle: Text(
              settings.themeMode == ThemeMode.dark
                  ? (l10n?.darkTheme ?? 'Dark Theme')
                  : (settings.themeMode == ThemeMode.light
                        ? (l10n?.lightTheme ?? 'Light Theme')
                        : (l10n?.themeSystem ?? 'System')),
            ),
            trailing: DropdownButton<ThemeMode>(
              value: settings.themeMode,
              underline: const SizedBox.shrink(),
              items: [
                DropdownMenuItem(
                  value: ThemeMode.system,
                  child: Text(l10n?.themeSystem ?? 'System'),
                ),
                DropdownMenuItem(
                  value: ThemeMode.light,
                  child: Text(l10n?.lightTheme ?? 'Light'),
                ),
                DropdownMenuItem(
                  value: ThemeMode.dark,
                  child: Text(l10n?.darkTheme ?? 'Dark'),
                ),
              ],
              onChanged: (mode) {
                if (mode != null) {
                  settings.setThemeMode(mode);
                }
              },
            ),
          ),
          const Divider(),

          // 3. Information & About
          _buildSectionHeader(
            l10n?.settingsTeamInfo ?? 'Team & Project Info',
            theme,
          ),

          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(l10n?.settingsTeamInfo ?? 'Team & Project Info'),
            subtitle: Text(
              l10n?.settingsTeamSubtitle ??
                  'Phenikaa University · Instructor: Dr. Nguyen Xuan Que',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TeamInfoScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.dataset_outlined),
            title: Text(
              l10n?.settingsCreditsTitle ?? 'Data & Media Attribution',
            ),
            subtitle: Text(
              l10n?.settingsCreditsSubtitle ??
                  'hasaneyldrm / Gym Visual / Open Food Facts',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TeamInfoScreen()),
              );
            },
          ),
          const Divider(),

          // 4. Account & Danger Zone
          _buildSectionHeader(
            l10n?.settingsAccountData ?? 'Account & Data',
            theme,
          ),

          ListTile(
            leading: Icon(
              Icons.delete_forever_outlined,
              color: theme.colorScheme.error,
            ),
            title: Text(
              l10n?.settingsDeleteAllData ?? 'Delete Personal Data',
              style: TextStyle(color: theme.colorScheme.error),
            ),
            subtitle: Text(
              l10n?.settingsDeleteDataSub ??
                  'Wipe custom plans, workout history, weight, and meal logs',
            ),
            onTap: () => _confirmDeleteMyData(context),
          ),

          ListTile(
            leading: const Icon(Icons.logout, color: Colors.orange),
            title: Text(
              l10n?.logout ?? 'Logout',
              style: const TextStyle(color: Colors.orange),
            ),
            onTap: () => _confirmLogout(context),
          ),
          const SizedBox(height: 32),

          Center(
            child: Text(
              'FitTrack v1.0.0 (Phenikaa University)',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.disabledColor,
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: theme.textTheme.labelMedium?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
