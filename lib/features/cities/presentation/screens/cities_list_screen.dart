// Author: PAMS Development Team
// File: cities_list_screen.dart
// Purpose: Manager/admin screen for listing and adding cities the business
// operates in. Implements the PAMS spec requirement that a manager can
// "expand the business in other cities".

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/security/rbac.dart';
import '../../../../core/services/city_service.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class CitiesListScreen extends StatefulWidget {
  const CitiesListScreen({super.key});

  @override
  State<CitiesListScreen> createState() => _CitiesListScreenState();
}

class _CitiesListScreenState extends State<CitiesListScreen> {
  final _service = CityService();
  List<String> _cities = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final cities = await _service.list();
      if (!mounted) return;
      setState(() {
        _cities = cities;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(_friendly(e))));
    }
  }

  Future<void> _openAddDialog() async {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final added = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add new city'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'City name',
              hintText: 'e.g. Edinburgh',
            ),
            textCapitalization: TextCapitalization.words,
            validator: (v) {
              if (v == null || v.trim().length < 2) {
                return 'Enter a city name (min 2 characters)';
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              if (!(formKey.currentState?.validate() ?? false)) return;
              try {
                await _service.add(controller.text);
                if (ctx.mounted) Navigator.pop(ctx, true);
              } catch (e) {
                if (ctx.mounted) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    SnackBar(content: Text(_friendly(e))),
                  );
                }
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
    if (added == true) await _load();
  }

  Future<void> _remove(String name) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Remove "$name"?'),
        content: const Text(
            'The city will only be removed if it is not used by any '
            'apartment, tenant, or user.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Remove')),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await _service.remove(name);
      await _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(_friendly(e))));
    }
  }

  String _friendly(Object e) {
    if (e is ArgumentError) return e.message?.toString() ?? e.toString();
    if (e is StateError) return e.message;
    return e.toString();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    final canExpand = Rbac.can(user, Permission.expandBusiness);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cities'),
      ),
      floatingActionButton: canExpand
          ? FloatingActionButton.extended(
              onPressed: _openAddDialog,
              icon: const Icon(Icons.add_location_alt),
              label: const Text('Expand to new city'),
            )
          : null,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _cities.isEmpty
              ? const Center(child: Text('No cities configured.'))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _cities.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (ctx, i) {
                    final name = _cities[i];
                    return ListTile(
                      leading: const Icon(Icons.location_city),
                      title: Text(name),
                      trailing: canExpand
                          ? IconButton(
                              icon: const Icon(Icons.delete_outline),
                              tooltip: 'Remove city',
                              onPressed: () => _remove(name),
                            )
                          : null,
                    );
                  },
                ),
    );
  }
}
