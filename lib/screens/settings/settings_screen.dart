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
    final confirmedFirst = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa dữ liệu cá nhân?'),
        content: const Text(
          'Hành động này sẽ xóa toàn bộ kế hoạch tập, lịch sử buổi tập, dữ liệu cân nặng và nhật ký ăn uống của bạn.\n\nTài khoản đăng nhập của bạn vẫn sẽ được giữ lại.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: theme.colorScheme.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'Tiếp tục',
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
          title: const Text('Xác nhận lần cuối'),
          content: const Text(
            'Bạn có chắc chắn 100% muốn xóa dữ liệu không? Thao tác này KHÔNG thể hoàn tác!',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text(
                'XÓA TẤT CẢ DỮ LIỆU',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
              const SnackBar(
                content: Text('Toàn bộ dữ liệu cá nhân đã được dọn sạch.'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Lỗi xóa dữ liệu: $e'), backgroundColor: Colors.red),
            );
          }
        }
      }
    }
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất khỏi ứng dụng không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Đăng xuất'),
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
      appBar: AppBar(
        title: Text(l10n?.navSettings ?? 'Cài đặt'),
        elevation: 0,
      ),
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
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
                          'Chỉnh sửa hồ sơ & chỉ số cơ thể →',
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
          _buildSectionHeader('Giao diện & Ngôn ngữ', theme),

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
                  ? 'Giao diện tối'
                  : (settings.themeMode == ThemeMode.light
                      ? 'Giao diện sáng'
                      : 'Theo hệ thống'),
            ),
            trailing: DropdownButton<ThemeMode>(
              value: settings.themeMode,
              underline: const SizedBox.shrink(),
              items: const [
                DropdownMenuItem(
                  value: ThemeMode.system,
                  child: Text('Hệ thống'),
                ),
                DropdownMenuItem(
                  value: ThemeMode.light,
                  child: Text('Sáng'),
                ),
                DropdownMenuItem(
                  value: ThemeMode.dark,
                  child: Text('Tối'),
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
          _buildSectionHeader('Thông tin ứng dụng', theme),

          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Thông tin nhóm & Dự án'),
            subtitle: const Text('Đại học Phenikaa · GV: TS. Nguyễn Xuân Quế'),
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
            title: const Text('Ghi công Dữ liệu & Bản quyền'),
            subtitle: const Text('hasaneyldrm / Gym Visual / Open Food Facts'),
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
          _buildSectionHeader('Tài khoản & Dữ liệu', theme),

          ListTile(
            leading: Icon(Icons.delete_forever_outlined, color: theme.colorScheme.error),
            title: Text(
              'Xóa toàn bộ dữ liệu cá nhân',
              style: TextStyle(color: theme.colorScheme.error),
            ),
            subtitle: const Text(
              'Xóa kế hoạch, lịch sử tập, cân nặng, nhật ký ăn (giữ tài khoản)',
            ),
            onTap: () => _confirmDeleteMyData(context),
          ),

          ListTile(
            leading: const Icon(Icons.logout, color: Colors.orange),
            title: const Text('Đăng xuất', style: TextStyle(color: Colors.orange)),
            onTap: () => _confirmLogout(context),
          ),
          const SizedBox(height: 32),

          Center(
            child: Text(
              'FitTrack v1.0.0 (Phenikaa University)',
              style: theme.textTheme.bodySmall?.copyWith(color: theme.disabledColor),
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
