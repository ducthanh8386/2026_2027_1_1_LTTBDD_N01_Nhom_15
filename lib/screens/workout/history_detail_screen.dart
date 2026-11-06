import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/set_log.dart';
import '../../models/workout_session.dart';
import '../../providers/exercise_provider.dart';
import '../../providers/workout_provider.dart';

/// HistoryDetailScreen owned by Partner B (Module B4).
///
/// Displays details of a completed workout session:
/// - Session header: Plan day name / Free workout, date/time, duration, volume, total sets.
/// - Exercises performed in sequence.
/// - Each exercise with its localized name, body part, individual set details (reps × weightKg),
///   and exercise total volume.
class HistoryDetailScreen extends StatefulWidget {
  final int sessionId;

  const HistoryDetailScreen({
    super.key,
    required this.sessionId,
  });

  @override
  State<HistoryDetailScreen> createState() => _HistoryDetailScreenState();
}

class _HistoryDetailScreenState extends State<HistoryDetailScreen> {
  WorkoutSession? _session;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSession();
  }

  Future<void> _loadSession() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final session =
          await context.read<WorkoutProvider>().getSession(widget.sessionId);
      if (mounted) {
        setState(() {
          _session = session;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.historyDetailTitle ?? 'Workout Detail'),
        elevation: 0,
      ),
      body: _buildBody(context, l10n, theme),
    );
  }

  Widget _buildBody(
    BuildContext context,
    AppLocalizations? l10n,
    ThemeData theme,
  ) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 12),
              Text(_error!),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _loadSession,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_session == null) {
      return Center(
        child: Text(
          l10n?.emptyStateMessage ?? 'No data found',
          style: theme.textTheme.titleMedium,
        ),
      );
    }

    final session = _session!;
    final locale = Localizations.localeOf(context).languageCode;
    final exerciseProvider = context.watch<ExerciseProvider>();

    // Parse start date
    DateTime? startDate = DateTime.tryParse(session.startedAt);
    final dateStr = startDate != null
        ? DateFormat('EEEE, dd/MM/yyyy • HH:mm').format(startDate)
        : session.startedAt;

    final durationMinutes = session.duration?.inMinutes ?? 0;

    // Group sets by exercise while preserving occurrence order
    final orderedExerciseIds = <int>[];
    final Map<int, List<SetLog>> exerciseSets = {};
    for (final s in session.sets) {
      if (!exerciseSets.containsKey(s.exerciseId)) {
        orderedExerciseIds.add(s.exerciseId);
        exerciseSets[s.exerciseId] = [];
      }
      exerciseSets[s.exerciseId]!.add(s);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Session Header Card
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.fitness_center,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              session.planDayName ??
                                  (l10n?.historyFreeWorkout ?? 'Free Workout'),
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              dateStr,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.disabledColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildMetricColumn(
                        context,
                        icon: Icons.timer_outlined,
                        value: '$durationMinutes',
                        unit: l10n?.historyMinutes ?? 'min',
                        label: l10n?.historyDuration ?? 'Duration',
                      ),
                      _buildMetricColumn(
                        context,
                        icon: Icons.scale_outlined,
                        value: session.totalVolume.toStringAsFixed(0),
                        unit: 'kg',
                        label: l10n?.historyVolume ?? 'Volume',
                      ),
                      _buildMetricColumn(
                        context,
                        icon: Icons.repeat_outlined,
                        value: '${session.setCount}',
                        unit: l10n?.historySets ?? 'sets',
                        label: l10n?.historyTotalSets ?? 'Total Sets',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // 2. Exercise Breakdown Header
          Text(
            l10n?.sessionDetails ?? 'Exercise Breakdown',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          // 3. Exercise Cards
          if (orderedExerciseIds.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Center(
                  child: Text(
                    l10n?.emptyStateMessage ?? 'No exercises logged in this session',
                    style: TextStyle(color: theme.disabledColor),
                  ),
                ),
              ),
            )
          else
            ...orderedExerciseIds.map((exId) {
              final sets = exerciseSets[exId] ?? [];
              final exercise = exerciseProvider.byId(exId);
              final exName = exercise?.localizedName(locale) ?? 'Exercise #$exId';
              final exVolume = sets.fold<double>(
                0.0,
                (acc, s) => acc + (s.reps * s.weightKg),
              );

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Exercise header: Name & Volume badge
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  exName,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (exercise != null) ...[
                                  const SizedBox(height: 4),
                                  Wrap(
                                    spacing: 6,
                                    children: [
                                      Chip(
                                        visualDensity: VisualDensity.compact,
                                        label: Text(
                                          exercise.bodyPart,
                                          style: const TextStyle(fontSize: 10),
                                        ),
                                        padding: EdgeInsets.zero,
                                      ),
                                      Chip(
                                        visualDensity: VisualDensity.compact,
                                        label: Text(
                                          exercise.targetMuscle,
                                          style: const TextStyle(fontSize: 10),
                                        ),
                                        padding: EdgeInsets.zero,
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${exVolume.toStringAsFixed(1)} kg',
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Set details list
                      Container(
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 6,
                          horizontal: 10,
                        ),
                        child: Column(
                          children: sets.asMap().entries.map((entry) {
                            final idx = entry.key + 1;
                            final setLog = entry.value;
                            final setVol = setLog.reps * setLog.weightKg;

                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4.0),
                              child: Row(
                                children: [
                                  Text(
                                    l10n?.historySetNumber(idx) ?? 'Set $idx',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    '${setLog.reps} reps × ${setLog.weightKg.toStringAsFixed(1)} kg',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  const SizedBox(width: 12),
                                  SizedBox(
                                    width: 70,
                                    child: Text(
                                      '(${setVol.toStringAsFixed(1)} kg)',
                                      textAlign: TextAlign.end,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: theme.disabledColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildMetricColumn(
    BuildContext context, {
    required IconData icon,
    required String value,
    required String unit,
    required String label,
  }) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              value,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 2),
            Text(
              unit,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.disabledColor,
              ),
            ),
          ],
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
        ),
      ],
    );
  }
}
