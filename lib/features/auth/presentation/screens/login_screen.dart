// Author: Alec Brothwood (23076824) - Project Manager
// Author: Ashley Shoniwa (24021297) - Frontend Developer
// File: login_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/aurora_background.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = context.read<AuthProvider>();
      
      final success = await authProvider.login(
        _usernameController.text.trim(),
        _passwordController.text,
      );

      if (!mounted) return;

      if (success) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.dashboard);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage ?? 'Login failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Aurora animated background with light grey base
          const AuroraBackground(
            colorStops: [
              Color(0xFF2563EB), // Calm Blue
              Color(0xFFFBBF24), // Vibrant Yellow
              Color(0xFF3B82F6), // Mid Blue
            ],
            blend: 0.4,
            amplitude: 1.0,
            speed: 0.3,
            backgroundColor: Color(0xFFF5F5F7), // Light Grey
          ),
          // Login content
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Card(
                elevation: 12,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: const Color(0xFFD1D1D6).withValues(alpha: 0.5), // Border Grey
                    width: 1,
                  ),
                ),
                child: Container(
                  width: 450,
                  padding: const EdgeInsets.all(32),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.apartment,
                          size: 64,
                          color: Theme.of(context).colorScheme.primary,
                        )
                            .animate()
                            .fadeIn(duration: 400.ms)
                            .scale(delay: 100.ms),
                        const SizedBox(height: 16),
                        Text(
                          'Welcome to PAMS',
                          style: Theme.of(context).textTheme.headlineMedium,
                        )
                            .animate()
                            .fadeIn(delay: 200.ms),
                        const SizedBox(height: 8),
                        Text(
                          'Login to continue',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: const Color(0xFF6B7280), // Text Secondary
                              ),
                        )
                            .animate()
                            .fadeIn(delay: 300.ms),
                        const SizedBox(height: 32),
                        TextFormField(
                          controller: _usernameController,
                          decoration: const InputDecoration(
                            labelText: 'Username',
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your username';
                            }
                            return null;
                          },
                        )
                            .animate()
                            .fadeIn(delay: 400.ms)
                            .slideX(begin: -0.2, end: 0),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            return null;
                          },
                        )
                            .animate()
                            .fadeIn(delay: 500.ms)
                            .slideX(begin: -0.2, end: 0),
                        const SizedBox(height: 24),
                        Consumer<AuthProvider>(
                          builder: (context, authProvider, child) {
                            return SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: authProvider.isLoading
                                    ? null
                                    : _handleLogin,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                  child: authProvider.isLoading
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                    Colors.white),
                                          ),
                                        )
                                      : const Text(
                                          'LOGIN',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                ),
                              ),
                            );
                          },
                        )
                            .animate()
                            .fadeIn(delay: 600.ms)
                            .scale(delay: 600.ms),
                        const SizedBox(height: 16),
                        Text(
                          'Demo accounts (password: Password123! unless noted)',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(fontWeight: FontWeight.w600),
                          textAlign: TextAlign.center,
                        )
                            .animate()
                            .fadeIn(delay: 700.ms),
                        const SizedBox(height: 4),
                        Text(
                          'admin / admin123\n'
                          'Managers: manager_bristol, manager_cardiff, manager_london, manager_manchester\n'
                          'Finance: finance_bristol, finance_cardiff, finance_london, finance_manchester\n'
                          'Maintenance: maint_bristol, maint_cardiff, maint_london, maint_manchester\n'
                          'Front-desk: front_bristol, front_cardiff, front_london, front_manchester',
                          style: Theme.of(context).textTheme.bodySmall,
                          textAlign: TextAlign.center,
                        )
                            .animate()
                            .fadeIn(delay: 750.ms),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
