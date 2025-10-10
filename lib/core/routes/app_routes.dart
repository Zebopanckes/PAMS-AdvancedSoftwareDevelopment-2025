import 'package:flutter/material.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/tenants/presentation/screens/tenants_list_screen.dart';
import '../../features/apartments/presentation/screens/apartments_list_screen.dart';
import '../../features/payments/presentation/screens/payments_list_screen.dart';
import '../../features/maintenance/presentation/screens/maintenance_list_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String tenants = '/tenants';
  static const String apartments = '/apartments';
  static const String payments = '/payments';
  static const String maintenance = '/maintenance';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return _buildRoute(const SplashScreen());
      case login:
        return _buildRoute(const LoginScreen());
      case dashboard:
        return _buildRoute(const DashboardScreen());
      case tenants:
        return _buildRoute(const TenantsListScreen());
      case apartments:
        return _buildRoute(const ApartmentsListScreen());
      case payments:
        return _buildRoute(const PaymentsListScreen());
      case maintenance:
        return _buildRoute(const MaintenanceListScreen());
      default:
        return _buildRoute(
          Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }

  static PageRoute _buildRoute(Widget screen) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => screen,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;
        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);
        return SlideTransition(position: offsetAnimation, child: child);
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}
