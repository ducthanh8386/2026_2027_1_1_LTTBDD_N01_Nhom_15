import 'package:flutter/foundation.dart';

/// ProgressProvider stub owned by Partner B (Module B2).
///
/// B will implement series fetching, date ranges, and chart data in B2.
class ProgressProvider extends ChangeNotifier {
  final bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> reload() async {}
}
