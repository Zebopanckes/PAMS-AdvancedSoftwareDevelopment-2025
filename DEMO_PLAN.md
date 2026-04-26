# PAMS - Demonstration Plan & Speaker Notes

> Reference document for the viva/demo session. Use it as a script outline,
> not a verbatim read-out. The 30-minute slot may be interrupted by tutor
> questions at any point, so every section ends with a "be ready for"
> prompt list.

**Group:**

| Name           | ID       | Role                               |
| -------------- | -------- | ---------------------------------- |
| Alec Brothwood | 23076824 | Project Manager                    |
| Saynab Saleh   | 23000156 | System Analyst                     |
| Douaa Tadli    | 23012698 | Backend Developer                  |
| Ashley Shoniwa | 24021297 | Frontend Developer                 |
| Okan Kaynak    | 23035729 | Quality & Documentation Specialist |

**Project:** Paragon Apartment Management System (PAMS) - Flutter desktop app
on Windows, SQLite backing store.

**Marking weight:** Demo 15 marks + Individual Q&A 10 marks = 25% of module.
Pass mark per task is 40%.

---

## 1. Suggested time budget (30-min slot)

| Mins  | Phase                                   | Lead           |
| ----- | --------------------------------------- | -------------- |
| 0-2   | Intro, group, project pitch             | Alec           |
| 2-5   | Methodology (Scrumban) & Agile evidence | Alec / Okan    |
| 5-9   | Design walkthrough (UML diagrams)       | Saynab         |
| 9-15  | Live system demo (happy path)           | Ashley + Alec  |
| 15-19 | Backend / security deep-dive            | Douaa          |
| 19-23 | Testing evidence                        | Okan           |
| 23-26 | Non-functional requirements & DB        | Douaa / Saynab |
| 26-30 | Q&A buffer                              | All            |

If tutor asks questions inline, assume that buffer is gone - keep each
section tight.

---

## 2. Opening pitch (Alec, ~2 min)

> "Paragon is a UK apartment management company operating across Bristol,
> Cardiff, London and Manchester. Their existing process is paper-based,
> per-office, and has no role-based access control. PAMS replaces that with
> a single Windows desktop application backed by a SQLite database. It
> covers user/account management, tenants, apartments, leases, payments and
> billing, maintenance, complaints and reporting - the six core components
> in the brief plus complaints and city-level expansion as added value."

Key points to land:

- Desktop application (the spec forbids websites).
- Built on Flutter / Dart - **tutor-approved** alternative to the suggested
  Python; Dart is a modern object-oriented language and Flutter gives a
  consistent native Windows desktop GUI.
- 5 user roles match the spec (Admin, Manager, Finance, Maintenance,
  Front-desk) plus a dedicated tenant view via the audit log.
- Persistence: bundled SQLite database, seeded with demo data on first
  launch. A MySQL-style dump (`pams_dump.sql`) is also provided.

Be ready for:

- "Why not Python?" -> OOP requirement satisfied; Flutter chosen for
  cross-platform desktop GUI quality and our prior team familiarity.
- "Why SQLite not MySQL?" -> Spec says relevant database; SQLite is a
  zero-install relational DB ideal for a single desktop deployment, the
  schema is portable, and we provide a SQL dump.

---

## 3. Methodology - Scrumban (Alec, ~3 min)

Use the wording from the project report:

> "We used an Agile Scrumban approach - a hybrid of Scrum's sprint
> structure and Kanban's work-in-progress limits (Atlassian, 2024). Scrum
> gave us the weekly rhythm: planning, review and retrospective. Kanban
> kept individual workload manageable by restricting each developer to
> one active task at a time. This suited a 5-person team with a finite
> development window."

Concrete evidence to point at:

- Git commit history (per-member commits show contribution).
- File header attribution (`// Author: ...`) on every source file.
- [CONTRIBUTIONS.md](CONTRIBUTIONS.md) maps every member to the files they
  authored / co-authored.
- [CHECKLIST.md](CHECKLIST.md) was the working sprint board.
- Roles map cleanly to a Scrum team: PM, Analyst, Backend, Frontend, QA/Docs.

Be ready for:

- "Why not pure Scrum?" -> Pure Scrum needs a dedicated SM and PO; with
  five students and one tutor as proxy product owner, Kanban's flow model
  was a better fit for individual cadence.
- "What was a sprint length?" -> Weekly mini-sprints aligned with lab
  sessions.

---

## 4. Design walkthrough (Saynab, ~4 min)

The PDF deliverable contains the use-case, class and sequence diagrams.
Flip to it on screen and walk through:

1. **Use-case diagram** - five actors (Admin, Manager, Finance,
   Maintenance, Front-desk) plus Tenant as a passive actor; key use cases
   include `Register Tenant`, `Assign Apartment`, `Generate Invoice`,
   `Log Maintenance`, `Generate Reports`.
2. **Class diagram** - point at the domain models in
   [lib/core/models/](lib/core/models/). Highlight relationships:
   `Tenant` <-> `Lease` <-> `Apartment` <-> `City`; `Invoice` /
   `Payment` against `Lease`; `MaintenanceRequest` against `Apartment`
   and `Tenant`; `User` carries a `UserRole`.
3. **Sequence diagrams** (at least three, per spec):
   - Login + RBAC enforcement.
   - Front-desk registers a tenant and assigns an apartment.
   - Finance generates an invoice and a tenant pays it.

Be ready for:

- "Show me where this class is in code" -> Open
  [lib/core/models/tenant_model.dart](lib/core/models/tenant_model.dart)
  etc. The class diagram and the model files are 1-to-1.
- "Why is `complaints` a separate model?" -> Spec lists complaint logs as
  a tenant-management concern; we modelled it explicitly so it can be
  filtered and reported on.

---

## 5. Live system demo (Ashley + Alec, ~6 min)

Run the app from a clean state if possible (`flutter run -d windows`).
The seeder populates 4 cities, staff for each, ~12 tenants, apartments,
leases, invoices and a few maintenance tickets, so there is data on
screen immediately.

Demo flow (rehearsed happy path):

1. **Login as `admin / admin123`** -> show admin dashboard with the
   global stats and per-city charts.
2. **Switch to `front_bristol / Password123!`** to demonstrate
   role-based UI:
   - Front-desk **can** add a new tenant and log a complaint.
   - Front-desk **cannot** see Finance reports - the navigation hides
     those screens (RBAC).
3. **Front-desk: register a new tenant.** Fill the form (name, NI
   number, email, occupation, references, etc.), submit, show it in the
   tenants list, then assign them to an apartment via a lease.
4. **Switch to `finance_bristol`** -> generate an invoice for the new
   lease, mark a payment, show the invoice PDF export.
5. **Switch to `maint_bristol`** -> pick up a maintenance request,
   log resolution time and cost.
6. **Switch to `manager_bristol`** -> open the Reports screen, show
   occupancy, financial summary (collected vs. pending) and maintenance
   cost report. Export one to PDF.
7. **Switch to `manager_london`** -> use the Cities screen to add a
   new city ("expand business" requirement), then show that the new
   city is empty until staff/apartments are added.

Be ready for:

- "Show me the early-termination penalty" -> Open a lease and trigger
  early termination; system charges 5% of monthly rent (per spec).
- "What if I enter a past date?" -> Forms validate against past dates
  for leases / maintenance bookings.
- "Where is the audit log?" -> Show the audit table in the DB or the
  admin-visible log view.

---

## 6. Backend & security deep-dive (Douaa, ~4 min)

Open these files on screen as you talk:

- [lib/core/services/auth_service.dart](lib/core/services/auth_service.dart) -
  login flow, **bcrypt** password hashing (not plain SHA, not plain text),
  failed-login lockout, audit logging.
- [lib/core/security/rbac.dart](lib/core/security/rbac.dart) -
  centralised role -> permission matrix; UI screens query this rather
  than hard-coding role checks, so a new role only needs one change.
- [lib/core/services/database_service.dart](lib/core/services/database_service.dart) -
  parameterised SQL via `sqflite`, no string concatenation, so SQL
  injection is structurally impossible.
- [lib/features/auth/presentation/providers/auth_provider.dart](lib/features/auth/presentation/providers/auth_provider.dart) -
  session state in memory only, cleared on logout; no plaintext password
  in `SharedPreferences`.

Security non-functional requirements covered:

- **Authentication:** bcrypt hashing with salt; configurable cost.
- **Authorisation:** RBAC enforced at the service layer **and** the
  navigation layer (defence in depth).
- **Audit:** every login, role change and destructive action is written
  to an `audit_log` table.
- **Input validation:** form validators on every screen + service-layer
  guards (e.g. invoice amount > 0, NI number format).
- **Data isolation:** managers/finance/maintenance/front-desk see only
  their assigned city. Admin (per spec) has full access to a single
  location; the Manager actor is the cross-city role.

Be ready for:

- "Show me where you stop a SQL injection" -> Point at any `db.query`
  call - all use `?` placeholders.
- "What happens if I forge a role?" -> The role lives in the DB; the
  client only holds a session token after bcrypt verification.

---

## 7. Testing evidence (Okan, ~4 min)

Open the test folder:

- [test/auth_service_test.dart](test/auth_service_test.dart) - unit
  tests for login, password hashing, lockout.
- [test/domain_test.dart](test/domain_test.dart) - unit tests on the
  domain models (validation rules, derived fields, e.g. lease
  early-termination penalty calculation).
- [test/widget_test.dart](test/widget_test.dart) - widget tests on
  shared UI (theme, smoke tests).

Then run:

```powershell
flutter test
```

and let the output scroll - all green. If there's time, point at
`test_results.json` / `test_results.txt` / `tests_expanded.txt` as
captured evidence.

Map this to what the lecture (Week 11) defined:

- **Unit testing** - covered by the three `*_test.dart` files.
- **Validation vs verification** - we verify the code matches design
  via unit tests, and validate behaviour matches the spec via the
  manual test-case table in the testing PDF.
- **Black-box** - the manual test cases (login with bad password,
  past date, negative rent, etc.).
- **White-box** - the unit tests target specific branches in the
  service classes (success path, failure path, lockout path).
- **Boundary values** - tested the lease penalty at exactly 1 month
  notice and at 0 days notice; tested rent at 0 and at large values.
- **Equivalence classes** - tested one valid email and several invalid
  formats rather than every possible string.

Be ready for:

- "How do you know how much you tested?" -> We have test cases for
  every public service method and every model invariant; the test
  table in the testing PDF lists ~N cases mapped to use cases
  (traceability).
- "Did any test ever fail?" -> Yes, originally the early-termination
  penalty rounded the wrong way; the failing unit test caught it
  before merge.

---

## 8. Non-functional requirements & database (Douaa / Saynab, ~3 min)

| NFR             | How we meet it                                                             |
| --------------- | -------------------------------------------------------------------------- |
| Security        | bcrypt, RBAC, audit log, parameterised SQL                                 |
| Efficiency      | Indexed SQLite tables, lazy loading on list screens                        |
| Scalability     | Pure relational schema portable to MySQL; SQL dump in `pams_dump.sql`    |
| Usability       | Consistent theme, role-aware navigation, form validation, PDF/Excel export |
| Maintainability | Feature-folder architecture, services injected via Provider                |

Database:

- SQLite at runtime (zero install); same schema works on MySQL.
- Tables: `users`, `cities`, `apartments`, `tenants`, `leases`,
  `invoices`, `payments`, `maintenance_requests`, `complaints`,
  `audit_log`.
- Dump: [pams_dump.sql](../pams_dump.sql) at repo root (sibling of the
  project folder).

Be ready for:

- "What about scalability for thousands of tenants?" -> Indexed FK
  columns, paginated list views; for true horizontal scaling the
  schema migrates unchanged to MySQL/Postgres.

---

## 9. Individual Q&A preparation (10 marks)

Each member must be able to speak in detail about **at least the files
attributed to them** in [CONTRIBUTIONS.md](CONTRIBUTIONS.md). Suggested
2-minute personal pitch per member:

### Alec (PM, all files)

- Project planning, sprint cadence, integration of components, conflict
  resolution.
- Wrote the application entry point ([lib/main.dart](lib/main.dart)) and
  the bulk of the backend.
- Owns the overall architecture decisions (Flutter, SQLite, Provider,
  feature-folder layout).

### Saynab (Analyst)

- Domain modelling: walk through one model file, explain attributes,
  invariants, and relationships.
- Routing and theming: how `app_routes.dart` keeps navigation centralised.
- Co-authored several feature screens because they bind directly to the
  domain models.

### Douaa (Backend)

- Service layer and RBAC. Be ready to explain the difference between
  `auth_service.dart` (authentication) and `rbac.dart` (authorisation).
- Database design and parameterised queries.
- Co-authored `auth_provider.dart` to bridge backend state into the UI.

### Ashley (Frontend)

- UI architecture: `app_shell.dart`, role-aware navigation, shared
  widgets.
- Form validation patterns - pick one form (e.g. tenant registration)
  and walk the validation rules.
- Background visuals (`silk_background`, `aurora_background`) - small
  feature, but a clear personal contribution to talk about.

### Okan (QA & Docs)

- Test strategy: unit / widget / manual; black-box vs white-box.
- Walk through one test in `auth_service_test.dart` line by line.
- The `tool/dump_db.dart` script and how the SQL dump was produced.
- Test-case table in the testing PDF and the traceability to use cases.

---

## 11. Things to NOT say in the demo

- "AI generated this." (Spec allows AI for code snippets only, not
  design. Safer to talk about *our* design choices.)
- "We didn't get round to..." Frame any gap as future work.
- "It was supposed to be Python." -> "Tutor approved Flutter/Dart as a
  suitable OOP alternative."
- "It only works on my machine." It works on any Windows box with
  Flutter SDK + VS 2022.

---

## 12. Last-minute checks before walking in

1. Run `flutter test` - all green screenshot ready.
2. Run `flutter run -d windows` once on the demo laptop, log in with
   `admin / admin123`, log out. (Warm SQLite cache + verify seed.)
3. Have the diagram PDF, the testing PDF and this file open in tabs.
4. Have [CONTRIBUTIONS.md](CONTRIBUTIONS.md) open so every member can
   point at their files when asked.
5. Bring a backup ZIP on a USB stick.
