// Author: Alec Brothwood (23076824) - Project Manager
// Author: Douaa Tadli (23012698) - Backend Developer
// Author: Saynab Saleh (23000156) - System Analyst
// File: billing_service.dart
// Purpose: Invoices + Payments. Handles the billing lifecycle emulation.

import 'package:uuid/uuid.dart';
import '../models/invoice_model.dart';
import '../models/lease_model.dart';
import '../models/payment_model.dart';
import 'database_service.dart';

class BillingService {
  final _uuid = const Uuid();

  // ---------------------------------------------------------------- invoices

  Future<InvoiceModel> issueInvoice({
    required LeaseModel lease,
    required DateTime periodMonth,
    int dueDays = 7,
    String? notes,
  }) async {
    final db = await DatabaseService.instance.database;
    final now = DateTime.now();
    final label =
        '${periodMonth.year}-${periodMonth.month.toString().padLeft(2, '0')}';
    final seq = (await db.rawQuery(
                'SELECT COUNT(*) AS c FROM invoices'))
            .first['c'] as int? ??
        0;
    final invoice = InvoiceModel(
      id: 'inv-${_uuid.v4()}',
      invoiceNumber: 'INV-${now.year}-${(seq + 1).toString().padLeft(5, '0')}',
      leaseId: lease.id,
      tenantId: lease.tenantId,
      periodLabel: label,
      amount: lease.rentAmount,
      issueDate: now,
      dueDate: now.add(Duration(days: dueDays)),
      notes: notes,
      createdAt: now,
      updatedAt: now,
    );
    await db.insert('invoices', invoice.toMap());
    return invoice;
  }

  Future<List<InvoiceModel>> allInvoices({
    InvoiceStatus? status,
    String? tenantId,
  }) async {
    final db = await DatabaseService.instance.database;
    final where = <String>[];
    final args = <Object?>[];
    if (status != null) {
      where.add('status = ?');
      args.add(status.name);
    }
    if (tenantId != null) {
      where.add('tenant_id = ?');
      args.add(tenantId);
    }
    final rows = await db.query(
      'invoices',
      where: where.isEmpty ? null : where.join(' AND '),
      whereArgs: args.isEmpty ? null : args,
      orderBy: 'due_date DESC',
    );
    return rows.map(InvoiceModel.fromMap).toList();
  }

  /// Flips invoices that have passed their due date to `overdue`.
  /// Returns the number of rows updated.
  Future<int> markOverdueInvoices() async {
    final db = await DatabaseService.instance.database;
    final now = DateTime.now().toIso8601String();
    return db.update(
      'invoices',
      {'status': InvoiceStatus.overdue.name, 'updated_at': now},
      where: 'status = ? AND due_date < ?',
      whereArgs: [InvoiceStatus.issued.name, now],
    );
  }

  Future<InvoiceModel?> getInvoice(String id) async {
    final db = await DatabaseService.instance.database;
    final rows = await db.query('invoices', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return InvoiceModel.fromMap(rows.first);
  }

  // ---------------------------------------------------------------- payments

  Future<PaymentModel> recordPayment({
    required InvoiceModel invoice,
    required double amount,
    required PaymentMethod method,
    String? reference,
    String? notes,
    DateTime? paymentDate,
  }) async {
    if (amount <= 0) {
      throw ArgumentError('Payment amount must be positive.');
    }
    final db = await DatabaseService.instance.database;
    final now = DateTime.now();

    final payment = PaymentModel(
      id: 'pay-${_uuid.v4()}',
      invoiceId: invoice.id,
      tenantId: invoice.tenantId,
      leaseId: invoice.leaseId,
      amount: amount,
      paymentDate: paymentDate ?? now,
      dueDate: invoice.dueDate,
      method: method,
      status: PaymentStatus.paid,
      referenceNumber: reference,
      notes: notes,
      createdAt: now,
      updatedAt: now,
    );
    await db.insert('payments', payment.toMap());

    // Sum payments against invoice to determine new invoice status.
    final totalRows = await db.rawQuery(
      'SELECT COALESCE(SUM(amount), 0) AS t FROM payments WHERE invoice_id = ?',
      [invoice.id],
    );
    final total = (totalRows.first['t'] as num).toDouble();
    InvoiceStatus newStatus;
    if (total >= invoice.amount) {
      newStatus = InvoiceStatus.paid;
    } else if (total > 0) {
      newStatus = InvoiceStatus.partial;
    } else {
      newStatus = invoice.status;
    }
    await db.update(
      'invoices',
      {'status': newStatus.name, 'updated_at': now.toIso8601String()},
      where: 'id = ?',
      whereArgs: [invoice.id],
    );

    return payment;
  }

  Future<List<PaymentModel>> allPayments({
    String? tenantId,
    String? leaseId,
    PaymentStatus? status,
  }) async {
    final db = await DatabaseService.instance.database;
    final where = <String>[];
    final args = <Object?>[];
    if (tenantId != null) {
      where.add('tenant_id = ?');
      args.add(tenantId);
    }
    if (leaseId != null) {
      where.add('lease_id = ?');
      args.add(leaseId);
    }
    if (status != null) {
      where.add('status = ?');
      args.add(status.name);
    }
    final rows = await db.query(
      'payments',
      where: where.isEmpty ? null : where.join(' AND '),
      whereArgs: args.isEmpty ? null : args,
      orderBy: 'payment_date DESC',
    );
    return rows.map(PaymentModel.fromMap).toList();
  }

  // Totals used by dashboards and reports.
  Future<double> totalCollected({DateTime? since}) async {
    final db = await DatabaseService.instance.database;
    final rows = since == null
        ? await db.rawQuery(
            'SELECT COALESCE(SUM(amount), 0) AS t FROM payments WHERE status = ?',
            [PaymentStatus.paid.name],
          )
        : await db.rawQuery(
            'SELECT COALESCE(SUM(amount), 0) AS t FROM payments WHERE status = ? AND payment_date >= ?',
            [PaymentStatus.paid.name, since.toIso8601String()],
          );
    return (rows.first['t'] as num).toDouble();
  }

  Future<double> totalOutstanding() async {
    final db = await DatabaseService.instance.database;
    final rows = await db.rawQuery('''
      SELECT COALESCE(SUM(i.amount - IFNULL(p.paid, 0)), 0) AS outstanding
      FROM invoices i
      LEFT JOIN (
        SELECT invoice_id, SUM(amount) AS paid FROM payments GROUP BY invoice_id
      ) p ON p.invoice_id = i.id
      WHERE i.status IN ('issued', 'overdue', 'partial')
    ''');
    return (rows.first['outstanding'] as num).toDouble();
  }
}
