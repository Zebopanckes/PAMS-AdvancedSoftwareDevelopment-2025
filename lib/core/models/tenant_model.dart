// Author: Alec Brothwood (23076824) - Project Manager
// Author: Saynab Saleh (23000156) - System Analyst
// File: tenant_model.dart
// Purpose: Domain model for a PAMS tenant.

import 'dart:convert';

enum TenantStatus { active, inactive, movedOut, prospective }

class TenantModel {
  final String id;
  final String niNumber;
  final String fullName;
  final String email;
  final String phone;
  final String? occupation;
  final String? references;
  final String? apartmentRequirements;
  final int? leasePeriodMonths;
  final String city;
  final String? emergencyContact;
  final TenantStatus status;
  final DateTime? moveInDate;
  final DateTime? moveOutDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  TenantModel({
    required this.id,
    required this.niNumber,
    required this.fullName,
    required this.email,
    required this.phone,
    this.occupation,
    this.references,
    this.apartmentRequirements,
    this.leasePeriodMonths,
    required this.city,
    this.emergencyContact,
    this.status = TenantStatus.active,
    this.moveInDate,
    this.moveOutDate,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Validates a UK National Insurance number (lightweight format check).
  static bool isValidNiNumber(String value) {
    final normalized = value.replaceAll(' ', '').toUpperCase();
    final re = RegExp(r'^[A-CEGHJ-PR-TW-Z]{2}\d{6}[A-D]$');
    return re.hasMatch(normalized);
  }

  static bool isValidEmail(String value) {
    final re = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    return re.hasMatch(value);
  }

  static bool isValidUkPhone(String value) {
    final v = value.replaceAll(RegExp(r'\s|-'), '');
    return RegExp(r'^(\+44|0)\d{9,10}$').hasMatch(v);
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'ni_number': niNumber,
        'full_name': fullName,
        'email': email,
        'phone': phone,
        'occupation': occupation,
        'references_info': references,
        'apartment_requirements': apartmentRequirements,
        'lease_period_months': leasePeriodMonths,
        'city': city,
        'emergency_contact': emergencyContact,
        'status': status.name,
        'move_in_date': moveInDate?.toIso8601String(),
        'move_out_date': moveOutDate?.toIso8601String(),
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  factory TenantModel.fromMap(Map<String, dynamic> m) => TenantModel(
        id: m['id'] as String,
        niNumber: m['ni_number'] as String,
        fullName: m['full_name'] as String,
        email: m['email'] as String,
        phone: m['phone'] as String,
        occupation: m['occupation'] as String?,
        references: m['references_info'] as String?,
        apartmentRequirements: m['apartment_requirements'] as String?,
        leasePeriodMonths: m['lease_period_months'] as int?,
        city: m['city'] as String,
        emergencyContact: m['emergency_contact'] as String?,
        status: TenantStatus.values.firstWhere(
          (e) => e.name == m['status'],
          orElse: () => TenantStatus.active,
        ),
        moveInDate: m['move_in_date'] == null
            ? null
            : DateTime.parse(m['move_in_date'] as String),
        moveOutDate: m['move_out_date'] == null
            ? null
            : DateTime.parse(m['move_out_date'] as String),
        createdAt: DateTime.parse(m['created_at'] as String),
        updatedAt: DateTime.parse(m['updated_at'] as String),
      );

  String toJson() => json.encode(toMap());
  factory TenantModel.fromJson(String s) => TenantModel.fromMap(json.decode(s));

  TenantModel copyWith({
    String? fullName,
    String? email,
    String? phone,
    String? occupation,
    String? references,
    String? apartmentRequirements,
    int? leasePeriodMonths,
    String? city,
    String? emergencyContact,
    TenantStatus? status,
    DateTime? moveInDate,
    DateTime? moveOutDate,
    DateTime? updatedAt,
  }) =>
      TenantModel(
        id: id,
        niNumber: niNumber,
        fullName: fullName ?? this.fullName,
        email: email ?? this.email,
        phone: phone ?? this.phone,
        occupation: occupation ?? this.occupation,
        references: references ?? this.references,
        apartmentRequirements:
            apartmentRequirements ?? this.apartmentRequirements,
        leasePeriodMonths: leasePeriodMonths ?? this.leasePeriodMonths,
        city: city ?? this.city,
        emergencyContact: emergencyContact ?? this.emergencyContact,
        status: status ?? this.status,
        moveInDate: moveInDate ?? this.moveInDate,
        moveOutDate: moveOutDate ?? this.moveOutDate,
        createdAt: createdAt,
        updatedAt: updatedAt ?? DateTime.now(),
      );
}
