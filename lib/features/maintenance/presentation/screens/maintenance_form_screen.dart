// Author: PAMS Development Team
// File: maintenance_form_screen.dart
// Purpose: Log a new maintenance request.

import 'package:flutter/material.dart';
import '../../../../core/models/apartment_model.dart';
import '../../../../core/models/maintenance_model.dart';
import '../../../../core/services/apartment_service.dart';
import '../../../../core/services/maintenance_service.dart';

class MaintenanceFormScreen extends StatefulWidget {
  const MaintenanceFormScreen({super.key});

  @override
  State<MaintenanceFormScreen> createState() => _MaintenanceFormScreenState();
}

class _MaintenanceFormScreenState extends State<MaintenanceFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = MaintenanceService();
  final _aptSvc = ApartmentService();
  List<ApartmentModel> _apartments = [];
  ApartmentModel? _apartment;
  MaintenancePriority _priority = MaintenancePriority.medium;
  final _title = TextEditingController();
  final _desc = TextEditingController();
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    _apartments = await _aptSvc.getAll();
    setState(() => _loading = false);
  }

  @override
  void dispose() {
    _title.dispose();
    _desc.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_apartment == null) return;
    setState(() => _saving = true);
    try {
      await _service.create(
        apartmentId: _apartment!.id,
        title: _title.text,
        description: _desc.text,
        priority: _priority,
      );
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('$e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(title: const Text('New Maintenance Request')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: ListView(children: [
            DropdownButtonFormField<ApartmentModel>(
              initialValue: _apartment,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Apartment *'),
              items: [
                for (final a in _apartments)
                  DropdownMenuItem(
                      value: a,
                      child: Text('${a.apartmentNumber} · ${a.city}')),
              ],
              validator: (v) => v == null ? 'Required' : null,
              onChanged: (v) => setState(() => _apartment = v),
            ),
            const SizedBox(height: 12),
            TextFormField(
                controller: _title,
                decoration: const InputDecoration(labelText: 'Title *'),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Required' : null),
            const SizedBox(height: 12),
            TextFormField(
                controller: _desc,
                maxLines: 4,
                decoration: const InputDecoration(labelText: 'Description *'),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Required' : null),
            const SizedBox(height: 12),
            DropdownButtonFormField<MaintenancePriority>(
              initialValue: _priority,
              decoration: const InputDecoration(labelText: 'Priority'),
              items: MaintenancePriority.values
                  .map((p) =>
                      DropdownMenuItem(value: p, child: Text(p.name)))
                  .toList(),
              onChanged: (v) => setState(() => _priority = v ?? _priority),
            ),
            const SizedBox(height: 20),
            Row(children: [
              OutlinedButton(
                  onPressed:
                      _saving ? null : () => Navigator.of(context).pop(),
                  child: const Text('Cancel')),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: _saving ? null : _save,
                icon: const Icon(Icons.save),
                label: const Text('Log request'),
              ),
            ]),
          ]),
        ),
      ),
    );
  }
}
