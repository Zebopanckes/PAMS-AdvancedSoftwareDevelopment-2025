# PAMS - Paragon Apartment Management System

A comprehensive desktop application for managing multi-location apartment businesses built with Flutter.

## Features

- **User Management**: Role-based access control (Admin, Manager, Finance, Maintenance, Front Desk)
- **Tenant Management**: Complete tenant lifecycle management
- **Apartment Management**: Track apartments, occupancy, and details
- **Payment System**: Billing, invoicing, and payment tracking
- **Maintenance**: Request logging, prioritization, and staff allocation
- **Dashboard**: Real-time statistics and insights
- **Security**: Password hashing, MFA support, audit trails

## Getting Started

### Prerequisites

- Flutter SDK (>=3.0.0)
- Dart SDK
- Windows/macOS/Linux desktop support enabled

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd PAMS-AdvancedSoftwareDevelopment-2025
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the application:
```bash
flutter run -d windows  # For Windows
flutter run -d macos    # For macOS
flutter run -d linux    # For Linux
```

## Default Credentials

- Username: `admin`
- Password: `admin123`

**⚠️ Important**: Change the default password after first login!

## Project Structure

```
lib/
├── core/
│   ├── models/          # Data models
│   ├── services/        # Services (database, auth)
│   ├── theme/           # App theme configuration
│   └── routes/          # Route management
├── features/
│   ├── auth/            # Authentication module
│   ├── dashboard/       # Dashboard module
│   ├── tenants/         # Tenants management
│   ├── apartments/      # Apartments management
│   ├── payments/        # Payments system
│   └── maintenance/     # Maintenance requests
└── main.dart            # Entry point
```

## Technology Stack

- **Framework**: Flutter
- **State Management**: Provider
- **Database**: SQLite
- **Security**: Crypto (SHA-256 hashing)
- **Animations**: flutter_animate
- **Charts**: fl_chart, syncfusion_flutter_charts

## Development Roadmap

- [x] Project setup and initialization
- [x] Authentication system
- [x] Database schema
- [x] Dashboard UI
- [ ] Tenant CRUD operations
- [ ] Apartment CRUD operations
- [ ] Payment processing
- [ ] Maintenance management
- [ ] Reports generation
- [ ] Advanced security features
- [ ] Unit & integration testing

## License

This project is developed for educational purposes as part of the Advanced Software Development module.

## Contributors

- Your Name - Initial development
