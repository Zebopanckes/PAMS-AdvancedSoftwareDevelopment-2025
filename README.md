# PAMS – Paragon Apartment Management System

A Flutter desktop application for managing a multi-location apartment rental
business. Built for the Advanced Software Development module.

---

## Prerequisites

- Flutter SDK **3.0.0 or newer** (stable channel)
- For Windows desktop builds: **Visual Studio 2022** with the "Desktop
  development with C++" workload

Verify the toolchain:

```powershell
flutter --version
flutter doctor
```

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

## Testing

```bash
# Run all tests
flutter test

# Run specific test
flutter test test/auth_service_test.dart
```

On first launch the app creates a SQLite database and seeds demonstration data
(apartments, tenants, leases, invoices, maintenance requests) automatically.

---

## Default login accounts

All staff accounts use password `Password123!` unless noted.

| Username               | Role        | Password         |
| ---------------------- | ----------- | ---------------- |
| `admin`              | Admin       | `admin123`     |
| `manager_bristol`    | Manager     | `Password123!` |
| `manager_cardiff`    | Manager     | `Password123!` |
| `manager_london`     | Manager     | `Password123!` |
| `manager_manchester` | Manager     | `Password123!` |
| `finance_<city>`     | Finance     | `Password123!` |
| `maint_<city>`       | Maintenance | `Password123!` |
| `front_<city>`       | Front-desk  | `Password123!` |

The full list is also shown on the login screen.

---

## Keyboard shortcuts

- **F11** — toggle fullscreen.

## Technology stack

- **Framework:** Flutter (Windows desktop)
- **Language:** Dart
- **State management:** Provider
- **Database:** SQLite (`sqflite` / `sqflite_common_ffi`)
- **Security:** bcrypt password hashing, role-based access control, audit
  logging
- **Reporting:** `pdf`, `printing`, `excel`
- **Charts:** `fl_chart`, `syncfusion_flutter_charts`
- **Window management:** `window_manager`

Full dependency list is declared in [`pubspec.yaml`](pubspec.yaml).

---

## Features

- Role-based authentication (Admin, Manager, Finance, Maintenance, Front-desk)
- Tenant, apartment, lease, invoice, payment, maintenance and complaints
  management
- City management — managers can expand the business into new cities at
  runtime
- Dashboards with per-city statistics and charts
- Reports with PDF/Excel export
- Seed data for rapid demo/evaluation
- Audit log of security-relevant actions
