import 'package:sqflite/sqflite.dart';

import '../../core/constants.dart';
import '../../models/user.dart';
import '../database_helper.dart';

class DuplicateEmailException implements Exception {
  final String message;
  DuplicateEmailException([this.message = 'Email is already registered.']);

  @override
  String toString() => message;
}

class UserRepository {
  final DatabaseHelper _dbHelper;

  UserRepository({DatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? DatabaseHelper();

  Future<int> insert(User user) async {
    final db = await _dbHelper.database;
    try {
      return await db.insert(
        AppConstants.tableUsers,
        user.toMap(),
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
    } on DatabaseException catch (e) {
      if (e.isUniqueConstraintError() ||
          e.toString().contains('users.email') ||
          e.toString().contains('UNIQUE constraint failed')) {
        throw DuplicateEmailException('Email already in use: ${user.email}');
      }
      rethrow;
    }
  }

  Future<User?> findByEmail(String email) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      AppConstants.tableUsers,
      where: 'LOWER(email) = ?',
      whereArgs: [email.trim().toLowerCase()],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  Future<User?> findById(int id) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      AppConstants.tableUsers,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  Future<int> update(User user) async {
    if (user.id == null) {
      throw ArgumentError('User must have an id to be updated.');
    }
    final db = await _dbHelper.database;
    try {
      return await db.update(
        AppConstants.tableUsers,
        user.toMap(),
        where: 'id = ?',
        whereArgs: [user.id],
      );
    } on DatabaseException catch (e) {
      if (e.isUniqueConstraintError() ||
          e.toString().contains('users.email') ||
          e.toString().contains('UNIQUE constraint failed')) {
        throw DuplicateEmailException('Email already in use: ${user.email}');
      }
      rethrow;
    }
  }
}
