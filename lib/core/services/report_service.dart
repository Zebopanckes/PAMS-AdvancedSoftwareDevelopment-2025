// Author: Alec Brothwood (23076824) - Project Manager
// Author: Douaa Tadli (23012698) - Backend Developer
// File: report_service.dart
// Purpose: Aggregate queries powering the reporting dashboards.

import 'database_service.dart';

class OccupancyRow {
  final String city;
  final int total;
  final int occupied;
  final int vacant;
  final int maintenance;
  OccupancyRow({
    required this.city,
    required this.total,
    required this.occupied,
    required this.vacant,
    required this.maintenance,
  });
  double get occupancyRate => total == 0 ? 0 : occupied / total;
}

class FinancialRow {
  final String city;
  final double collected;
  final double outstanding;
  FinancialRow({
    required this.city,
    required this.collected,
    required this.outstanding,
  });
}

class MaintenanceCostRow {
  final String city;
  final int requests;
  final double totalCost;
  final double totalHours;
  MaintenanceCostRow({
    required this.city,
    required this.requests,
    required this.totalCost,
    required this.totalHours,
  });
}

class ReportService {
  Future<List<OccupancyRow>> occupancyByCity() async {
    final db = await DatabaseService.instance.database;
    final rows = await db.rawQuery('''
      SELECT city,
        COUNT(*) AS total,
        SUM(CASE WHEN status = 'occupied' THEN 1 ELSE 0 END) AS occupied,
        SUM(CASE WHEN status = 'vacant' THEN 1 ELSE 0 END) AS vacant,
        SUM(CASE WHEN status = 'maintenance' THEN 1 ELSE 0 END) AS maint
      FROM apartments
      GROUP BY city
      ORDER BY city
    ''');
    return rows
        .map((r) => OccupancyRow(
              city: r['city'] as String,
              total: (r['total'] as int?) ?? 0,
              occupied: (r['occupied'] as int?) ?? 0,
              vacant: (r['vacant'] as int?) ?? 0,
              maintenance: (r['maint'] as int?) ?? 0,
            ))
        .toList();
  }

  Future<List<FinancialRow>> financialByCity() async {
    final db = await DatabaseService.instance.database;
    // Collected: sum of paid payments grouped by apartment.city
    final collected = await db.rawQuery('''
      SELECT a.city AS city, COALESCE(SUM(p.amount), 0) AS collected
      FROM payments p
      JOIN lease_agreements l ON l.id = p.lease_id
      JOIN apartments a ON a.id = l.apartment_id
      WHERE p.status = 'paid'
      GROUP BY a.city
    ''');
    // Outstanding: invoices - payments grouped by apartment city
    final outstanding = await db.rawQuery('''
      SELECT a.city AS city,
        COALESCE(SUM(i.amount - IFNULL(p.paid, 0)), 0) AS outstanding
      FROM invoices i
      JOIN lease_agreements l ON l.id = i.lease_id
      JOIN apartments a ON a.id = l.apartment_id
      LEFT JOIN (
        SELECT invoice_id, SUM(amount) AS paid FROM payments GROUP BY invoice_id
      ) p ON p.invoice_id = i.id
      WHERE i.status IN ('issued', 'overdue', 'partial')
      GROUP BY a.city
    ''');
    final byCity = <String, FinancialRow>{};
    for (final r in collected) {
      final c = r['city'] as String;
      byCity[c] = FinancialRow(
        city: c,
        collected: (r['collected'] as num).toDouble(),
        outstanding: 0,
      );
    }
    for (final r in outstanding) {
      final c = r['city'] as String;
      final existing = byCity[c];
      final out = (r['outstanding'] as num).toDouble();
      if (existing == null) {
        byCity[c] = FinancialRow(city: c, collected: 0, outstanding: out);
      } else {
        byCity[c] = FinancialRow(
          city: c,
          collected: existing.collected,
          outstanding: out,
        );
      }
    }
    final list = byCity.values.toList()..sort((a, b) => a.city.compareTo(b.city));
    return list;
  }

  Future<List<MaintenanceCostRow>> maintenanceCostByCity() async {
    final db = await DatabaseService.instance.database;
    final rows = await db.rawQuery('''
      SELECT a.city AS city,
        COUNT(*) AS requests,
        COALESCE(SUM(m.cost), 0) AS cost,
        COALESCE(SUM(m.hours_spent), 0) AS hours
      FROM maintenance_requests m
      JOIN apartments a ON a.id = m.apartment_id
      GROUP BY a.city
      ORDER BY a.city
    ''');
    return rows
        .map((r) => MaintenanceCostRow(
              city: r['city'] as String,
              requests: (r['requests'] as int?) ?? 0,
              totalCost: (r['cost'] as num).toDouble(),
              totalHours: (r['hours'] as num).toDouble(),
            ))
        .toList();
  }

  /// Top-level KPIs used by the dashboard.
  Future<Map<String, num>> dashboardStats() async {
    final db = await DatabaseService.instance.database;
    final totalApts = (await db
                .rawQuery('SELECT COUNT(*) AS c FROM apartments'))
            .first['c'] as int? ??
        0;
    final occupied = (await db.rawQuery(
                "SELECT COUNT(*) AS c FROM apartments WHERE status = 'occupied'"))
            .first['c'] as int? ??
        0;
    final pendingPayments = (await db.rawQuery(
                "SELECT COUNT(*) AS c FROM invoices WHERE status IN ('issued', 'overdue', 'partial')"))
            .first['c'] as int? ??
        0;
    final maintOpen = (await db.rawQuery(
                "SELECT COUNT(*) AS c FROM maintenance_requests WHERE status NOT IN ('resolved', 'cancelled')"))
            .first['c'] as int? ??
        0;
    final tenants = (await db.rawQuery(
                "SELECT COUNT(*) AS c FROM tenants WHERE status = 'active'"))
            .first['c'] as int? ??
        0;
    return {
      'totalApartments': totalApts,
      'occupied': occupied,
      'vacant': totalApts - occupied,
      'pendingPayments': pendingPayments,
      'maintenanceOpen': maintOpen,
      'activeTenants': tenants,
    };
  }
}
