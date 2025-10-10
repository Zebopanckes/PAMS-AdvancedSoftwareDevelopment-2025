import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import 'database_service.dart';

class AuthService {
  static const String _currentUserKey = 'current_user';
  static const String _isLoggedInKey = 'is_logged_in';

  // Hash password using SHA-256
  String hashPassword(String password) {
    final bytes = utf8.encode(password);
    final hash = sha256.convert(bytes);
    return hash.toString();
  }

  // Login user
  Future<UserModel?> login(String username, String password) async {
    try {
      final db = await DatabaseService.instance.database;
      final passwordHash = hashPassword(password);

      final result = await db.query(
        'users',
        where: 'username = ? AND password_hash = ? AND is_active = 1',
        whereArgs: [username, passwordHash],
      );

      if (result.isEmpty) {
        return null;
      }

      final user = UserModel.fromMap(result.first);
      await _saveUserSession(user);
      
      // Log the login action
      await _logAuditAction(user.id, 'LOGIN', 'user', user.id, 'User logged in');

      return user;
    } catch (e) {
      // Login error - in production, use a logging framework
      // For development: Login error: $e
      return null;
    }
  }

  // Logout user
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_currentUserKey);
    
    if (userJson != null) {
      final user = UserModel.fromJson(userJson);
      await _logAuditAction(user.id, 'LOGOUT', 'user', user.id, 'User logged out');
    }

    await prefs.remove(_currentUserKey);
    await prefs.setBool(_isLoggedInKey, false);
  }

  // Get current logged-in user
  Future<UserModel?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_currentUserKey);
    
    if (userJson == null) return null;
    
    return UserModel.fromJson(userJson);
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  // Save user session
  Future<void> _saveUserSession(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currentUserKey, user.toJson());
    await prefs.setBool(_isLoggedInKey, true);
  }

  // Register new user
  Future<bool> registerUser(UserModel user, String password) async {
    try {
      final db = await DatabaseService.instance.database;
      final passwordHash = hashPassword(password);

      final userMap = user.toMap();
      userMap['password_hash'] = passwordHash;

      await db.insert('users', userMap);
      
      // Log the registration
      await _logAuditAction(user.id, 'CREATE', 'user', user.id, 'New user registered');

      return true;
    } catch (e) {
      // Registration error - in production, use a logging framework
      // For development: Registration error: $e
      return false;
    }
  }

  // Log audit action
  Future<void> _logAuditAction(
    String userId,
    String action,
    String entityType,
    String? entityId,
    String details,
  ) async {
    try {
      final db = await DatabaseService.instance.database;
      await db.insert('audit_logs', {
        'id': 'audit-${DateTime.now().millisecondsSinceEpoch}',
        'user_id': userId,
        'action': action,
        'entity_type': entityType,
        'entity_id': entityId,
        'details': details,
        'ip_address': 'localhost',
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      // Audit log error - in production, use a logging framework
      // For development: Audit log error: $e
    }
  }
}
