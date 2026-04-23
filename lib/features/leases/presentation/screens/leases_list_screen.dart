// Author: Alec Brothwood (23076824) - Project Manager
// Author: Ashley Shoniwa (24021297) - Frontend Developer
// File: leases_list_screen.dart
// Purpose: List leases with filter for active/expiring + creation action.

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../core/models/apartment_model.dart';
import '../../../../core/models/lease_model.dart';
import '../../../../core/models/tenant_model.dart';
import '../../../../core/security/rbac.dart';
import '../../../../core/services/apartment_service.dart';
import '../../../../core/services/lease_service.dart';
import '../../../../core/services/tenant_service.dart';
import '../../../../core/widgets/app_shell.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import 'lease_form_screen.dart';

class LeasesListScreen extends StatefulWidget {
  const LeasesListScreen({super.key});

  @override
  State<LeasesListScreen> createState() => _LeasesListScreenState();
}

class _LeasesListScreenState extends State<LeasesListScreen> {
  final _service = LeaseService();
  final _tenantSvc = TenantService();
  final _aptSvc = ApartmentService();
  LeaseStatus? _statusFilter;
  Future<_Data>? _future;
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

  Future<_Data> _load() async {
    final all = await _service.getAll(status: _statusFilter);
    final tenants = {for (final t in await _tenantSvc.getAll()) t.id: t};
    final apts = {for (final a in await _aptSvc.getAll()) a.id: a};
    final expiring =
        await _service.getExpiringWithin(const Duration(days: 60));
    return _Data(all, tenants, apts, expiring);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final canManage = Rbac.can(auth.currentUser, Permission.manageLeases);

    return AppShell(
      title: 'Leases',
      floatingActionButton: canManage
          ? FloatingActionButton.extended(
              onPressed: () async {
                final ok = await Navigator.of(context).push<bool>(
                    MaterialPageRoute(
                        builder: (_) => const LeaseFormScreen()));
                if (ok == true) _reload();
              },
              icon: const Icon(Icons.assignment_add),
              label: const Text('New Lease'),
            )
          : null,
      child: FutureBuilder<_Data>(
        future: _future,
        builder: (_, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final d = snap.data!;
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (d.expiring.isNotEmpty)
                  Card(
                    color: Colors.amber.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.warning_amber,
                                  color: Colors.orange),
                              const SizedBox(width: 8),
                              Text('Leases expiring within 60 days',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium),
                            ],
                          ),
                          const SizedBox(height: 8),
                          for (final l in d.expiring.take(5))
                            Text(
                                '${d.tenants[l.tenantId]?.fullName ?? l.tenantId} · ends ${_date.format(l.endDate)}'),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    DropdownButton<LeaseStatus?>(
                      value: _statusFilter,
                      hint: const Text('All statuses'),
                      items: [
                        const DropdownMenuItem(
                            value: null, child: Text('All statuses')),
                        ...LeaseStatus.values.map((s) => DropdownMenuItem(
                            value: s, child: Text(s.name))),
                      ],
                      onChanged: (v) {
                        setState(() => _statusFilter = v);
                        _reload();
                      },
                    ),
                    const Spacer(),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.refresh),
                      label: const Text('Refresh'),
                      onPressed: _reload,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: Card(
                    child: ListView.separated(
                      itemCount: d.leases.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (_, i) {
                        final l = d.leases[i];
                        final tenant = d.tenants[l.tenantId];
                        final apt = d.apartments[l.apartmentId];
                        return ListTile(
                          leading: CircleAvatar(
                              child: Text(
                                  (tenant?.fullName[0] ?? '?').toUpperCase())),
                          title: Text(
                              '${tenant?.fullName ?? l.tenantId} · ${apt?.apartmentNumber ?? l.apartmentId}'),
                          subtitle: Text(
                              '${apt?.city ?? '-'} · ${_date.format(l.startDate)} → ${_date.format(l.endDate)} · ${_currency.format(l.rentAmount)}/mo'),
                          trailing: Chip(
                              label: Text(l.status.name),
                              backgroundColor: _statusColor(l.status)
                                  .withValues(alpha: 0.15),
                              labelStyle:
                                  TextStyle(color: _statusColor(l.status))),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Color _statusColor(LeaseStatus s) => switch (s) {
        LeaseStatus.active => Colors.green,
        LeaseStatus.expired => Colors.grey,
        LeaseStatus.terminatedEarly => Colors.orange,
        LeaseStatus.pending => Colors.blue,
      };
}

class _Data {
  final List<LeaseModel> leases;
  final Map<String, TenantModel> tenants;
  final Map<String, ApartmentModel> apartments;
  final List<LeaseModel> expiring;
  _Data(this.leases, this.tenants, this.apartments, this.expiring);
}
