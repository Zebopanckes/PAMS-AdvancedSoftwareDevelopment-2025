// Author: PAMS Development Team
// File: billing_screen.dart
// Purpose: Invoices + Payments management for Finance Manager / Admin.

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../core/models/apartment_model.dart';
import '../../../../core/models/invoice_model.dart';
import '../../../../core/models/lease_model.dart';
import '../../../../core/models/payment_model.dart';
import '../../../../core/models/tenant_model.dart';
import '../../../../core/security/rbac.dart';
import '../../../../core/services/apartment_service.dart';
import '../../../../core/services/billing_service.dart';
import '../../../../core/services/lease_service.dart';
import '../../../../core/services/pdf_export_service.dart';
import '../../../../core/services/tenant_service.dart';
import '../../../../core/widgets/app_shell.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class BillingScreen extends StatefulWidget {
  const BillingScreen({super.key});

  @override
  State<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends State<BillingScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;
  final _billing = BillingService();
  final _leaseSvc = LeaseService();
  final _tenantSvc = TenantService();
  final _aptSvc = ApartmentService();
  final _pdf = PdfExportService();

  Future<_BillingData>? _future;
  static final _date = DateFormat('dd MMM yyyy');
  static final _currency =
      NumberFormat.currency(locale: 'en_GB', symbol: '£');

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    _reload();
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  void _reload() {
    setState(() {
      _future = _load();
    });
  }

  Future<_BillingData> _load() async {
    await _billing.markOverdueInvoices();
    final invoices = await _billing.allInvoices();
    final payments = await _billing.allPayments();
    final tenants = {for (final t in await _tenantSvc.getAll()) t.id: t};
    final leases = {for (final l in await _leaseSvc.getAll()) l.id: l};
    final apartments = {for (final a in await _aptSvc.getAll()) a.id: a};
    final collected = await _billing.totalCollected();
    final outstanding = await _billing.totalOutstanding();
    return _BillingData(invoices, payments, tenants, leases, apartments,
        collected, outstanding);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final canManage = Rbac.can(auth.currentUser, Permission.managePayments);
    final canIssue = Rbac.can(auth.currentUser, Permission.generateInvoices);

    return AppShell(
      title: 'Billing',
      floatingActionButton: canIssue
          ? FloatingActionButton.extended(
              onPressed: _issueInvoiceDialog,
              icon: const Icon(Icons.receipt_long),
              label: const Text('Issue Invoice'),
            )
          : null,
      child: FutureBuilder<_BillingData>(
        future: _future,
        builder: (_, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final d = snap.data!;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    _summaryCard(
                        'Collected',
                        _currency.format(d.collected),
                        Colors.green),
                    const SizedBox(width: 16),
                    _summaryCard(
                        'Outstanding',
                        _currency.format(d.outstanding),
                        Colors.red),
                    const SizedBox(width: 16),
                    _summaryCard(
                        'Invoices',
                        d.invoices.length.toString(),
                        Colors.blue),
                    const SizedBox(width: 16),
                    _summaryCard(
                        'Payments',
                        d.payments.length.toString(),
                        Colors.purple),
                  ],
                ),
              ),
              TabBar(
                controller: _tab,
                tabs: const [
                  Tab(text: 'Invoices'),
                  Tab(text: 'Payments'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  controller: _tab,
                  children: [
                    _invoicesTab(d, canManage),
                    _paymentsTab(d),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _summaryCard(String label, String value, Color color) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 4),
              Text(value,
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: color)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _invoicesTab(_BillingData d, bool canManage) {
    if (d.invoices.isEmpty) {
      return const Center(child: Text('No invoices yet.'));
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: DataTable(
            columns: const [
              DataColumn(label: Text('Invoice #')),
              DataColumn(label: Text('Tenant')),
              DataColumn(label: Text('Period')),
              DataColumn(label: Text('Amount'), numeric: true),
              DataColumn(label: Text('Issued')),
              DataColumn(label: Text('Due')),
              DataColumn(label: Text('Status')),
              DataColumn(label: Text('Actions')),
            ],
            rows: [
              for (final inv in d.invoices)
                DataRow(cells: [
                  DataCell(Text(inv.invoiceNumber)),
                  DataCell(Text(d.tenants[inv.tenantId]?.fullName ?? '-')),
                  DataCell(Text(inv.periodLabel)),
                  DataCell(Text(_currency.format(inv.amount))),
                  DataCell(Text(_date.format(inv.issueDate))),
                  DataCell(Text(_date.format(inv.dueDate))),
                  DataCell(Chip(
                    label: Text(inv.status.name),
                    backgroundColor:
                        _invStatusColor(inv.status).withValues(alpha: 0.15),
                    labelStyle:
                        TextStyle(color: _invStatusColor(inv.status)),
                  )),
                  DataCell(Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.picture_as_pdf),
                        tooltip: 'Preview PDF',
                        onPressed: () async {
                          final tenant = d.tenants[inv.tenantId];
                          final lease = d.leases[inv.leaseId];
                          final apt = lease == null
                              ? null
                              : d.apartments[lease.apartmentId];
                          final payments = await _billing
                              .allPayments(tenantId: inv.tenantId);
                          if (tenant != null && lease != null && apt != null) {
                            await _pdf.previewInvoice(
                              invoice: inv,
                              tenant: tenant,
                              lease: lease,
                              apartment: apt,
                              payments: payments
                                  .where((p) => p.invoiceId == inv.id)
                                  .toList(),
                            );
                          }
                        },
                      ),
                      if (canManage &&
                          inv.status != InvoiceStatus.paid &&
                          inv.status != InvoiceStatus.cancelled)
                        IconButton(
                          icon: const Icon(Icons.payment),
                          tooltip: 'Record payment',
                          onPressed: () => _recordPaymentDialog(inv, d),
                        ),
                    ],
                  )),
                ]),
            ],
          ),
        ),
      ],
    );
  }

  Widget _paymentsTab(_BillingData d) {
    if (d.payments.isEmpty) {
      return const Center(child: Text('No payments yet.'));
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: DataTable(
            columns: const [
              DataColumn(label: Text('Date')),
              DataColumn(label: Text('Tenant')),
              DataColumn(label: Text('Method')),
              DataColumn(label: Text('Reference')),
              DataColumn(label: Text('Amount'), numeric: true),
              DataColumn(label: Text('Status')),
              DataColumn(label: Text('Actions')),
            ],
            rows: [
              for (final p in d.payments)
                DataRow(cells: [
                  DataCell(Text(_date.format(p.paymentDate))),
                  DataCell(Text(d.tenants[p.tenantId]?.fullName ?? '-')),
                  DataCell(Text(p.method.name)),
                  DataCell(Text(p.referenceNumber ?? '-')),
                  DataCell(Text(_currency.format(p.amount))),
                  DataCell(Text(p.status.name)),
                  DataCell(IconButton(
                    icon: const Icon(Icons.receipt),
                    tooltip: 'Receipt PDF',
                    onPressed: () {
                      final tenant = d.tenants[p.tenantId];
                      final lease = d.leases[p.leaseId];
                      final apt = lease == null
                          ? null
                          : d.apartments[lease.apartmentId];
                      if (tenant != null && apt != null) {
                        _pdf.previewReceipt(
                            payment: p, tenant: tenant, apartment: apt);
                      }
                    },
                  )),
                ]),
            ],
          ),
        ),
      ],
    );
  }

  Color _invStatusColor(InvoiceStatus s) => switch (s) {
        InvoiceStatus.paid => Colors.green,
        InvoiceStatus.issued => Colors.blue,
        InvoiceStatus.partial => Colors.orange,
        InvoiceStatus.overdue => Colors.red,
        InvoiceStatus.cancelled => Colors.grey,
      };

  Future<void> _issueInvoiceDialog() async {
    final leases = await _leaseSvc.getAll(status: LeaseStatus.active);
    if (!mounted) return;
    if (leases.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No active leases available.')));
      return;
    }
    LeaseModel? selected = leases.first;
    DateTime period = DateTime.now();
    int dueDays = 7;
    await showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          title: const Text('Issue invoice'),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<LeaseModel>(
                  initialValue: selected,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Lease'),
                  items: [
                    for (final l in leases)
                      DropdownMenuItem(
                        value: l,
                        child: Text(
                            'Lease ${l.id.substring(0, 10)} · £${l.rentAmount.toStringAsFixed(0)}'),
                      ),
                  ],
                  onChanged: (v) => setLocal(() => selected = v),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  initialValue: dueDays.toString(),
                  decoration:
                      const InputDecoration(labelText: 'Due in (days)'),
                  keyboardType: TextInputType.number,
                  onChanged: (v) =>
                      dueDays = int.tryParse(v) ?? dueDays,
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () async {
                    final p = await showDatePicker(
                      context: ctx,
                      initialDate: period,
                      firstDate: DateTime(2024),
                      lastDate: DateTime(2035),
                    );
                    if (p != null) setLocal(() => period = p);
                  },
                  child: InputDecorator(
                    decoration:
                        const InputDecoration(labelText: 'Period month'),
                    child: Text(DateFormat('MMMM yyyy').format(period)),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel')),
            FilledButton(
              onPressed: () async {
                if (selected == null) return;
                await _billing.issueInvoice(
                    lease: selected!,
                    periodMonth: period,
                    dueDays: dueDays);
                if (ctx.mounted) Navigator.pop(ctx);
                _reload();
              },
              child: const Text('Issue'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _recordPaymentDialog(InvoiceModel invoice, _BillingData d) async {
    final amountCtrl =
        TextEditingController(text: invoice.amount.toStringAsFixed(2));
    final refCtrl = TextEditingController();
    PaymentMethod method = PaymentMethod.bankTransfer;
    await showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          title: Text('Record payment for ${invoice.invoiceNumber}'),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                    controller: amountCtrl,
                    keyboardType: TextInputType.number,
                    decoration:
                        const InputDecoration(labelText: 'Amount (£)')),
                const SizedBox(height: 8),
                DropdownButtonFormField<PaymentMethod>(
                  initialValue: method,
                  decoration: const InputDecoration(labelText: 'Method'),
                  items: PaymentMethod.values
                      .map((m) =>
                          DropdownMenuItem(value: m, child: Text(m.name)))
                      .toList(),
                  onChanged: (v) =>
                      setLocal(() => method = v ?? method),
                ),
                const SizedBox(height: 8),
                TextField(
                    controller: refCtrl,
                    decoration:
                        const InputDecoration(labelText: 'Reference')),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel')),
            FilledButton(
              onPressed: () async {
                final amt = double.tryParse(amountCtrl.text);
                if (amt == null || amt <= 0) return;
                await _billing.recordPayment(
                    invoice: invoice,
                    amount: amt,
                    method: method,
                    reference:
                        refCtrl.text.isEmpty ? null : refCtrl.text);
                if (ctx.mounted) Navigator.pop(ctx);
                _reload();
              },
              child: const Text('Record'),
            ),
          ],
        ),
      ),
    );
  }
}

class _BillingData {
  final List<InvoiceModel> invoices;
  final List<PaymentModel> payments;
  final Map<String, TenantModel> tenants;
  final Map<String, LeaseModel> leases;
  final Map<String, ApartmentModel> apartments;
  final double collected;
  final double outstanding;
  _BillingData(this.invoices, this.payments, this.tenants, this.leases,
      this.apartments, this.collected, this.outstanding);
}
