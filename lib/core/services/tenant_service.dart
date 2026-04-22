// Author: PAMS Development Team
// File: tenant_service.dart
// Purpose: CRUD + query operations for tenants.

import 'package:uuid/uuid.dart';
import '../models/tenant_model.dart';
import 'database_service.dart';

class TenantService {
  final _uuid = const Uuid();

  Future<TenantModel> create({
    required String niNumber,
    required String fullName,
    required String email,
    required String phone,
    required String city,
    String? occupation,
    String? references,
    String? apartmentRequirements,
    int? leasePeriodMonths,
    String? emergencyContact,
    TenantStatus status = TenantStatus.prospective,
  }) async {
    if (!TenantModel.isValidNiNumber(niNumber)) {
      throw ArgumentError('Invalid UK National Insurance number format.');
    }
    if (!TenantModel.isValidEmail(email)) {
      throw ArgumentError('Invalid email address.');
    }
    if (!TenantModel.isValidUkPhone(phone)) {
      throw ArgumentError('Invalid UK phone number.');
    }
    if (fullName.trim().length < 2) {
      throw ArgumentError('Full name is required.');
    }

    final now = DateTime.now();
    final normalisedNi = niNumber.toUpperCase().replaceAll(' ', '');

    final db = await DatabaseService.instance.database;
    final existing = await db.query(
      'tenants',
      where: 'ni_number = ?',
      whereArgs: [normalisedNi],
      limit: 1,
    );
    if (existing.isNotEmpty) {
      throw StateError(
          'A tenant with NI number $normalisedNi already exists.');
    }

    final tenant = TenantModel(
      id: 'tenant-${_uuid.v4()}',
      niNumber: normalisedNi,
      fullName: fullName.trim(),
      email: email.trim().toLowerCase(),
      phone: phone.trim(),
      occupation: occupation,
      references: references,
      apartmentRequirements: apartmentRequirements,
      leasePeriodMonths: leasePeriodMonths,
      city: city,
      emergencyContact: emergencyContact,
      status: status,
      createdAt: now,
      updatedAt: now,
    );

    await db.insert('tenants', tenant.toMap());
    return tenant;
  }

  Future<void> update(TenantModel tenant) async {
    final db = await DatabaseService.instance.database;
    await db.update(
      'tenants',
      tenant.copyWith(updatedAt: DateTime.now()).toMap(),
      where: 'id = ?',
      whereArgs: [tenant.id],
    );
  }

  Future<void> delete(String id) async {
    final db = await DatabaseService.instance.database;
    await db.delete('tenants', where: 'id = ?', whereArgs: [id]);
  }

  Future<TenantModel?> getById(String id) async {
    final db = await DatabaseService.instance.database;
    final rows = await db.query('tenants', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return TenantModel.fromMap(rows.first);
  }

  Future<List<TenantModel>> getAll({
    String? city,
    TenantStatus? status,
    String? search,
  }) async {
    final db = await DatabaseService.instance.database;
    final where = <String>[];
    final args = <Object?>[];
    if (city != null && city.isNotEmpty) {
      where.add('city = ?');
      args.add(city);
    }
    if (status != null) {
      where.add('status = ?');
      args.add(status.name);
    }
    if (search != null && search.trim().isNotEmpty) {
      final q = '%${search.trim()}%';
      where.add(
          '(full_name LIKE ? OR email LIKE ? OR ni_number LIKE ? OR phone LIKE ?)');
      args.addAll([q, q, q, q]);
    }
    final rows = await db.query(
      'tenants',
      where: where.isEmpty ? null : where.join(' AND '),
      whereArgs: args.isEmpty ? null : args,
      orderBy: 'created_at DESC',
    );
    return rows.map(TenantModel.fromMap).toList();
  }

  Future<int> count({String? city}) async {
    final db = await DatabaseService.instance.database;
    final res = city == null
        ? await db.rawQuery('SELECT COUNT(*) AS c FROM tenants')
        : await db.rawQuery(
            'SELECT COUNT(*) AS c FROM tenants WHERE city = ?', [city]);
    return (res.first['c'] as int?) ?? 0;
  }
}
