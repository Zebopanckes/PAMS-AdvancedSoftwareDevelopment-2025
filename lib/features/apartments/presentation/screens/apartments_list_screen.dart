import 'package:flutter/material.dart';

class ApartmentsListScreen extends StatelessWidget {
  const ApartmentsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Apartments Management'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.apartment,
              size: 80,
              color: const Color(0xFF2563EB), // Calm Blue
            ),
            const SizedBox(height: 16),
            Text(
              'Apartments Module',
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
            const SnackBar(content: Text('Add Apartment feature coming soon!')),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Apartment'),
      ),
    );
  }
}
