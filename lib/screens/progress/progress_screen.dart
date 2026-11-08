import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../providers/exercise_provider.dart';
import '../../providers/progress_provider.dart';
import '../../services/stats_service.dart';
import 'add_weight_sheet.dart';

/// ProgressScreen owned by Partner B (Module B2/B4).
///
/// Features:
/// - TabBar: Weight Progress | Workout Volume.
/// - SegmentedButton for time range (7 days, 30 days, All).
/// - Dynamic KPI cards (Current weight, Range change, Min/Max; Total Volume, Avg, Max).
/// - Weekly summary card (Sessions, Volume, Calories).
/// - Interactive fl_chart LineChart for Weight and BarChart for Volume.
/// - Max weight by exercise section with exercise selector.
/// - FloatingActionButton to log/update weight.
class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  int? _selectedExerciseId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().currentUser;
      if (user != null) {
        context.read<ProgressProvider>().updateUser(user.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n?.progressTitle ?? 'Progress'),
          elevation: 0,
          bottom: TabBar(
            tabs: [
              Tab(
                icon: const Icon(Icons.monitor_weight_outlined),
                text: l10n?.progressWeightTab ?? 'Weight',
              ),
              Tab(
                icon: const Icon(Icons.bar_chart_outlined),
                text: l10n?.progressVolumeTab ?? 'Volume',
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          heroTag: 'progress_weight_fab',
          onPressed: () => AddWeightSheet.show(context),
          icon: const Icon(Icons.add),
          label: Text(l10n?.progressAddWeight ?? 'Log Weight'),
        ),
        body: TabBarView(
          children: [_buildWeightTab(context), _buildVolumeTab(context)],
        ),
      ),
    );
  }

  Widget _buildWeightTab(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Consumer<ProgressProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.error != null && provider.weightPoints.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 12),
                Text(provider.error!),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => provider.reload(),
                  child: Text(l10n?.retry ?? 'Retry'),
                ),
              ],
            ),
          );
        }

        final points = provider.weightPoints;

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Time Range SegmentedButton
              _buildRangeSelector(context, provider),
              const SizedBox(height: 16),

              // 2. Summary KPI Cards
              if (points.isNotEmpty) ...[
                _buildSummaryCards(context, points),
                const SizedBox(height: 20),
              ],

              // 3. Chart Container
              _buildChartCard(context, points),
            ],
          ),
        );
      },
    );
  }

  Widget _buildVolumeTab(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Consumer<ProgressProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final points = provider.volumePoints;
        final summary = provider.weeklySummary;

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Weekly Summary Banner
              _buildWeeklySummaryCard(context, summary),
              const SizedBox(height: 16),

              // 2. Range Selector
              _buildRangeSelector(context, provider),
              const SizedBox(height: 16),

              // 3. Volume KPI Cards
              if (points.isNotEmpty) ...[
                _buildVolumeKpiCards(context, points),
                const SizedBox(height: 16),
              ],

              // 4. Volume Bar Chart
              _buildVolumeBarChartCard(context, points),
              const SizedBox(height: 24),

              // 5. Max Weight by Exercise Section
              _buildMaxWeightSection(context, provider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWeeklySummaryCard(BuildContext context, WeeklySummary? summary) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    final sessions = summary?.sessions ?? 0;
    final volume = (summary?.totalVolume ?? 0.0).toStringAsFixed(0);
    final kcal = (summary?.totalKcal ?? 0.0).toStringAsFixed(0);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 18,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  l10n?.progressWeeklySummary ?? 'Weekly Summary',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildWeeklyItem(
                  context,
                  label: l10n?.progressWeeklySessions ?? 'Sessions',
                  value: '$sessions',
                  icon: Icons.fitness_center_outlined,
                ),
                _buildWeeklyItem(
                  context,
                  label: l10n?.progressWeeklyVolume ?? 'Volume',
                  value: '$volume kg',
                  icon: Icons.scale_outlined,
                ),
                _buildWeeklyItem(
                  context,
                  label: l10n?.progressWeeklyKcal ?? 'Calories',
                  value: '$kcal kcal',
                  icon: Icons.local_fire_department_outlined,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyItem(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
  }) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.disabledColor,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildVolumeKpiCards(BuildContext context, List<VolumePoint> points) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    double totalVol = 0;
    double maxVol = 0;
    for (final p in points) {
      totalVol += p.value;
      if (p.value > maxVol) maxVol = p.value;
    }
    final avgVol = points.isNotEmpty ? (totalVol / points.length) : 0.0;

    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            context,
            label: l10n?.progressTotalVolume ?? 'Total Volume',
            value: '${totalVol.toStringAsFixed(0)} kg',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildMetricCard(
            context,
            label: l10n?.progressAvgVolume ?? 'Avg / Session',
            value: '${avgVol.toStringAsFixed(0)} kg',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildMetricCard(
            context,
            label: l10n?.progressMaxVolume ?? 'Max Session',
            value: '${maxVol.toStringAsFixed(0)} kg',
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    BuildContext context, {
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Column(
          children: [
            Text(
              label,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(fontSize: 10),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVolumeBarChartCard(
    BuildContext context,
    List<VolumePoint> points,
  ) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    if (points.isEmpty) {
      return Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.fitness_center_outlined,
                size: 64,
                color: theme.disabledColor,
              ),
              const SizedBox(height: 12),
              Text(
                l10n?.progressNoVolumeData ?? 'No volume records yet',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                l10n?.progressNoVolumeSub ?? 'Completed workouts will automatically generate volume charts.',
                textAlign: TextAlign.center,
                style: TextStyle(color: theme.disabledColor),
              ),
            ],
          ),
        ),
      );
    }

    double maxVol = 100.0;
    for (final p in points) {
      if (p.value > maxVol) maxVol = p.value;
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 20, 20, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n?.progressVolumeChartTitle ?? 'Workout Volume',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 260,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxVol * 1.15,
                  minY: 0,
                  gridData: const FlGridData(
                    show: true,
                    drawVerticalLine: false,
                  ),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 42,
                        getTitlesWidget: (val, _) {
                          final label = val >= 1000
                              ? '${(val / 1000).toStringAsFixed(1)}k'
                              : val.toStringAsFixed(0);
                          return Text(
                            label,
                            style: TextStyle(
                              color: theme.disabledColor,
                              fontSize: 10,
                            ),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        getTitlesWidget: (val, _) {
                          final idx = val.toInt();
                          if (idx >= 0 && idx < points.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                DateFormat('dd/MM').format(points[idx].date),
                                style: TextStyle(
                                  color: theme.disabledColor,
                                  fontSize: 10,
                                ),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                  ),
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final idx = group.x.toInt();
                        final dateStr = (idx >= 0 && idx < points.length)
                            ? DateFormat('dd/MM/yyyy').format(points[idx].date)
                            : '';
                        return BarTooltipItem(
                          '$dateStr\n',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          children: [
                            TextSpan(
                              text: '${rod.toY.toStringAsFixed(1)} kg',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  barGroups: points.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final pt = entry.value;
                    final barWidth = (140.0 / points.length.clamp(1, 15)).clamp(
                      8.0,
                      24.0,
                    );

                    return BarChartGroupData(
                      x: idx,
                      barRods: [
                        BarChartRodData(
                          toY: pt.value,
                          color: theme.colorScheme.primary,
                          width: barWidth,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMaxWeightSection(
    BuildContext context,
    ProgressProvider provider,
  ) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final exercises = context.watch<ExerciseProvider>().exercises;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.trending_up,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n?.progressMaxWeightTitle ?? 'Max Weight By Exercise',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Exercise Dropdown Selector
            DropdownButtonFormField<int>(
              value: _selectedExerciseId,
              isExpanded: true,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                hintText: l10n?.progressSelectExercise ?? 'Select Exercise',
              ),
              items: exercises.map((ex) {
                return DropdownMenuItem<int>(
                  value: ex.id,
                  child: Text(
                    ex.localizedName(locale),
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() => _selectedExerciseId = val);
                  provider.loadMaxWeight(val);
                }
              },
            ),
            const SizedBox(height: 16),

            // Max Weight Chart or Hint
            if (_selectedExerciseId == null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Center(
                  child: Text(
                    l10n?.progressSelectExercise ??
                        'Select an exercise above to see progression',
                    style: TextStyle(color: theme.disabledColor),
                  ),
                ),
              )
            else if (provider.maxWeightPoints.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Center(
                  child: Text(
                    l10n?.progressNoExerciseData ??
                        'No data recorded for this exercise in selected range',
                    style: TextStyle(color: theme.disabledColor),
                  ),
                ),
              )
            else
              _buildMaxWeightChart(context, provider.maxWeightPoints),
          ],
        ),
      ),
    );
  }

  Widget _buildMaxWeightChart(BuildContext context, List<VolumePoint> points) {
    final theme = Theme.of(context);

    final spots = <FlSpot>[];
    double minKg = points.first.value;
    double maxKg = points.first.value;
    for (int i = 0; i < points.length; i++) {
      final p = points[i];
      if (p.value < minKg) minKg = p.value;
      if (p.value > maxKg) maxKg = p.value;
      spots.add(FlSpot(i.toDouble(), p.value));
    }

    final minY = (minKg - 5).clamp(0.0, 500.0);
    final maxY = maxKg + 5;

    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: (points.length <= 1 ? 2 : points.length - 1).toDouble(),
          minY: minY,
          maxY: maxY,
          gridData: const FlGridData(show: true, drawVerticalLine: false),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 36,
                getTitlesWidget: (val, _) => Text(
                  val.toStringAsFixed(0),
                  style: TextStyle(color: theme.disabledColor, fontSize: 10),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 24,
                getTitlesWidget: (val, _) {
                  final idx = val.toInt();
                  if (idx >= 0 && idx < points.length) {
                    return Text(
                      DateFormat('dd/MM').format(points[idx].date),
                      style: TextStyle(
                        color: theme.disabledColor,
                        fontSize: 10,
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: spots.length > 2,
              color: Colors.deepOrange,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(show: spots.length <= 15),
              belowBarData: BarAreaData(
                show: true,
                color: Colors.deepOrange.withOpacity(0.15),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRangeSelector(BuildContext context, ProgressProvider provider) {
    final l10n = AppLocalizations.of(context);

    return Center(
      child: SegmentedButton<StatsRange>(
        segments: [
          ButtonSegment(
            value: StatsRange.days7,
            label: Text(l10n?.progressDays7 ?? '7 Days'),
          ),
          ButtonSegment(
            value: StatsRange.days30,
            label: Text(l10n?.progressDays30 ?? '30 Days'),
          ),
          ButtonSegment(
            value: StatsRange.all,
            label: Text(l10n?.progressAll ?? 'All'),
          ),
        ],
        selected: {provider.range},
        onSelectionChanged: (set) {
          if (set.isNotEmpty) {
            provider.setRange(set.first);
            if (_selectedExerciseId != null) {
              provider.loadMaxWeight(_selectedExerciseId!);
            }
          }
        },
      ),
    );
  }

  Widget _buildSummaryCards(BuildContext context, List<WeightPoint> points) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    final currentWeight = points.last.kg;
    final firstWeight = points.first.kg;
    final diff = currentWeight - firstWeight;
    final diffSign = diff > 0 ? '+' : '';
    final diffText = '${diffSign}${diff.toStringAsFixed(1)} kg';

    double minKg = points.first.kg;
    double maxKg = points.first.kg;
    for (final p in points) {
      if (p.kg < minKg) minKg = p.kg;
      if (p.kg > maxKg) maxKg = p.kg;
    }

    return Row(
      children: [
        // Current Weight
        Expanded(
          child: Card(
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
              child: Column(
                children: [
                  Text(
                    l10n?.progressCurrentWeight ?? 'Current',
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${currentWeight.toStringAsFixed(1)} kg',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),

        // Difference
        Expanded(
          child: Card(
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
              child: Column(
                children: [
                  Text(
                    l10n?.progressChange ?? 'Change',
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    diffText,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: diff == 0
                          ? Colors.grey
                          : (diff < 0 ? Colors.green : Colors.orange),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),

        // Min / Max
        Expanded(
          child: Card(
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
              child: Column(
                children: [
                  Text(
                    l10n?.progressMinMax ?? 'Min / Max',
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${minKg.toStringAsFixed(0)} / ${maxKg.toStringAsFixed(0)} kg',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChartCard(BuildContext context, List<WeightPoint> points) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    if (points.isEmpty) {
      return Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.monitor_weight_outlined,
                size: 64,
                color: theme.disabledColor,
              ),
              const SizedBox(height: 12),
              Text(
                l10n?.progressNoWeightData ?? 'No weight records yet',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                l10n?.progressNoWeightSub ??
                    'Tap the button below to log your first weight.',
                textAlign: TextAlign.center,
                style: TextStyle(color: theme.disabledColor),
              ),
            ],
          ),
        ),
      );
    }

    final List<FlSpot> spots = [];
    double minKg = points.first.kg;
    double maxKg = points.first.kg;

    for (int i = 0; i < points.length; i++) {
      final p = points[i];
      if (p.kg < minKg) minKg = p.kg;
      if (p.kg > maxKg) maxKg = p.kg;
      spots.add(FlSpot(i.toDouble(), p.kg));
    }

    final minY = (minKg - 2).clamp(0.0, 500.0);
    final maxY = maxKg + 2;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 20, 20, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 280,
              child: LineChart(
                LineChartData(
                  minX: 0,
                  maxX: (points.length <= 1 ? 2 : points.length - 1).toDouble(),
                  minY: minY,
                  maxY: maxY,
                  gridData: const FlGridData(
                    show: true,
                    drawVerticalLine: false,
                  ),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 42,
                        getTitlesWidget: (val, _) => Text(
                          val.toStringAsFixed(0),
                          style: TextStyle(
                            color: theme.disabledColor,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        interval: (points.length / 4).ceilToDouble().clamp(
                          1.0,
                          10.0,
                        ),
                        getTitlesWidget: (val, _) {
                          final idx = val.toInt();
                          if (idx >= 0 && idx < points.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                DateFormat('dd/MM').format(points[idx].date),
                                style: TextStyle(
                                  color: theme.disabledColor,
                                  fontSize: 10,
                                ),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: spots.length > 2,
                      color: theme.colorScheme.primary,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(show: spots.length <= 15),
                      belowBarData: BarAreaData(
                        show: true,
                        color: theme.colorScheme.primary.withOpacity(0.15),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
