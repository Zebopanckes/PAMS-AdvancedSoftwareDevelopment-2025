// Author: Alec Brothwood (23076824) - Project Manager
// Author: Ashley Shoniwa (24021297) - Frontend Developer
// Author: Okan Kaynak (23035729) - Quality & Documentation Specialist
// File: reports_screen.dart
// Purpose: Occupancy, financial and maintenance reports across cities.

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/services/report_service.dart';
import '../../../../core/widgets/app_shell.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final _svc = ReportService();
  Future<_Data>? _future;
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

  Future<_Data> _load() async {
    final occ = await _svc.occupancyByCity();
    final fin = await _svc.financialByCity();
    final maint = await _svc.maintenanceCostByCity();
    return _Data(occ, fin, maint);
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: 'Reports',
      actions: [
        IconButton(
            icon: const Icon(Icons.refresh), onPressed: _reload),
      ],
      child: FutureBuilder<_Data>(
        future: _future,
        builder: (_, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final d = snap.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Occupancy by City',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                _occupancyChart(d),
                const SizedBox(height: 12),
                _occupancyTable(d),
                const SizedBox(height: 32),
                Text('Financial Performance by City',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                _financialTable(d),
                const SizedBox(height: 32),
                Text('Maintenance Costs by City',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                _maintenanceTable(d),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _occupancyChart(_Data d) {
    if (d.occ.isEmpty) return const Card(child: Padding(padding: EdgeInsets.all(16), child: Text('No data')));
    return SizedBox(
      height: 240,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: BarChart(BarChartData(
            alignment: BarChartAlignment.spaceAround,
            titlesData: FlTitlesData(
              leftTitles: const AxisTitles(
                  sideTitles:
                      SideTitles(showTitles: true, reservedSize: 30)),
              rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false)),
              topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (v, _) {
                    final i = v.toInt();
                    if (i < 0 || i >= d.occ.length) {
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(d.occ[i].city,
                          style: const TextStyle(fontSize: 11)),
                    );
                  },
                ),
              ),
            ),
            borderData: FlBorderData(show: false),
            barGroups: [
              for (int i = 0; i < d.occ.length; i++)
                BarChartGroupData(x: i, barRods: [
                  BarChartRodData(
                      toY: d.occ[i].occupied.toDouble(),
                      color: Colors.green,
                      width: 14),
                  BarChartRodData(
                      toY: d.occ[i].vacant.toDouble(),
                      color: Colors.blue,
                      width: 14),
                  BarChartRodData(
                      toY: d.occ[i].maintenance.toDouble(),
                      color: Colors.orange,
                      width: 14),
                ]),
            ],
          )),
        ),
      ),
    );
  }

  Widget _occupancyTable(_Data d) {
    return Card(
      child: DataTable(
        columns: const [
          DataColumn(label: Text('City')),
          DataColumn(label: Text('Total'), numeric: true),
          DataColumn(label: Text('Occupied'), numeric: true),
          DataColumn(label: Text('Vacant'), numeric: true),
          DataColumn(label: Text('Maintenance'), numeric: true),
          DataColumn(label: Text('Rate'), numeric: true),
        ],
        rows: [
          for (final r in d.occ)
            DataRow(cells: [
              DataCell(Text(r.city)),
              DataCell(Text(r.total.toString())),
              DataCell(Text(r.occupied.toString())),
              DataCell(Text(r.vacant.toString())),
              DataCell(Text(r.maintenance.toString())),
              DataCell(Text('${(r.occupancyRate * 100).toStringAsFixed(1)}%')),
            ]),
        ],
      ),
    );
  }

  Widget _financialTable(_Data d) {
    return Card(
      child: DataTable(
        columns: const [
          DataColumn(label: Text('City')),
          DataColumn(label: Text('Collected'), numeric: true),
          DataColumn(label: Text('Outstanding'), numeric: true),
        ],
        rows: [
          for (final r in d.fin)
            DataRow(cells: [
              DataCell(Text(r.city)),
              DataCell(Text(_currency.format(r.collected))),
              DataCell(Text(_currency.format(r.outstanding))),
            ]),
        ],
      ),
    );
  }

  Widget _maintenanceTable(_Data d) {
    return Card(
      child: DataTable(
        columns: const [
          DataColumn(label: Text('City')),
          DataColumn(label: Text('Requests'), numeric: true),
          DataColumn(label: Text('Hours'), numeric: true),
          DataColumn(label: Text('Cost'), numeric: true),
        ],
        rows: [
          for (final r in d.maint)
            DataRow(cells: [
              DataCell(Text(r.city)),
              DataCell(Text(r.requests.toString())),
              DataCell(Text(r.totalHours.toStringAsFixed(1))),
              DataCell(Text(_currency.format(r.totalCost))),
            ]),
        ],
      ),
    );
  }
}

class _Data {
  final List<OccupancyRow> occ;
  final List<FinancialRow> fin;
  final List<MaintenanceCostRow> maint;
  _Data(this.occ, this.fin, this.maint);
}
