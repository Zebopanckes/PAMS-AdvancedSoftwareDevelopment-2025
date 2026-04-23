// Author: Alec Brothwood (23076824) - Project Manager
// Author: Douaa Tadli (23012698) - Backend Developer
// File: user_service.dart
// Purpose: Manage staff/user accounts (admin responsibility).

import 'package:bcrypt/bcrypt.dart';
import 'package:uuid/uuid.dart';
import '../models/user_model.dart';
import 'database_service.dart';

class UserService {
  final _uuid = const Uuid();

  static const int _bcryptLogRounds = 12;

  String _hash(String password) =>
      BCrypt.hashpw(password, BCrypt.gensalt(logRounds: _bcryptLogRounds));

  Future<UserModel> create({
    required String username,
    required String email,
    required String password,
    required UserRole role,
    required String fullName,
    String? phone,
    String? city,
  }) async {
    if (username.trim().length < 3) {
      throw ArgumentError('Username must be at least 3 characters.');
    }
    if (password.length < 8) {
      throw ArgumentError('Password must be at least 8 characters.');
    }
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      throw ArgumentError('Invalid email.');
    }
    final now = DateTime.now();
    final user = UserModel(
      id: 'user-${_uuid.v4()}',
      username: username.trim(),
      email: email.trim().toLowerCase(),
      role: role,
      fullName: fullName.trim(),
      phone: phone,
      city: city,
      createdAt: now,
      updatedAt: now,
    );
    final map = user.toMap();
    map['password_hash'] = _hash(password);
    final db = await DatabaseService.instance.database;
    await db.insert('users', map);
    return user;
  }

  Future<void> update(UserModel user) async {
    final db = await DatabaseService.instance.database;
    final m = user.copyWith(updatedAt: DateTime.now()).toMap();
    m.remove('password_hash');
    await db.update(
      'users',
      m,
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  Future<void> resetPassword(String id, String newPassword) async {
    if (newPassword.length < 8) {
      throw ArgumentError('Password must be at least 8 characters.');
    }
    final db = await DatabaseService.instance.database;
    await db.update(
      'users',
      {
        'password_hash': _hash(newPassword),
        'failed_login_attempts': 0,
        'locked_until': null,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> setActive(String id, bool active) async {
    final db = await DatabaseService.instance.database;
    await db.update(
      'users',
      {
        'is_active': active ? 1 : 0,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<UserModel?> getById(String id) async {
    final db = await DatabaseService.instance.database;
    final rows = await db.query('users', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return UserModel.fromMap(rows.first);
  }

  Future<List<UserModel>> getAll({UserRole? role}) async {
    final db = await DatabaseService.instance.database;
    final rows = role == null
        ? await db.query('users', orderBy: 'created_at DESC')
        : await db.query(
            'users',
            where: 'role = ?',
            whereArgs: [role.name],
            orderBy: 'created_at DESC',
          );
    return rows.map(UserModel.fromMap).toList();
  }
}
