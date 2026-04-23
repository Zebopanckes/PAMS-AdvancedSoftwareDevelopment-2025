// Author: Alec Brothwood (23076824) - Project Manager
// Author: Okan Kaynak (23035729) - Quality & Documentation Specialist
// File: tool/dump_db.dart
// Purpose: Produce a SQL dump (schema + INSERT statements) of the runtime
// SQLite database used by PAMS, for submission as a database dump file.
//
// Run from the project root:
//   dart run tool/dump_db.dart > pams_dump.sql

import 'dart:io';

import 'package:sqflite_common_ffi/sqflite_ffi.dart';

Future<void> main() async {
  sqfliteFfiInit();
  final factory = databaseFactoryFfi;

  final dbPath = File(p0('.dart_tool/sqflite_common_ffi/databases/pams.db'))
      .absolute
      .path;
  if (!File(dbPath).existsSync()) {
    stderr.writeln('Database not found at: $dbPath');
    stderr.writeln('Run the app once (flutter run -d windows) to create it.');
    exit(1);
  }

  final db = await factory.openDatabase(dbPath,
      options: OpenDatabaseOptions(readOnly: true));

  final buffer = StringBuffer();
  buffer.writeln('-- PAMS SQLite database dump');
  buffer.writeln('-- Generated: ${DateTime.now().toIso8601String()}');
  buffer.writeln('-- Source: $dbPath');
  buffer.writeln('PRAGMA foreign_keys=OFF;');
  buffer.writeln('BEGIN TRANSACTION;');

  // Schema (tables + indexes), skipping SQLite internals.
  final schemaRows = await db.rawQuery(
      "SELECT type, name, sql FROM sqlite_master "
      "WHERE sql IS NOT NULL AND name NOT LIKE 'sqlite_%' "
      "ORDER BY CASE type WHEN 'table' THEN 0 WHEN 'index' THEN 1 ELSE 2 END, name");

  for (final row in schemaRows) {
    buffer.writeln('${row['sql']};');
  }
  buffer.writeln();

  // Data: one INSERT per row per table.
  final tables = schemaRows
      .where((r) => r['type'] == 'table')
      .map((r) => r['name'] as String)
      .toList();

  for (final table in tables) {
    final rows = await db.rawQuery('SELECT * FROM "$table"');
    if (rows.isEmpty) continue;
    buffer.writeln('-- Data for table $table (${rows.length} rows)');
    for (final row in rows) {
      final cols = row.keys.map((k) => '"$k"').join(', ');
      final vals = row.values.map(_sqlLiteral).join(', ');
      buffer.writeln('INSERT INTO "$table" ($cols) VALUES ($vals);');
    }
    buffer.writeln();
  }

  buffer.writeln('COMMIT;');
  stdout.write(buffer.toString());

  await db.close();
}

/// Convenience: prefix path with current directory.
String p0(String rel) => rel.replaceAll('/', Platform.pathSeparator);

String _sqlLiteral(Object? value) {
  if (value == null) return 'NULL';
  if (value is num) return value.toString();
  if (value is List<int>) {
    final hex = value
        .map((b) => b.toRadixString(16).padLeft(2, '0'))
        .join();
    return "X'$hex'";
  }
  final s = value.toString().replaceAll("'", "''");
  return "'$s'";
}
