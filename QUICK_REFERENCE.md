# 🚀 PAMS Quick Reference Card

## Essential Commands

### Setup
```bash
flutter pub get                    # Install dependencies
flutter doctor                     # Check installation
flutter devices                    # List available devices
```

### Running
```bash
flutter run -d windows            # Run on Windows
flutter run --release             # Release build
flutter run --debug               # Debug build (default)
```

### Development
```bash
# In running app terminal:
r                                 # Hot reload
R                                 # Hot restart
q                                 # Quit
```

### Testing
```bash
flutter test                      # Run all tests
flutter test test/auth_service_test.dart  # Run specific test
```

### Build
```bash
flutter build windows             # Build Windows executable
flutter clean                     # Clean build files
```

## Default Login

| Field    | Value    |
|----------|----------|
| Username | admin    |
| Password | admin123 |

## File Locations

### Core Files
- Entry Point: `lib/main.dart`
- Database: `lib/core/services/database_service.dart`
- Auth: `lib/core/services/auth_service.dart`
- Theme: `lib/core/theme/app_theme.dart`
- Routes: `lib/core/routes/app_routes.dart`

### Feature Screens
- Login: `lib/features/auth/presentation/screens/login_screen.dart`
- Dashboard: `lib/features/dashboard/presentation/screens/dashboard_screen.dart`
- Tenants: `lib/features/tenants/presentation/screens/tenants_list_screen.dart`

## User Roles

| Role        | Purpose                          |
|-------------|----------------------------------|
| admin       | Full system access               |
| manager     | Tenant & apartment management    |
| finance     | Payment & financial operations   |
| maintenance | Maintenance request management   |
| frontDesk   | Basic operations                 |

## Database Tables

1. **users** - User accounts
2. **tenants** - Tenant information
3. **apartments** - Property details
4. **lease_agreements** - Tenant-apartment links
5. **payments** - Transaction records
6. **maintenance_requests** - Service requests
7. **audit_logs** - Activity tracking

## Key Dependencies

| Package           | Purpose              |
|-------------------|----------------------|
| provider          | State management     |
| sqflite           | Database             |
| crypto            | Password hashing     |
| flutter_animate   | Animations           |
| shared_preferences| Session storage      |
| pdf               | Report generation    |
| fl_chart          | Data visualization   |

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── core/                     # Shared utilities
│   ├── models/              # Data models
│   ├── services/            # Business logic
│   ├── theme/               # UI theme
│   └── routes/              # Navigation
└── features/                # Feature modules
    ├── auth/                # Authentication
    ├── dashboard/           # Main dashboard
    ├── tenants/             # Tenant management
    ├── apartments/          # Apartment management
    ├── payments/            # Payment system
    └── maintenance/         # Maintenance tracking
```

## Common Tasks

### Add New Screen
1. Create screen file in `lib/features/[module]/presentation/screens/`
2. Add route in `lib/core/routes/app_routes.dart`
3. Navigate using: `Navigator.pushNamed(context, AppRoutes.routeName)`

### Add New Model
1. Create model file in `lib/core/models/`
2. Add `toMap()` and `fromMap()` methods
3. Add `toJson()` and `fromJson()` methods

### Add Database Table
1. Update `_createDB()` in `database_service.dart`
2. Create corresponding model
3. Implement CRUD operations

### Add Provider
1. Create provider in feature's `providers/` directory
2. Extend `ChangeNotifier`
3. Add to `MultiProvider` in `main.dart`

## Development Workflow

1. **Plan** - Define feature requirements
2. **Model** - Create data models
3. **Service** - Implement business logic
4. **Provider** - Setup state management
5. **UI** - Build screens and widgets
6. **Test** - Write unit tests
7. **Refine** - Polish UI and animations

## Troubleshooting

| Issue                    | Solution                          |
|--------------------------|-----------------------------------|
| Flutter not found        | Add Flutter to PATH               |
| Dependencies fail        | Run `flutter pub cache repair`    |
| Build errors             | Run `flutter clean` then rebuild  |
| Database errors          | Check DatabaseService init        |
| Hot reload not working   | Try hot restart (R)               |

## Next Steps

### Priority 1: Tenant Module
- [ ] Create complete TenantModel
- [ ] Implement CRUD in service
- [ ] Build list screen with data
- [ ] Create add/edit forms
- [ ] Add validation

### Priority 2: Apartment Module
- [ ] Create ApartmentModel
- [ ] Implement CRUD operations
- [ ] Build list with filters
- [ ] Create forms
- [ ] Track occupancy

### Priority 3: Payment Module
- [ ] Create PaymentModel
- [ ] Record payments
- [ ] Payment history
- [ ] Generate invoices
- [ ] Track due dates

## Resources

- **Documentation**: See `docs/` folder
- **Setup Guide**: `SETUP_GUIDE.md`
- **Project Summary**: `PROJECT_SUMMARY.md`
- **Flutter Docs**: https://docs.flutter.dev
- **Material Design**: https://m3.material.io

## Tips

💡 **Hot Reload**: Use `r` for instant UI updates  
💡 **Provider**: Use `context.watch<T>()` to rebuild on changes  
💡 **Async**: Always use `async/await` for database operations  
💡 **Navigation**: Use named routes for type safety  
💡 **Theme**: Access theme via `Theme.of(context)`  

---

**Status**: ✅ Foundation Complete - Ready to Build Features

**Support**: Check documentation files for detailed information
