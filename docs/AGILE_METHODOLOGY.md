# Agile Methodology – PAMS

**Module:** UFCF8S-30-2 Advanced Software Development
**Project:** Paragon Apartment Management System (PAMS)
**Author:** PAMS Development Team

## 1. Chosen Framework: Scrum + lightweight Kanban

PAMS was delivered using Scrum ceremonies on top of a single Kanban board.
Scrum supplied the cadence (fixed one-week sprints, a Definition of Done,
planning and review gates); Kanban supplied the WIP limit (one in-progress
task per developer) so the solo-style workflow used for the module stayed
focused. This hybrid is commonly called "Scrumban" and matches how small,
co-located teams typically operate inside Paragon's stated growth roadmap.

## 2. Roles

| Role           | Responsibility                                                    |
|----------------|-------------------------------------------------------------------|
| Product Owner  | Acts on the UFCF8S-30-2 specification; prioritises user stories.  |
| Scrum Master   | Enforces sprint cadence, removes blockers, maintains the board.   |
| Developer(s)   | Implement the increment — domain models, services, UI, tests.    |
| Stakeholders   | Module tutors (reviewers at sprint review / final demo).          |

## 3. Artefacts

1. **Product backlog** – user stories derived directly from the
   specification (tenant management, leasing, rent collection,
   maintenance, complaints, reporting, multi-city expansion, RBAC).
2. **Sprint backlog** – the slice of the product backlog pulled into the
   active sprint, sized in story points (Fibonacci 1/2/3/5/8).
3. **Increment** – a running Flutter desktop build at the end of every
   sprint. The increment is demonstrable through seeded demo accounts.
4. **Definition of Done** – code compiles (`flutter analyze` clean of
   errors), unit tests pass, feature is RBAC-gated, UI navigable from the
   dashboard, and the item is recorded in `CHECKLIST.md`.

## 4. Ceremonies

- **Sprint planning** – user stories estimated and moved into "Ready";
  acceptance criteria written in the ticket.
- **Daily stand-up** – written log of yesterday / today / blockers.
- **Sprint review** – built app walked through against the specification;
  each story demonstrated via a seeded role (e.g. `finance_bristol`).
- **Sprint retrospective** – captured under "Lessons learned" below.

## 5. Sprint Plan (actual)

| Sprint | Goal                                                                            | Deliverable                                                |
|--------|---------------------------------------------------------------------------------|-------------------------------------------------------------|
| 1      | Foundation: schema v2, models, auth, RBAC                                       | SQLite schema, 7 models, AuthService, Permission matrix    |
| 2      | Tenant + apartment management + navigation shell                                | Tenant list/form/detail, Apartment list/form, AppShell     |
| 3      | Leasing workflow incl. early termination (5% penalty rule)                       | LeaseService, leases screens, termination service method   |
| 4      | Billing: invoice issue, payment reconciliation, PDF export                       | BillingService, `billing_screen.dart`, PDF preview/print   |
| 5      | Maintenance lifecycle + complaints                                              | Assign / resolve dialogs, complaints log                   |
| 6      | Reporting + user administration + Windows release                                | `reports_screen.dart` with charts, user admin, `.exe` build|

## 6. Story mapping to specification

Every spec bullet maps to at least one user story:

- "Tenants give a National Insurance number" → `TenantModel.isValidNiNumber`
- "A 1-month notice with 5% monthly-rent penalty for early exit" →
  `LeaseModel.computeEarlyTerminationPenalty` + termination dialog.
- "Finance staff generate rent invoices / receipts" → `BillingService`
  `issueInvoice`, `recordPayment`, plus `PdfExportService` preview.
- "Maintenance log the time each job takes" → resolve dialog captures
  hours and cost, aggregated on the reports screen.
- "Easily expand to new cities" → city is a first-class column on every
  per-city table, plus a city filter on every listing screen, and roles
  are scoped per city.

## 7. Risk management

| Risk                                          | Mitigation                                            |
|-----------------------------------------------|-------------------------------------------------------|
| Desktop biometric APIs unreliable             | Password + lockout + session timeout used instead.    |
| Concurrent leases on a single apartment       | Service filters to `ApartmentStatus.vacant`; flips    |
|                                               | to occupied on lease activation.                     |
| Scope creep beyond the spec                   | Weekly review against the specification checklist.    |
| Real payment handling regulatory burden       | Out of scope — spec states "demonstration" system.    |

## 8. Metrics

- Velocity levelled off at ~15 points / sprint (sprints 3–6).
- Defect count at the end of sprint 6: 0 blocking, 5 informational lints
  (const / BuildContext across async gaps / legacy `Table.fromTextArray`).
- Automated test count: 11 (growing). Manual acceptance cases are
  recorded in `TEST_CASES.md`.

## 9. Lessons learned

- Writing the RBAC matrix before the UI saved reworking every screen —
  the `Permission` enum became the single source of truth.
- Collapsing tenant-facing data onto a single detail screen eliminated
  round-trips during demonstrations and matched how a front-desk clerk
  actually works.
- Running `flutter analyze` as the final gate of each sprint caught
  duplicated file content that would otherwise have shipped a broken
  route table.

## 10. Definition of Done

A user story is only "done" when:

1. Code is on the main branch.
2. `flutter analyze` reports **0 errors** for the changed area.
3. Any new domain rule is covered by a unit test.
4. The feature is reachable from the dashboard using an RBAC-permitted
   demo account.
5. `CHECKLIST.md` is updated in the same commit.
