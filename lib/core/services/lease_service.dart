// Author: PAMS Development Team
// File: lease_service.dart
// Purpose: Create and manage lease agreements, including early termination.

import 'package:uuid/uuid.dart';
import '../models/apartment_model.dart';
import '../models/lease_model.dart';
import 'apartment_service.dart';
import 'database_service.dart';

class LeaseService {
  final _uuid = const Uuid();
  final ApartmentService _apartmentService = ApartmentService();

  Future<LeaseModel> create({
    required String tenantId,
    required String apartmentId,
    required DateTime startDate,
    required DateTime endDate,
    required double rentAmount,
    required double depositAmount,
    String? terms,
  }) async {
    if (!endDate.isAfter(startDate)) {
      throw ArgumentError('End date must be after start date.');
    }
    if (rentAmount <= 0 || depositAmount < 0) {
      throw ArgumentError('Invalid rent/deposit values.');
    }

    final db = await DatabaseService.instance.database;

    // Guard: apartment must not already have an active lease.
    final active = await db.query(
      'lease_agreements',
      where: 'apartment_id = ? AND status = ?',
      whereArgs: [apartmentId, LeaseStatus.active.name],
    );
    if (active.isNotEmpty) {
      throw StateError('Apartment already has an active lease.');
    }

    final now = DateTime.now();
    final lease = LeaseModel(
      id: 'lease-${_uuid.v4()}',
      tenantId: tenantId,
      apartmentId: apartmentId,
      startDate: startDate,
      endDate: endDate,
      rentAmount: rentAmount,
      depositAmount: depositAmount,
      status: LeaseStatus.active,
      terms: terms,
      createdAt: now,
      updatedAt: now,
    );
    await db.insert('lease_agreements', lease.toMap());
    await _apartmentService.setStatus(apartmentId, ApartmentStatus.occupied);
    await db.update(
      'tenants',
      {'status': 'active', 'move_in_date': startDate.toIso8601String()},
      where: 'id = ?',
      whereArgs: [tenantId],
    );
    return lease;
  }

  Future<void> terminateEarly(String leaseId, DateTime noticeDate) async {
    final db = await DatabaseService.instance.database;
    final rows =
        await db.query('lease_agreements', where: 'id = ?', whereArgs: [leaseId]);
    if (rows.isEmpty) throw StateError('Lease not found.');
    final lease = LeaseModel.fromMap(rows.first);

    // Spec: 1 month notice required, 5% monthly rent penalty.
    final penalty = lease.computeEarlyTerminationPenalty();
    await db.update(
      'lease_agreements',
      {
        'status': LeaseStatus.terminatedEarly.name,
        'early_termination_notice_date': noticeDate.toIso8601String(),
        'early_termination_penalty': penalty,
        'end_date': noticeDate.add(const Duration(days: 30)).toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [leaseId],
    );
    await _apartmentService.setStatus(
        lease.apartmentId, ApartmentStatus.vacant);
    await db.update(
      'tenants',
      {
        'status': 'movedOut',
        'move_out_date':
            noticeDate.add(const Duration(days: 30)).toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [lease.tenantId],
    );
  }

  Future<void> markExpired(String leaseId) async {
    final db = await DatabaseService.instance.database;
    final rows =
        await db.query('lease_agreements', where: 'id = ?', whereArgs: [leaseId]);
    if (rows.isEmpty) return;
    final lease = LeaseModel.fromMap(rows.first);
    await db.update(
      'lease_agreements',
      {
        'status': LeaseStatus.expired.name,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [leaseId],
    );
    await _apartmentService.setStatus(
        lease.apartmentId, ApartmentStatus.vacant);
  }

  Future<LeaseModel?> getById(String id) async {
    final db = await DatabaseService.instance.database;
    final rows = await db
        .query('lease_agreements', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return LeaseModel.fromMap(rows.first);
  }

  Future<LeaseModel?> getActiveForTenant(String tenantId) async {
    final db = await DatabaseService.instance.database;
    final rows = await db.query(
      'lease_agreements',
      where: 'tenant_id = ? AND status = ?',
      whereArgs: [tenantId, LeaseStatus.active.name],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return LeaseModel.fromMap(rows.first);
  }

  Future<LeaseModel?> getActiveForApartment(String apartmentId) async {
    final db = await DatabaseService.instance.database;
    final rows = await db.query(
      'lease_agreements',
      where: 'apartment_id = ? AND status = ?',
      whereArgs: [apartmentId, LeaseStatus.active.name],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return LeaseModel.fromMap(rows.first);
  }

  Future<List<LeaseModel>> getAll({LeaseStatus? status}) async {
    final db = await DatabaseService.instance.database;
    final rows = status == null
        ? await db.query('lease_agreements', orderBy: 'start_date DESC')
        : await db.query(
            'lease_agreements',
            where: 'status = ?',
            whereArgs: [status.name],
            orderBy: 'start_date DESC',
          );
    return rows.map(LeaseModel.fromMap).toList();
  }

  Future<List<LeaseModel>> getExpiringWithin(Duration window) async {
    final db = await DatabaseService.instance.database;
    final now = DateTime.now();
    final end = now.add(window);
    final rows = await db.query(
      'lease_agreements',
      where: 'status = ? AND end_date BETWEEN ? AND ?',
      whereArgs: [
        LeaseStatus.active.name,
        now.toIso8601String(),
        end.toIso8601String(),
      ],
      orderBy: 'end_date ASC',
    );
    return rows.map(LeaseModel.fromMap).toList();
  }
}
