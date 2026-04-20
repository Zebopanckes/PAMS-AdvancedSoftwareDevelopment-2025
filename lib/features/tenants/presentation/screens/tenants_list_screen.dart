// Author: PAMS Development Team
// File: tenants_list_screen.dart
// Purpose: Browse, search and manage tenants.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/models/tenant_model.dart';
import '../../../../core/security/rbac.dart';
import '../../../../core/services/tenant_service.dart';
import '../../../../core/widgets/app_shell.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import 'tenant_form_screen.dart';
import 'tenant_detail_screen.dart';

class TenantsListScreen extends StatefulWidget {
  const TenantsListScreen({super.key});

  @override
  State<TenantsListScreen> createState() => _TenantsListScreenState();
}

class _TenantsListScreenState extends State<TenantsListScreen> {
  final TenantService _service = TenantService();
  final TextEditingController _searchCtrl = TextEditingController();
  String? _cityFilter;
  TenantStatus? _statusFilter;
  Future<List<TenantModel>>? _future;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    setState(() {
      _future = _service.getAll(
        city: _cityFilter,
        status: _statusFilter,
        search: _searchCtrl.text,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final canCreate = Rbac.can(auth.currentUser, Permission.createTenant);

    return AppShell(
      title: 'Tenants',
      floatingActionButton: canCreate
          ? FloatingActionButton.extended(
              onPressed: () async {
                final created = await Navigator.of(context).push<bool>(
                    MaterialPageRoute(
                        builder: (_) => const TenantFormScreen()));
                if (created == true) _reload();
              },
              icon: const Icon(Icons.person_add),
              label: const Text('New Tenant'),
            )
          : null,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildFilters(),
            const SizedBox(height: 16),
            Expanded(
              child: FutureBuilder<List<TenantModel>>(
                future: _future,
                builder: (context, snap) {
                  if (!snap.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snap.hasError) {
                    return Center(child: Text('Error: ${snap.error}'));
                  }
                  final items = snap.data!;
                  if (items.isEmpty) {
                    return const Center(
                      child: Text('No tenants match the current filters.'),
                    );
                  }
                  return Card(
                    child: Scrollbar(
                      child: ListView.separated(
                        itemCount: items.length,
                        separatorBuilder: (_, __) =>
                            const Divider(height: 1),
                        itemBuilder: (_, i) =>
                            _TenantTile(tenant: items[i], onChanged: _reload),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        SizedBox(
          width: 320,
          child: TextField(
            controller: _searchCtrl,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Search name / email / NI / phone',
            ),
            onSubmitted: (_) => _reload(),
          ),
        ),
        DropdownButton<String?>(
          value: _cityFilter,
          hint: const Text('All cities'),
          items: const [
            DropdownMenuItem(value: null, child: Text('All cities')),
            DropdownMenuItem(value: 'Bristol', child: Text('Bristol')),
            DropdownMenuItem(value: 'Cardiff', child: Text('Cardiff')),
            DropdownMenuItem(value: 'London', child: Text('London')),
            DropdownMenuItem(value: 'Manchester', child: Text('Manchester')),
          ],
          onChanged: (v) {
            setState(() => _cityFilter = v);
            _reload();
          },
        ),
        DropdownButton<TenantStatus?>(
          value: _statusFilter,
          hint: const Text('All statuses'),
          items: [
            const DropdownMenuItem(value: null, child: Text('All statuses')),
            ...TenantStatus.values.map(
              (s) => DropdownMenuItem(value: s, child: Text(s.name)),
            ),
          ],
          onChanged: (v) {
            setState(() => _statusFilter = v);
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
}

class _TenantTile extends StatelessWidget {
  final TenantModel tenant;
  final VoidCallback onChanged;
  const _TenantTile({required this.tenant, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        child: Text(tenant.fullName[0].toUpperCase()),
      ),
      title: Text(tenant.fullName),
      subtitle: Text(
          '${tenant.email} · ${tenant.phone} · NI: ${tenant.niNumber} · ${tenant.city}'),
      trailing: Chip(
        label: Text(tenant.status.name),
        backgroundColor: _statusColor(tenant.status).withValues(alpha: 0.15),
        labelStyle: TextStyle(color: _statusColor(tenant.status)),
      ),
      onTap: () async {
        final changed = await Navigator.of(context).push<bool>(
          MaterialPageRoute(
            builder: (_) => TenantDetailScreen(tenantId: tenant.id),
          ),
        );
        if (changed == true) onChanged();
      },
    );
  }

  Color _statusColor(TenantStatus s) {
    switch (s) {
      case TenantStatus.active:
        return Colors.green;
      case TenantStatus.prospective:
        return Colors.blue;
      case TenantStatus.inactive:
        return Colors.grey;
      case TenantStatus.movedOut:
        return Colors.orange;
    }
  }
}
