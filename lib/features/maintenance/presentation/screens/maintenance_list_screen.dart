// Author: Alec Brothwood (23076824) - Project Manager
// Author: Ashley Shoniwa (24021297) - Frontend Developer
// File: maintenance_list_screen.dart
// Purpose: Lifecycle board for maintenance requests.

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../core/models/apartment_model.dart';
import '../../../../core/models/maintenance_model.dart';
import '../../../../core/models/user_model.dart';
import '../../../../core/security/rbac.dart';
import '../../../../core/services/apartment_service.dart';
import '../../../../core/services/maintenance_service.dart';
import '../../../../core/services/user_service.dart';
import '../../../../core/widgets/app_shell.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import 'maintenance_form_screen.dart';

class MaintenanceListScreen extends StatefulWidget {
  const MaintenanceListScreen({super.key});

  @override
  State<MaintenanceListScreen> createState() =>
      _MaintenanceListScreenState();
}

class _MaintenanceListScreenState extends State<MaintenanceListScreen> {
  final _service = MaintenanceService();
  final _aptSvc = ApartmentService();
  final _userSvc = UserService();

  MaintenanceStatus? _statusFilter;
  MaintenancePriority? _priorityFilter;
  Future<_MData>? _future;
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

  Future<_MData> _load() async {
    final items = await _service.getAll(
        status: _statusFilter, priority: _priorityFilter);
    final apts = {for (final a in await _aptSvc.getAll()) a.id: a};
    final maintUsers =
        await _userSvc.getAll(role: UserRole.maintenance);
    final users = {for (final u in maintUsers) u.id: u};
    return _MData(items, apts, users);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final canCreate =
        Rbac.can(auth.currentUser, Permission.createMaintenance);
    final canAssign =
        Rbac.can(auth.currentUser, Permission.assignMaintenance);
    final canResolve =
        Rbac.can(auth.currentUser, Permission.resolveMaintenance);

    return AppShell(
      title: 'Maintenance',
      floatingActionButton: canCreate
          ? FloatingActionButton.extended(
              onPressed: () async {
                final ok = await Navigator.of(context).push<bool>(
                    MaterialPageRoute(
                        builder: (_) => const MaintenanceFormScreen()));
                if (ok == true) _reload();
              },
              icon: const Icon(Icons.add),
              label: const Text('New Request'),
            )
          : null,
      child: FutureBuilder<_MData>(
        future: _future,
        builder: (_, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final d = snap.data!;
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _filters(),
                const SizedBox(height: 12),
                Expanded(
                  child: d.items.isEmpty
                      ? const Center(child: Text('No maintenance requests.'))
                      : Card(
                          child: ListView.separated(
                            itemCount: d.items.length,
                            separatorBuilder: (_, __) =>
                                const Divider(height: 1),
                            itemBuilder: (_, i) {
                              final m = d.items[i];
                              final apt = d.apartments[m.apartmentId];
                              return ListTile(
                                leading: Icon(Icons.build,
                                    color: _priorityColor(m.priority)),
                                title: Text(m.title),
                                subtitle: Text(
                                    '${apt?.apartmentNumber ?? '-'}, ${apt?.city ?? '-'} · reported ${_date.format(m.reportedDate)} · priority: ${m.priority.name}${m.cost != null ? ' · cost: ${_currency.format(m.cost!)}' : ''}'),
                                trailing: Wrap(
                                  spacing: 4,
                                  crossAxisAlignment:
                                      WrapCrossAlignment.center,
                                  children: [
                                    Chip(
                                      label: Text(m.status.name),
                                      backgroundColor: _statusColor(m.status)
                                          .withValues(alpha: 0.15),
                                      labelStyle: TextStyle(
                                          color: _statusColor(m.status)),
                                    ),
                                    if (canAssign)
                                      IconButton(
                                        icon: const Icon(
                                            Icons.assignment_ind),
                                        tooltip: 'Assign',
                                        onPressed: () =>
                                            _assignDialog(m, d.users),
                                      ),
                                    if (canResolve &&
                                        m.status !=
                                            MaintenanceStatus.resolved)
                                      IconButton(
                                        icon: const Icon(Icons.done_all),
                                        tooltip: 'Resolve',
                                        onPressed: () => _resolveDialog(m),
                                      ),
                                  ],
                                ),
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

  Widget _filters() {
    return Wrap(
      spacing: 12,
      children: [
        DropdownButton<MaintenanceStatus?>(
          value: _statusFilter,
          hint: const Text('All statuses'),
          items: [
            const DropdownMenuItem(value: null, child: Text('All statuses')),
            ...MaintenanceStatus.values.map(
                (s) => DropdownMenuItem(value: s, child: Text(s.name))),
          ],
          onChanged: (v) {
            setState(() => _statusFilter = v);
            _reload();
          },
        ),
        DropdownButton<MaintenancePriority?>(
          value: _priorityFilter,
          hint: const Text('All priorities'),
          items: [
            const DropdownMenuItem(
                value: null, child: Text('All priorities')),
            ...MaintenancePriority.values.map(
                (p) => DropdownMenuItem(value: p, child: Text(p.name))),
          ],
          onChanged: (v) {
            setState(() => _priorityFilter = v);
            _reload();
          },
        ),
        OutlinedButton.icon(
          icon: const Icon(Icons.refresh),
          label: const Text('Refresh'),
          onPressed: _reload,
        ),
      ],
    );
  }

  Color _priorityColor(MaintenancePriority p) => switch (p) {
        MaintenancePriority.urgent => Colors.red,
        MaintenancePriority.high => Colors.orange,
        MaintenancePriority.medium => Colors.blue,
        MaintenancePriority.low => Colors.grey,
      };

  Color _statusColor(MaintenanceStatus s) => switch (s) {
        MaintenanceStatus.reported => Colors.blue,
        MaintenanceStatus.investigating => Colors.teal,
        MaintenanceStatus.scheduled => Colors.purple,
        MaintenanceStatus.inProgress => Colors.orange,
        MaintenanceStatus.onHold => Colors.amber,
        MaintenanceStatus.resolved => Colors.green,
        MaintenanceStatus.cancelled => Colors.grey,
      };

  Future<void> _assignDialog(
      MaintenanceRequestModel m, Map<String, UserModel> users) async {
    if (users.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No maintenance staff available.')));
      return;
    }
    UserModel? selected = users.values.first;
    DateTime? scheduled = DateTime.now().add(const Duration(days: 1));
    await showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          title: const Text('Assign to maintenance worker'),
          content: SizedBox(
            width: 400,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              DropdownButtonFormField<UserModel>(
                initialValue: selected,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Worker'),
                items: [
                  for (final u in users.values)
                    DropdownMenuItem(
                        value: u,
                        child: Text(
                            '${u.fullName}${u.city != null ? ' · ${u.city}' : ''}'))
                ],
                onChanged: (v) => setLocal(() => selected = v),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: () async {
                  final p = await showDatePicker(
                    context: ctx,
                    initialDate: scheduled ?? DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate:
                        DateTime.now().add(const Duration(days: 365)),
                  );
                  if (p != null) setLocal(() => scheduled = p);
                },
                child: InputDecorator(
                  decoration: const InputDecoration(
                      labelText: 'Scheduled date (communicated to tenant)'),
                  child: Text(scheduled == null
                      ? 'Pick a date'
                      : DateFormat('dd MMM yyyy').format(scheduled!)),
                ),
              ),
            ]),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel')),
            FilledButton(
              onPressed: () async {
                if (selected == null) return;
                await _service.assign(m.id, selected!.id, scheduled);
                if (ctx.mounted) Navigator.pop(ctx);
                _reload();
              },
              child: const Text('Assign'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _resolveDialog(MaintenanceRequestModel m) async {
    final notesCtrl = TextEditingController();
    final hoursCtrl = TextEditingController(text: '1.0');
    final costCtrl = TextEditingController(text: '0.00');
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Resolve maintenance'),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  controller: notesCtrl,
                  maxLines: 3,
                  decoration:
                      const InputDecoration(labelText: 'Resolution notes')),
              const SizedBox(height: 8),
              TextField(
                  controller: hoursCtrl,
                  keyboardType: TextInputType.number,
                  decoration:
                      const InputDecoration(labelText: 'Hours spent')),
              const SizedBox(height: 8),
              TextField(
                  controller: costCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Cost (£)')),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              final hours = double.tryParse(hoursCtrl.text) ?? 0;
              final cost = double.tryParse(costCtrl.text) ?? 0;
              await _service.resolve(
                id: m.id,
                resolutionNotes: notesCtrl.text,
                hoursSpent: hours,
                cost: cost,
              );
              if (ctx.mounted) Navigator.pop(ctx);
              _reload();
            },
            child: const Text('Mark resolved'),
          ),
        ],
      ),
    );
  }
}

class _MData {
  final List<MaintenanceRequestModel> items;
  final Map<String, ApartmentModel> apartments;
  final Map<String, UserModel> users;
  _MData(this.items, this.apartments, this.users);
}
