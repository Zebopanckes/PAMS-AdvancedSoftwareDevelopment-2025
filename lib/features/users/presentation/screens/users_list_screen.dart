// Author: Alec Brothwood (23076824) - Project Manager
// Author: Ashley Shoniwa (24021297) - Frontend Developer
// Author: Saynab Saleh (23000156) - System Analyst
// File: users_list_screen.dart
// Purpose: Admin-only staff account management.

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../core/models/user_model.dart';
import '../../../../core/security/rbac.dart';
import '../../../../core/services/city_service.dart';
import '../../../../core/services/user_service.dart';
import '../../../../core/widgets/app_shell.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class UsersListScreen extends StatefulWidget {
  const UsersListScreen({super.key});

  @override
  State<UsersListScreen> createState() => _UsersListScreenState();
}

class _UsersListScreenState extends State<UsersListScreen> {
  final _service = UserService();
  final _cityService = CityService();
  List<UserModel> _users = [];
  List<String> _cities = const ['Bristol', 'Cardiff', 'London', 'Manchester'];
  bool _loading = true;
  static final _date = DateFormat('dd MMM yyyy HH:mm');

  @override
  void initState() {
    super.initState();
    _load();
    _cityService.list().then((list) {
      if (!mounted || list.isEmpty) return;
      setState(() => _cities = list);
    });
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    _users = await _service.getAll();
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _createDialog() async {
    final username = TextEditingController();
    final email = TextEditingController();
    final fullName = TextEditingController();
    final password = TextEditingController();
    UserRole role = UserRole.frontDesk;
    String? city = 'Bristol';
    await showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          title: const Text('New staff account'),
          content: SizedBox(
            width: 440,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              TextField(
                  controller: username,
                  decoration: const InputDecoration(labelText: 'Username')),
              const SizedBox(height: 8),
              TextField(
                  controller: fullName,
                  decoration: const InputDecoration(labelText: 'Full name')),
              const SizedBox(height: 8),
              TextField(
                  controller: email,
                  decoration: const InputDecoration(labelText: 'Email')),
              const SizedBox(height: 8),
              TextField(
                  controller: password,
                  obscureText: true,
                  decoration: const InputDecoration(
                      labelText: 'Initial password (≥8 chars)')),
              const SizedBox(height: 8),
              DropdownButtonFormField<UserRole>(
                initialValue: role,
                decoration: const InputDecoration(labelText: 'Role'),
                items: UserRole.values
                    .map((r) =>
                        DropdownMenuItem(value: r, child: Text(r.display)))
                    .toList(),
                onChanged: (v) => setLocal(() => role = v ?? role),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String?>(
                initialValue: city,
                decoration: const InputDecoration(labelText: 'City'),
                items: [
                  const DropdownMenuItem(value: null, child: Text('No city')),
                  ..._cities.map(
                    (c) => DropdownMenuItem(value: c, child: Text(c)),
                  ),
                ],
                onChanged: (v) => setLocal(() => city = v),
              ),
            ]),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel')),
            FilledButton(
              onPressed: () async {
                try {
                  await _service.create(
                    username: username.text,
                    email: email.text,
                    password: password.text,
                    role: role,
                    fullName: fullName.text,
                    city: city,
                  );
                  if (ctx.mounted) Navigator.pop(ctx);
                  _load();
                } catch (e) {
                  if (ctx.mounted) {
                    ScaffoldMessenger.of(ctx).showSnackBar(
                        SnackBar(content: Text('$e')));
                  }
                }
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _resetPassword(UserModel u) async {
    final ctrl = TextEditingController();
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Reset password for ${u.username}'),
        content: TextField(
          controller: ctrl,
          obscureText: true,
          decoration:
              const InputDecoration(labelText: 'New password (≥8 chars)'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              try {
                await _service.resetPassword(u.id, ctrl.text);
                if (ctx.mounted) Navigator.pop(ctx);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Password reset successfully.')));
                }
              } catch (e) {
                if (ctx.mounted) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                      SnackBar(content: Text('$e')));
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final canManage = Rbac.can(auth.currentUser, Permission.manageUsers);
    if (!canManage) {
      return const AppShell(
        title: 'Users',
        child: Center(child: Text('Forbidden: admin access only.')),
      );
    }

    return AppShell(
      title: 'Users',
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createDialog,
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text('New user'),
      ),
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Username')),
                      DataColumn(label: Text('Name')),
                      DataColumn(label: Text('Role')),
                      DataColumn(label: Text('City')),
                      DataColumn(label: Text('Last login')),
                      DataColumn(label: Text('Active')),
                      DataColumn(label: Text('Actions')),
                    ],
                    rows: [
                      for (final u in _users)
                        DataRow(cells: [
                          DataCell(Text(u.username)),
                          DataCell(Text(u.fullName)),
                          DataCell(Text(u.role.display)),
                          DataCell(Text(u.city ?? '-')),
                          DataCell(Text(u.lastLogin == null
                              ? '-'
                              : _date.format(u.lastLogin!))),
                          DataCell(Switch(
                            value: u.isActive,
                            onChanged: (v) async {
                              await _service.setActive(u.id, v);
                              _load();
                            },
                          )),
                          DataCell(Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.lock_reset),
                                tooltip: 'Reset password',
                                onPressed: () => _resetPassword(u),
                              ),
                            ],
                          )),
                        ]),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
