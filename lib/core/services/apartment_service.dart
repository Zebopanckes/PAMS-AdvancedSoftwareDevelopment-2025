// Author: PAMS Development Team
// File: apartment_service.dart
// Purpose: CRUD + query operations for apartments.

import 'package:uuid/uuid.dart';
import '../models/apartment_model.dart';
import 'database_service.dart';

class ApartmentService {
  final _uuid = const Uuid();

  Future<ApartmentModel> create({
    required String apartmentNumber,
    required String city,
    required String location,
    required String type,
    required int floor,
    required int bedrooms,
    required int bathrooms,
    required double areaSqft,
    required double rentAmount,
    ApartmentStatus status = ApartmentStatus.vacant,
    String? description,
  }) async {
    if (apartmentNumber.trim().isEmpty) {
      throw ArgumentError('Apartment number is required.');
    }
    if (rentAmount <= 0) {
      throw ArgumentError('Rent amount must be > 0.');
    }
    if (bedrooms < 0 || bathrooms < 0 || areaSqft <= 0) {
      throw ArgumentError('Bedrooms/bathrooms/area must be non-negative.');
    }

    final now = DateTime.now();
    final apt = ApartmentModel(
      id: 'apt-${_uuid.v4()}',
      apartmentNumber: apartmentNumber.trim(),
      city: city,
      location: location,
      type: type,
      floor: floor,
      bedrooms: bedrooms,
      bathrooms: bathrooms,
      areaSqft: areaSqft,
      rentAmount: rentAmount,
      status: status,
      description: description,
      createdAt: now,
      updatedAt: now,
    );
    final db = await DatabaseService.instance.database;
    await db.insert('apartments', apt.toMap());
    return apt;
  }

  Future<void> update(ApartmentModel apt) async {
    final db = await DatabaseService.instance.database;
    await db.update(
      'apartments',
      apt.copyWith(updatedAt: DateTime.now()).toMap(),
      where: 'id = ?',
      whereArgs: [apt.id],
    );
  }

  Future<void> setStatus(String id, ApartmentStatus status) async {
    final db = await DatabaseService.instance.database;
    await db.update(
      'apartments',
      {
        'status': status.name,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> delete(String id) async {
    final db = await DatabaseService.instance.database;
    await db.delete('apartments', where: 'id = ?', whereArgs: [id]);
  }

  Future<ApartmentModel?> getById(String id) async {
    final db = await DatabaseService.instance.database;
    final rows = await db.query('apartments', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return ApartmentModel.fromMap(rows.first);
  }

  Future<List<ApartmentModel>> getAll({
    String? city,
    ApartmentStatus? status,
    int? minBedrooms,
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
    if (minBedrooms != null) {
      where.add('bedrooms >= ?');
      args.add(minBedrooms);
    }
    if (search != null && search.trim().isNotEmpty) {
      final q = '%${search.trim()}%';
      where.add('(apartment_number LIKE ? OR location LIKE ? OR type LIKE ?)');
      args.addAll([q, q, q]);
    }
    final rows = await db.query(
      'apartments',
      where: where.isEmpty ? null : where.join(' AND '),
      whereArgs: args.isEmpty ? null : args,
      orderBy: 'city ASC, apartment_number ASC',
    );
    return rows.map(ApartmentModel.fromMap).toList();
  }

  Future<Map<String, int>> statusCounts({String? city}) async {
    final db = await DatabaseService.instance.database;
    final rows = city == null
        ? await db.rawQuery(
            'SELECT status, COUNT(*) AS c FROM apartments GROUP BY status')
        : await db.rawQuery(
            'SELECT status, COUNT(*) AS c FROM apartments WHERE city = ? GROUP BY status',
            [city],
          );
    final map = <String, int>{};
    for (final r in rows) {
      map[r['status'] as String] = (r['c'] as int?) ?? 0;
    }
    return map;
  }

  Future<int> count({String? city}) async {
    final db = await DatabaseService.instance.database;
    final r = city == null
        ? await db.rawQuery('SELECT COUNT(*) AS c FROM apartments')
        : await db.rawQuery(
            'SELECT COUNT(*) AS c FROM apartments WHERE city = ?', [city]);
    return (r.first['c'] as int?) ?? 0;
  }
}
