// Author: PAMS Development Team
// File: main.dart
// Purpose: Application entry point. Initialises database and seed data, then
// launches the Flutter desktop UI.

import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:window_manager/window_manager.dart';

import 'core/routes/app_routes.dart';
import 'core/services/auth_service.dart';
import 'core/services/database_service.dart';
import 'core/services/seed_service.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/providers/auth_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Enable sqflite on desktop targets.
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // Initialise window manager for desktop fullscreen support.
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    await windowManager.ensureInitialized();
    await windowManager.waitUntilReadyToShow(null, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  // Prime the database.
  await DatabaseService.instance.database;

  // Populate demonstration data on first launch.
  try {
    await SeedService().seedIfEmpty();
  } catch (e) {
    debugPrint('Seed data skipped: $e');
  }

  runApp(const PAMSApp());
}

class PAMSApp extends StatelessWidget {
  const PAMSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(AuthService())),
      ],
      child: KeyboardListener(
        focusNode: FocusNode(),
        autofocus: true,
        onKeyEvent: (event) async {
          if (event is KeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.f11) {
            final isFullScreen = await windowManager.isFullScreen();
            await windowManager.setFullScreen(!isFullScreen);
          }
        },
        child: MaterialApp(
          title: 'PAMS – Paragon Apartment Management System',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.light,
          initialRoute: AppRoutes.splash,
          onGenerateRoute: AppRoutes.onGenerateRoute,
          debugShowCheckedModeBanner: false,
        ),
      ),
    );
  }
}
