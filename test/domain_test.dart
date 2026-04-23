// Author: Alec Brothwood (23076824) - Project Manager
// Author: Okan Kaynak (23035729) - Quality & Documentation Specialist
// File: domain_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:pams/core/models/lease_model.dart';
import 'package:pams/core/models/tenant_model.dart';
import 'package:pams/core/models/user_model.dart';
import 'package:pams/core/security/rbac.dart';

UserModel _user(UserRole role) => UserModel(
      id: 'u',
      username: 'u',
      email: 'u@example.com',
      role: role,
      fullName: 'Test User',
      city: 'Bristol',
      createdAt: DateTime(2024),
      updatedAt: DateTime(2024),
    );

void main() {
  group('TenantModel validators', () {
    test('valid NI numbers pass', () {
      expect(TenantModel.isValidNiNumber('AB123456C'), isTrue);
      expect(TenantModel.isValidNiNumber('ab 12 34 56 c'), isTrue);
    });
    test('invalid NI numbers rejected', () {
      expect(TenantModel.isValidNiNumber('12345678'), isFalse);
      expect(TenantModel.isValidNiNumber('ABCDEFGHI'), isFalse);
    });
    test('email validator', () {
      expect(TenantModel.isValidEmail('jane.doe@example.co.uk'), isTrue);
      expect(TenantModel.isValidEmail('bad-email'), isFalse);
    });
    test('UK phone validator', () {
      expect(TenantModel.isValidUkPhone('07123456789'), isTrue);
      expect(TenantModel.isValidUkPhone('+441179876543'), isTrue);
      expect(TenantModel.isValidUkPhone('123'), isFalse);
    });
  });

  group('LeaseModel.computeEarlyTerminationPenalty', () {
    test('returns 5% of monthly rent per spec', () {
      final lease = LeaseModel(
        id: 'l',
        tenantId: 't',
        apartmentId: 'a',
        startDate: DateTime(2025, 1, 1),
        endDate: DateTime(2026, 1, 1),
        rentAmount: 1200,
        depositAmount: 1200,
        createdAt: DateTime(2025),
        updatedAt: DateTime(2025),
      );
      expect(lease.computeEarlyTerminationPenalty(), closeTo(60.0, 0.0001));
      expect(lease.durationMonths(), equals(12));
    });
  });

  group('Rbac matrix', () {
    test('admin has full tenant/user/report permissions', () {
      final admin = _user(UserRole.admin);
      expect(Rbac.can(admin, Permission.manageUsers), isTrue);
      expect(Rbac.can(admin, Permission.deleteTenant), isTrue);
      expect(Rbac.can(admin, Permission.viewReports), isTrue);
      expect(Rbac.can(admin, Permission.managePayments), isTrue);
    });
    test('frontDesk cannot manage users or apartments', () {
      final fd = _user(UserRole.frontDesk);
      expect(Rbac.can(fd, Permission.manageUsers), isFalse);
      expect(Rbac.can(fd, Permission.manageApartments), isFalse);
      expect(Rbac.can(fd, Permission.viewTenants), isTrue);
    });
    test('finance can manage payments but not apartments', () {
      final fin = _user(UserRole.finance);
      expect(Rbac.can(fin, Permission.managePayments), isTrue);
      expect(Rbac.can(fin, Permission.manageApartments), isFalse);
    });
    test('null user is always denied', () {
      expect(Rbac.can(null, Permission.viewTenants), isFalse);
    });
  });
}
