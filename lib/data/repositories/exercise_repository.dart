import 'package:sqflite/sqflite.dart';
import '../../core/constants.dart';
import '../../models/exercise.dart';
import '../database_helper.dart';

/// ExerciseRepository owned by Partner B (Module B1).
///
/// Implements full search, body part and equipment filtering,
/// distinct queries, and Vietnamese accent-insensitive matching.
class ExerciseRepository {
  final DatabaseHelper _dbHelper;

  ExerciseRepository({DatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? DatabaseHelper();

  Future<Database> get _db => _dbHelper.database;

  Future<List<Exercise>> findAll({
    String? bodyPart,
    String? equipment,
    String? query,
  }) async {
    final db = await _db;
    final List<String> whereClauses = [];
    final List<dynamic> whereArgs = [];

    if (bodyPart != null &&
        bodyPart.trim().isNotEmpty &&
        bodyPart.toLowerCase() != 'all') {
      whereClauses.add('body_part = ?');
      whereArgs.add(bodyPart.trim());
    }

    if (equipment != null &&
        equipment.trim().isNotEmpty &&
        equipment.toLowerCase() != 'all') {
      whereClauses.add('equipment = ?');
      whereArgs.add(equipment.trim());
    }

    final String? where =
        whereClauses.isNotEmpty ? whereClauses.join(' AND ') : null;

    final results = await db.query(
      AppConstants.tableExercises,
      where: where,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      orderBy: 'name_en ASC',
    );

    List<Exercise> exercises =
        results.map((m) => Exercise.fromMap(m)).toList();

    if (query != null && query.trim().isNotEmpty) {
      final cleanQuery = query.trim().toLowerCase();
      final noDiacriticQuery = _stripDiacritics(cleanQuery);

      exercises = exercises.where((ex) {
        final en = ex.nameEn.toLowerCase();
        final vi = ex.nameVi.toLowerCase();
        final viNoDiacritic = _stripDiacritics(vi);
        final target = (ex.target ?? '').toLowerCase();

        return en.contains(cleanQuery) ||
            vi.contains(cleanQuery) ||
            viNoDiacritic.contains(noDiacriticQuery) ||
            target.contains(cleanQuery);
      }).toList();
    }

    return exercises;
  }

  Future<Exercise?> findById(int id) async {
    final db = await _db;
    final results = await db.query(
      AppConstants.tableExercises,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (results.isEmpty) return null;
    return Exercise.fromMap(results.first);
  }

  Future<Exercise?> findBySourceId(String sourceId) async {
    final db = await _db;
    final results = await db.query(
      AppConstants.tableExercises,
      where: 'source_id = ?',
      whereArgs: [sourceId],
      limit: 1,
    );
    if (results.isEmpty) return null;
    return Exercise.fromMap(results.first);
  }

  Future<List<String>> distinctBodyParts() async {
    final db = await _db;
    final results = await db.rawQuery(
      'SELECT DISTINCT body_part FROM ${AppConstants.tableExercises} WHERE body_part IS NOT NULL AND body_part != "" ORDER BY body_part ASC',
    );
    return results.map((r) => r['body_part'] as String).toList();
  }

  Future<List<String>> distinctEquipment() async {
    final db = await _db;
    final results = await db.rawQuery(
      'SELECT DISTINCT equipment FROM ${AppConstants.tableExercises} WHERE equipment IS NOT NULL AND equipment != "" ORDER BY equipment ASC',
    );
    return results.map((r) => r['equipment'] as String).toList();
  }

  static String _stripDiacritics(String str) {
    var result = str.toLowerCase();
    const map = {
      'a': ['á', 'à', 'ả', 'ã', 'ạ', 'ă', 'ắ', 'ằ', 'ẳ', 'ẵ', 'ặ', 'â', 'ấ', 'ầ', 'ẩ', 'ẫ', 'ậ'],
      'd': ['đ'],
      'e': ['é', 'è', 'ẻ', 'ẽ', 'ẹ', 'ê', 'ế', 'ề', 'ể', 'ễ', 'ệ'],
      'i': ['í', 'ì', 'ỉ', 'ĩ', 'ị'],
      'o': ['ó', 'ò', 'ỏ', 'õ', 'ọ', 'ô', 'ố', 'ồ', 'ổ', 'ỗ', 'ộ', 'ơ', 'ớ', 'ờ', 'ở', 'ỡ', 'ợ'],
      'u': ['ú', 'ù', 'ủ', 'ũ', 'ụ', 'ư', 'ứ', 'ừ', 'ử', 'ữ', 'ự'],
      'y': ['ý', 'ỳ', 'ỷ', 'ỹ', 'ỵ'],
    };

    map.forEach((nonDiacritic, diacritics) {
      for (final char in diacritics) {
        result = result.replaceAll(char, nonDiacritic);
      }
    });

    return result;
  }
}
