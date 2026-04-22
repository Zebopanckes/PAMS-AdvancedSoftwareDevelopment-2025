// Author: PAMS Development Team
// File: apartments_list_screen.dart
// Purpose: Browse, filter and manage apartments.

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../core/models/apartment_model.dart';
import '../../../../core/security/rbac.dart';
import '../../../../core/services/apartment_service.dart';
import '../../../../core/services/city_service.dart';
import '../../../../core/widgets/app_shell.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import 'apartment_form_screen.dart';

class ApartmentsListScreen extends StatefulWidget {
  const ApartmentsListScreen({super.key});

  @override
  State<ApartmentsListScreen> createState() => _ApartmentsListScreenState();
}

class _ApartmentsListScreenState extends State<ApartmentsListScreen> {
  final _service = ApartmentService();
  final _searchCtrl = TextEditingController();
  String? _cityFilter;
  ApartmentStatus? _statusFilter;
  int? _minBedrooms;
  Future<List<ApartmentModel>>? _future;
  List<String> _cities = const ['Bristol', 'Cardiff', 'London', 'Manchester'];

  @override
  void initState() {
    super.initState();
    _reload();
    CityService().list().then((list) {
      if (!mounted || list.isEmpty) return;
      setState(() => _cities = list);
    });
  }

  void _reload() {
    setState(() {
      _future = _service.getAll(
        city: _cityFilter,
        status: _statusFilter,
        minBedrooms: _minBedrooms,
        search: _searchCtrl.text,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final canManage = Rbac.can(auth.currentUser, Permission.manageApartments);
    return AppShell(
      title: 'Apartments',
      floatingActionButton: canManage
          ? FloatingActionButton.extended(
              onPressed: () async {
                final created = await Navigator.of(context).push<bool>(
                    MaterialPageRoute(
                        builder: (_) => const ApartmentFormScreen()));
                if (created == true) _reload();
              },
              icon: const Icon(Icons.add_home),
              label: const Text('New Apartment'),
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
              child: FutureBuilder<List<ApartmentModel>>(
                future: _future,
                builder: (_, snap) {
                  if (!snap.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final items = snap.data!;
                  if (items.isEmpty) {
                    return const Center(child: Text('No apartments.'));
                  }
                  return GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 360,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 1.25,
                    ),
                    itemCount: items.length,
                    itemBuilder: (_, i) =>
                        _ApartmentCard(a: items[i], canManage: canManage, onChanged: _reload),
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
          width: 280,
          child: TextField(
            controller: _searchCtrl,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Search number / location / type',
            ),
            onSubmitted: (_) => _reload(),
          ),
        ),
        DropdownButton<String?>(
          value: _cityFilter,
          hint: const Text('All cities'),
          items: [
            const DropdownMenuItem(value: null, child: Text('All cities')),
            ..._cities.map(
              (c) => DropdownMenuItem(value: c, child: Text(c)),
            ),
          ],
          onChanged: (v) {
            setState(() => _cityFilter = v);
            _reload();
          },
        ),
        DropdownButton<ApartmentStatus?>(
          value: _statusFilter,
          hint: const Text('Any status'),
          items: [
            const DropdownMenuItem(value: null, child: Text('Any status')),
            ...ApartmentStatus.values.map(
              (s) => DropdownMenuItem(value: s, child: Text(s.name)),
            ),
          ],
          onChanged: (v) {
            setState(() => _statusFilter = v);
            _reload();
          },
        ),
        DropdownButton<int?>(
          value: _minBedrooms,
          hint: const Text('Min bedrooms'),
          items: const [
            DropdownMenuItem(value: null, child: Text('Any beds')),
            DropdownMenuItem(value: 1, child: Text('1+')),
            DropdownMenuItem(value: 2, child: Text('2+')),
            DropdownMenuItem(value: 3, child: Text('3+')),
          ],
          onChanged: (v) {
            setState(() => _minBedrooms = v);
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

class _ApartmentCard extends StatelessWidget {
  final ApartmentModel a;
  final bool canManage;
  final VoidCallback onChanged;
  const _ApartmentCard(
      {required this.a, required this.canManage, required this.onChanged});

  static final _currency =
      NumberFormat.currency(locale: 'en_GB', symbol: '£');

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: canManage
            ? () async {
                final changed = await Navigator.of(context).push<bool>(
                  MaterialPageRoute(
                    builder: (_) => ApartmentFormScreen(existing: a),
                  ),
                );
                if (changed == true) onChanged();
              }
            : null,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.apartment, color: Theme.of(context).primaryColor),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${a.apartmentNumber} · ${a.type}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  _statusChip(a.status),
                ],
              ),
              const SizedBox(height: 6),
              Text('${a.location}, ${a.city}',
                  style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 8),
              Row(
                children: [
                  _kv(Icons.bed, '${a.bedrooms} bed'),
                  const SizedBox(width: 12),
                  _kv(Icons.bathtub, '${a.bathrooms} bath'),
                  const SizedBox(width: 12),
                  _kv(Icons.straighten, '${a.areaSqft.toStringAsFixed(0)} sqft'),
                ],
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_currency.format(a.rentAmount)}/mo',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text('Floor ${a.floor}'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _kv(IconData icon, String text) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          const SizedBox(width: 4),
          Text(text, style: const TextStyle(fontSize: 12)),
        ],
      );

  Widget _statusChip(ApartmentStatus s) {
    final color = switch (s) {
      ApartmentStatus.occupied => Colors.green,
      ApartmentStatus.vacant => Colors.blue,
      ApartmentStatus.maintenance => Colors.orange,
      ApartmentStatus.unavailable => Colors.grey,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(s.name, style: TextStyle(color: color, fontSize: 11)),
    );
  }
}
