// Author: PAMS Development Team
// File: maintenance_model.dart
// Purpose: A maintenance request logged by the front-desk/tenant and actioned
// by maintenance staff.

import 'dart:convert';

enum MaintenancePriority { low, medium, high, urgent }

enum MaintenanceStatus {
  reported,
  investigating,
  scheduled,
  inProgress,
  onHold,
  resolved,
  cancelled,
}

class MaintenanceRequestModel {
  final String id;
  final String apartmentId;
  final String? tenantId;
  final String title;
  final String description;
  final MaintenancePriority priority;
  final MaintenanceStatus status;
  final String? assignedTo; // user id of maintenance staff
  final DateTime reportedDate;
  final DateTime? scheduledDate;
  final DateTime? completedDate;
  final String? resolutionNotes;
  final double? hoursSpent;
  final double? cost;
  final DateTime createdAt;
  final DateTime updatedAt;

  MaintenanceRequestModel({
    required this.id,
    required this.apartmentId,
    this.tenantId,
    required this.title,
    required this.description,
    this.priority = MaintenancePriority.medium,
    this.status = MaintenanceStatus.reported,
    this.assignedTo,
    required this.reportedDate,
    this.scheduledDate,
    this.completedDate,
    this.resolutionNotes,
    this.hoursSpent,
    this.cost,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'apartment_id': apartmentId,
        'tenant_id': tenantId,
        'title': title,
        'description': description,
        'priority': priority.name,
        'status': status.name,
        'assigned_to': assignedTo,
        'reported_date': reportedDate.toIso8601String(),
        'scheduled_date': scheduledDate?.toIso8601String(),
        'completed_date': completedDate?.toIso8601String(),
        'resolution_notes': resolutionNotes,
        'hours_spent': hoursSpent,
        'cost': cost,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  factory MaintenanceRequestModel.fromMap(Map<String, dynamic> m) =>
      MaintenanceRequestModel(
        id: m['id'] as String,
        apartmentId: m['apartment_id'] as String,
        tenantId: m['tenant_id'] as String?,
        title: m['title'] as String,
        description: m['description'] as String,
        priority: MaintenancePriority.values.firstWhere(
          (e) => e.name == m['priority'],
          orElse: () => MaintenancePriority.medium,
        ),
        status: MaintenanceStatus.values.firstWhere(
          (e) => e.name == m['status'],
          orElse: () => MaintenanceStatus.reported,
        ),
        assignedTo: m['assigned_to'] as String?,
        reportedDate: DateTime.parse(m['reported_date'] as String),
        scheduledDate: m['scheduled_date'] == null
            ? null
            : DateTime.parse(m['scheduled_date'] as String),
        completedDate: m['completed_date'] == null
            ? null
            : DateTime.parse(m['completed_date'] as String),
        resolutionNotes: m['resolution_notes'] as String?,
        hoursSpent: (m['hours_spent'] as num?)?.toDouble(),
        cost: (m['cost'] as num?)?.toDouble(),
        createdAt: DateTime.parse(m['created_at'] as String),
        updatedAt: DateTime.parse(m['updated_at'] as String),
      );

  String toJson() => json.encode(toMap());
  factory MaintenanceRequestModel.fromJson(String s) =>
      MaintenanceRequestModel.fromMap(json.decode(s));

  MaintenanceRequestModel copyWith({
    MaintenancePriority? priority,
    MaintenanceStatus? status,
    String? assignedTo,
    DateTime? scheduledDate,
    DateTime? completedDate,
    String? resolutionNotes,
    double? hoursSpent,
    double? cost,
    DateTime? updatedAt,
  }) =>
      MaintenanceRequestModel(
        id: id,
        apartmentId: apartmentId,
        tenantId: tenantId,
        title: title,
        description: description,
        priority: priority ?? this.priority,
        status: status ?? this.status,
        assignedTo: assignedTo ?? this.assignedTo,
        reportedDate: reportedDate,
        scheduledDate: scheduledDate ?? this.scheduledDate,
        completedDate: completedDate ?? this.completedDate,
        resolutionNotes: resolutionNotes ?? this.resolutionNotes,
        hoursSpent: hoursSpent ?? this.hoursSpent,
        cost: cost ?? this.cost,
        createdAt: createdAt,
        updatedAt: updatedAt ?? DateTime.now(),
      );
}
