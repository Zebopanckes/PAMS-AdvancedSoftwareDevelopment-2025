# PAMS Development Checklist

Tracks spec-to-implementation coverage for UFCF8S-30-2 (Paragon Apartment
Management System). Items are grouped by the specification's requirement
areas. All boxes below are completed unless explicitly marked `[ ]`.

## Foundation

- [x] Flutter desktop project (Windows / Linux / macOS via `sqflite_ffi`)
- [x] `pubspec.yaml` dependencies (Provider, sqflite, pdf, printing, intl,
      fl_chart, flutter_animate, crypto, uuid)
- [x] Material 3 theme (`calmBlue` #2563EB / `vibrantYellow` #FBBF24)
- [x] Route table with 11 named routes and fade transitions
- [x] `AppShell` navigation rail shared across feature screens
- [x] SQLite schema v2 covering users, tenants, apartments, leases,
      invoices, payments, maintenance, complaints, audit logs
- [x] Seed data for default admin + per-role/per-city demo users

## Authentication & Security

- [x] SHA-256 password hashing
- [x] Account lockout after 5 failed attempts (15 minute cooldown)
- [x] 2-hour rolling session timeout
- [x] Audit log on every login / logout / failed attempt
- [x] RBAC: `Permission` enum (20 permissions) + 5-role matrix in
      `lib/core/security/rbac.dart`
- [x] Role-scoped navigation (items hidden when user lacks permission)
- [x] Per-city scoping for manager / finance / maintenance / frontDesk users

## Tenant Management (front-desk + admin)

- [x] Tenant list with search, city filter and status filter
- [x] Tenant form with UK-specific validation
  - [x] National Insurance number regex `[A-Z]{2}\d{6}[A-D]`
  - [x] Email + UK phone validators
  - [x] NI number locked on edit (integrity)
- [x] Lease period, apartment requirements, references, emergency contact
- [x] Tenant detail screen: profile + active lease + payments +
      maintenance + complaints in one view
- [x] Early termination workflow launched from tenant detail (spec rule:
      1-month notice, 5% monthly-rent penalty — confirmation dialog shows
      the calculated amount before committing)

## Apartment Management (admin / manager)

- [x] Grid of apartment cards with status chips (vacant / occupied /
      under maintenance / reserved)
- [x] Filters: city, status, minimum bedrooms, free-text search
- [x] Full CRUD form (city, type, floor, beds, baths, area, rent, status)
- [x] Permission-gated FAB + delete action

## Lease Management

- [x] Lease list with tenant + apartment resolution, status chips
- [x] Warning banner for leases expiring within 60 days
- [x] Lease form filters apartments to vacant-only (service-level guard
      also present) to prevent double-booking
- [x] Auto-default end date 12 months after start; rent auto-populated
      from selected apartment
- [x] Early termination service method records penalty, termination
      notice date and flips apartment to vacant

## Billing & Invoicing (finance)

- [x] Tabbed screen: Invoices / Payments
- [x] Summary cards: total collected, outstanding, invoice count,
      payment count
- [x] Issue invoice dialog (lease picker, billing period, due-days)
- [x] Record payment dialog (amount, method, reference) that reconciles
      partial → paid status on invoices
- [x] Mark-overdue pass runs automatically on screen load
- [x] PDF preview / print for invoices and receipts (Printing package)

## Maintenance Lifecycle

- [x] List with status + priority filters and priority-coloured icons
- [x] Create request form (apartment, title, description, priority)
- [x] Assign dialog records assignee + scheduled date (spec: tenant is
      informed of the scheduled time)
- [x] Resolve dialog captures notes, hours spent and cost (spec: staff
      log time for each job)
- [x] Cost + hour totals surfaced on the reports screen

## Complaints (front-desk)

- [x] List with create dialog (tenant picker, category, description)
- [x] Logged-by captured from current session user
- [x] Popup menu on each row changes status; resolved/closed auto-stamps
      `resolved_date`

## User Administration (admin only)

- [x] Screen gated behind `Permission.manageUsers`
- [x] DataTable: username, name, role, city, last login, active switch
- [x] Create-user dialog with role + city dropdowns
- [x] Reset-password dialog
- [x] Active toggle via `UserService.setActive`

## Reports (admin / manager / finance)

- [x] Occupancy bar chart (fl_chart) per city with occupied / vacant /
      under-maintenance rods
- [x] Occupancy table with occupancy-rate %
- [x] Financial table: collected vs outstanding per city
- [x] Maintenance table: request count, hours, cost per city

## Quality & Delivery

- [x] `flutter analyze` — 0 errors (5 informational lints remain)
- [x] `flutter build windows --debug` — succeeds
- [x] Unit tests: `test/domain_tests.dart` — validators, lease penalty,
      RBAC matrix (11 assertions)
- [x] Unit tests: `test/auth_service_test.dart` — password hashing
- [x] Seed on first launch via `SeedService().seedIfEmpty()` in `main.dart`
- [x] Agile methodology write-up (`docs/AGILE_METHODOLOGY.md`)
- [x] Test-cases deliverable (`docs/TEST_CASES.md`)

## Deferred / Out of Scope

- [ ] Biometric auth (package imported but not wired — desktop target
      does not provide a reliable biometric provider)
- [ ] Two-factor auth flow (schema column exists, UI deferred)
- [ ] Real payment gateway (spec explicitly treats PAMS as a demonstration
      system; receipts are generated locally)
# PAMS Development Checklist

## ✅ Completed - Foundation Phase

### Project Setup
- [x] Create Flutter project structure
- [x] Configure pubspec.yaml with all dependencies
- [x] Setup .gitignore
- [x] Create assets directories
- [x] Create test directory structure

### Core Infrastructure
- [x] Database service with complete schema
- [x] Authentication service with password hashing
- [x] User model with role-based access
- [x] Route management system
- [x] App theme configuration
- [x] State management setup (Provider)

### Authentication Module
- [x] Splash screen with animations
- [x] Login screen with validation
- [x] Auth provider for state management
- [x] Session management
- [x] Logout functionality
- [x] Default admin account creation

### Dashboard
- [x] Dashboard layout
- [x] Statistics cards
- [x] Quick action cards
- [x] Navigation to all modules
- [x] User profile display
- [x] Animations and transitions

### Documentation
- [x] Project README
- [x] Setup guide
- [x] Development guide
- [x] Project summary
- [x] Quick reference card
- [x] Code comments

---

## 🔄 In Progress - Feature Development

### Tenant Management Module

#### Data Layer
- [ ] Create complete TenantModel class
- [ ] Create TenantService for CRUD operations
- [ ] Implement database queries
- [ ] Add data validation logic
- [ ] Create TenantProvider for state management

#### UI Layer
- [ ] Build tenants list screen
  - [ ] Data table/list view
  - [ ] Search functionality
  - [ ] Filter by status
  - [ ] Sort options
  - [ ] Pagination
- [ ] Create tenant detail screen
  - [ ] Display all tenant information
  - [ ] Show lease history
  - [ ] Show payment history
  - [ ] Show maintenance requests
- [ ] Build add tenant form
  - [ ] Input validation
  - [ ] Date pickers
  - [ ] Phone number formatting
  - [ ] Email validation
  - [ ] ID number validation
- [ ] Build edit tenant form
  - [ ] Pre-populate fields
  - [ ] Update functionality
  - [ ] Change tracking
- [ ] Add delete confirmation dialog
- [ ] Implement status change (active/inactive/moved out)

#### Testing
- [ ] Unit tests for TenantModel
- [ ] Unit tests for TenantService
- [ ] Widget tests for tenant screens
- [ ] Integration tests

---

### Apartment Management Module

#### Data Layer
- [ ] Create ApartmentModel class
- [ ] Create ApartmentService for CRUD operations
- [ ] Implement database queries
- [ ] Add data validation
- [ ] Create ApartmentProvider

#### UI Layer
- [ ] Build apartments list screen
  - [ ] Grid/list view toggle
  - [ ] Filter by status (vacant/occupied/maintenance)
  - [ ] Filter by location
  - [ ] Filter by bedrooms
  - [ ] Sort options
  - [ ] Search functionality
- [ ] Create apartment detail screen
  - [ ] Property information
  - [ ] Current tenant info
  - [ ] Lease information
  - [ ] Maintenance history
  - [ ] Photo gallery
- [ ] Build add apartment form
  - [ ] Property details inputs
  - [ ] Rent amount
  - [ ] Features checklist
  - [ ] Photo upload
- [ ] Build edit apartment form
  - [ ] Update property details
  - [ ] Change rent amount
  - [ ] Update status
- [ ] Implement occupancy tracking
- [ ] Add availability calendar

#### Testing
- [ ] Unit tests for ApartmentModel
- [ ] Unit tests for ApartmentService
- [ ] Widget tests for apartment screens
- [ ] Integration tests

---

### Lease Management Module

#### Data Layer
- [ ] Create LeaseModel class
- [ ] Create LeaseService for CRUD operations
- [ ] Link tenants to apartments
- [ ] Implement lease status tracking
- [ ] Create LeaseProvider

#### UI Layer
- [ ] Build lease agreements list
- [ ] Create new lease form
  - [ ] Tenant selection
  - [ ] Apartment selection
  - [ ] Date range picker
  - [ ] Terms and conditions editor
  - [ ] Rent and deposit amounts
- [ ] View lease agreement details
- [ ] Renew lease functionality
- [ ] Terminate lease functionality
- [ ] Lease document generation (PDF)

#### Testing
- [ ] Unit tests for LeaseModel
- [ ] Unit tests for LeaseService
- [ ] Widget tests
- [ ] Integration tests

---

### Payment Management Module

#### Data Layer
- [ ] Create PaymentModel class
- [ ] Create PaymentService for CRUD operations
- [ ] Implement payment calculations
- [ ] Track payment status
- [ ] Create PaymentProvider

#### UI Layer
- [ ] Build payments list screen
  - [ ] Filter by date range
  - [ ] Filter by status (paid/pending/overdue)
  - [ ] Filter by tenant
  - [ ] Search functionality
- [ ] Create payment recording form
  - [ ] Tenant selection
  - [ ] Amount input
  - [ ] Payment method
  - [ ] Reference number
  - [ ] Receipt generation
- [ ] Build payment history view
- [ ] Implement invoice generation (PDF)
  - [ ] Company branding
  - [ ] Itemized billing
  - [ ] Due dates
  - [ ] Payment instructions
- [ ] Create payment reminders system
- [ ] Add overdue payment alerts
- [ ] Build payment analytics dashboard

#### Testing
- [ ] Unit tests for PaymentModel
- [ ] Unit tests for PaymentService
- [ ] PDF generation tests
- [ ] Widget tests
- [ ] Integration tests

---

### Maintenance Management Module

#### Data Layer
- [ ] Create MaintenanceRequestModel class
- [ ] Create MaintenanceService for CRUD operations
- [ ] Implement priority system
- [ ] Track request status
- [ ] Create MaintenanceProvider

#### UI Layer
- [ ] Build maintenance requests list
  - [ ] Filter by status
  - [ ] Filter by priority
  - [ ] Filter by apartment
  - [ ] Sort by date/priority
- [ ] Create maintenance request form
  - [ ] Apartment selection
  - [ ] Issue description
  - [ ] Priority selection
  - [ ] Photo attachment
  - [ ] Category selection
- [ ] Build request detail screen
  - [ ] Full request information
  - [ ] Status timeline
  - [ ] Staff assignment
  - [ ] Cost tracking
  - [ ] Completion notes
- [ ] Implement staff assignment
  - [ ] User selection (maintenance role)
  - [ ] Notification to assigned staff
- [ ] Add status update functionality
- [ ] Build completion form
  - [ ] Work performed notes
  - [ ] Cost entry
  - [ ] Before/after photos

#### Testing
- [ ] Unit tests for MaintenanceRequestModel
- [ ] Unit tests for MaintenanceService
- [ ] Widget tests
- [ ] Integration tests

---

### Reporting Module

#### Report Types
- [ ] Occupancy report
  - [ ] Current occupancy rate
  - [ ] Historical trends
  - [ ] By location
  - [ ] Vacancy duration
- [ ] Financial report
  - [ ] Total rent collected
  - [ ] Outstanding payments
  - [ ] Revenue by period
  - [ ] Expense tracking
- [ ] Maintenance report
  - [ ] Open requests
  - [ ] Completed requests
  - [ ] Cost analysis
  - [ ] Average resolution time
- [ ] Tenant report
  - [ ] Active tenants
  - [ ] Move-ins/move-outs
  - [ ] Tenant demographics
  - [ ] Lease expirations

#### Features
- [ ] Date range selection
- [ ] Export to PDF
- [ ] Export to Excel
- [ ] Email reports
- [ ] Schedule automated reports
- [ ] Custom report builder

#### Visualizations
- [ ] Bar charts (revenue, occupancy)
- [ ] Line charts (trends)
- [ ] Pie charts (distributions)
- [ ] Interactive dashboards

---

### Advanced Features

#### Security Enhancements
- [ ] Implement MFA (Two-Factor Authentication)
  - [ ] Setup screen
  - [ ] QR code generation
  - [ ] Verification during login
- [ ] Password strength requirements
- [ ] Password reset functionality
- [ ] Session timeout
- [ ] Account lockout after failed attempts
- [ ] IP address tracking

#### Notifications System
- [ ] In-app notifications
- [ ] Email notifications
- [ ] Payment due reminders
- [ ] Lease expiration alerts
- [ ] Maintenance updates
- [ ] System announcements

#### Search & Filters
- [ ] Global search functionality
- [ ] Advanced filter builder
- [ ] Saved search queries
- [ ] Search history

#### User Management
- [ ] User list screen
- [ ] Add/edit user forms
- [ ] Role assignment
- [ ] Permission management
- [ ] User activity logs
- [ ] Deactivate/activate users

#### Settings Module
- [ ] Company profile settings
- [ ] System preferences
- [ ] Email configuration
- [ ] Notification settings
- [ ] Backup/restore functionality
- [ ] Data export

#### Multi-language Support
- [ ] Internationalization setup
- [ ] Language selection
- [ ] Translation files
- [ ] RTL support

---

## Testing & Quality Assurance

### Unit Tests
- [ ] All models tested
- [ ] All services tested
- [ ] All providers tested
- [ ] Edge cases covered
- [ ] Error handling tested

### Widget Tests
- [ ] All screens tested
- [ ] All custom widgets tested
- [ ] Form validation tested
- [ ] Navigation tested

### Integration Tests
- [ ] User flow: Login → Dashboard
- [ ] User flow: Create tenant → Assign apartment
- [ ] User flow: Record payment → Generate invoice
- [ ] User flow: Create maintenance → Assign → Complete
- [ ] User flow: Generate reports

### Performance Tests
- [ ] Large dataset handling
- [ ] Database query optimization
- [ ] Memory leak detection
- [ ] UI responsiveness

### User Acceptance Testing
- [ ] Admin role testing
- [ ] Manager role testing
- [ ] Finance role testing
- [ ] Maintenance role testing
- [ ] Front desk role testing

---

## Polish & Finalization

### UI/UX Refinement
- [ ] Consistent spacing and alignment
- [ ] Error message improvements
- [ ] Loading states for all operations
- [ ] Empty states for all lists
- [ ] Confirmation dialogs
- [ ] Success/error feedback
- [ ] Keyboard shortcuts
- [ ] Tooltips and help text

### Animations
- [ ] Page transitions
- [ ] List item animations
- [ ] Button feedback
- [ ] Loading animations
- [ ] Success animations
- [ ] Error animations

### Accessibility
- [ ] Screen reader support
- [ ] Keyboard navigation
- [ ] Color contrast compliance
- [ ] Font size options
- [ ] Focus indicators

### Performance Optimization
- [ ] Database indexing
- [ ] Query optimization
- [ ] Image optimization
- [ ] Lazy loading
- [ ] Caching strategy

### Code Quality
- [ ] Code review
- [ ] Remove dead code
- [ ] Consistent formatting
- [ ] Documentation updates
- [ ] Comment cleanup
- [ ] Refactor duplicate code

---

## Documentation

### User Documentation
- [ ] User manual
- [ ] Quick start guide
- [ ] Video tutorials
- [ ] FAQ document
- [ ] Troubleshooting guide

### Technical Documentation
- [ ] API documentation
- [ ] Database schema documentation
- [ ] Architecture diagrams
- [ ] Deployment guide
- [ ] Maintenance guide

### Project Documentation
- [ ] Final project report
- [ ] Test cases document
- [ ] Known issues/limitations
- [ ] Future enhancements roadmap
- [ ] Individual contribution summary

---

## Deployment Preparation

### Build & Package
- [ ] Test release build
- [ ] Create installer
- [ ] Code signing
- [ ] Version numbering
- [ ] Changelog creation

### Deployment
- [ ] Installation guide
- [ ] System requirements document
- [ ] Backup strategy
- [ ] Rollback plan

### Submission
- [ ] Zip project files
- [ ] Include all documentation
- [ ] Verify all requirements met
- [ ] Prepare demo presentation
- [ ] Prepare viva questions/answers

---

## Viva Preparation

### Technical Questions
- [ ] Explain architecture decisions
- [ ] Discuss design patterns used
- [ ] Explain database schema
- [ ] Discuss security measures
- [ ] Explain state management choice

### Demo Script
- [ ] Login and authentication
- [ ] Dashboard overview
- [ ] Tenant management demo
- [ ] Payment processing demo
- [ ] Maintenance tracking demo
- [ ] Report generation demo
- [ ] User management demo

### Challenges & Solutions
- [ ] Document challenges faced
- [ ] Explain solutions implemented
- [ ] Discuss alternative approaches
- [ ] Lessons learned

---

## Progress Tracking

**Overall Progress**: Foundation Complete (25%)

**Current Phase**: Feature Development

**Next Milestone**: Tenant Management Module Complete

**Target Completion Date**: [Add your date]

---

**Last Updated**: [Current Date]

**Notes**: Update this checklist as you complete each item. Use it to track progress and ensure nothing is missed.
