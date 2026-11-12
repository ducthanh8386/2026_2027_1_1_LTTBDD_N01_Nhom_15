import 'dart:async';

import 'package:flutter/foundation.dart';

import '../services/stats_service.dart';

/// ProgressProvider owned by Partner B (Module B2/B4).
///
/// Manages state for weight tracking, progress charts, and weekly summaries.
/// Injected via `ChangeNotifierProxyProvider<AuthProvider, ProgressProvider>` in main.dart.
class ProgressProvider extends ChangeNotifier {
  final StatsService _service;

  int? _userId;
  StatsRange _range = StatsRange.days7;
  List<WeightPoint> _weightPoints = [];
  List<VolumePoint> _volumePoints = [];
  List<VolumePoint> _maxWeightPoints = [];
  WeeklySummary? _weeklySummary;

  bool _isLoading = false;
  String? _error;
  bool _disposed = false;

  ProgressProvider({StatsService? service})
    : _service = service ?? StatsService();

  int? get userId => _userId;
  StatsRange get range => _range;
  List<WeightPoint> get weightPoints => List.unmodifiable(_weightPoints);
  List<VolumePoint> get volumePoints => List.unmodifiable(_volumePoints);
  List<VolumePoint> get maxWeightPoints => List.unmodifiable(_maxWeightPoints);
  WeeklySummary? get weeklySummary => _weeklySummary;
  bool get isLoading => _isLoading;
  String? get error => _error;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  void _safeNotifyListeners() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  /// Called by ChangeNotifierProxyProvider.update from main.dart.
  /// Must NOT call notifyListeners synchronously in build tree -> uses scheduleMicrotask.
  void updateUser(int? userId) {
    if (_userId == userId) return;
    _userId = userId;
    _weightPoints = [];
    _volumePoints = [];
    _maxWeightPoints = [];
    _weeklySummary = null;

    if (_userId != null) {
      scheduleMicrotask(() => reload());
    } else {
      scheduleMicrotask(() => _safeNotifyListeners());
    }
  }

  void setRange(StatsRange r) {
    if (_range == r) return;
    _range = r;
    _safeNotifyListeners();
    reload();
  }

  Future<void> reload() async {
    if (_userId == null) return;

    _isLoading = true;
    _error = null;
    _safeNotifyListeners();

    try {
      _weightPoints = await _service.weightSeries(_userId!, _range);
      _volumePoints = await _service.volumeSeries(_userId!, _range);
      _weeklySummary = await _service.weeklySummary(_userId!);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      _safeNotifyListeners();
    }
  }

  Future<void> loadWeekly() async {
    if (_userId == null) return;
    try {
      _weeklySummary = await _service.weeklySummary(_userId!);
      _safeNotifyListeners();
    } catch (_) {}
  }

  Future<void> loadMaxWeight(int exerciseId) async {
    if (_userId == null) return;
    try {
      _maxWeightPoints = await _service.maxWeightSeries(
        _userId!,
        exerciseId,
        _range,
      );
      _safeNotifyListeners();
    } catch (_) {}
  }

  Future<void> addWeight(DateTime date, double kg) async {
    if (_userId == null) return;
    try {
      await _service.upsertWeight(_userId!, date, kg);
      await reload();
    } catch (e) {
      _error = e.toString();
      _safeNotifyListeners();
      rethrow;
    }
  }
}
