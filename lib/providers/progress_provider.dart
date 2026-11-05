import 'package:flutter/foundation.dart';

import '../services/stats_service.dart';

/// ProgressProvider stub owned by Partner B (Module B2).
/// Signatures defined in docs/contracts/contract.md.
class ProgressProvider extends ChangeNotifier {
  ProgressProvider({StatsService? service});

  int? _userId;
  StatsRange _range = StatsRange.days7;
  final bool _isLoading = false;
  String? _error;

  void updateUser(int? userId) {
    if (_userId == userId) return;
    _userId = userId;
  }

  StatsRange get range => _range;
  void setRange(StatsRange r) {
    _range = r;
    notifyListeners();
  }

  List<WeightPoint> get weightPoints => const [];
  List<VolumePoint> get volumePoints => const [];
  List<VolumePoint> get maxWeightPoints => const [];
  WeeklySummary? get weeklySummary => null;

  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> reload() async {}
  Future<void> loadWeekly() async {}
  Future<void> loadMaxWeight(int exerciseId) async {}
  Future<void> addWeight(DateTime date, double kg) async {}
}
