// Author: PAMS Development Team
// File: tenant_form_screen.dart
// Purpose: Create or edit a tenant record.

import 'package:flutter/material.dart';
import '../../../../core/models/tenant_model.dart';
import '../../../../core/services/city_service.dart';
import '../../../../core/services/tenant_service.dart';

class TenantFormScreen extends StatefulWidget {
  final TenantModel? existing;
  const TenantFormScreen({super.key, this.existing});

  @override
  State<TenantFormScreen> createState() => _TenantFormScreenState();
}

class _TenantFormScreenState extends State<TenantFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = TenantService();

  late final TextEditingController _ni;
  late final TextEditingController _name;
  late final TextEditingController _email;
  late final TextEditingController _phone;
  late final TextEditingController _occupation;
  late final TextEditingController _refs;
  late final TextEditingController _reqs;
  late final TextEditingController _emergency;
  late final TextEditingController _leaseMonths;
  String _city = 'Bristol';
  TenantStatus _status = TenantStatus.prospective;
  bool _saving = false;
  List<String> _cities = const ['Bristol', 'Cardiff', 'London', 'Manchester'];

  @override
  void initState() {
    super.initState();
    final t = widget.existing;
    _ni = TextEditingController(text: t?.niNumber ?? '');
    _name = TextEditingController(text: t?.fullName ?? '');
    _email = TextEditingController(text: t?.email ?? '');
    _phone = TextEditingController(text: t?.phone ?? '');
    _occupation = TextEditingController(text: t?.occupation ?? '');
    _refs = TextEditingController(text: t?.references ?? '');
    _reqs = TextEditingController(text: t?.apartmentRequirements ?? '');
    _emergency = TextEditingController(text: t?.emergencyContact ?? '');
    _leaseMonths = TextEditingController(
        text: t?.leasePeriodMonths?.toString() ?? '12');
    if (t != null) {
      _city = t.city;
      _status = t.status;
    }
    CityService().list().then((list) {
      if (!mounted || list.isEmpty) return;
      setState(() {
        _cities = list;
        if (!_cities.contains(_city)) _city = _cities.first;
      });
    });
  }

  @override
  void dispose() {
    for (final c in [
      _ni,
      _name,
      _email,
      _phone,
      _occupation,
      _refs,
      _reqs,
      _emergency,
      _leaseMonths,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      if (widget.existing == null) {
        await _service.create(
          niNumber: _ni.text,
          fullName: _name.text,
          email: _email.text,
          phone: _phone.text,
          city: _city,
          occupation: _occupation.text.isEmpty ? null : _occupation.text,
          references: _refs.text.isEmpty ? null : _refs.text,
          apartmentRequirements: _reqs.text.isEmpty ? null : _reqs.text,
          leasePeriodMonths: int.tryParse(_leaseMonths.text),
          emergencyContact: _emergency.text.isEmpty ? null : _emergency.text,
          status: _status,
        );
      } else {
        await _service.update(widget.existing!.copyWith(
          fullName: _name.text,
          email: _email.text,
          phone: _phone.text,
          city: _city,
          occupation: _occupation.text,
          references: _refs.text,
          apartmentRequirements: _reqs.text,
          leasePeriodMonths: int.tryParse(_leaseMonths.text),
          emergencyContact: _emergency.text,
          status: _status,
        ));
      }
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        final msg = _friendlyError(e);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(msg)));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String _friendlyError(Object e) {
    final raw = e.toString();
    if (e is ArgumentError) return e.message?.toString() ?? raw;
    if (e is StateError) return e.message;
    // Database unique-constraint fallback (older paths or other unique cols).
    if (raw.contains('UNIQUE constraint failed: tenants.ni_number')) {
      return 'A tenant with this NI number already exists.';
    }
    if (raw.contains('UNIQUE constraint failed')) {
      return 'This record conflicts with an existing entry.';
    }
    return raw;
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Edit Tenant' : 'New Tenant')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _row([
                _field(_ni, 'National Insurance #', required: true,
                    validator: (v) {
                  if (v == null || v.isEmpty) return 'Required';
                  if (!TenantModel.isValidNiNumber(v)) {
                    return 'Invalid UK NI number (e.g. AB123456C)';
                  }
                  return null;
                }, enabled: !isEdit),
                _field(_name, 'Full Name', required: true),
              ]),
              _row([
                _field(_email, 'Email', required: true, validator: (v) {
                  if (!TenantModel.isValidEmail(v ?? '')) return 'Invalid email';
                  return null;
                }),
                _field(_phone, 'Phone', required: true, validator: (v) {
                  if (!TenantModel.isValidUkPhone(v ?? '')) {
                    return 'Invalid UK phone';
                  }
                  return null;
                }),
              ]),
              _row([
                _field(_occupation, 'Occupation'),
                DropdownButtonFormField<String>(
                  initialValue:
                      _cities.contains(_city) ? _city : _cities.first,
                  decoration: const InputDecoration(labelText: 'City *'),
                  items: _cities
                      .map((c) =>
                          DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (v) =>
                      setState(() => _city = v ?? _cities.first),
                ),
              ]),
              _row([
                _field(_leaseMonths, 'Lease period (months)',
                    keyboardType: TextInputType.number,
                    validator: (v) {
                  final n = int.tryParse(v ?? '');
                  if (n == null || n <= 0) return 'Must be > 0';
                  return null;
                }),
                DropdownButtonFormField<TenantStatus>(
                  initialValue: _status,
                  decoration: const InputDecoration(labelText: 'Status'),
                  items: TenantStatus.values
                      .map((s) => DropdownMenuItem(
                          value: s, child: Text(s.name)))
                      .toList(),
                  onChanged: (v) => setState(
                      () => _status = v ?? TenantStatus.prospective),
                ),
              ]),
              _field(_reqs, 'Apartment requirements',
                  maxLines: 2,
                  hint: 'e.g. two-bedroom house near central Bristol'),
              _field(_refs, 'References', maxLines: 2),
              _field(_emergency, 'Emergency contact'),
              const SizedBox(height: 20),
              Row(
                children: [
                  OutlinedButton(
                    onPressed: _saving
                        ? null
                        : () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _saving ? null : _save,
                    icon: const Icon(Icons.save),
                    label: Text(isEdit ? 'Save changes' : 'Create tenant'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < children.length; i++) ...[
            Expanded(child: children[i]),
            if (i != children.length - 1) const SizedBox(width: 16),
          ],
        ],
      ),
    );
  }

  Widget _field(
    TextEditingController c,
    String label, {
    bool required = false,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? hint,
    bool enabled = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: c,
        enabled: enabled,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: required ? '$label *' : label,
          hintText: hint,
        ),
        validator: validator ??
            (required
                ? (v) => (v == null || v.trim().isEmpty) ? 'Required' : null
                : null),
      ),
    );
  }
}
