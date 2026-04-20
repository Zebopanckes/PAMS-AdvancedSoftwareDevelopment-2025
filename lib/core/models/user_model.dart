// Author: PAMS Development Team
// File: user_model.dart
// Purpose: Domain model for a system user (staff account).

import 'dart:convert';

/// Roles defined by the PAMS specification:
///   * admin         – full system access to a particular location.
///   * manager       – oversees occupancy and performance across locations;
///                     may expand into new cities.
///   * finance       – handles payments, invoices, late payments, reports.
///   * maintenance   – handles maintenance lifecycle and logs resolutions.
///   * frontDesk     – registers tenants, logs maintenance/complaints.
enum UserRole { admin, manager, finance, maintenance, frontDesk }

extension UserRoleX on UserRole {
  String get display {
    switch (this) {
      case UserRole.admin:
        return 'Administrator';
      case UserRole.manager:
        return 'Manager';
      case UserRole.finance:
        return 'Finance Manager';
      case UserRole.maintenance:
        return 'Maintenance Staff';
      case UserRole.frontDesk:
        return 'Front-desk Staff';
    }
  }
}

class UserModel {
  final String id;
  final String username;
  final String email;
  final UserRole role;
  final String fullName;
  final String? phone;
  final String? city;
  final bool isActive;
  final bool mfaEnabled;
  final int failedLoginAttempts;
  final DateTime? lockedUntil;
  final DateTime? lastLogin;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
    required this.fullName,
    this.phone,
    this.city,
    this.isActive = true,
    this.mfaEnabled = false,
    this.failedLoginAttempts = 0,
    this.lockedUntil,
    this.lastLogin,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isLocked =>
      lockedUntil != null && lockedUntil!.isAfter(DateTime.now());

  Map<String, dynamic> toMap() => {
        'id': id,
        'username': username,
        'email': email,
        'role': role.name,
        'full_name': fullName,
        'phone': phone,
        'city': city,
        'is_active': isActive ? 1 : 0,
        'mfa_enabled': mfaEnabled ? 1 : 0,
        'failed_login_attempts': failedLoginAttempts,
        'locked_until': lockedUntil?.toIso8601String(),
        'last_login': lastLogin?.toIso8601String(),
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  factory UserModel.fromMap(Map<String, dynamic> m) => UserModel(
        id: m['id'] as String,
        username: m['username'] as String,
        email: m['email'] as String,
        role: UserRole.values.firstWhere(
          (e) => e.name == m['role'],
          orElse: () => UserRole.frontDesk,
        ),
        fullName: m['full_name'] as String,
        phone: m['phone'] as String?,
        city: m['city'] as String?,
        isActive: (m['is_active'] as int? ?? 1) == 1,
        mfaEnabled: (m['mfa_enabled'] as int? ?? 0) == 1,
        failedLoginAttempts: (m['failed_login_attempts'] as int?) ?? 0,
        lockedUntil: m['locked_until'] == null
            ? null
            : DateTime.parse(m['locked_until'] as String),
        lastLogin: m['last_login'] == null
            ? null
            : DateTime.parse(m['last_login'] as String),
        createdAt: DateTime.parse(m['created_at'] as String),
        updatedAt: DateTime.parse(m['updated_at'] as String),
      );

  String toJson() => json.encode(toMap());
  factory UserModel.fromJson(String s) => UserModel.fromMap(json.decode(s));

  UserModel copyWith({
    String? username,
    String? email,
    UserRole? role,
    String? fullName,
    String? phone,
    String? city,
    bool? isActive,
    bool? mfaEnabled,
    int? failedLoginAttempts,
    DateTime? lockedUntil,
    DateTime? lastLogin,
    DateTime? updatedAt,
  }) =>
      UserModel(
        id: id,
        username: username ?? this.username,
        email: email ?? this.email,
        role: role ?? this.role,
        fullName: fullName ?? this.fullName,
        phone: phone ?? this.phone,
        city: city ?? this.city,
        isActive: isActive ?? this.isActive,
        mfaEnabled: mfaEnabled ?? this.mfaEnabled,
        failedLoginAttempts: failedLoginAttempts ?? this.failedLoginAttempts,
        lockedUntil: lockedUntil ?? this.lockedUntil,
        lastLogin: lastLogin ?? this.lastLogin,
        createdAt: createdAt,
        updatedAt: updatedAt ?? DateTime.now(),
      );
}
