// Author: PAMS Development Team
// File: tenant_detail_screen.dart
// Purpose: Show full tenant record with lease, payments, maintenance and
// complaint history. Supports edit/early-termination.

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../core/models/apartment_model.dart';
import '../../../../core/models/complaint_model.dart';
import '../../../../core/models/lease_model.dart';
import '../../../../core/models/maintenance_model.dart';
import '../../../../core/models/payment_model.dart';
import '../../../../core/models/tenant_model.dart';
import '../../../../core/security/rbac.dart';
import '../../../../core/services/apartment_service.dart';
import '../../../../core/services/billing_service.dart';
import '../../../../core/services/database_service.dart';
import '../../../../core/services/lease_service.dart';
import '../../../../core/services/maintenance_service.dart';
import '../../../../core/services/tenant_service.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import 'tenant_form_screen.dart';

class TenantDetailScreen extends StatefulWidget {
  final String tenantId;
  const TenantDetailScreen({super.key, required this.tenantId});

  @override
  State<TenantDetailScreen> createState() => _TenantDetailScreenState();
}

class _TenantDetailScreenState extends State<TenantDetailScreen> {
  final _tenantSvc = TenantService();
  final _leaseSvc = LeaseService();
  final _aptSvc = ApartmentService();
  final _billingSvc = BillingService();
  final _maintSvc = MaintenanceService();

  Future<_Bundle>? _future;
  static final _date = DateFormat('dd MMM yyyy');
  static final _currency =
      NumberFormat.currency(locale: 'en_GB', symbol: '£');

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    setState(() {
      _future = _load();
    });
  }

  Future<_Bundle> _load() async {
    final tenant = await _tenantSvc.getById(widget.tenantId);
    if (tenant == null) throw StateError('Tenant not found');
    final lease = await _leaseSvc.getActiveForTenant(tenant.id);
    ApartmentModel? apt;
    if (lease != null) {
      apt = await _aptSvc.getById(lease.apartmentId);
    }
    final payments = await _billingSvc.allPayments(tenantId: tenant.id);
    final maintenance = await _maintSvc.getAll();
    final relatedMaint =
        maintenance.where((m) => m.tenantId == tenant.id).toList();
    final db = await DatabaseService.instance.database;
    final complaintRows = await db.query('complaints',
        where: 'tenant_id = ?', whereArgs: [tenant.id]);
    final complaints =
        complaintRows.map(ComplaintModel.fromMap).toList();
    return _Bundle(tenant, lease, apt, payments, relatedMaint, complaints);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final canEdit = Rbac.can(auth.currentUser, Permission.editTenant);

    return Scaffold(
      appBar: AppBar(title: const Text('Tenant')),
      body: FutureBuilder<_Bundle>(
        future: _future,
        builder: (context, snap) {
          if (!snap.hasData) {
            if (snap.hasError) {
              return Center(child: Text('Error: ${snap.error}'));
            }
            return const Center(child: CircularProgressIndicator());
          }
          final b = snap.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _profileCard(b.tenant, canEdit),
                const SizedBox(height: 16),
                _leaseCard(b),
                const SizedBox(height: 16),
                _paymentsCard(b.payments),
                const SizedBox(height: 16),
                _maintenanceCard(b.maintenance),
                const SizedBox(height: 16),
                _complaintsCard(b),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _profileCard(TenantModel t, bool canEdit) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  child: Text(t.fullName[0],
                      style: const TextStyle(fontSize: 24)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(t.fullName,
                          style: Theme.of(context).textTheme.headlineMedium),
                      Text('${t.email} · ${t.phone}'),
                      Text('NI: ${t.niNumber} · ${t.city}'),
                    ],
                  ),
                ),
                Chip(label: Text(t.status.name)),
                if (canEdit)
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () async {
                      final changed = await Navigator.of(context).push<bool>(
                        MaterialPageRoute(
                          builder: (_) => TenantFormScreen(existing: t),
                        ),
                      );
                      if (changed == true) _reload();
                    },
                  ),
              ],
            ),
            const Divider(height: 32),
            _infoGrid({
              'Occupation': t.occupation ?? '-',
              'Lease period': t.leasePeriodMonths == null
                  ? '-'
                  : '${t.leasePeriodMonths} months',
              'Emergency contact': t.emergencyContact ?? '-',
              'Move-in': t.moveInDate == null ? '-' : _date.format(t.moveInDate!),
              'Apartment requirements': t.apartmentRequirements ?? '-',
              'References': t.references ?? '-',
            }),
          ],
        ),
      ),
    );
  }

  Widget _infoGrid(Map<String, String> items) {
    return Wrap(
      runSpacing: 8,
      spacing: 32,
      children: items.entries
          .map((e) => SizedBox(
                width: 300,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(e.key,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        )),
                    Text(e.value),
                  ],
                ),
              ))
          .toList(),
    );
  }

  Widget _leaseCard(_Bundle b) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Current Lease',
                    style: Theme.of(context).textTheme.titleLarge),
                const Spacer(),
                if (b.lease != null)
                  TextButton.icon(
                    icon: const Icon(Icons.warning_amber),
                    label: const Text('Request early termination'),
                    onPressed: () => _confirmEarlyTermination(b.lease!),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (b.lease == null)
              const Text('No active lease.')
            else
              _infoGrid({
                'Apartment': b.apartment == null
                    ? '-'
                    : '${b.apartment!.apartmentNumber}, ${b.apartment!.location}, ${b.apartment!.city}',
                'Rent': _currency.format(b.lease!.rentAmount),
                'Deposit': _currency.format(b.lease!.depositAmount),
                'Start': _date.format(b.lease!.startDate),
                'End': _date.format(b.lease!.endDate),
                'Status': b.lease!.status.name,
                if (b.lease!.earlyTerminationPenalty != null)
                  'Early termination penalty':
                      _currency.format(b.lease!.earlyTerminationPenalty!),
              }),
          ],
        ),
      ),
    );
  }

  Widget _paymentsCard(List<PaymentModel> payments) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Payment history (${payments.length})',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            if (payments.isEmpty)
              const Text('No payments recorded.')
            else
              DataTable(columns: const [
                DataColumn(label: Text('Date')),
                DataColumn(label: Text('Method')),
                DataColumn(label: Text('Reference')),
                DataColumn(label: Text('Amount')),
                DataColumn(label: Text('Status')),
              ], rows: [
                for (final p in payments.take(10))
                  DataRow(cells: [
                    DataCell(Text(_date.format(p.paymentDate))),
                    DataCell(Text(p.method.name)),
                    DataCell(Text(p.referenceNumber ?? '-')),
                    DataCell(Text(_currency.format(p.amount))),
                    DataCell(Text(p.status.name)),
                  ]),
              ]),
          ],
        ),
      ),
    );
  }

  Widget _maintenanceCard(List<MaintenanceRequestModel> items) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Maintenance (${items.length})',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            if (items.isEmpty)
              const Text('No maintenance requests.')
            else
              for (final m in items)
                ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.build, color: _priorityColor(m.priority)),
                  title: Text(m.title),
                  subtitle: Text(
                      '${m.status.name} · priority: ${m.priority.name} · reported ${_date.format(m.reportedDate)}'),
                  trailing: m.cost == null
                      ? null
                      : Text(_currency.format(m.cost!)),
                ),
          ],
        ),
      ),
    );
  }

  Widget _complaintsCard(_Bundle b) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Complaints (${b.complaints.length})',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            if (b.complaints.isEmpty)
              const Text('No complaints logged.')
            else
              for (final c in b.complaints)
                ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: Text(c.subject),
                  subtitle: Text('${c.status.name} · ${_date.format(c.loggedDate)}'),
                ),
          ],
        ),
      ),
    );
  }

  Color _priorityColor(MaintenancePriority p) {
    switch (p) {
      case MaintenancePriority.urgent:
        return Colors.red;
      case MaintenancePriority.high:
        return Colors.orange;
      case MaintenancePriority.medium:
        return Colors.blue;
      case MaintenancePriority.low:
        return Colors.grey;
    }
  }

  Future<void> _confirmEarlyTermination(LeaseModel lease) async {
    final penalty = lease.computeEarlyTerminationPenalty();
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirm early termination'),
        content: Text(
            'Per the tenancy terms, early termination requires 1 month notice '
            'and a penalty of 5% of the monthly rent '
            '(${_currency.format(penalty)}). Proceed?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Confirm')),
        ],
      ),
    );
    if (ok == true) {
      await _leaseSvc.terminateEarly(lease.id, DateTime.now());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Early termination recorded with penalty ${_currency.format(penalty)}.')),
        );
        _reload();
      }
    }
  }
}

class _Bundle {
  final TenantModel tenant;
  final LeaseModel? lease;
  final ApartmentModel? apartment;
  final List<PaymentModel> payments;
  final List<MaintenanceRequestModel> maintenance;
  final List<ComplaintModel> complaints;
  _Bundle(
    this.tenant,
    this.lease,
    this.apartment,
    this.payments,
    this.maintenance,
    this.complaints,
  );
}
