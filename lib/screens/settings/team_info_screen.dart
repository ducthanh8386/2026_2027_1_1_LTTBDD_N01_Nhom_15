import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'team_data.dart';

/// TeamInfoScreen owned by Partner B (Module B3).
///
/// Displays:
/// - Course and Project details.
/// - Team member cards with roles, contributions, and clickable GitHub links.
/// - Third-party datasets and media attributions.
class TeamInfoScreen extends StatelessWidget {
  const TeamInfoScreen({super.key});

  Future<void> _launchUrl(BuildContext context, String urlString) async {
    final uri = Uri.tryParse(urlString);
    if (uri != null) {
      try {
        final success = await launchUrl(uri, mode: LaunchMode.externalApplication);
        if (!success && context.mounted) {
          final l10n = AppLocalizations.of(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                l10n?.teamLinkError(urlString) ?? 'Could not open link: $urlString',
              ),
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          final l10n = AppLocalizations.of(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                l10n?.teamLinkError(e.toString()) ?? 'Error opening link: $e',
              ),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.settingsTeamInfo ?? 'Team & Project Info'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Project & Course Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: theme.colorScheme.primaryContainer,
                      child: Icon(
                        Icons.fitness_center,
                        size: 40,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      TeamData.appName,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      TeamData.projectTitle,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const Divider(height: 24),
                    _buildInfoRow('Trường:', TeamData.university, theme),
                    const SizedBox(height: 6),
                    _buildInfoRow('Học phần:', TeamData.course, theme),
                    const SizedBox(height: 6),
                    _buildInfoRow('Giảng viên:', TeamData.instructor, theme),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 2. Members Section Header
            Text(
              'Thành viên nhóm',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // 3. Member Cards
            ...TeamData.members.map((member) => _buildMemberCard(context, member, theme)),
            const SizedBox(height: 20),

            // 4. Data & License Attributions
            Text(
              'Ghi công bản quyền & Dữ liệu',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.dataset_outlined),
                      title: const Text(
                        'Dữ liệu & Hình ảnh bài tập',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: const Text(TeamData.exerciseAttribution),
                      trailing: IconButton(
                        icon: const Icon(Icons.open_in_new, size: 20),
                        onPressed: () => _launchUrl(context, 'https://gymvisual.com/'),
                      ),
                    ),
                    const Divider(),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.qr_code_scanner_outlined),
                      title: const Text(
                        'Cơ sở dữ liệu Dinh dưỡng Open Food Facts',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: const Text(TeamData.nutritionAttribution),
                      trailing: IconButton(
                        icon: const Icon(Icons.open_in_new, size: 20),
                        onPressed: () => _launchUrl(context, 'https://openfoodfacts.org'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.disabledColor,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildMemberCard(BuildContext context, TeamMember member, ThemeData theme) {
    final initials = member.name.isNotEmpty
        ? member.name.trim().split(' ').last.substring(0, 1).toUpperCase()
        : '?';

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  child: Text(
                    initials,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        member.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        member.role,
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              member.contribution,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.35),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'MSSV: ${member.studentId}',
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.disabledColor),
                ),
                OutlinedButton.icon(
                  onPressed: () => _launchUrl(context, member.githubUrl),
                  icon: const Icon(Icons.code, size: 16),
                  label: const Text('GitHub'),
                  style: OutlinedButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
