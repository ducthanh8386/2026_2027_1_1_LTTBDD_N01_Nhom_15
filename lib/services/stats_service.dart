import '../data/repositories/stats_repository.dart';
import '../data/repositories/weight_repository.dart';
import '../models/weight_entry.dart';

enum StatsRange { days7, days30, all }

class WeightPoint {
  final DateTime date;
  final double kg;

  const WeightPoint({required this.date, required this.kg});

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

  const VolumePoint({required this.date, required this.value});

  @override
  String toString() => 'VolumePoint(date: $date, value: $value)';
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
/// Implements weight tracking, data series generation, and upsert operations.
/// Volume series and weekly summary will be expanded with real workout sessions in B07.
class StatsService {
  final StatsRepository _statsRepo;
  final WeightRepository _weightRepo;

  StatsService({StatsRepository? stats, WeightRepository? weights})
    : _statsRepo = stats ?? StatsRepository(),
      _weightRepo = weights ?? WeightRepository();

  StatsRepository get statsRepo => _statsRepo;
  WeightRepository get weightRepo => _weightRepo;

  Future<List<WeightPoint>> weightSeries(int userId, StatsRange range) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    DateTime from;
    final to = DateTime(now.year, now.month, now.day, 23, 59, 59);

    switch (range) {
      case StatsRange.days7:
        from = today.subtract(const Duration(days: 6));
        break;
      case StatsRange.days30:
        from = today.subtract(const Duration(days: 29));
        break;
      case StatsRange.all:
        from = DateTime(2000, 1, 1);
        break;
    }

    final entries = await _weightRepo.findRange(userId, from, to);

    final points = entries.map((e) {
      final parts = e.date.split('-');
      final d = (parts.length == 3)
          ? DateTime(
              int.parse(parts[0]),
              int.parse(parts[1]),
              int.parse(parts[2]),
            )
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

    final entry = WeightEntry(userId: userId, date: dateStr, weightKg: kg);

    await _weightRepo.upsert(entry);
  }

  // --- Stubs to be completed in B07 using real workout sessions ---

  Future<List<VolumePoint>> volumeSeries(int userId, StatsRange range) async {
    // B07: calculate volume points from WorkoutSession & SetLog
    return [];
  }

  Future<List<VolumePoint>> maxWeightSeries(
    int userId,
    int exerciseId,
    StatsRange range,
  ) async {
    // B07: calculate exercise 1RM / max weight series
    return [];
  }

  Future<WeeklySummary> weeklySummary(int userId) async {
    // B07: calculate weekly total volume and food log kcal
    return const WeeklySummary(sessions: 0, totalVolume: 0.0, totalKcal: 0.0);
  }
}
