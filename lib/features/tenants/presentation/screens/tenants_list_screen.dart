import 'package:flutter/material.dart';

class TenantsListScreen extends StatelessWidget {
  const TenantsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tenants Management'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.people,
              size: 80,
              color: Color(0xFF3B82F6), // Mid Blue
            ),
            const SizedBox(height: 16),
            Text(
              'Tenants Module',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Coming Soon',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: const Color(0xFF6B7280), // Text Secondary
                  ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Add Tenant feature coming soon!')),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Tenant'),
      ),
    );
  }
}
