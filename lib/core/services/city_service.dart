// Author: PAMS Development Team
// File: city_service.dart
// Purpose: Managed list of cities in which PAMS operates. Enables the manager
// role to expand the business into new cities (per PAMS spec).

import 'database_service.dart';

class CityService {
  static const List<String> _defaults = [
    'Bristol',
    'Cardiff',
    'London',
    'Manchester',
  ];

  /// Ensures the `cities` table exists. Older database files created before
  /// the cities feature was introduced may be missing it if the schema
  /// migration was skipped (e.g. hot reload without full restart).
  Future<void> _ensureTable() async {
    final db = await DatabaseService.instance.database;
    await db.execute('''
      CREATE TABLE IF NOT EXISTS cities (
        name TEXT PRIMARY KEY,
        created_at TEXT NOT NULL
      )
    ''');
    final count = (await db.rawQuery('SELECT COUNT(*) AS c FROM cities'))
            .first['c'] as int? ??
        0;
    if (count == 0) {
      final now = DateTime.now().toIso8601String();
      for (final c in _defaults) {
        await db.insert('cities', {'name': c, 'created_at': now});
      }
    }
  }

  /// Returns all registered city names, alphabetically sorted.
  Future<List<String>> list() async {
    await _ensureTable();
    final db = await DatabaseService.instance.database;
    final rows = await db.query('cities', orderBy: 'name ASC');
    return rows.map((r) => r['name'] as String).toList();
  }

  /// Adds a new city. Trims, title-cases, and rejects blanks/duplicates.
  Future<String> add(String rawName) async {
    final name = _normalise(rawName);
    if (name.isEmpty) {
      throw ArgumentError('City name cannot be empty.');
    }
    if (name.length < 2) {
      throw ArgumentError('City name must be at least 2 characters.');
    }
    await _ensureTable();
    final db = await DatabaseService.instance.database;
    final existing = await db.query(
      'cities',
      where: 'LOWER(name) = ?',
      whereArgs: [name.toLowerCase()],
      limit: 1,
    );
    if (existing.isNotEmpty) {
      throw StateError('City "$name" already exists.');
    }
    await db.insert('cities', {
      'name': name,
      'created_at': DateTime.now().toIso8601String(),
    });
    return name;
  }

  /// Removes a city. Fails if it is in use by apartments, tenants, or users.
  Future<void> remove(String name) async {
    await _ensureTable();
    final db = await DatabaseService.instance.database;
    final refs = <String, int>{};
    for (final table in const ['apartments', 'tenants', 'users']) {
      final r = await db.rawQuery(
          'SELECT COUNT(*) AS c FROM $table WHERE city = ?', [name]);
      refs[table] = (r.first['c'] as int?) ?? 0;
    }
    final total = refs.values.fold<int>(0, (a, b) => a + b);
    if (total > 0) {
      throw StateError(
          'Cannot remove "$name" – still used by '
          '${refs['apartments']} apartment(s), '
          '${refs['tenants']} tenant(s), '
          '${refs['users']} user(s).');
    }
    await db.delete('cities', where: 'name = ?', whereArgs: [name]);
  }

  String _normalise(String value) {
    final trimmed = value.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (trimmed.isEmpty) return '';
    return trimmed
        .split(' ')
        .map((w) => w.isEmpty
            ? w
            : w[0].toUpperCase() + w.substring(1).toLowerCase())
        .join(' ');
  }
}
