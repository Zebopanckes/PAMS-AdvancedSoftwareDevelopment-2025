# Paragon Apartment Management System (PAMS)

## ✅ Project Status: Foundation Complete - Ready for Feature Development

## Application Overview
PAMS is a desktop application designed to manage a multi-location apartment business efficiently. It includes tenant, apartment, payment, maintenance, and user management with a modern, fluid, and professional UI enriched by smooth animations using Flutter.

## 🚀 Quick Start

### Default Login Credentials
- **Username**: `admin`
- **Password**: `admin123`

### Setup Instructions
1. **Install Flutter**: See `SETUP_GUIDE.md` for detailed instructions
2. **Install Dependencies**: `flutter pub get`
3. **Run Application**: `flutter run -d windows`

## 📚 Documentation

- **SETUP_GUIDE.md** - Complete installation and setup instructions
- **PROJECT_SUMMARY.md** - Detailed overview of what has been implemented
- **QUICK_REFERENCE.md** - Quick command reference and file locations
- **CHECKLIST.md** - Development progress tracking
- **docs/DEVELOPMENT_GUIDE.md** - Architecture and development guidelines

## ✅ What's Implemented

### Core Infrastructure
- ✅ Complete Flutter project structure
- ✅ SQLite database with 7 tables (users, tenants, apartments, leases, payments, maintenance, audit logs)
- ✅ Authentication system with SHA-256 password hashing
- ✅ Role-based access control (Admin, Manager, Finance, Maintenance, Front Desk)
- ✅ Session management and audit logging
- ✅ Professional Material Design 3 theme
- ✅ Smooth animations and transitions

### Working Features
- ✅ Splash screen with animations
- ✅ Login with authentication
- ✅ Dashboard with statistics and quick actions
- ✅ Navigation to all modules
- ✅ Logout functionality
- ✅ Responsive UI with professional design

### Architecture
- ✅ Clean architecture with separation of concerns
- ✅ Provider pattern for state management
- ✅ Reusable widgets and components
- ✅ Centralized routing system
- ✅ Comprehensive error handling

## 🔄 Next Steps (See CHECKLIST.md)

### Priority 1: Tenant Management
- Complete CRUD operations for tenants
- Build tenant list with search/filter
- Create add/edit forms with validation

### Priority 2: Apartment Management
- Complete CRUD operations for apartments
- Build apartment list with status tracking
- Implement occupancy management

### Priority 3: Payment System
- Payment recording and tracking
- Invoice generation (PDF)
- Payment history and analytics

### Priority 4: Maintenance Module
- Maintenance request management
- Priority-based tracking
- Staff assignment and completion tracking

### Priority 5: Reports & Analytics
- Generate comprehensive reports
- Data visualization with charts
- Export to PDF/Excel

## Key Features (Planned)
- ✅ Role-based User Account Management (Admin, Manager, Finance, Maintenance, Front Desk)
- 🔄 Tenant Lifecycle Management (agreements, payments, complaints)
- 🔄 Apartment Registration and Occupancy Tracking
- 🔄 Payment/Billing with invoice generation and due tracking
- 🔄 Maintenance Logging, Prioritization, and Staff Allocation
- ✅ Real-time Dashboards and Reports (Foundation)
- ✅ Advanced Security Features (password hashing, MFA structure, audit trails)
- ✅ Smooth Animations and Fluent Design powered by Flutter

## Technology Stack

- **Framework**: Flutter (Desktop)
- **State Management**: Provider
- **Database**: SQLite with sqflite
- **Security**: SHA-256 password hashing, audit logging
- **UI/Animations**: Material Design 3, flutter_animate
- **Charts**: fl_chart, syncfusion_flutter_charts
- **Reports**: PDF, Excel export capabilities

## Project Structure

```
lib/
├── main.dart                    # Application entry point
├── core/
│   ├── models/                  # Data models (UserModel)
│   ├── services/                # Business logic (DatabaseService, AuthService)
│   ├── theme/                   # UI theme configuration
│   └── routes/                  # Navigation and routing
└── features/
    ├── auth/                    # ✅ Authentication module (complete)
    ├── dashboard/               # ✅ Dashboard module (complete)
    ├── tenants/                 # 🔄 Tenant management (in progress)
    ├── apartments/              # 🔄 Apartment management (in progress)
    ├── payments/                # 🔄 Payment system (in progress)
    └── maintenance/             # 🔄 Maintenance module (in progress)
```

## Database Schema

### Implemented Tables
1. **users** - User accounts with roles and authentication
2. **tenants** - Tenant information and status
3. **apartments** - Property details and specifications
4. **lease_agreements** - Links tenants to apartments
5. **payments** - Transaction history and tracking
6. **maintenance_requests** - Service request management
7. **audit_logs** - Complete system activity trail

## Development Progress

### ✅ Phase 1: Planning & Requirements (Complete)
- Defined user roles, workflows, and core functionalities
- Created comprehensive database schema
- Established architecture and design patterns

### ✅ Phase 2: Environment Setup (Complete)
- Flutter development environment configured
- SQLite database integrated
- Git version control setup

### ✅ Phase 3: Core Backend Development (Complete)
- Database schema implementation
- Authentication service with security
- User management system
- Audit logging

### ✅ Phase 4: Basic UI & Navigation (Complete)
- Professional theme implementation
- Splash screen with animations
- Login screen with validation
- Dashboard with statistics
- Navigation system with smooth transitions

### 🔄 Phase 5: Feature Implementation (In Progress)
- 🔄 Tenant Management Module
- 🔄 Apartment Management Module
- 🔄 Payment and Billing System
- 🔄 Maintenance Management
- 🔄 Reporting Module

### ⏳ Phase 6: Animations & UI Refinement (Upcoming)
- Additional smooth animations
- UI responsiveness optimization
- Professional polish

### ⏳ Phase 7: Testing & Validation (Upcoming)
- Unit testing for backend components
- Widget testing for UI
- Integration testing
- Test documentation

### ⏳ Phase 8: Finalization & Deployment (Upcoming)
- Project documentation completion
- Build and package application
- Viva/demo preparation
- Individual contribution summary

## Getting Started

### Prerequisites
- Flutter SDK (>=3.0.0)
- Visual Studio 2022 (for Windows desktop)
- Git

### Installation Steps

1. **Clone the repository**
```bash
git clone <repository-url>
cd PAMS-AdvancedSoftwareDevelopment-2025
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Run the application**
```bash
flutter run -d windows
```

For detailed setup instructions, see **SETUP_GUIDE.md**

## Running the Application

1. Launch the application
2. Login with default credentials (admin/admin123)
3. Explore the dashboard
4. Navigate through different modules

## Testing

```bash
# Run all tests
flutter test

# Run specific test
flutter test test/auth_service_test.dart
```

## Contributing

This is an academic project for the Advanced Software Development module. Development follows clean architecture principles and Flutter best practices.

## Resources

- **Flutter Documentation**: https://docs.flutter.dev/
- **Material Design 3**: https://m3.material.io/
- **SQLite Documentation**: https://www.sqlite.org/

## Development Timeline

- **Week 1-2**: ✅ Foundation and core infrastructure (Complete)
- **Week 3-4**: 🔄 Tenant and Apartment modules (Current)
- **Week 5-6**: ⏳ Payment and Maintenance systems
- **Week 7-8**: ⏳ Reports, testing, and finalization

## License

This project is developed for educational purposes as part of the Advanced Software Development module.

---

## 📋 Additional Resources

- See **CHECKLIST.md** for detailed development tasks
- See **QUICK_REFERENCE.md** for common commands
- See **PROJECT_SUMMARY.md** for implementation details
- See **docs/DEVELOPMENT_GUIDE.md** for architecture information

---

**Last Updated**: October 2025  
**Status**: Foundation Complete - Active Development  
**Next Milestone**: Tenant Management Module