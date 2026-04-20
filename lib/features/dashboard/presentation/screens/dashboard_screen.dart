// Author: PAMS Development Team
// File: dashboard_screen.dart
// Purpose: Landing page with live KPIs and role-aware quick actions.

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../../../core/models/user_model.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/security/rbac.dart';
import '../../../../core/services/report_service.dart';
import '../../../../core/widgets/app_shell.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../widgets/dashboard_card.dart';
import '../widgets/stat_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _reports = ReportService();
  Future<Map<String, num>>? _future;

  @override
  void initState() {
    super.initState();
    _future = _reports.dashboardStats();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;
    if (user == null) return const SizedBox.shrink();

    return AppShell(
      title: 'Dashboard',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome back, ${user.fullName}!',
              style: Theme.of(context).textTheme.displaySmall,
            )
                .animate()
                .fadeIn(duration: 300.ms)
                .slideY(begin: -0.2, end: 0),
            const SizedBox(height: 8),
            Text(
              '${user.role.display}${user.city != null ? " · ${user.city}" : ''}',
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(color: const Color(0xFF6B7280)),
            ).animate().fadeIn(delay: 100.ms),
            const SizedBox(height: 32),
            FutureBuilder<Map<String, num>>(
              future: _future,
              builder: (_, snap) {
                final s = snap.data ??
                    const {
                      'totalApartments': 0,
                      'occupied': 0,
                      'pendingPayments': 0,
                      'maintenanceOpen': 0,
                      'activeTenants': 0,
                    };
                return GridView.count(
                  crossAxisCount: 4,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    StatCard(
                      title: 'Total Apartments',
                      value: s['totalApartments'].toString(),
                      icon: Icons.apartment,
                      color: const Color(0xFF2563EB),
                      delay: 150,
                    ),
                    StatCard(
                      title: 'Occupied',
                      value: s['occupied'].toString(),
                      icon: Icons.check_circle,
                      color: const Color(0xFF10B981),
                      delay: 200,
                    ),
                    StatCard(
                      title: 'Active Tenants',
                      value: s['activeTenants'].toString(),
                      icon: Icons.people,
                      color: const Color(0xFF3B82F6),
                      delay: 250,
                    ),
                    StatCard(
                      title: 'Pending Invoices',
                      value: s['pendingPayments'].toString(),
                      icon: Icons.receipt_long,
                      color: const Color(0xFFFBBF24),
                      delay: 300,
                    ),
                    StatCard(
                      title: 'Open Maintenance',
                      value: s['maintenanceOpen'].toString(),
                      icon: Icons.build,
                      color: const Color(0xFFF97316),
                      delay: 350,
                    ),
                    StatCard(
                      title: 'Vacant',
                      value: s['vacant'].toString(),
                      icon: Icons.home_outlined,
                      color: const Color(0xFF6B7280),
                      delay: 400,
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 32),
            Text(
              'Quick actions',
              style: Theme.of(context).textTheme.headlineMedium,
            ).animate().fadeIn(delay: 500.ms),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 3,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.5,
              children: [
                if (Rbac.can(user, Permission.viewTenants))
                  DashboardCard(
                    title: 'Tenants',
                    icon: Icons.people,
                    color: const Color(0xFF3B82F6),
                    onTap: () => Navigator.of(context)
                        .pushNamed(AppRoutes.tenants),
                    delay: 550,
                  ),
                if (Rbac.can(user, Permission.viewApartments))
                  DashboardCard(
                    title: 'Apartments',
                    icon: Icons.apartment,
                    color: const Color(0xFF2563EB),
                    onTap: () => Navigator.of(context)
                        .pushNamed(AppRoutes.apartments),
                    delay: 600,
                  ),
                if (Rbac.can(user, Permission.viewLeases))
                  DashboardCard(
                    title: 'Leases',
                    icon: Icons.assignment,
                    color: const Color(0xFF7C3AED),
                    onTap: () => Navigator.of(context)
                        .pushNamed(AppRoutes.leases),
                    delay: 650,
                  ),
                if (Rbac.can(user, Permission.viewPayments))
                  DashboardCard(
                    title: 'Billing',
                    icon: Icons.receipt_long,
                    color: const Color(0xFFFBBF24),
                    onTap: () => Navigator.of(context)
                        .pushNamed(AppRoutes.payments),
                    delay: 700,
                  ),
                if (Rbac.can(user, Permission.viewMaintenance))
                  DashboardCard(
                    title: 'Maintenance',
                    icon: Icons.build,
                    color: const Color(0xFFF97316),
                    onTap: () => Navigator.of(context)
                        .pushNamed(AppRoutes.maintenance),
                    delay: 750,
                  ),
                if (Rbac.can(user, Permission.viewComplaints))
                  DashboardCard(
                    title: 'Complaints',
                    icon: Icons.report_problem,
                    color: const Color(0xFFEF4444),
                    onTap: () => Navigator.of(context)
                        .pushNamed(AppRoutes.complaints),
                    delay: 800,
                  ),
                if (Rbac.can(user, Permission.viewReports))
                  DashboardCard(
                    title: 'Reports',
                    icon: Icons.assessment,
                    color: const Color(0xFF60A5FA),
                    onTap: () => Navigator.of(context)
                        .pushNamed(AppRoutes.reports),
                    delay: 850,
                  ),
                if (Rbac.can(user, Permission.manageUsers))
                  DashboardCard(
                    title: 'Users',
                    icon: Icons.manage_accounts,
                    color: const Color(0xFF6B7280),
                    onTap: () => Navigator.of(context)
                        .pushNamed(AppRoutes.users),
                    delay: 900,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
