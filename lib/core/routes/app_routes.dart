// Author: PAMS Development Team
// File: app_routes.dart
// Purpose: Central route table for PAMS.

import 'package:flutter/material.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/tenants/presentation/screens/tenants_list_screen.dart';
import '../../features/apartments/presentation/screens/apartments_list_screen.dart';
import '../../features/leases/presentation/screens/leases_list_screen.dart';
import '../../features/payments/presentation/screens/billing_screen.dart';
import '../../features/maintenance/presentation/screens/maintenance_list_screen.dart';
import '../../features/complaints/presentation/screens/complaints_list_screen.dart';
import '../../features/users/presentation/screens/users_list_screen.dart';
import '../../features/reports/presentation/screens/reports_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String tenants = '/tenants';
  static const String apartments = '/apartments';
  static const String leases = '/leases';
  static const String payments = '/payments';
  static const String maintenance = '/maintenance';
  static const String complaints = '/complaints';
  static const String reports = '/reports';
  static const String users = '/users';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return _buildRoute(const SplashScreen(), settings);
      case login:
        return _buildRoute(const LoginScreen(), settings);
      case dashboard:
        return _buildRoute(const DashboardScreen(), settings);
      case tenants:
        return _buildRoute(const TenantsListScreen(), settings);
      case apartments:
        return _buildRoute(const ApartmentsListScreen(), settings);
      case leases:
        return _buildRoute(const LeasesListScreen(), settings);
      case payments:
        return _buildRoute(const BillingScreen(), settings);
      case maintenance:
        return _buildRoute(const MaintenanceListScreen(), settings);
      case complaints:
        return _buildRoute(const ComplaintsListScreen(), settings);
      case reports:
        return _buildRoute(const ReportsScreen(), settings);
      case users:
        return _buildRoute(const UsersListScreen(), settings);
      default:
        return _buildRoute(
          Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
          settings,
        );
    }
  }

  static PageRoute _buildRoute(Widget screen, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, _) => screen,
      transitionsBuilder: (context, animation, _, child) {
        return FadeTransition(opacity: animation, child: child);
      },
      transitionDuration: const Duration(milliseconds: 200),
    );
  }
}
