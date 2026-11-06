import '../database_helper.dart';

/// StatsRepository owned by Partner B (Module B2/B4).
///
/// Provides aggregate SQL queries for workout volume, weekly summaries,
/// and exercise max weight tracking.
class StatsRepository {
  final DatabaseHelper _dbHelper;

  StatsRepository({DatabaseHelper? dbHelper})
    : _dbHelper = dbHelper ?? DatabaseHelper();

  DatabaseHelper get dbHelper => _dbHelper;
}
