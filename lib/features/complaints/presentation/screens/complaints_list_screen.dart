// Author: Alec Brothwood (23076824) - Project Manager
// Author: Ashley Shoniwa (24021297) - Frontend Developer
// Author: Okan Kaynak (23035729) - Quality & Documentation Specialist
// File: complaints_list_screen.dart
// Purpose: Front-desk complaint register.

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/models/complaint_model.dart';
import '../../../../core/models/tenant_model.dart';
import '../../../../core/security/rbac.dart';
import '../../../../core/services/database_service.dart';
import '../../../../core/services/tenant_service.dart';
import '../../../../core/widgets/app_shell.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class ComplaintsListScreen extends StatefulWidget {
  const ComplaintsListScreen({super.key});

  @override
  State<ComplaintsListScreen> createState() => _ComplaintsListScreenState();
}

class _ComplaintsListScreenState extends State<ComplaintsListScreen> {
  final _tenantSvc = TenantService();
  List<ComplaintModel> _complaints = [];
  Map<String, TenantModel> _tenants = {};
  bool _loading = true;
  static final _date = DateFormat('dd MMM yyyy');

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final db = await DatabaseService.instance.database;
    final rows =
        await db.query('complaints', orderBy: 'logged_date DESC');
    _complaints = rows.map(ComplaintModel.fromMap).toList();
    _tenants = {for (final t in await _tenantSvc.getAll()) t.id: t};
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _create(BuildContext context, String userId) async {
    if (_tenants.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No tenants to file against.')));
      return;
    }
    TenantModel? selected = _tenants.values.first;
    final subject = TextEditingController();
    final desc = TextEditingController();
    await showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          title: const Text('New complaint'),
          content: SizedBox(
            width: 440,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              DropdownButtonFormField<TenantModel>(
                initialValue: selected,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Tenant'),
                items: [
                  for (final t in _tenants.values)
                    DropdownMenuItem(
                        value: t,
                        child: Text('${t.fullName} · ${t.city}')),
                ],
                onChanged: (v) => setLocal(() => selected = v),
              ),
              const SizedBox(height: 8),
              TextField(
                  controller: subject,
                  decoration: const InputDecoration(labelText: 'Subject')),
              const SizedBox(height: 8),
              TextField(
                  controller: desc,
                  maxLines: 4,
                  decoration:
                      const InputDecoration(labelText: 'Description')),
            ]),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel')),
            FilledButton(
              onPressed: () async {
                if (selected == null || subject.text.isEmpty) return;
                final now = DateTime.now();
                final c = ComplaintModel(
                  id: 'cmp-${const Uuid().v4()}',
                  tenantId: selected!.id,
                  subject: subject.text,
                  description: desc.text,
                  loggedBy: userId,
                  loggedDate: now,
                  createdAt: now,
                  updatedAt: now,
                );
                final db = await DatabaseService.instance.database;
                await db.insert('complaints', c.toMap());
                if (ctx.mounted) Navigator.pop(ctx);
                _load();
              },
              child: const Text('Log'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateStatus(
      ComplaintModel c, ComplaintStatus status) async {
    final db = await DatabaseService.instance.database;
    await db.update(
      'complaints',
      {
        'status': status.name,
        'resolved_date': status == ComplaintStatus.resolved ||
                status == ComplaintStatus.closed
            ? DateTime.now().toIso8601String()
            : null,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [c.id],
    );
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final canManage =
        Rbac.can(auth.currentUser, Permission.manageComplaints);

    return AppShell(
      title: 'Complaints',
      floatingActionButton: canManage
          ? FloatingActionButton.extended(
              onPressed: () =>
                  _create(context, auth.currentUser?.id ?? 'unknown'),
              icon: const Icon(Icons.add_comment),
              label: const Text('Log Complaint'),
            )
          : null,
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : _complaints.isEmpty
              ? const Center(child: Text('No complaints logged.'))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _complaints.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) {
                    final c = _complaints[i];
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                              _color(c.status).withValues(alpha: 0.15),
                          child: Icon(Icons.report, color: _color(c.status)),
                        ),
                        title: Text(c.subject),
                        subtitle: Text(
                            '${_tenants[c.tenantId]?.fullName ?? c.tenantId} · ${_date.format(c.loggedDate)}\n${c.description}'),
                        isThreeLine: true,
                        trailing: canManage
                            ? PopupMenuButton<ComplaintStatus>(
                                initialValue: c.status,
                                onSelected: (s) => _updateStatus(c, s),
                                itemBuilder: (_) => [
                                  for (final s in ComplaintStatus.values)
                                    PopupMenuItem(
                                        value: s, child: Text(s.name)),
                                ],
                                child: Chip(label: Text(c.status.name)),
                              )
                            : Chip(label: Text(c.status.name)),
                      ),
                    );
                  },
                ),
    );
  }

  Color _color(ComplaintStatus s) => switch (s) {
        ComplaintStatus.open => Colors.red,
        ComplaintStatus.inProgress => Colors.orange,
        ComplaintStatus.resolved => Colors.green,
        ComplaintStatus.closed => Colors.grey,
      };
}
