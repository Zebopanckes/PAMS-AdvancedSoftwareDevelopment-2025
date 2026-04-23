// Author: Alec Brothwood (23076824) - Project Manager
// Author: Douaa Tadli (23012698) - Backend Developer
// File: seed_service.dart
// Purpose: Populate the database with spec-aligned demonstration data.

import 'dart:math';
import '../models/apartment_model.dart';
import '../models/lease_model.dart';
import '../models/maintenance_model.dart';
import '../models/payment_model.dart';
import '../models/tenant_model.dart';
import '../models/user_model.dart';
import 'apartment_service.dart';
import 'billing_service.dart';
import 'database_service.dart';
import 'lease_service.dart';
import 'maintenance_service.dart';
import 'tenant_service.dart';
import 'user_service.dart';

class SeedService {
  final _users = UserService();
  final _tenants = TenantService();
  final _apartments = ApartmentService();
  final _leases = LeaseService();
  final _billing = BillingService();
  final _maintenance = MaintenanceService();

  static const cities = ['Bristol', 'Cardiff', 'London', 'Manchester'];

  /// Returns true when seeding actually ran.
  Future<bool> seedIfEmpty() async {
    final db = await DatabaseService.instance.database;
    final aptCount = (await db.rawQuery('SELECT COUNT(*) AS c FROM apartments'))
            .first['c'] as int? ??
        0;
    if (aptCount > 0) return false;
    await seed();
    return true;
  }

  /// Repopulate all data (wipes business data first). Keeps the admin user.
  Future<void> reseed() async {
    await DatabaseService.instance.wipeBusinessData();
    await seed();
  }

  Future<void> seed() async {
    final random = Random(42); // Deterministic for reproducible demos.

    // --- Staff accounts (one set per city) --------------------------------
    final cityStaff = <String, Map<UserRole, UserModel>>{};
    for (final city in cities) {
      final cityLower = city.toLowerCase();
      final manager = await _createUserOrKeep(
          'manager_$cityLower', 'manager@$cityLower.pams', UserRole.manager,
          '$city Manager', city);
      final finance = await _createUserOrKeep(
          'finance_$cityLower', 'finance@$cityLower.pams', UserRole.finance,
          '$city Finance Officer', city);
      final maint = await _createUserOrKeep(
          'maint_$cityLower', 'maint@$cityLower.pams', UserRole.maintenance,
          '$city Maintenance Lead', city);
      final frontDesk = await _createUserOrKeep(
          'front_$cityLower', 'front@$cityLower.pams', UserRole.frontDesk,
          '$city Front-desk', city);
      cityStaff[city] = {
        UserRole.manager: manager,
        UserRole.finance: finance,
        UserRole.maintenance: maint,
        UserRole.frontDesk: frontDesk,
      };
    }

    // --- Apartments -------------------------------------------------------
    const apartmentTypes = ['Studio', '1-bed flat', '2-bed flat', '3-bed house'];
    const locations = {
      'Bristol': ['Harbourside', 'Clifton', 'Redland', 'Bedminster'],
      'Cardiff': ['Cardiff Bay', 'Pontcanna', 'Roath', 'Canton'],
      'London': ['Canary Wharf', 'Shoreditch', 'Chelsea', 'Camden'],
      'Manchester': ['Deansgate', 'Northern Quarter', 'Salford Quays', 'Didsbury'],
    };

    final apartments = <ApartmentModel>[];
    for (final city in cities) {
      for (int i = 1; i <= 8; i++) {
        final type = apartmentTypes[i % apartmentTypes.length];
        final bedrooms = type.startsWith('Studio')
            ? 0
            : int.parse(type.substring(0, 1));
        final rent = 700 + random.nextInt(1800).toDouble();
        final apt = await _apartments.create(
          apartmentNumber: '${city.substring(0, 1)}${100 + i}',
          city: city,
          location: locations[city]![i % 4],
          type: type,
          floor: 1 + (i % 6),
          bedrooms: bedrooms,
          bathrooms: (bedrooms == 0 ? 1 : (1 + (i % 2))),
          areaSqft: 350 + random.nextInt(900).toDouble(),
          rentAmount: double.parse(rent.toStringAsFixed(2)),
          description: 'Well-maintained $type in $city',
        );
        apartments.add(apt);
      }
    }

    // --- Tenants ----------------------------------------------------------
    final tenantNames = [
      ['James Porter', 'james.porter@example.com', 'AB123456C'],
      ['Sarah Knight', 'sarah.knight@example.com', 'CD234567D'],
      ['Liam O\'Connor', 'liam.oconnor@example.com', 'EG345678A'],
      ['Priya Patel', 'priya.patel@example.com', 'HJ456789B'],
      ['Marcus Wright', 'marcus.wright@example.com', 'JK567890C'],
      ['Chloe Bennett', 'chloe.bennett@example.com', 'KL678901D'],
      ['Daniel Murphy', 'daniel.murphy@example.com', 'MN789012A'],
      ['Hannah Reid', 'hannah.reid@example.com', 'PR890123B'],
      ['Tomasz Kowalski', 'tomasz.kowalski@example.com', 'RS901234C'],
      ['Aisha Rahman', 'aisha.rahman@example.com', 'ST012345D'],
      ['Oliver Grant', 'oliver.grant@example.com', 'TW123450A'],
      ['Emily Clarke', 'emily.clarke@example.com', 'WZ234561B'],
    ];
    const occupations = [
      'Software Engineer',
      'Nurse',
      'Teacher',
      'Accountant',
      'Graphic Designer',
      'Student',
      'Consultant',
    ];

    final tenants = <TenantModel>[];
    for (int i = 0; i < tenantNames.length; i++) {
      final city = cities[i % cities.length];
      final name = tenantNames[i][0];
      final email = tenantNames[i][1];
      final ni = tenantNames[i][2];
      final t = await _tenants.create(
        niNumber: ni,
        fullName: name,
        email: email,
        phone: '+447${(700000000 + random.nextInt(99999999))}',
        city: city,
        occupation: occupations[i % occupations.length],
        references: 'Previous landlord available on request.',
        apartmentRequirements:
            'Seeking ${apartments[i].type} in $city near transport.',
        leasePeriodMonths: 12,
        emergencyContact: 'Relative: +447${800000000 + random.nextInt(99999999)}',
        status: TenantStatus.prospective,
      );
      tenants.add(t);
    }

    // --- Leases (assign most tenants to apartments in their city) --------
    final leases = <LeaseModel>[];
    int aptIdx = 0;
    for (int i = 0; i < tenants.length - 2; i++) {
      final tenant = tenants[i];
      // Find an apartment in same city that's still vacant.
      final candidate = apartments.firstWhere(
        (a) => a.city == tenant.city && a.status == ApartmentStatus.vacant,
        orElse: () => apartments[aptIdx++ % apartments.length],
      );
      final start = DateTime.now().subtract(Duration(days: 30 * (i + 1)));
      final end = DateTime(start.year + 1, start.month, start.day);
      try {
        final lease = await _leases.create(
          tenantId: tenant.id,
          apartmentId: candidate.id,
          startDate: start,
          endDate: end,
          rentAmount: candidate.rentAmount,
          depositAmount: candidate.rentAmount * 1.5,
          terms: 'Standard 12-month assured shorthold tenancy.',
        );
        leases.add(lease);
        // Mutate our local copy so next iteration sees the change.
        final idx = apartments.indexOf(candidate);
        apartments[idx] = candidate.copyWith(status: ApartmentStatus.occupied);
      } on StateError {
        // apartment already leased – skip
      }
    }

    // --- Invoices + Payments ---------------------------------------------
    for (final lease in leases) {
      for (int m = 0; m < 3; m++) {
        final periodMonth = DateTime(
          lease.startDate.year,
          lease.startDate.month + m,
          1,
        );
        final invoice = await _billing.issueInvoice(
          lease: lease,
          periodMonth: periodMonth,
          dueDays: 7,
        );
        // Pay most invoices, leave a couple outstanding.
        if (random.nextDouble() < 0.75) {
          await _billing.recordPayment(
            invoice: invoice,
            amount: invoice.amount,
            method: PaymentMethod
                .values[random.nextInt(PaymentMethod.values.length)],
            reference: 'REF-${1000 + random.nextInt(9000)}',
          );
        }
      }
    }
    await _billing.markOverdueInvoices();

    // --- Maintenance requests --------------------------------------------
    final sampleIssues = [
      ['Leaking tap', 'Kitchen tap drips constantly.', MaintenancePriority.medium],
      ['Boiler no heat', 'Boiler does not heat water on demand.', MaintenancePriority.urgent],
      ['Broken window latch', 'Bedroom window will not close properly.', MaintenancePriority.high],
      ['Lightbulb replacement', 'Hallway bulb has blown.', MaintenancePriority.low],
      ['Washing machine leak', 'Pooling water around the machine.', MaintenancePriority.high],
    ];
    for (int i = 0; i < leases.length; i++) {
      if (random.nextDouble() < 0.5) continue;
      final lease = leases[i];
      final issue = sampleIssues[i % sampleIssues.length];
      final req = await _maintenance.create(
        apartmentId: lease.apartmentId,
        tenantId: lease.tenantId,
        title: issue[0] as String,
        description: issue[1] as String,
        priority: issue[2] as MaintenancePriority,
      );
      // Assign + sometimes resolve.
      final city = apartments
          .firstWhere((a) => a.id == lease.apartmentId)
          .city;
      final maintStaff = cityStaff[city]![UserRole.maintenance]!;
      await _maintenance.assign(
        req.id,
        maintStaff.id,
        DateTime.now().add(Duration(days: 1 + random.nextInt(5))),
      );
      if (random.nextDouble() < 0.6) {
        await _maintenance.resolve(
          id: req.id,
          resolutionNotes: 'Issue resolved on site.',
          hoursSpent: 1 + random.nextInt(4).toDouble(),
          cost: 50 + random.nextInt(300).toDouble(),
        );
      }
    }
  }

  Future<UserModel> _createUserOrKeep(
    String username,
    String email,
    UserRole role,
    String fullName,
    String city,
  ) async {
    final existing = await _users.getAll(role: role);
    final match = existing.where((u) => u.username == username);
    if (match.isNotEmpty) return match.first;
    return _users.create(
      username: username,
      email: email,
      password: 'Password123!',
      role: role,
      fullName: fullName,
      city: city,
    );
  }
}
