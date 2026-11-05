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

/// Stub service owned by Partner B (Module B2).
class StatsService {
  Future<List<WeightPoint>> weightSeries(int userId, StatsRange range) async {
    return [];
  }

  Future<List<VolumePoint>> volumeSeries(int userId, StatsRange range) async {
    return [];
  }

  Future<List<VolumePoint>> maxWeightSeries(
    int userId,
    int exerciseId,
    StatsRange range,
  ) async {
    return [];
  }

  Future<WeeklySummary> weeklySummary(int userId) async {
    return const WeeklySummary(sessions: 0, totalVolume: 0.0, totalKcal: 0.0);
  }
}
