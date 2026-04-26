# PAMS - Technical Reference ("How It Works")

> Purpose: a single document any team member can read before the demo to
> answer technical questions about the project. It explains the tech
> stack, the architecture, how files are wired together, the data model,
> the auth/RBAC pipeline, and the request -> render flow for typical
> actions.

---

## 1. Tech stack at a glance

| Layer            | Choice                                                          | Why                                                          |
| ---------------- | --------------------------------------------------------------- | ------------------------------------------------------------ |
| Language         | **Dart** (SDK >= 3.0.0)                                         | Strongly-typed, OOP, satisfies the spec's "OO language" rule |
| UI framework     | **Flutter** (Windows desktop)                                   | Native compiled desktop GUI; spec forbids websites           |
| State management | **Provider** (`provider: ^6.1.2`)                              | Lightweight, recommended for app-wide state in Flutter        |
| Database         | **SQLite** via `sqflite` + `sqflite_common_ffi`              | Zero-install relational DB; same schema works on MySQL        |
| Auth hashing     | **bcrypt** (`bcrypt: ^1.1.3`, log2 rounds = 12)                | Industry standard, salted, slow on purpose                    |
| Session storage  | `shared_preferences`                                          | Stores **only** the session token + login time, never a password |
| Window mgmt      | `window_manager`                                              | F11 fullscreen + window state on Windows                      |
| Reporting        | `pdf`, `printing`, `excel`                                  | PDF/XLSX export from the Reports screen                       |
| Charts           | `fl_chart`, `syncfusion_flutter_charts`                       | Dashboard occupancy / financial charts                        |
| Testing          | `flutter_test`, `mockito`                                     | Unit + widget tests                                           |

Full list: [pubspec.yaml](pubspec.yaml).

---

## 2. Project layout

```
lib/
├── main.dart                       <- entry point
├── core/
│   ├── models/                     <- domain classes (1 per entity)
│   ├── routes/app_routes.dart      <- central route table
│   ├── theme/app_theme.dart        <- colors, typography, light/dark
│   ├── security/rbac.dart          <- permission matrix
│   ├── services/                   <- business logic + DB access
│   ├── widgets/                    <- shared UI (AppShell, backgrounds)
│   └── screens/                    <- shared screens (background demo)
└── features/
    ├── auth/
    ├── dashboard/
    ├── tenants/
    ├── apartments/
    ├── leases/
    ├── payments/
    ├── maintenance/
    ├── complaints/
    ├── cities/
    ├── reports/
    └── users/
```

Each feature folder follows a tiny clean-architecture slice:
`features/<x>/presentation/screens/<x>_screen.dart` (and providers /
widgets where needed). All business logic lives under `core/services/`.

---

## 3. Application bootstrap (what happens on launch)

[lib/main.dart](lib/main.dart):

1. `WidgetsFlutterBinding.ensureInitialized()` — required before any
   plugin call.
2. **Desktop SQLite shim:** on Windows/Linux/macOS, calls
   `sqfliteFfiInit()` and swaps `databaseFactory = databaseFactoryFfi`.
   This is what lets the same SQLite code run on desktop (where there's
   no Android/iOS native bridge).
3. **Window manager:** initialises `window_manager`, shows and focuses
   the window. This is also why the F11 keypress can toggle fullscreen
   (handled in the `KeyboardListener` inside `PAMSApp`).
4. **Database prime:** `await DatabaseService.instance.database`
   creates `pams.db` in the user's app-data folder, runs `_createDB`
   (or `_onUpgrade`) and inserts the default `admin` user.
5. **Seeder:** `SeedService().seedIfEmpty()` populates 4 cities, staff
   per city, ~12 tenants, apartments, leases, invoices and a few
   maintenance tickets — only if the tables are empty.
6. `runApp(PAMSApp())` — boots the widget tree.

Inside `PAMSApp`:

- `MultiProvider` makes `AuthProvider(AuthService())` available to
  every widget below it via `context.watch<AuthProvider>()` /
  `context.read<AuthProvider>()`.
- `MaterialApp` is configured with `initialRoute: AppRoutes.splash`
  and `onGenerateRoute: AppRoutes.onGenerateRoute` — i.e. routing is
  centralised.

---

## 4. Routing

[lib/core/routes/app_routes.dart](lib/core/routes/app_routes.dart):

Routes are **named string constants** on `AppRoutes`:

| Constant                | Path             | Screen                         |
| ----------------------- | ---------------- | ------------------------------ |
| `AppRoutes.splash`    | `/`            | `SplashScreen`               |
| `AppRoutes.login`     | `/login`       | `LoginScreen`                |
| `AppRoutes.dashboard` | `/dashboard`   | `DashboardScreen`            |
| `AppRoutes.tenants`   | `/tenants`     | `TenantsListScreen`          |
| `AppRoutes.apartments`| `/apartments`  | `ApartmentsListScreen`       |
| `AppRoutes.leases`    | `/leases`      | `LeasesListScreen`           |
| `AppRoutes.payments`  | `/payments`    | `BillingScreen`              |
| `AppRoutes.maintenance`| `/maintenance`| `MaintenanceListScreen`      |
| `AppRoutes.complaints`| `/complaints`  | `ComplaintsListScreen`       |
| `AppRoutes.reports`   | `/reports`     | `ReportsScreen`              |
| `AppRoutes.users`     | `/users`       | `UsersListScreen`            |
| `AppRoutes.cities`    | `/cities`      | `CitiesListScreen`           |

`onGenerateRoute` switches on `settings.name` and returns a
`PageRouteBuilder` with a 200 ms fade transition, so navigations look
the same everywhere.

Why a central table? It guarantees there is exactly **one** place that
knows all routes, which means screens never import each other directly
and a typo in a route name can't silently break navigation — the
default branch shows "No route defined for ...".

Navigation calls look like:

```dart
Navigator.of(context).pushReplacementNamed(AppRoutes.dashboard);
```

The splash screen runs `AuthProvider.checkAuthStatus()` and either
forwards to `/dashboard` (valid session) or `/login`.

---

## 5. State management with Provider

We use the `provider` package because it is the lowest-friction option
for app-wide state in Flutter. There is **one** app-wide provider
(`AuthProvider`); everything else is fetched on demand by the screens
calling services directly. This keeps the dependency graph flat:

```
PAMSApp
└── MultiProvider
    └── ChangeNotifierProvider<AuthProvider>(AuthService())
        └── MaterialApp -> Routes -> Screens
                └── context.watch<AuthProvider>()  // reactive
                └── context.read<AuthProvider>()   // one-shot
```

[lib/features/auth/presentation/providers/auth_provider.dart](lib/features/auth/presentation/providers/auth_provider.dart):

- Holds `currentUser`, `isLoading`, `errorMessage`.
- Exposes role helpers (`isAdmin`, `isManager`, `isFinance`,
  `isMaintenance`, `isFrontDesk`) and `hasAnyRole([...])`.
- Calls `notifyListeners()` after every state change so any widget
  that did `context.watch<AuthProvider>()` rebuilds.

---

## 6. Authentication flow

[lib/core/services/auth_service.dart](lib/core/services/auth_service.dart):

When the user submits the login form:

1. `AuthProvider.login(username, password)` is called.
2. It delegates to `AuthService.login(...)`.
3. `AuthService` runs a parameterised `db.query('users', where:
   'username = ?', whereArgs: [username])` — no string concatenation,
   so SQL injection is structurally impossible.
4. If no row, returns `LoginResult.invalidCredentials`.
5. If the user is `is_active = 0`, returns `accountDisabled`.
6. If `locked_until` is in the future, returns `accountLocked`.
7. Otherwise `BCrypt.checkpw(password, storedHash)` verifies.
   - **Failure:** increments `failed_login_attempts`. After 5 failures
     it sets `locked_until = now + 15 minutes`. Writes a
     `LOGIN_FAIL` row to `audit_logs`.
   - **Success:** clears the counters, stamps `last_login`, writes a
     `LOGIN` audit row, saves `(currentUser, loginTime)` to
     `SharedPreferences` (no plaintext password ever stored).
8. `AuthProvider` updates `_currentUser` and notifies listeners; the
   splash/login screens push to `/dashboard`.

Session timeout: `AuthService.getCurrentUser()` checks the stored
`loginTime`; anything older than 2 hours triggers automatic logout.

Default credentials (created by `_createDefaultAdmin` in
`database_service.dart`): `admin / admin123`. All seeded staff use
`Password123!`.

---

## 7. Authorisation (RBAC)

[lib/core/security/rbac.dart](lib/core/security/rbac.dart):

There are 21 `Permission` enum values (e.g. `viewTenants`,
`createTenant`, `manageUsers`, `expandBusiness`). A
`Map<UserRole, Set<Permission>>` defines which role gets which
permission. Anywhere in the app we ask:

```dart
Rbac.can(user, Permission.createTenant)   // bool
Rbac.canAny(user, [Permission.viewReports, Permission.manageUsers])
```

Two layers of enforcement (defence in depth):

1. **Navigation:** the side nav in
   [lib/core/widgets/app_shell.dart](lib/core/widgets/app_shell.dart)
   builds a `_NavItem` list and skips items whose `visible` is false.
   Front-desk literally has no Reports link to click.
2. **Service / screen guards:** action buttons (e.g. "Generate
   invoice", "Add tenant") check `Rbac.can(...)` before the action
   runs. Even if a user manually navigates by name, the action is
   blocked.

The role-permission matrix mirrors the PAMS spec exactly:

- **Admin:** everything.
- **Manager:** read-only on tenants, payments, maintenance, complaints;
  manages apartments and leases; views reports; can `expandBusiness`
  (add cities).
- **Finance:** sees tenants/apartments/leases; manages payments;
  generates invoices; views reports.
- **Maintenance:** apartments + tenants + maintenance; can assign and
  resolve.
- **Front-desk:** registers tenants, logs complaints, raises
  maintenance, sees apartments/leases/payments read-only.

---

## 8. Data model & schema

[lib/core/services/database_service.dart](lib/core/services/database_service.dart)
creates the schema. There are **10 tables** plus indexes:

| Table                  | Owns                                     | Notes                                                          |
| ---------------------- | ---------------------------------------- | -------------------------------------------------------------- |
| `users`              | Staff accounts                            | bcrypt `password_hash`, `failed_login_attempts`, `locked_until` |
| `tenants`            | Tenant records                            | `ni_number`, references, requirements, lease period, `status` |
| `apartments`         | Property inventory                        | UNIQUE on `(apartment_number, city)`                            |
| `lease_agreements`   | Tenancy contracts                         | FK to tenant + apartment, `early_termination_penalty`           |
| `invoices`           | Bills issued against a lease              | `invoice_number` is sequential (`INV-YYYY-00001`)             |
| `payments`           | Payments against an invoice               | `payment_method`, `status`, optional `reference_number`       |
| `maintenance_requests`| Repair tickets                           | priority, hours_spent, cost, assigned_to                       |
| `complaints`         | Tenant complaints                         | logged_by, status, resolution                                  |
| `audit_logs`         | Security trail                            | every login, logout, role change, destructive action           |
| `cities`             | Operating cities                          | seeded with Bristol/Cardiff/London/Manchester                  |

Foreign keys are turned on at open time (`PRAGMA foreign_keys = ON`)
and use `ON DELETE CASCADE` (e.g. deleting a tenant deletes their
leases and invoices) or `ON DELETE SET NULL` (e.g. the user who logged
a complaint can be removed without losing the complaint).

Indexes are created on the high-traffic columns: `tenants.city`,
`apartments.city`, `apartments.status`, `lease_agreements.status`,
`payments.status`, `maintenance_requests.status`. This is what makes
the per-city dashboards stay fast as data grows.

A SQL dump compatible with MySQL is produced by
[tool/dump_db.dart](tool/dump_db.dart) and lives at
[../pams_dump.sql](../pams_dump.sql).

---

## 9. Service layer (business logic)

Every entity has its own service. They are stateless (no instance
fields except a `Uuid()` generator) and are constructed directly by
screens — the only "global" service they use is the singleton
`DatabaseService.instance`.

| Service                    | Responsibility                                                    |
| -------------------------- | ----------------------------------------------------------------- |
| `auth_service.dart`      | Login, logout, hashing, audit logging, session timeout            |
| `user_service.dart`      | Staff CRUD, password resets, role changes                          |
| `tenant_service.dart`    | Tenant CRUD, NI validation, status transitions                     |
| `apartment_service.dart` | Apartment CRUD, status transitions (vacant/occupied/maintenance)   |
| `lease_service.dart`     | Create/terminate leases, **5% early-termination penalty**, guards against double-booking |
| `billing_service.dart`   | Issue invoices (sequential numbering), record payments, mark overdue |
| `maintenance_service.dart`| Raise/assign/resolve tickets, log hours+cost                      |
| `city_service.dart`      | Add new cities (the "expand business" use case)                   |
| `report_service.dart`    | Aggregate queries: occupancy / financial / maintenance cost       |
| `pdf_export_service.dart`| Render invoices and reports to PDF using `pdf`+`printing`     |
| `seed_service.dart`      | One-shot demo data populator                                      |

**Why services and not repositories?** For a coursework-sized app this
keeps the layer count down — UI talks to services, services talk to
SQLite. Adding a repository abstraction would be overkill.

### How a typical action flows

Example: front-desk registers a tenant.

```
TenantFormScreen (UI)
    │  validates form, builds TenantModel
    ▼
TenantService.create(TenantModel)
    │  business rules (unique NI, valid email, etc.)
    │  parameterised INSERT
    ▼
DatabaseService.instance.database  →  sqflite  →  SQLite
    │  triggers FK / unique constraints
    ▼
returns saved TenantModel  →  screen pops + shows snackbar
```

Example: finance issues an invoice.

```
BillingScreen (UI)
    │  picks an active lease + month
    ▼
BillingService.issueInvoice(lease, month)
    │  reads the next sequence number
    │  builds InvoiceModel with INV-YYYY-NNNNN
    │  INSERT into invoices
    ▼
PdfExportService.invoicePdf(invoice)  ← optional, on "Export"
    │
    ▼
printing package shows preview / save dialog
```

Example: manager terminates a lease early.

```
LeasesListScreen
    │  user clicks "End lease early"
    ▼
LeaseService.terminateEarly(leaseId, noticeDate)
    │  computeEarlyTerminationPenalty()  ← LeaseModel method
    │  UPDATE lease_agreements SET status='terminated', penalty=...
    │  apartmentService.setStatus(apt, vacant)
    ▼
audit_logs row written
```

The 1-month-notice + 5% penalty rule lives on
[lib/core/models/lease_model.dart](lib/core/models/lease_model.dart) so
that it is unit-testable in isolation (see
[test/domain_test.dart](test/domain_test.dart)).

---

## 10. UI shell and screens

[lib/core/widgets/app_shell.dart](lib/core/widgets/app_shell.dart)
provides the consistent layout used by every authenticated screen:

```
+----------------------------------------------------------+
|  AppBar (title)            [user] [role · city] [logout] |
+--------+-------------------------------------------------+
|        |                                                 |
| Side   |                screen content                   |
| Nav    |                                                 |
|        |                                                 |
+--------+-------------------------------------------------+
```

Screens build their own bodies and pass them in:

```dart
return AppShell(
  title: 'Tenants',
  child: TenantsTable(...),
  floatingActionButton: Rbac.can(user, Permission.createTenant)
      ? FloatingActionButton(onPressed: ..., child: Icon(Icons.add))
      : null,
);
```

The side nav is built from a list of `_NavItem`s with a `visible`
flag derived from `Rbac.can(...)`. That single line is why a
front-desk login literally cannot see "Reports" or "Users".

Visual flourish (gradient/silk background) is in
[lib/core/widgets/aurora_background.dart](lib/core/widgets/aurora_background.dart)
and [lib/core/widgets/silk_background.dart](lib/core/widgets/silk_background.dart);
the login + splash screens use them.

---

## 11. Reports

[lib/core/services/report_service.dart](lib/core/services/report_service.dart)
exposes three queries that are spec-mandated:

| Method                     | Returns                                                    |
| -------------------------- | ---------------------------------------------------------- |
| `occupancyByCity()`      | `OccupancyRow{city, total, occupied, vacant, maintenance}` plus `occupancyRate` |
| `financialByCity()`      | `FinancialRow{city, collected, outstanding}`             |
| `maintenanceCostsByCity()`| `MaintenanceCostRow{city, requests, totalCost, totalHours}` |

These are pure SQL `GROUP BY city` aggregates — fast even on tens of
thousands of rows.

[lib/features/reports/presentation/screens/reports_screen.dart](lib/features/reports/presentation/screens/reports_screen.dart)
binds these to charts (`fl_chart` / `syncfusion_flutter_charts`) and a
PDF export button (`PdfExportService`).

---

## 12. Security summary (the four NFRs the rubric asks about)

| NFR              | Where                                                                   |
| ---------------- | ----------------------------------------------------------------------- |
| Authentication   | bcrypt hash + per-install salt, `_bcryptLogRounds = 12`              |
| Authorisation    | `Rbac` matrix; enforced in nav + at action sites                      |
| Auditing         | `audit_logs` table, written on login, logout, failed login, etc.      |
| Input validation | Form validators on every `*_form_screen.dart` + service-layer guards |
| SQL safety       | All queries use `?` placeholders via `sqflite`                       |
| Session control  | 2-hour timeout, lockout after 5 failed attempts for 15 min              |
| Data isolation   | City-scoped users only see their city; admin/manager see across         |

---

## 13. Testing

| File                                                          | Tests                                                          |
| ------------------------------------------------------------- | -------------------------------------------------------------- |
| [test/auth_service_test.dart](test/auth_service_test.dart)    | Password hashing round-trip, login success/fail, lockout       |
| [test/domain_test.dart](test/domain_test.dart)                | Model invariants — early-termination penalty, status transitions |
| [test/widget_test.dart](test/widget_test.dart)                | Theme + smoke tests on shared widgets                           |

Run all tests:

```powershell
flutter test
```

Captured outputs are in
[test_results.json](test_results.json),
[test_results.txt](test_results.txt) and
[tests_expanded.txt](tests_expanded.txt).

---

## 14. Common questions & quick answers

**Q. Where does the database file live?**
A. In the OS app-data folder (`getDatabasesPath()`). On Windows that
is typically `%LOCALAPPDATA%\com.example.pams\databases\pams.db`.

**Q. How do you add a new city without redeploying?**
A. Manager logs in -> Cities screen -> "Add city". `CityService.add()`
inserts a row into `cities`. Apartments can then be created in that
city. This satisfies the "Manager can expand the business in other
cities" requirement from the spec.

**Q. How is the early-termination penalty calculated?**
A. `LeaseModel.computeEarlyTerminationPenalty()` returns 5% of the
monthly rent (per spec). Stored on the lease row when
`LeaseService.terminateEarly` runs.

**Q. What stops two tenants getting the same apartment?**
A. `LeaseService.create()` checks for any existing
`LeaseStatus.active` lease on that apartment ID and throws
`StateError` if found. This is enforced at the service level so the UI
cannot bypass it.

**Q. What stops a front-desk staff member generating financial reports?**
A. Two layers: the side nav doesn't show "Reports"
(`Rbac.can(user, Permission.viewReports)` is false), and even if they
deep-link with `Navigator.pushNamed('/reports')`, the report screen
gates its actions on `Rbac.can`. The data services don't expose
report queries to that role either.

**Q. What happens on schema upgrade?**
A. `_schemaVersion` is bumped (currently `4`), and `_onUpgrade` drops
all known tables and recreates them. Acceptable for a coursework
demo; in production we would write incremental `ALTER TABLE`
migrations. `pams_dump.sql` documents the current schema.

**Q. Why bcrypt instead of SHA-256?**
A. SHA-256 is fast — bad for password hashing because attackers can
brute-force quickly. bcrypt is intentionally slow (`logRounds = 12`)
and includes a per-password salt baked into the hash string, so two
identical passwords produce different hashes. This is the same
algorithm Spring Security and `passlib` default to.

**Q. Why Provider and not BLoC / Riverpod?**
A. We only have one piece of cross-screen state (`AuthProvider`).
Provider is the smallest tool that solves it. `flutter_bloc` is
listed as a dependency but is not currently wired in.

**Q. How does the F11 fullscreen work?**
A. The root `KeyboardListener` in `PAMSApp` listens for
`LogicalKeyboardKey.f11` and toggles `windowManager.setFullScreen()`.
That's why it works on every screen, not just one.

**Q. Where is the audit log shown?**
A. It is queried from the admin Users screen and persisted in
`audit_logs`. Every `auth_service` operation calls
`logAuditAction(...)` so we have evidence of who logged in and when.

---

## 15. One-paragraph summary (for the elevator-pitch question)

PAMS is a Windows desktop application written in **Dart with the
Flutter framework**, backed by an embedded **SQLite** database accessed
through a singleton `DatabaseService`. Routing is centralised in
`AppRoutes`, state is managed by a single `Provider`-based
`AuthProvider`, and authentication is handled by `AuthService` using
**bcrypt** with a per-password salt, account lockout and an
`audit_logs` trail. Authorisation is centralised in
[lib/core/security/rbac.dart](lib/core/security/rbac.dart) as a
permission matrix and enforced **both** in the navigation and at the
service layer. Each business entity has a dedicated service that
talks to SQLite via parameterised queries, so the UI never builds raw
SQL. The Reports screen aggregates per-city occupancy, financials and
maintenance costs, and exports them as PDF/Excel through the
`pdf` + `printing` packages.
