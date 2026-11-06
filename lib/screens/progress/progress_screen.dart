import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../providers/progress_provider.dart';
import '../../services/stats_service.dart';
import 'add_weight_sheet.dart';

/// ProgressScreen owned by Partner B (Module B2).
///
/// Features:
/// - TabBar: Weight Progress | Workout Volume.
/// - SegmentedButton for time range (7 days, 30 days, All).
/// - Dynamic KPI cards (Current weight, Range change, Min/Max).
/// - Interactive fl_chart LineChart with gradient and tooltips.
/// - FloatingActionButton to log/update weight.
class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
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
          children: [
            _buildWeightTab(context),
            _buildVolumePlaceholder(context),
          ],
        ),
      ),
    );
  }

  Widget _buildWeightTab(BuildContext context) {
    return Consumer<ProgressProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.error != null) {
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
                  child: const Text('Retry'),
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

  Widget _buildVolumePlaceholder(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.fitness_center_outlined,
              size: 64,
              color: theme.disabledColor,
            ),
            const SizedBox(height: 16),
            Text(
              'Biểu đồ Khối lượng tạ',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Dữ liệu khối lượng buổi tập sẽ được tổng hợp tự động khi bạn hoàn thành các buổi tập thật (Module B07).',
              textAlign: TextAlign.center,
              style: TextStyle(color: theme.disabledColor),
            ),
          ],
        ),
      ),
    );
  }
}
