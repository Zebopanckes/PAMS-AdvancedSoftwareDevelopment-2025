// Author: PAMS Development Team
// File: maintenance_service.dart
// Purpose: CRUD + lifecycle operations for maintenance requests.

import 'package:uuid/uuid.dart';
import '../models/maintenance_model.dart';
import 'database_service.dart';

class MaintenanceService {
  final _uuid = const Uuid();

  Future<MaintenanceRequestModel> create({
    required String apartmentId,
    String? tenantId,
    required String title,
    required String description,
    MaintenancePriority priority = MaintenancePriority.medium,
  }) async {
    if (title.trim().isEmpty || description.trim().isEmpty) {
      throw ArgumentError('Title and description are required.');
    }
    final now = DateTime.now();
    final req = MaintenanceRequestModel(
      id: 'mnt-${_uuid.v4()}',
      apartmentId: apartmentId,
      tenantId: tenantId,
      title: title.trim(),
      description: description.trim(),
      priority: priority,
      status: MaintenanceStatus.reported,
      reportedDate: now,
      createdAt: now,
      updatedAt: now,
    );
    final db = await DatabaseService.instance.database;
    await db.insert('maintenance_requests', req.toMap());
    return req;
  }

  Future<void> update(MaintenanceRequestModel req) async {
    final db = await DatabaseService.instance.database;
    await db.update(
      'maintenance_requests',
      req.copyWith(updatedAt: DateTime.now()).toMap(),
      where: 'id = ?',
      whereArgs: [req.id],
    );
  }

  Future<void> assign(String id, String userId, DateTime? scheduledDate) async {
    final db = await DatabaseService.instance.database;
    await db.update(
      'maintenance_requests',
      {
        'assigned_to': userId,
        'status': MaintenanceStatus.scheduled.name,
        'scheduled_date': scheduledDate?.toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> setStatus(String id, MaintenanceStatus status) async {
    final db = await DatabaseService.instance.database;
    await db.update(
      'maintenance_requests',
      {
        'status': status.name,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> resolve({
    required String id,
    required String resolutionNotes,
    required double hoursSpent,
    required double cost,
    DateTime? completedDate,
  }) async {
    if (hoursSpent < 0 || cost < 0) {
      throw ArgumentError('Hours and cost must be non-negative.');
    }
    final db = await DatabaseService.instance.database;
    await db.update(
      'maintenance_requests',
      {
        'status': MaintenanceStatus.resolved.name,
        'resolution_notes': resolutionNotes,
        'hours_spent': hoursSpent,
        'cost': cost,
        'completed_date':
            (completedDate ?? DateTime.now()).toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> delete(String id) async {
    final db = await DatabaseService.instance.database;
    await db.delete('maintenance_requests', where: 'id = ?', whereArgs: [id]);
  }

  Future<MaintenanceRequestModel?> getById(String id) async {
    final db = await DatabaseService.instance.database;
    final rows = await db
        .query('maintenance_requests', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return MaintenanceRequestModel.fromMap(rows.first);
  }

  Future<List<MaintenanceRequestModel>> getAll({
    MaintenanceStatus? status,
    MaintenancePriority? priority,
    String? assignedTo,
    String? apartmentId,
  }) async {
    final db = await DatabaseService.instance.database;
    final where = <String>[];
    final args = <Object?>[];
    if (status != null) {
      where.add('status = ?');
      args.add(status.name);
    }
    if (priority != null) {
      where.add('priority = ?');
      args.add(priority.name);
    }
    if (assignedTo != null) {
      where.add('assigned_to = ?');
      args.add(assignedTo);
    }
    if (apartmentId != null) {
      where.add('apartment_id = ?');
      args.add(apartmentId);
    }
    final rows = await db.query(
      'maintenance_requests',
      where: where.isEmpty ? null : where.join(' AND '),
      whereArgs: args.isEmpty ? null : args,
      orderBy: 'reported_date DESC',
    );
    return rows.map(MaintenanceRequestModel.fromMap).toList();
  }

  /// Total maintenance cost, optionally since a given date, used in reports.
  Future<double> totalCost({DateTime? since}) async {
    final db = await DatabaseService.instance.database;
    final rows = since == null
        ? await db.rawQuery(
            'SELECT COALESCE(SUM(cost), 0) AS t FROM maintenance_requests WHERE cost IS NOT NULL')
        : await db.rawQuery(
            'SELECT COALESCE(SUM(cost), 0) AS t FROM maintenance_requests WHERE cost IS NOT NULL AND reported_date >= ?',
            [since.toIso8601String()],
          );
    return (rows.first['t'] as num).toDouble();
  }
}
