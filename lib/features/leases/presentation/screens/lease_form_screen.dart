// Author: Alec Brothwood (23076824) - Project Manager
// Author: Ashley Shoniwa (24021297) - Frontend Developer
// Author: Saynab Saleh (23000156) - System Analyst
// File: lease_form_screen.dart
// Purpose: Create a new lease agreement (tenant x apartment).

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/models/apartment_model.dart';
import '../../../../core/models/tenant_model.dart';
import '../../../../core/services/apartment_service.dart';
import '../../../../core/services/lease_service.dart';
import '../../../../core/services/tenant_service.dart';

class LeaseFormScreen extends StatefulWidget {
  const LeaseFormScreen({super.key});

  @override
  State<LeaseFormScreen> createState() => _LeaseFormScreenState();
}

class _LeaseFormScreenState extends State<LeaseFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tenantSvc = TenantService();
  final _aptSvc = ApartmentService();
  final _leaseSvc = LeaseService();

  List<TenantModel> _tenants = [];
  List<ApartmentModel> _vacant = [];
  TenantModel? _tenant;
  ApartmentModel? _apartment;
  DateTime _start = DateTime.now();
  DateTime _end = DateTime.now().add(const Duration(days: 365));
  late final TextEditingController _deposit;
  late final TextEditingController _terms;
  bool _loading = true;
  bool _saving = false;
  static final _df = DateFormat('dd MMM yyyy');

  @override
  void initState() {
    super.initState();
    _deposit = TextEditingController(text: '0');
    _terms = TextEditingController();
    _load();
  }

  Future<void> _load() async {
    _tenants = await _tenantSvc.getAll();
    _vacant = await _aptSvc.getAll(status: ApartmentStatus.vacant);
    setState(() => _loading = false);
  }

  @override
  void dispose() {
    _deposit.dispose();
    _terms.dispose();
    super.dispose();
  }

  Future<void> _pickDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _start : _end,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _start = picked;
          if (!_end.isAfter(_start)) {
            _end = _start.add(const Duration(days: 365));
          }
        } else {
          _end = picked;
        }
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_tenant == null || _apartment == null) return;
    setState(() => _saving = true);
    try {
      await _leaseSvc.create(
        tenantId: _tenant!.id,
        apartmentId: _apartment!.id,
        startDate: _start,
        endDate: _end,
        rentAmount: _apartment!.rentAmount,
        depositAmount: double.parse(_deposit.text),
        terms: _terms.text.isEmpty ? null : _terms.text,
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
      appBar: AppBar(title: const Text('New Lease')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<TenantModel>(
                initialValue: _tenant,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Tenant *'),
                items: [
                  for (final t in _tenants)
                    DropdownMenuItem(
                        value: t,
                        child: Text('${t.fullName} · ${t.city} · ${t.email}')),
                ],
                validator: (v) => v == null ? 'Select a tenant' : null,
                onChanged: (v) => setState(() => _tenant = v),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<ApartmentModel>(
                initialValue: _apartment,
                isExpanded: true,
                decoration:
                    const InputDecoration(labelText: 'Vacant apartment *'),
                items: [
                  for (final a in _vacant)
                    DropdownMenuItem(
                      value: a,
                      child: Text(
                          '${a.apartmentNumber} · ${a.city} · ${a.type} · £${a.rentAmount.toStringAsFixed(0)}/mo'),
                    ),
                ],
                validator: (v) => v == null ? 'Select an apartment' : null,
                onChanged: (v) => setState(() => _apartment = v),
              ),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                    child: _dateField('Start date', _start, () => _pickDate(true))),
                const SizedBox(width: 16),
                Expanded(
                    child: _dateField('End date', _end, () => _pickDate(false))),
              ]),
              const SizedBox(height: 12),
              TextFormField(
                controller: _deposit,
                decoration: const InputDecoration(labelText: 'Deposit (£)'),
                keyboardType: TextInputType.number,
                validator: (v) {
                  final n = double.tryParse(v ?? '');
                  if (n == null || n < 0) return 'Invalid deposit';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _terms,
                maxLines: 4,
                decoration: const InputDecoration(
                    labelText: 'Additional terms (optional)'),
              ),
              const SizedBox(height: 20),
              Row(children: [
                OutlinedButton(
                    onPressed: _saving
                        ? null
                        : () => Navigator.of(context).pop(),
                    child: const Text('Cancel')),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _saving ? null : _save,
                  icon: const Icon(Icons.save),
                  label: const Text('Create lease'),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dateField(String label, DateTime value, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: const Icon(Icons.calendar_today),
        ),
        child: Text(_df.format(value)),
      ),
    );
  }
}
