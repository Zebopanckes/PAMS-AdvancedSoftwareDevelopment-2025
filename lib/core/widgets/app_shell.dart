// Author: Alec Brothwood (23076824) - Project Manager
// Author: Ashley Shoniwa (24021297) - Frontend Developer
// File: app_shell.dart
// Purpose: Common scaffold with side navigation for all authenticated pages.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../models/user_model.dart';
import '../routes/app_routes.dart';
import '../security/rbac.dart';
import '../theme/app_theme.dart';

class AppShell extends StatelessWidget {
  final String title;
  final Widget child;
  final List<Widget> actions;
  final Widget? floatingActionButton;

  const AppShell({
    super.key,
    required this.title,
    required this.child,
    this.actions = const [],
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;
    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.login);
      });
      return const Scaffold(body: SizedBox.shrink());
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          ...actions,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(user.fullName,
                        style: const TextStyle(fontSize: 13)),
                    Text(
                      '${user.role.display}${user.city != null ? " · ${user.city}" : ''}',
                      style: const TextStyle(
                          fontSize: 11, color: Colors.white70),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.white24,
                  child: Text(user.fullName[0].toUpperCase(),
                      style: const TextStyle(color: Colors.white)),
                ),
                const SizedBox(width: 8),
                IconButton(
                  tooltip: 'Logout',
                  icon: const Icon(Icons.logout),
                  onPressed: () async {
                    await auth.logout();
                    if (context.mounted) {
                      Navigator.of(context)
                          .pushReplacementNamed(AppRoutes.login);
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      body: Row(
        children: [
          _SideNav(user: user),
          Expanded(
            child: Container(
              color: AppTheme.lightGrey,
              child: child,
            ),
          ),
        ],
      ),
      floatingActionButton: floatingActionButton,
    );
  }
}

class _SideNav extends StatelessWidget {
  final UserModel user;
  const _SideNav({required this.user});

  @override
  Widget build(BuildContext context) {
    final currentRoute = ModalRoute.of(context)?.settings.name;
    final items = <_NavItem>[
      _NavItem(Icons.dashboard, 'Dashboard', AppRoutes.dashboard, true),
      _NavItem(
        Icons.people,
        'Tenants',
        AppRoutes.tenants,
        Rbac.can(user, Permission.viewTenants),
      ),
      _NavItem(
        Icons.apartment,
        'Apartments',
        AppRoutes.apartments,
        Rbac.can(user, Permission.viewApartments),
      ),
      _NavItem(
        Icons.assignment,
        'Leases',
        AppRoutes.leases,
        Rbac.can(user, Permission.viewLeases),
      ),
      _NavItem(
        Icons.receipt_long,
        'Billing',
        AppRoutes.payments,
        Rbac.can(user, Permission.viewPayments),
      ),
      _NavItem(
        Icons.build,
        'Maintenance',
        AppRoutes.maintenance,
        Rbac.can(user, Permission.viewMaintenance),
      ),
      _NavItem(
        Icons.report_problem,
        'Complaints',
        AppRoutes.complaints,
        Rbac.can(user, Permission.viewComplaints),
      ),
      _NavItem(
        Icons.assessment,
        'Reports',
        AppRoutes.reports,
        Rbac.can(user, Permission.viewReports),
      ),
      _NavItem(
        Icons.manage_accounts,
        'Users',
        AppRoutes.users,
        Rbac.can(user, Permission.manageUsers),
      ),
    ];

    return Container(
      width: 220,
      color: Colors.white,
      child: Column(
        children: [
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.calmBlue,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.home_work, color: Colors.white),
                ),
                const SizedBox(width: 12),
                const Text(
                  'PAMS',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: ListView(
              children: [
                for (final item in items)
                  if (item.visible)
                    _NavTile(
                      icon: item.icon,
                      label: item.label,
                      selected: currentRoute == item.route,
                      onTap: () {
                        if (currentRoute != item.route) {
                          Navigator.of(context)
                              .pushReplacementNamed(item.route);
                        }
                      },
                    ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  final String route;
  final bool visible;
  _NavItem(this.icon, this.label, this.route, this.visible);
}

class _NavTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavTile({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Material(
        color: selected ? AppTheme.paleBlue : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Icon(icon,
                    size: 20,
                    color: selected
                        ? AppTheme.calmBlue
                        : AppTheme.textSecondary),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: TextStyle(
                    color: selected
                        ? AppTheme.calmBlue
                        : AppTheme.textPrimary,
                    fontWeight:
                        selected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
