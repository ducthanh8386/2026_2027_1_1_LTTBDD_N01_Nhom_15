import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';

import '../data/repositories/user_repository.dart';
import '../models/user.dart';

class AuthException implements Exception {
  final String message;
  const AuthException(this.message);

  @override
  String toString() => message;
}

class AuthService {
  final UserRepository _userRepo;

  AuthService({UserRepository? userRepo})
      : _userRepo = userRepo ?? UserRepository();

  /// Generates a cryptographically secure random salt encoded in base64url.
  static String generateSalt([int length = 16]) {
    final rand = Random.secure();
    final bytes = List<int>.generate(length, (_) => rand.nextInt(256));
    return base64Url.encode(bytes);
  }

  /// Hashes a password with salt using SHA-256: sha256(utf8.encode(password + salt)).
  static String hashPassword(String password, String salt) {
    final bytes = utf8.encode(password + salt);
    return sha256.convert(bytes).toString();
  }

  /// Registers a new user. Throws [DuplicateEmailException] if the email is taken.
  Future<User> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final cleanEmail = email.trim().toLowerCase();
    final existing = await _userRepo.findByEmail(cleanEmail);
    if (existing != null) {
      throw DuplicateEmailException('Email already in use: $cleanEmail');
    }

    final salt = generateSalt();
    final passwordHash = hashPassword(password, salt);
    final now = DateTime.now().toIso8601String();

    final user = User(
      name: name.trim(),
      email: cleanEmail,
      passwordHash: passwordHash,
      salt: salt,
      createdAt: now,
    );

    final id = await _userRepo.insert(user);
    return user.copyWith(id: id);
  }

  /// Authenticates a user. Throws [AuthException] on invalid credentials.
  Future<User> login({
    required String email,
    required String password,
  }) async {
    final cleanEmail = email.trim().toLowerCase();
    final user = await _userRepo.findByEmail(cleanEmail);
    if (user == null) {
      throw const AuthException('Invalid email or password');
    }

    final calculatedHash = hashPassword(password, user.salt);
    if (calculatedHash != user.passwordHash) {
      throw const AuthException('Invalid email or password');
    }

    return user;
  }
}
