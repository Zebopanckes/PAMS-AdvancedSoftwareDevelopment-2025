import 'dart:convert';

enum UserRole {
  admin,
  manager,
  finance,
  maintenance,
  frontDesk,
}

class UserModel {
  final String id;
  final String username;
  final String email;
  final UserRole role;
  final String fullName;
  final String? phone;
  final bool isActive;
  final bool mfaEnabled;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
    required this.fullName,
    this.phone,
    this.isActive = true,
    this.mfaEnabled = false,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'role': role.name,
      'full_name': fullName,
      'phone': phone,
      'is_active': isActive ? 1 : 0,
      'mfa_enabled': mfaEnabled ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      username: map['username'],
      email: map['email'],
      role: UserRole.values.firstWhere((e) => e.name == map['role']),
      fullName: map['full_name'],
      phone: map['phone'],
      isActive: map['is_active'] == 1,
      mfaEnabled: map['mfa_enabled'] == 1,
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source));

  UserModel copyWith({
    String? id,
    String? username,
    String? email,
    UserRole? role,
    String? fullName,
    String? phone,
    bool? isActive,
    bool? mfaEnabled,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      role: role ?? this.role,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      isActive: isActive ?? this.isActive,
      mfaEnabled: mfaEnabled ?? this.mfaEnabled,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
