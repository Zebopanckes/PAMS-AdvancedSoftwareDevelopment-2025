# PAMS - Contribution Map (for Demonstration)

This document lists, per team member, the source files that carry their
authorship credit. It is intended as a quick reference during the viva/demo
so each member can speak to the files attributed to them.

---

## Saynab Saleh (23000156) - System Analyst

Responsible for domain modelling, routing, and visual theming (structural
analysis of the system).

**Domain models (`lib/core/models/`)**

- [apartment_model.dart](lib/core/models/apartment_model.dart)
- [complaint_model.dart](lib/core/models/complaint_model.dart)
- [invoice_model.dart](lib/core/models/invoice_model.dart)
- [lease_model.dart](lib/core/models/lease_model.dart)
- [maintenance_model.dart](lib/core/models/maintenance_model.dart)
- [payment_model.dart](lib/core/models/payment_model.dart)
- [tenant_model.dart](lib/core/models/tenant_model.dart)
- [user_model.dart](lib/core/models/user_model.dart)

**Routing & theme**

- [lib/core/routes/app_routes.dart](lib/core/routes/app_routes.dart)
- [lib/core/theme/app_theme.dart](lib/core/theme/app_theme.dart)

---

## Douaa Tadli (23012698) - Backend Developer

Responsible for the data/service layer, authentication, RBAC security, and
the auth state provider that bridges backend to the UI.

**Security**

- [lib/core/security/rbac.dart](lib/core/security/rbac.dart)

**Services (`lib/core/services/`)**

- [apartment_service.dart](lib/core/services/apartment_service.dart)
- [auth_service.dart](lib/core/services/auth_service.dart)
- [billing_service.dart](lib/core/services/billing_service.dart)
- [city_service.dart](lib/core/services/city_service.dart)
- [database_service.dart](lib/core/services/database_service.dart)
- [lease_service.dart](lib/core/services/lease_service.dart)
- [maintenance_service.dart](lib/core/services/maintenance_service.dart)
- [pdf_export_service.dart](lib/core/services/pdf_export_service.dart)
- [report_service.dart](lib/core/services/report_service.dart)
- [seed_service.dart](lib/core/services/seed_service.dart)
- [tenant_service.dart](lib/core/services/tenant_service.dart)
- [user_service.dart](lib/core/services/user_service.dart)

**Auth state provider**

- [lib/features/auth/presentation/providers/auth_provider.dart](lib/features/auth/presentation/providers/auth_provider.dart)

---

## Ashley Shoniwa (24021297) - Frontend Developer

Responsible for all user-facing screens, shared UI widgets, and background
visuals.

**Shared UI (`lib/core/`)**

- [screens/silk_background_demo.dart](lib/core/screens/silk_background_demo.dart)
- [widgets/app_shell.dart](lib/core/widgets/app_shell.dart)
- [widgets/aurora_background.dart](lib/core/widgets/aurora_background.dart)
- [widgets/silk_background.dart](lib/core/widgets/silk_background.dart)

**Feature screens (`lib/features/`)**

- Apartments
  - [apartments_list_screen.dart](lib/features/apartments/presentation/screens/apartments_list_screen.dart)
  - [apartment_form_screen.dart](lib/features/apartments/presentation/screens/apartment_form_screen.dart)
- Auth
  - [login_screen.dart](lib/features/auth/presentation/screens/login_screen.dart)
  - [splash_screen.dart](lib/features/auth/presentation/screens/splash_screen.dart)
- Cities
  - [cities_list_screen.dart](lib/features/cities/presentation/screens/cities_list_screen.dart)
- Complaints
  - [complaints_list_screen.dart](lib/features/complaints/presentation/screens/complaints_list_screen.dart)
- Dashboard
  - [dashboard_screen.dart](lib/features/dashboard/presentation/screens/dashboard_screen.dart)
  - [widgets/dashboard_card.dart](lib/features/dashboard/presentation/widgets/dashboard_card.dart)
  - [widgets/stat_card.dart](lib/features/dashboard/presentation/widgets/stat_card.dart)
- Leases
  - [leases_list_screen.dart](lib/features/leases/presentation/screens/leases_list_screen.dart)
  - [lease_form_screen.dart](lib/features/leases/presentation/screens/lease_form_screen.dart)
- Maintenance
  - [maintenance_list_screen.dart](lib/features/maintenance/presentation/screens/maintenance_list_screen.dart)
  - [maintenance_form_screen.dart](lib/features/maintenance/presentation/screens/maintenance_form_screen.dart)
- Payments / Billing
  - [billing_screen.dart](lib/features/payments/presentation/screens/billing_screen.dart)
- Reports
  - [reports_screen.dart](lib/features/reports/presentation/screens/reports_screen.dart)
- Tenants
  - [tenants_list_screen.dart](lib/features/tenants/presentation/screens/tenants_list_screen.dart)
  - [tenant_detail_screen.dart](lib/features/tenants/presentation/screens/tenant_detail_screen.dart)
  - [tenant_form_screen.dart](lib/features/tenants/presentation/screens/tenant_form_screen.dart)
- Users
  - [users_list_screen.dart](lib/features/users/presentation/screens/users_list_screen.dart)

---

## Okan Kaynak (23035729) - Quality & Documentation Specialist

Responsible for the automated test suite and the supporting database dump
tool used to produce evidence artefacts.

**Tests (`test/`)**

- [auth_service_test.dart](test/auth_service_test.dart)
- [domain_test.dart](test/domain_test.dart)
- [widget_test.dart](test/widget_test.dart)

**Tooling (`tool/`)**

- [dump_db.dart](tool/dump_db.dart)
