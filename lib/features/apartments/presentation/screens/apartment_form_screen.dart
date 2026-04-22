// Author: PAMS Development Team
// File: apartment_form_screen.dart
// Purpose: Add or edit an apartment.

import 'package:flutter/material.dart';
import '../../../../core/models/apartment_model.dart';
import '../../../../core/services/apartment_service.dart';
import '../../../../core/services/city_service.dart';

class ApartmentFormScreen extends StatefulWidget {
  final ApartmentModel? existing;
  const ApartmentFormScreen({super.key, this.existing});

  @override
  State<ApartmentFormScreen> createState() => _ApartmentFormScreenState();
}

class _ApartmentFormScreenState extends State<ApartmentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = ApartmentService();

  late final TextEditingController _number;
  late final TextEditingController _location;
  late final TextEditingController _floor;
  late final TextEditingController _bedrooms;
  late final TextEditingController _bathrooms;
  late final TextEditingController _area;
  late final TextEditingController _rent;
  late final TextEditingController _description;

  String _city = 'Bristol';
  String _type = 'Studio';
  ApartmentStatus _status = ApartmentStatus.vacant;
  bool _saving = false;
  List<String> _cities = const ['Bristol', 'Cardiff', 'London', 'Manchester'];

  @override
  void initState() {
    super.initState();
    final a = widget.existing;
    _number = TextEditingController(text: a?.apartmentNumber ?? '');
    _location = TextEditingController(text: a?.location ?? '');
    _floor = TextEditingController(text: a?.floor.toString() ?? '1');
    _bedrooms = TextEditingController(text: a?.bedrooms.toString() ?? '1');
    _bathrooms = TextEditingController(text: a?.bathrooms.toString() ?? '1');
    _area = TextEditingController(text: a?.areaSqft.toString() ?? '500');
    _rent = TextEditingController(text: a?.rentAmount.toString() ?? '1000');
    _description = TextEditingController(text: a?.description ?? '');
    if (a != null) {
      _city = a.city;
      _type = a.type;
      _status = a.status;
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
      _number,
      _location,
      _floor,
      _bedrooms,
      _bathrooms,
      _area,
      _rent,
      _description,
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
          apartmentNumber: _number.text,
          city: _city,
          location: _location.text,
          type: _type,
          floor: int.parse(_floor.text),
          bedrooms: int.parse(_bedrooms.text),
          bathrooms: int.parse(_bathrooms.text),
          areaSqft: double.parse(_area.text),
          rentAmount: double.parse(_rent.text),
          status: _status,
          description: _description.text.isEmpty ? null : _description.text,
        );
      } else {
        await _service.update(widget.existing!.copyWith(
          apartmentNumber: _number.text,
          city: _city,
          location: _location.text,
          type: _type,
          floor: int.parse(_floor.text),
          bedrooms: int.parse(_bedrooms.text),
          bathrooms: int.parse(_bathrooms.text),
          areaSqft: double.parse(_area.text),
          rentAmount: double.parse(_rent.text),
          status: _status,
          description: _description.text,
        ));
      }
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
    final isEdit = widget.existing != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Apartment' : 'New Apartment'),
        actions: [
          if (isEdit)
            IconButton(
              icon: const Icon(Icons.delete_forever),
              onPressed: _saving
                  ? null
                  : () async {
                      final ok = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Delete apartment?'),
                          content: const Text(
                              'This also removes any lease, invoice and maintenance history.'),
                          actions: [
                            TextButton(
                                onPressed: () =>
                                    Navigator.pop(context, false),
                                child: const Text('Cancel')),
                            FilledButton(
                                style: FilledButton.styleFrom(
                                    backgroundColor: Colors.red),
                                onPressed: () =>
                                    Navigator.pop(context, true),
                                child: const Text('Delete')),
                          ],
                        ),
                      );
                      if (ok == true) {
                        await _service.delete(widget.existing!.id);
                        if (mounted) Navigator.of(context).pop(true);
                      }
                    },
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _row([
                _text(_number, 'Apartment #', required: true),
                _text(_location, 'Location / building', required: true),
              ]),
              _row([
                DropdownButtonFormField<String>(
                  initialValue: _cities.contains(_city) ? _city : _cities.first,
                  decoration: const InputDecoration(labelText: 'City *'),
                  items: _cities
                      .map((c) =>
                          DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (v) => setState(() => _city = v ?? _city),
                ),
                DropdownButtonFormField<String>(
                  initialValue: _type,
                  decoration: const InputDecoration(labelText: 'Type *'),
                  items: const [
                    DropdownMenuItem(value: 'Studio', child: Text('Studio')),
                    DropdownMenuItem(
                        value: '1-bed flat', child: Text('1-bed flat')),
                    DropdownMenuItem(
                        value: '2-bed flat', child: Text('2-bed flat')),
                    DropdownMenuItem(
                        value: '3-bed house', child: Text('3-bed house')),
                    DropdownMenuItem(
                        value: 'Penthouse', child: Text('Penthouse')),
                  ],
                  onChanged: (v) => setState(() => _type = v ?? _type),
                ),
              ]),
              _row([
                _text(_floor, 'Floor',
                    keyboardType: TextInputType.number, isInt: true),
                _text(_bedrooms, 'Bedrooms',
                    keyboardType: TextInputType.number, isInt: true),
                _text(_bathrooms, 'Bathrooms',
                    keyboardType: TextInputType.number, isInt: true),
              ]),
              _row([
                _text(_area, 'Area (sqft)',
                    keyboardType: TextInputType.number, isDouble: true),
                _text(_rent, 'Monthly rent (£)',
                    keyboardType: TextInputType.number, isDouble: true),
                DropdownButtonFormField<ApartmentStatus>(
                  initialValue: _status,
                  decoration: const InputDecoration(labelText: 'Status'),
                  items: ApartmentStatus.values
                      .map((s) =>
                          DropdownMenuItem(value: s, child: Text(s.name)))
                      .toList(),
                  onChanged: (v) => setState(() => _status = v ?? _status),
                ),
              ]),
              _text(_description, 'Description', maxLines: 3),
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
                    label: Text(isEdit ? 'Save changes' : 'Create apartment'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(List<Widget> children) => Padding(
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

  Widget _text(
    TextEditingController c,
    String label, {
    bool required = false,
    TextInputType? keyboardType,
    int maxLines = 1,
    bool isInt = false,
    bool isDouble = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: c,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(labelText: required ? '$label *' : label),
        validator: (v) {
          final s = v?.trim() ?? '';
          if (required && s.isEmpty) return 'Required';
          if (isInt && s.isNotEmpty && int.tryParse(s) == null) {
            return 'Enter an integer';
          }
          if (isDouble && s.isNotEmpty && double.tryParse(s) == null) {
            return 'Enter a number';
          }
          return null;
        },
      ),
    );
  }
}
