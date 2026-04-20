// Author: PAMS Development Team
// File: invoice_model.dart
// Purpose: Billing invoice issued against a lease.

import 'dart:convert';

enum InvoiceStatus { issued, paid, partial, overdue, cancelled }

class InvoiceModel {
  final String id;
  final String invoiceNumber;
  final String leaseId;
  final String tenantId;
  final String periodLabel; // e.g. "2026-04"
  final double amount;
  final DateTime issueDate;
  final DateTime dueDate;
  final InvoiceStatus status;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  InvoiceModel({
    required this.id,
    required this.invoiceNumber,
    required this.leaseId,
    required this.tenantId,
    required this.periodLabel,
    required this.amount,
    required this.issueDate,
    required this.dueDate,
    this.status = InvoiceStatus.issued,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isOverdue =>
      status != InvoiceStatus.paid &&
      status != InvoiceStatus.cancelled &&
      DateTime.now().isAfter(dueDate);

  Map<String, dynamic> toMap() => {
        'id': id,
        'invoice_number': invoiceNumber,
        'lease_id': leaseId,
        'tenant_id': tenantId,
        'period_label': periodLabel,
        'amount': amount,
        'issue_date': issueDate.toIso8601String(),
        'due_date': dueDate.toIso8601String(),
        'status': status.name,
        'notes': notes,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  factory InvoiceModel.fromMap(Map<String, dynamic> m) => InvoiceModel(
        id: m['id'] as String,
        invoiceNumber: m['invoice_number'] as String,
        leaseId: m['lease_id'] as String,
        tenantId: m['tenant_id'] as String,
        periodLabel: m['period_label'] as String,
        amount: (m['amount'] as num).toDouble(),
        issueDate: DateTime.parse(m['issue_date'] as String),
        dueDate: DateTime.parse(m['due_date'] as String),
        status: InvoiceStatus.values.firstWhere(
          (e) => e.name == m['status'],
          orElse: () => InvoiceStatus.issued,
        ),
        notes: m['notes'] as String?,
        createdAt: DateTime.parse(m['created_at'] as String),
        updatedAt: DateTime.parse(m['updated_at'] as String),
      );

  String toJson() => json.encode(toMap());
  factory InvoiceModel.fromJson(String s) =>
      InvoiceModel.fromMap(json.decode(s));

  InvoiceModel copyWith({InvoiceStatus? status, DateTime? updatedAt}) =>
      InvoiceModel(
        id: id,
        invoiceNumber: invoiceNumber,
        leaseId: leaseId,
        tenantId: tenantId,
        periodLabel: periodLabel,
        amount: amount,
        issueDate: issueDate,
        dueDate: dueDate,
        status: status ?? this.status,
        notes: notes,
        createdAt: createdAt,
        updatedAt: updatedAt ?? DateTime.now(),
      );
}
