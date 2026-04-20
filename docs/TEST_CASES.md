# PAMS – Test Cases

Covers functional, security and role-based tests. Automated rows reference
the test file under `test/`. Manual rows are the acceptance script run
against the built Windows binary with seeded demo accounts.

## Automated

| ID    | Area              | Steps                                                                      | Expected result                                             | Status |
|-------|-------------------|----------------------------------------------------------------------------|-------------------------------------------------------------|--------|
| AUTH-01 | Password hashing | Hash `"testPassword123"` twice; hash a different password once             | Same input → same hash; different input → different hash    | Pass (`auth_service_test.dart`) |
| VAL-01 | NI number        | `isValidNiNumber("AB123456C")`                                             | `true`                                                       | Pass (`domain_tests.dart`) |
| VAL-02 | NI number        | `isValidNiNumber("12345678")`                                              | `false`                                                      | Pass |
| VAL-03 | Email            | `isValidEmail("jane.doe@example.co.uk")`                                   | `true`                                                       | Pass |
| VAL-04 | UK phone         | `isValidUkPhone("+441179876543")`                                          | `true`                                                       | Pass |
| LSE-01 | Early termination | 12-month lease at £1200/mo → `computeEarlyTerminationPenalty()`             | `60.0` (5% of monthly rent, per spec)                        | Pass |
| LSE-02 | Lease duration   | start 01/01/2025, end 01/01/2026 → `durationMonths()`                      | `12`                                                         | Pass |
| RBAC-01 | Admin            | `Rbac.can(admin, manageUsers)`, `deleteTenant`, `viewReports`, `managePayments` | All `true`                                               | Pass |
| RBAC-02 | Front desk      | `Rbac.can(frontDesk, manageUsers)`, `manageApartments`                     | Both `false`; `viewTenants` `true`                           | Pass |
| RBAC-03 | Finance         | `Rbac.can(finance, managePayments)` / `manageApartments`                   | `true` / `false`                                             | Pass |
| RBAC-04 | Null user       | `Rbac.can(null, viewTenants)`                                              | `false`                                                      | Pass |

Command: `flutter test test/domain_tests.dart test/auth_service_test.dart`
→ `All tests passed!` (11 assertions).

## Manual acceptance

Credentials used: `admin / admin123`, `manager_bristol / Password123!`,
`finance_bristol / Password123!`, `maintenance_bristol / Password123!`,
`frontdesk_bristol / Password123!`.

| ID     | Area              | Steps                                                                                                                        | Expected result                                                                                    |
|--------|-------------------|------------------------------------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------|
| ACC-01 | Lockout          | Log in as `admin` with wrong password 5 times; try correct password on 6th.                                                 | 6th attempt refused with lockout message; audit log records failures; retry after 15 min succeeds. |
| ACC-02 | Session timeout  | Log in, idle the app for >2 hours.                                                                                          | User is redirected to login on next action.                                                         |
| ACC-03 | RBAC – front desk | Log in as `frontdesk_bristol`; inspect sidebar and dashboard tiles.                                                         | Users, Apartments (manage) and Reports (admin-only parts) are hidden; Tenants / Complaints shown.   |
| ACC-04 | Per-city scoping | Log in as `manager_bristol`; open Apartments filter.                                                                        | Default city filter is Bristol; tenants/apartments list shows Bristol data.                         |
| TEN-01 | Tenant validation | Create a tenant with NI `"ABC123"`.                                                                                         | Form rejects with "Invalid NI number" message; save disabled.                                       |
| TEN-02 | NI immutability  | Edit an existing tenant.                                                                                                    | NI field is disabled; other fields editable.                                                        |
| APT-01 | Apartment CRUD   | Admin adds a new vacant apartment in Cardiff; edits it; deletes it.                                                         | Apartment appears in list, update reflected, deletion confirmed.                                    |
| LSE-03 | Lease creation   | Create a lease for a vacant apartment in Bristol.                                                                           | Apartment status flips to `occupied`; lease shows in Leases list; rent auto-filled from apartment.  |
| LSE-04 | Double-booking   | Try to create a second lease for the same apartment.                                                                        | Apartment no longer available in the lease form dropdown.                                           |
| LSE-05 | Early termination | From tenant detail, choose "Request early termination".                                                                     | Dialog shows "£{rent × 5%} penalty"; on confirm lease becomes `terminatedEarly`, apartment vacant.  |
| BIL-01 | Issue invoice    | Finance issues an invoice for an active lease (period: current month, due in 14 days).                                      | Invoice appears as `pending`; outstanding total increases by invoice amount.                        |
| BIL-02 | Record payment   | Finance records full payment against the invoice.                                                                           | Invoice flips to `paid`; collected total increases; outstanding decreases.                          |
| BIL-03 | Partial payment  | Record payment < invoice amount.                                                                                            | Invoice flips to `partial`; outstanding reduced by the payment amount.                             |
| BIL-04 | PDF preview      | Click PDF icon on an invoice.                                                                                               | Printing preview opens with the invoice + apartment + tenant + any payments.                        |
| BIL-05 | Overdue pass     | Advance system date past an invoice due date, open Billing.                                                                 | Invoice status moves to `overdue` automatically.                                                    |
| MNT-01 | Create + assign  | Front-desk creates a high-priority request; admin assigns a worker + scheduled date.                                        | Status = `scheduled`; assignee set; scheduled date stored.                                          |
| MNT-02 | Resolve          | Maintenance worker resolves the request with 2.5 hrs and £45 cost.                                                          | Status = `resolved`; hours + cost persisted; reports screen totals update.                          |
| CMP-01 | Complaint log    | Front-desk logs a complaint against a tenant; changes status to `resolved`.                                                 | Complaint added with `logged_by` = current user; `resolved_date` stamped on status change.         |
| USR-01 | User admin       | Admin creates `manager_cardiff`; resets password; toggles inactive.                                                         | Account shows in user list; deactivated users cannot log in.                                        |
| RPT-01 | Occupancy chart  | Admin opens Reports.                                                                                                        | Bar chart shows 4 cities; rates calculated as occupied / total.                                     |
| RPT-02 | Financial report | Reports → Financial.                                                                                                        | Collected + outstanding per city matches Billing totals.                                            |
