// Author: PAMS Development Team
// File: lease_model.dart
// Purpose: Domain model for a lease agreement between tenant and apartment.

import 'dart:convert';

enum LeaseStatus { active, expired, terminatedEarly, pending }

class LeaseModel {
  final String id;
  final String tenantId;
  final String apartmentId;
  final DateTime startDate;
  final DateTime endDate;
  final double rentAmount;
  final double depositAmount;
  final LeaseStatus status;
  final String? terms;
  final DateTime? earlyTerminationNoticeDate;
  final double? earlyTerminationPenalty;
  final DateTime createdAt;
  final DateTime updatedAt;

  LeaseModel({
    required this.id,
    required this.tenantId,
    required this.apartmentId,
    required this.startDate,
    required this.endDate,
    required this.rentAmount,
    required this.depositAmount,
    this.status = LeaseStatus.active,
    this.terms,
    this.earlyTerminationNoticeDate,
    this.earlyTerminationPenalty,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Per spec: 5% of monthly rent if a tenant gives notice to leave early.
  double computeEarlyTerminationPenalty() => rentAmount * 0.05;

  int durationMonths() {
    return (endDate.year - startDate.year) * 12 +
        (endDate.month - startDate.month);
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'tenant_id': tenantId,
        'apartment_id': apartmentId,
        'start_date': startDate.toIso8601String(),
        'end_date': endDate.toIso8601String(),
        'rent_amount': rentAmount,
        'deposit_amount': depositAmount,
        'status': status.name,
        'terms': terms,
        'early_termination_notice_date':
            earlyTerminationNoticeDate?.toIso8601String(),
        'early_termination_penalty': earlyTerminationPenalty,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  factory LeaseModel.fromMap(Map<String, dynamic> m) => LeaseModel(
        id: m['id'] as String,
        tenantId: m['tenant_id'] as String,
        apartmentId: m['apartment_id'] as String,
        startDate: DateTime.parse(m['start_date'] as String),
        endDate: DateTime.parse(m['end_date'] as String),
        rentAmount: (m['rent_amount'] as num).toDouble(),
        depositAmount: (m['deposit_amount'] as num).toDouble(),
        status: LeaseStatus.values.firstWhere(
          (e) => e.name == m['status'],
          orElse: () => LeaseStatus.active,
        ),
        terms: m['terms'] as String?,
        earlyTerminationNoticeDate: m['early_termination_notice_date'] == null
            ? null
            : DateTime.parse(m['early_termination_notice_date'] as String),
        earlyTerminationPenalty:
            (m['early_termination_penalty'] as num?)?.toDouble(),
        createdAt: DateTime.parse(m['created_at'] as String),
        updatedAt: DateTime.parse(m['updated_at'] as String),
      );

  String toJson() => json.encode(toMap());
  factory LeaseModel.fromJson(String s) => LeaseModel.fromMap(json.decode(s));

  LeaseModel copyWith({
    LeaseStatus? status,
    DateTime? earlyTerminationNoticeDate,
    double? earlyTerminationPenalty,
    DateTime? endDate,
    DateTime? updatedAt,
    String? terms,
  }) =>
      LeaseModel(
        id: id,
        tenantId: tenantId,
        apartmentId: apartmentId,
        startDate: startDate,
        endDate: endDate ?? this.endDate,
        rentAmount: rentAmount,
        depositAmount: depositAmount,
        status: status ?? this.status,
        terms: terms ?? this.terms,
        earlyTerminationNoticeDate:
            earlyTerminationNoticeDate ?? this.earlyTerminationNoticeDate,
        earlyTerminationPenalty:
            earlyTerminationPenalty ?? this.earlyTerminationPenalty,
        createdAt: createdAt,
        updatedAt: updatedAt ?? DateTime.now(),
      );
}
