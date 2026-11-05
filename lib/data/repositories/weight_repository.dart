import '../../models/weight_entry.dart';

/// Stub repository owned by Partner B (Module B2).
///
/// B will implement upsert by UNIQUE(user_id, date), findRange, latest,
/// and delete in B2.
class WeightRepository {
  Future<void> upsert(WeightEntry entry) async {
    throw UnimplementedError('WeightRepository will be implemented by Partner B in Module B2.');
  }

  Future<List<WeightEntry>> findRange(int userId, DateTime from, DateTime to) async {
    return [];
  }

  Future<WeightEntry?> latest(int userId) async {
    return null;
  }

  Future<int> delete(int id) async {
    throw UnimplementedError('WeightRepository will be implemented by Partner B in Module B2.');
  }
}
