import '../data/repositories/stats_repository.dart';
import '../data/repositories/weight_repository.dart';
import '../models/weight_entry.dart';

enum StatsRange { days7, days30, all }

class WeightPoint {
  final DateTime date;
  final double kg;

  const WeightPoint({
    required this.date,
    required this.kg,
  });

  @override
  String toString() => 'WeightPoint(date: $date, kg: $kg)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WeightPoint &&
          runtimeType == other.runtimeType &&
          date.year == other.date.year &&
          date.month == other.date.month &&
          date.day == other.date.day &&
          kg == other.kg;

  @override
  int get hashCode => date.hashCode ^ kg.hashCode;
}

class VolumePoint {
  final DateTime date;
  final double value;

  const VolumePoint({
    required this.date,
    required this.value,
  });

  @override
  String toString() => 'VolumePoint(date: $date, value: $value)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VolumePoint &&
          runtimeType == other.runtimeType &&
          date.year == other.date.year &&
          date.month == other.date.month &&
          date.day == other.date.day &&
          value == other.value;

  @override
  int get hashCode => date.hashCode ^ value.hashCode;
}

class WeeklySummary {
  final int sessions;
  final double totalVolume;
  final double totalKcal;

  const WeeklySummary({
    required this.sessions,
    required this.totalVolume,
    required this.totalKcal,
  });

  @override
  String toString() =>
      'WeeklySummary(sessions: $sessions, totalVolume: $totalVolume, totalKcal: $totalKcal)';
}

/// StatsService owned by Partner B (Module B2/B4).
///
/// Implements calculation and aggregation logic for weight tracking,
/// workout volume progression, and weekly summary statistics.
class StatsService {
  final StatsRepository _statsRepo;
  final WeightRepository _weightRepo;

  StatsService({
    StatsRepository? stats,
    WeightRepository? weights,
  })  : _statsRepo = stats ?? StatsRepository(),
        _weightRepo = weights ?? WeightRepository();

  StatsRepository get statsRepo => _statsRepo;
  WeightRepository get weightRepo => _weightRepo;

  DateTime _getFromDate(StatsRange range, DateTime today) {
    switch (range) {
      case StatsRange.days7:
        return today.subtract(const Duration(days: 6));
      case StatsRange.days30:
        return today.subtract(const Duration(days: 29));
      case StatsRange.all:
        return DateTime(2000, 1, 1);
    }
  }

  Future<List<WeightPoint>> weightSeries(int userId, StatsRange range) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final from = _getFromDate(range, today);
    final to = DateTime(now.year, now.month, now.day, 23, 59, 59);

    final entries = await _weightRepo.findRange(userId, from, to);

    final points = entries.map((e) {
      final parts = e.date.split('-');
      final d = (parts.length == 3)
          ? DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]))
          : DateTime.parse(e.date);
      return WeightPoint(date: d, kg: e.weightKg);
    }).toList();

    points.sort((a, b) => a.date.compareTo(b.date));
    return points;
  }

  Future<void> upsertWeight(int userId, DateTime date, double kg) async {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    final dateStr = '$y-$m-$d';

    final entry = WeightEntry(
      userId: userId,
      date: dateStr,
      weightKg: kg,
    );

    await _weightRepo.upsert(entry);
  }

  /// Aggregated volume (sum of reps * weight_kg) series grouped by day.
  Future<List<VolumePoint>> volumeSeries(int userId, StatsRange range) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final from = _getFromDate(range, today);
    final to = DateTime(now.year, now.month, now.day, 23, 59, 59);

    final records = await _statsRepo.getVolumeByDateRange(
      userId: userId,
      from: from,
      to: to,
    );

    final points = records.map((r) {
      final parts = r.date.split('-');
      final d = (parts.length == 3)
          ? DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]))
          : DateTime.parse(r.date);
      return VolumePoint(date: d, value: r.volume);
    }).toList();

    points.sort((a, b) => a.date.compareTo(b.date));
    return points;
  }

  /// Maximum weight lifted for a specific exercise over time.
  Future<List<VolumePoint>> maxWeightSeries(
      int userId, int exerciseId, StatsRange range) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final from = _getFromDate(range, today);
    final to = DateTime(now.year, now.month, now.day, 23, 59, 59);

    final records = await _statsRepo.getMaxWeightByExercise(
      userId: userId,
      exerciseId: exerciseId,
      from: from,
      to: to,
    );

    final points = records.map((r) {
      final parts = r.date.split('-');
      final d = (parts.length == 3)
          ? DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]))
          : DateTime.parse(r.date);
      return VolumePoint(date: d, value: r.maxWeight);
    }).toList();

    points.sort((a, b) => a.date.compareTo(b.date));
    return points;
  }

  /// Weekly summary starting on Monday: sessions, total volume, total kcal.
  Future<WeeklySummary> weeklySummary(int userId) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final monday = today.subtract(Duration(days: today.weekday - 1));

    final workoutStats = await _statsRepo.getWeeklyWorkoutStats(
      userId: userId,
      monday: monday,
    );

    final totalKcal = await _statsRepo.getWeeklyTotalKcal(
      userId: userId,
      monday: monday,
    );

    return WeeklySummary(
      sessions: workoutStats['session_count'] as int? ?? 0,
      totalVolume: (workoutStats['total_vol'] as num?)?.toDouble() ?? 0.0,
      totalKcal: totalKcal,
    );
  }
}
