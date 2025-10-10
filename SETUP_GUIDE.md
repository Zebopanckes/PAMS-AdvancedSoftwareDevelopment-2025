# PAMS Project Setup Guide

## Prerequisites Installation

### 1. Install Flutter

#### Windows Installation:

1. **Download Flutter SDK**
   - Visit: https://docs.flutter.dev/get-started/install/windows
   - Download the latest stable Flutter SDK
   - Extract to `C:\src\flutter` (or your preferred location)

2. **Add Flutter to PATH**
   - Open "Edit environment variables for your account"
   - Under "User variables", find and select "Path"
   - Click "Edit"
   - Click "New" and add: `C:\src\flutter\bin`
   - Click "OK" to save

3. **Verify Installation**
   ```powershell
   flutter --version
   flutter doctor
   ```

4. **Enable Windows Desktop Support**
   ```powershell
   flutter config --enable-windows-desktop
   ```

### 2. Install Visual Studio (for Windows Desktop)

1. Download Visual Studio 2022 Community Edition
2. Install with "Desktop development with C++" workload
3. Run `flutter doctor` to verify

### 3. Install Git (if not already installed)

1. Download from: https://git-scm.com/download/win
2. Install with default options
3. Verify: `git --version`

## Project Setup

### Step 1: Navigate to Project Directory

```powershell
cd "c:\Users\alecb\Documents\coding things\PAMS-AdvancedSoftwareDevelopment-2025"
```

### Step 2: Install Dependencies

```powershell
flutter pub get
```

### Step 3: Verify Project Configuration

```powershell
flutter doctor -v
```

### Step 4: Run the Application

```powershell
# For Windows Desktop
flutter run -d windows

# To see available devices
flutter devices
```

## Default Login Credentials

- **Username**: `admin`
- **Password**: `admin123`

⚠️ **Important**: Change this password after first login!

## Project Structure Created

```
PAMS-AdvancedSoftwareDevelopment-2025/
├── lib/
│   ├── main.dart                 # Entry point
│   ├── core/
│   │   ├── models/              # Data models (UserModel)
│   │   ├── services/            # Services (DatabaseService, AuthService)
│   │   ├── theme/               # App theme configuration
│   │   └── routes/              # Route management
│   └── features/
│       ├── auth/                # Authentication module
│       │   └── presentation/
│       │       ├── providers/   # AuthProvider
│       │       └── screens/     # Login, Splash screens
│       ├── dashboard/           # Dashboard module
│       │   └── presentation/
│       │       ├── screens/     # Dashboard screen
│       │       └── widgets/     # Dashboard widgets
│       ├── tenants/             # Tenants management (placeholder)
│       ├── apartments/          # Apartments management (placeholder)
│       ├── payments/            # Payments system (placeholder)
│       └── maintenance/         # Maintenance module (placeholder)
├── assets/                      # Static assets
│   ├── images/
│   ├── animations/
│   ├── icons/
│   └── fonts/
├── test/                        # Unit tests
├── docs/                        # Documentation
├── pubspec.yaml                 # Dependencies configuration
├── .gitignore                   # Git ignore rules
└── README.md                    # Project documentation
```

## What's Implemented

✅ **Core Infrastructure**
- Flutter project structure
- SQLite database with complete schema
- Authentication system with password hashing
- Role-based user model (Admin, Manager, Finance, Maintenance, Front Desk)
- Route management with smooth animations

✅ **Authentication**
- Splash screen with animations
- Login screen with form validation
- Session management
- Logout functionality
- Default admin account

✅ **Dashboard**
- Professional UI with statistics cards
- Quick action navigation
- Role-based access display
- Smooth animations and transitions

✅ **Security**
- SHA-256 password hashing
- Audit logging system
- Role-based access control structure
- Session persistence

✅ **Database Schema**
- Users table
- Tenants table
- Apartments table
- Lease agreements table
- Payments table
- Maintenance requests table
- Audit logs table

## Next Steps for Development

### Phase 1: Tenant Management
1. Create TenantModel with all fields
2. Implement tenant CRUD operations
3. Build tenant list screen with search/filter
4. Create tenant detail/edit forms
5. Add validation and error handling

### Phase 2: Apartment Management
1. Create ApartmentModel
2. Implement apartment CRUD operations
3. Build apartment list with status indicators
4. Create apartment detail/edit forms
5. Implement occupancy tracking

### Phase 3: Payments System
1. Create PaymentModel and LeaseModel
2. Implement payment recording
3. Build payment history view
4. Generate invoices (PDF)
5. Add payment reminders/notifications

### Phase 4: Maintenance Management
1. Create MaintenanceRequestModel
2. Implement request CRUD operations
3. Build priority-based listing
4. Add staff assignment functionality
5. Track completion and costs

### Phase 5: Advanced Features
1. Generate reports (PDF/Excel)
2. Add charts and visualizations
3. Implement notifications system
4. Add advanced search and filters
5. Multi-factor authentication

### Phase 6: Testing & Polish
1. Write comprehensive unit tests
2. Integration testing
3. UI/UX refinement
4. Performance optimization
5. Documentation completion

## Troubleshooting

### Flutter not recognized
- Verify Flutter is installed
- Check PATH environment variable
- Restart terminal/IDE after PATH changes

### Dependencies not installing
- Check internet connection
- Clear pub cache: `flutter pub cache repair`
- Try: `flutter clean` then `flutter pub get`

### Database errors
- Verify sqflite_common_ffi is in dependencies
- Check database initialization in main.dart
- Ensure write permissions in app directory

### Build errors on Windows
- Verify Visual Studio is installed with C++ tools
- Run as Administrator if permission issues
- Check Windows SDK is installed

## Development Tips

1. **Hot Reload**: Press `r` in terminal while app is running
2. **Hot Restart**: Press `R` in terminal
3. **Debug Mode**: Use VS Code Flutter extension for debugging
4. **Database Viewer**: Use DB Browser for SQLite to inspect database
5. **State Management**: Use Provider.of<T>(context) for reading state

## Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Dart Documentation](https://dart.dev/guides)
- [Material Design 3](https://m3.material.io/)
- [Provider Package](https://pub.dev/packages/provider)
- [SQLite Documentation](https://www.sqlite.org/docs.html)

## Contact & Support

For questions or issues:
1. Review this documentation
2. Check Flutter documentation
3. Review code comments in source files
4. Create issue in repository

---

**Ready to start development!** 🚀

Once Flutter is installed, run:
```powershell
flutter pub get
flutter run -d windows
```
