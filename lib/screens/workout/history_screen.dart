import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/workout_session.dart';
import '../../providers/auth_provider.dart';
import '../../providers/progress_provider.dart';
import '../../providers/workout_provider.dart';
import 'history_detail_screen.dart';

/// HistoryScreen owned by Partner B (Module B4).
///
/// Displays completed workout sessions ordered newest first, grouped by date.
/// Uses ONLY WorkoutProvider (loadHistory, history, deleteSession) without writing SQL.
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refresh();
    });
  }

  void _refresh() {
    final user = context.read<AuthProvider>().currentUser;
    if (user != null && user.id != null) {
      context.read<WorkoutProvider>().loadHistory(user.id!);
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WorkoutProvider provider,
    WorkoutSession session,
  ) async {
    final l10n = AppLocalizations.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n?.historyDeleteTitle ?? 'Delete Session'),
        content: Text(
          l10n?.historyDeleteConfirm ??
              'Are you sure you want to delete this workout session?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n?.cancel ?? 'Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l10n?.deletePlan ?? 'Delete'),
          ),
        ],
      ),
    );

    if (confirm == true && session.id != null) {
      await provider.deleteSession(session.id!);
      if (context.mounted) {
        // Also refresh progress so volume/summary charts stay in sync
        context.read<ProgressProvider>().reload();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.historyTitle ?? 'Workout History'),
        elevation: 0,
      ),
      body: Consumer<WorkoutProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.history.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null && provider.history.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 12),
                    Text(provider.error!),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _refresh,
                      child: Text(l10n?.retry ?? 'Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          final sessions = provider.history;
          if (sessions.isEmpty) {
            return _buildEmptyState(context, l10n, theme);
          }

          // Group sessions by date string (YYYY-MM-DD)
          final Map<String, List<WorkoutSession>> grouped = {};
          for (final s in sessions) {
            final dateKey = s.startedAt.length >= 10
                ? s.startedAt.substring(0, 10)
                : s.startedAt;
            grouped.putIfAbsent(dateKey, () => []).add(s);
          }

          return RefreshIndicator(
            onRefresh: () async => _refresh(),
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
              itemCount: grouped.keys.length,
              itemBuilder: (context, groupIndex) {
                final dateKey = grouped.keys.elementAt(groupIndex);
                final daySessions = grouped[dateKey]!;

                DateTime? parsedDate = DateTime.tryParse(dateKey);
                final headerDateStr = parsedDate != null
                    ? DateFormat('EEEE, dd/MM/yyyy').format(parsedDate)
                    : dateKey;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section Date Header
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8.0,
                        horizontal: 4.0,
                      ),
                      child: Text(
                        headerDateStr,
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    // Session items
                    ...daySessions.map((session) {
                      return _buildSessionCard(
                        context,
                        provider,
                        session,
                        l10n,
                        theme,
                      );
                    }),
                    const SizedBox(height: 8),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    AppLocalizations? l10n,
    ThemeData theme,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history_toggle_off_outlined,
              size: 72,
              color: theme.disabledColor,
            ),
            const SizedBox(height: 16),
            Text(
              l10n?.historyEmptyTitle ?? 'No Workout History',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n?.historyEmptySubtitle ??
                  'Completed workouts will appear here. Start training today!',
              textAlign: TextAlign.center,
              style: TextStyle(color: theme.disabledColor),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _refresh,
              icon: const Icon(Icons.refresh),
              label: Text(l10n?.refresh ?? 'Refresh'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionCard(
    BuildContext context,
    WorkoutProvider provider,
    WorkoutSession session,
    AppLocalizations? l10n,
    ThemeData theme,
  ) {
    DateTime? startTime = DateTime.tryParse(session.startedAt);
    final timeStr = startTime != null
        ? DateFormat('HH:mm').format(startTime)
        : session.startedAt;

    final durationMinutes = session.duration?.inMinutes ?? 0;
    final planTitle =
        session.planDayName ?? (l10n?.historyFreeWorkout ?? 'Free Workout');

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          if (session.id != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => HistoryDetailScreen(sessionId: session.id!),
              ),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Title + Time + Delete Menu
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.fitness_center,
                      size: 20,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          planTitle,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          timeStr,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.disabledColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.delete_outline,
                      size: 20,
                      color: theme.disabledColor,
                    ),
                    tooltip: l10n?.deletePlan ?? 'Delete',
                    onPressed: () => _confirmDelete(context, provider, session),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Badges: Duration • Volume • Sets
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  _buildChip(
                    theme,
                    icon: Icons.timer_outlined,
                    label: '$durationMinutes ${l10n?.historyMinutes ?? 'min'}',
                  ),
                  _buildChip(
                    theme,
                    icon: Icons.scale_outlined,
                    label: '${session.totalVolume.toStringAsFixed(0)} kg',
                  ),
                  _buildChip(
                    theme,
                    icon: Icons.repeat_outlined,
                    label: '${session.setCount} ${l10n?.historySets ?? 'sets'}',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChip(
    ThemeData theme, {
    required IconData icon,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: theme.colorScheme.primary),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
