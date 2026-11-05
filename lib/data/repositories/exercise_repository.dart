import '../../models/exercise.dart';

/// Stub repository owned by Partner B (Module B1).
///
/// B will implement full search, body part and equipment filtering,
/// and distinct queries in B1.
class ExerciseRepository {
  Future<List<Exercise>> findAll({
    String? bodyPart,
    String? equipment,
    String? query,
  }) async {
    return [];
  }

  Future<Exercise?> findById(int id) async {
    return null;
  }

  Future<Exercise?> findBySourceId(String sourceId) async {
    return null;
  }

  Future<List<String>> distinctBodyParts() async {
    return [];
  }

  Future<List<String>> distinctEquipment() async {
    return [];
  }
}
