// Author: PAMS Development Team
// File: complaint_model.dart
// Purpose: Tenant complaint logged via front-desk staff.

import 'dart:convert';

enum ComplaintStatus { open, inProgress, resolved, closed }

class ComplaintModel {
  final String id;
  final String tenantId;
  final String subject;
  final String description;
  final ComplaintStatus status;
  final String? loggedBy;
  final DateTime loggedDate;
  final DateTime? resolvedDate;
  final String? resolution;
  final DateTime createdAt;
  final DateTime updatedAt;

  ComplaintModel({
    required this.id,
    required this.tenantId,
    required this.subject,
    required this.description,
    this.status = ComplaintStatus.open,
    this.loggedBy,
    required this.loggedDate,
    this.resolvedDate,
    this.resolution,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'tenant_id': tenantId,
        'subject': subject,
        'description': description,
        'status': status.name,
        'logged_by': loggedBy,
        'logged_date': loggedDate.toIso8601String(),
        'resolved_date': resolvedDate?.toIso8601String(),
        'resolution': resolution,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  factory ComplaintModel.fromMap(Map<String, dynamic> m) => ComplaintModel(
        id: m['id'] as String,
        tenantId: m['tenant_id'] as String,
        subject: m['subject'] as String,
        description: m['description'] as String,
        status: ComplaintStatus.values.firstWhere(
          (e) => e.name == m['status'],
          orElse: () => ComplaintStatus.open,
        ),
        loggedBy: m['logged_by'] as String?,
        loggedDate: DateTime.parse(m['logged_date'] as String),
        resolvedDate: m['resolved_date'] == null
            ? null
            : DateTime.parse(m['resolved_date'] as String),
        resolution: m['resolution'] as String?,
        createdAt: DateTime.parse(m['created_at'] as String),
        updatedAt: DateTime.parse(m['updated_at'] as String),
      );

  String toJson() => json.encode(toMap());
  factory ComplaintModel.fromJson(String s) =>
      ComplaintModel.fromMap(json.decode(s));
}
