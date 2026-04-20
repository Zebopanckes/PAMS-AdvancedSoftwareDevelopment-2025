// Author: PAMS Development Team
// File: payment_model.dart
// Purpose: A payment (money received) recorded against a lease/invoice.

import 'dart:convert';

enum PaymentStatus { pending, paid, overdue, cancelled, refunded }

enum PaymentMethod { bankTransfer, card, cash, cheque, standingOrder, other }

class PaymentModel {
  final String id;
  final String? invoiceId;
  final String tenantId;
  final String leaseId;
  final double amount;
  final DateTime paymentDate;
  final DateTime dueDate;
  final PaymentMethod method;
  final PaymentStatus status;
  final String? referenceNumber;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  PaymentModel({
    required this.id,
    this.invoiceId,
    required this.tenantId,
    required this.leaseId,
    required this.amount,
    required this.paymentDate,
    required this.dueDate,
    this.method = PaymentMethod.bankTransfer,
    this.status = PaymentStatus.paid,
    this.referenceNumber,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isLate =>
      status != PaymentStatus.paid && DateTime.now().isAfter(dueDate);

  Map<String, dynamic> toMap() => {
        'id': id,
        'invoice_id': invoiceId,
        'tenant_id': tenantId,
        'lease_id': leaseId,
        'amount': amount,
        'payment_date': paymentDate.toIso8601String(),
        'due_date': dueDate.toIso8601String(),
        'payment_method': method.name,
        'status': status.name,
        'reference_number': referenceNumber,
        'notes': notes,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  factory PaymentModel.fromMap(Map<String, dynamic> m) => PaymentModel(
        id: m['id'] as String,
        invoiceId: m['invoice_id'] as String?,
        tenantId: m['tenant_id'] as String,
        leaseId: m['lease_id'] as String,
        amount: (m['amount'] as num).toDouble(),
        paymentDate: DateTime.parse(m['payment_date'] as String),
        dueDate: DateTime.parse(m['due_date'] as String),
        method: PaymentMethod.values.firstWhere(
          (e) => e.name == m['payment_method'],
          orElse: () => PaymentMethod.bankTransfer,
        ),
        status: PaymentStatus.values.firstWhere(
          (e) => e.name == m['status'],
          orElse: () => PaymentStatus.paid,
        ),
        referenceNumber: m['reference_number'] as String?,
        notes: m['notes'] as String?,
        createdAt: DateTime.parse(m['created_at'] as String),
        updatedAt: DateTime.parse(m['updated_at'] as String),
      );

  String toJson() => json.encode(toMap());
  factory PaymentModel.fromJson(String s) =>
      PaymentModel.fromMap(json.decode(s));
}
