// Author: PAMS Development Team
// File: auth_service.dart
// Purpose: Authentication, session management and audit logging.

import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/user_model.dart';
import 'database_service.dart';

/// Outcome of a login attempt.
enum LoginResult { success, invalidCredentials, accountLocked, accountDisabled }

class LoginOutcome {
  final LoginResult result;
  final UserModel? user;
  final String? message;
  LoginOutcome(this.result, {this.user, this.message});
}

class AuthService {
  static const String _currentUserKey = 'current_user';
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _loginTimeKey = 'login_time';

  /// Session timeout (security requirement). Defaults to 2 hours.
  static const Duration sessionTimeout = Duration(hours: 2);

  /// Account lockout threshold.
  static const int _maxFailedAttempts = 5;
  static const Duration _lockDuration = Duration(minutes: 15);

  final _uuid = const Uuid();

  String hashPassword(String password) =>
      sha256.convert(utf8.encode(password)).toString();

  Future<LoginOutcome> login(String username, String password) async {
    try {
      final db = await DatabaseService.instance.database;
      final rows = await db.query(
        'users',
        where: 'username = ?',
        whereArgs: [username.trim()],
        limit: 1,
      );
      if (rows.isEmpty) {
        return LoginOutcome(LoginResult.invalidCredentials,
            message: 'Invalid username or password.');
      }

      final user = UserModel.fromMap(rows.first);

      if (!user.isActive) {
        return LoginOutcome(LoginResult.accountDisabled,
            message: 'Account disabled. Contact your administrator.');
      }
      if (user.isLocked) {
        return LoginOutcome(LoginResult.accountLocked,
            message:
                'Account locked until ${user.lockedUntil!.toLocal()}. Try again later.');
      }

      final providedHash = hashPassword(password);
      final storedHash = rows.first['password_hash'] as String;

      if (providedHash != storedHash) {
        // Increment failed attempts and potentially lock.
        final attempts = user.failedLoginAttempts + 1;
        final update = <String, Object?>{
          'failed_login_attempts': attempts,
          'updated_at': DateTime.now().toIso8601String(),
        };
        if (attempts >= _maxFailedAttempts) {
          update['locked_until'] =
              DateTime.now().add(_lockDuration).toIso8601String();
        }
        await db.update('users', update,
            where: 'id = ?', whereArgs: [user.id]);
        await logAuditAction(user.id, 'LOGIN_FAIL', 'user', user.id,
            'Failed login (attempt $attempts)');
        return LoginOutcome(LoginResult.invalidCredentials,
            message: attempts >= _maxFailedAttempts
                ? 'Too many failed attempts; account locked for 15 minutes.'
                : 'Invalid username or password.');
      }

      // Successful login – reset counters, stamp last_login.
      final refreshed = user.copyWith(
        failedLoginAttempts: 0,
        lockedUntil: null,
        lastLogin: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await db.update(
        'users',
        {
          'failed_login_attempts': 0,
          'locked_until': null,
          'last_login': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [user.id],
      );
      await _saveUserSession(refreshed);
      await logAuditAction(user.id, 'LOGIN', 'user', user.id, 'User logged in');
      return LoginOutcome(LoginResult.success, user: refreshed);
    } catch (e) {
      return LoginOutcome(LoginResult.invalidCredentials,
          message: 'Login error: $e');
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_currentUserKey);
    if (userJson != null) {
      final user = UserModel.fromJson(userJson);
      await logAuditAction(user.id, 'LOGOUT', 'user', user.id, 'User logged out');
    }
    await prefs.remove(_currentUserKey);
    await prefs.remove(_loginTimeKey);
    await prefs.setBool(_isLoggedInKey, false);
  }

  /// Returns the current user only if a valid session exists.
  Future<UserModel?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_currentUserKey);
    final loginTimeStr = prefs.getString(_loginTimeKey);
    if (userJson == null || loginTimeStr == null) return null;

    final loginTime = DateTime.tryParse(loginTimeStr);
    if (loginTime == null ||
        DateTime.now().difference(loginTime) > sessionTimeout) {
      await logout();
      return null;
    }
    return UserModel.fromJson(userJson);
  }

  Future<bool> isLoggedIn() async =>
      (await getCurrentUser()) != null;

  Future<void> _saveUserSession(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currentUserKey, user.toJson());
    await prefs.setString(_loginTimeKey, DateTime.now().toIso8601String());
    await prefs.setBool(_isLoggedInKey, true);
  }

  Future<void> logAuditAction(
    String userId,
    String action,
    String entityType,
    String? entityId,
    String details,
  ) async {
    try {
      final db = await DatabaseService.instance.database;
      await db.insert('audit_logs', {
        'id': 'audit-${_uuid.v4()}',
        'user_id': userId,
        'action': action,
        'entity_type': entityType,
        'entity_id': entityId,
        'details': details,
        'ip_address': 'localhost',
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (_) {
      // Silently swallow audit log failures – they should not break the app.
    }
  }
}
