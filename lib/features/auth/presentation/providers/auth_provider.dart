// Author: PAMS Development Team
// File: auth_provider.dart
// Purpose: Provider glue for authentication state.

import 'package:flutter/foundation.dart';
import '../../../../core/models/user_model.dart';
import '../../../../core/services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  AuthProvider(this._authService);

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _currentUser != null;

  /// Convenient role helpers (used heavily in role-based UI gates).
  bool get isAdmin => _currentUser?.role == UserRole.admin;
  bool get isManager => _currentUser?.role == UserRole.manager;
  bool get isFinance => _currentUser?.role == UserRole.finance;
  bool get isMaintenance => _currentUser?.role == UserRole.maintenance;
  bool get isFrontDesk => _currentUser?.role == UserRole.frontDesk;

  bool hasAnyRole(List<UserRole> roles) =>
      _currentUser != null && roles.contains(_currentUser!.role);

  Future<void> checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();
    _currentUser = await _authService.getCurrentUser();
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final outcome = await _authService.login(username, password);
    _isLoading = false;

    if (outcome.result == LoginResult.success) {
      _currentUser = outcome.user;
      notifyListeners();
      return true;
    }
    _errorMessage = outcome.message ?? 'Login failed.';
    notifyListeners();
    return false;
  }

  Future<void> logout() async {
    await _authService.logout();
    _currentUser = null;
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
