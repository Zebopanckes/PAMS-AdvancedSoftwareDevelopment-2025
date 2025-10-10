import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../widgets/dashboard_card.dart';
import '../widgets/stat_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  user?.fullName ?? 'User',
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.white24,
                  child: Text(
                    (user?.fullName ?? 'U')[0].toUpperCase(),
                    style: const TextStyle(fontSize: 14, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () async {
                    await authProvider.logout();
                    if (context.mounted) {
                      Navigator.of(context).pushReplacementNamed(AppRoutes.login);
                    }
                  },
                  tooltip: 'Logout',
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome back, ${user?.fullName ?? 'User'}!',
              style: Theme.of(context).textTheme.displaySmall,
            )
                .animate()
                .fadeIn(duration: 400.ms)
                .slideY(begin: -0.2, end: 0),
            const SizedBox(height: 8),
            Text(
              'Here\'s what\'s happening with your properties today.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: const Color(0xFF6B7280), // Text Secondary
                  ),
            )
                .animate()
                .fadeIn(delay: 100.ms, duration: 400.ms),
            const SizedBox(height: 32),
            
            // Statistics Cards
            GridView.count(
              crossAxisCount: 4,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: const [
                StatCard(
                  title: 'Total Apartments',
                  value: '48',
                  icon: Icons.apartment,
                  color: Color(0xFF2563EB), // Calm Blue
                  delay: 200,
                ),
                StatCard(
                  title: 'Occupied',
                  value: '42',
                  icon: Icons.check_circle,
                  color: Color(0xFF10B981), // Success Green
                  delay: 300,
                ),
                StatCard(
                  title: 'Pending Payments',
                  value: '12',
                  icon: Icons.payment,
                  color: Color(0xFFFBBF24), // Vibrant Yellow
                  delay: 400,
                ),
                StatCard(
                  title: 'Maintenance',
                  value: '5',
                  icon: Icons.build,
                  color: Color(0xFFF97316), // Bright Orange
                  delay: 500,
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.headlineMedium,
            )
                .animate()
                .fadeIn(delay: 600.ms),
            const SizedBox(height: 16),
            
            // Quick Action Cards
            GridView.count(
              crossAxisCount: 3,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.5,
              children: [
                DashboardCard(
                  title: 'Tenants',
                  icon: Icons.people,
                  color: const Color(0xFF3B82F6), // Mid Blue
                  onTap: () => Navigator.of(context).pushNamed(AppRoutes.tenants),
                  delay: 700,
                ),
                DashboardCard(
                  title: 'Apartments',
                  icon: Icons.apartment,
                  color: const Color(0xFF2563EB), // Calm Blue
                  onTap: () => Navigator.of(context).pushNamed(AppRoutes.apartments),
                  delay: 800,
                ),
                DashboardCard(
                  title: 'Payments',
                  icon: Icons.payment,
                  color: const Color(0xFFFBBF24), // Vibrant Yellow
                  onTap: () => Navigator.of(context).pushNamed(AppRoutes.payments),
                  delay: 900,
                ),
                DashboardCard(
                  title: 'Maintenance',
                  icon: Icons.build,
                  color: const Color(0xFFF97316), // Bright Orange
                  onTap: () => Navigator.of(context).pushNamed(AppRoutes.maintenance),
                  delay: 1000,
                ),
                DashboardCard(
                  title: 'Reports',
                  icon: Icons.assessment,
                  color: const Color(0xFF60A5FA), // Light Blue
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Reports coming soon!')),
                    );
                  },
                  delay: 1100,
                ),
                DashboardCard(
                  title: 'Settings',
                  icon: Icons.settings,
                  color: const Color(0xFF6B7280), // Text Secondary (Grey)
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Settings coming soon!')),
                    );
                  },
                  delay: 1200,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
