// Author: PAMS Development Team
// File: rbac.dart
// Purpose: Centralised role-based access checks derived from the PAMS spec.

import '../models/user_model.dart';

/// Permissions that map to discrete actions in the UI and services.
///
/// The mapping below mirrors the responsibilities described in the PAMS
/// specification for each of the five staff roles.
enum Permission {
  // Tenants
  viewTenants,
  createTenant,
  editTenant,
  deleteTenant,
  // Apartments
  viewApartments,
  manageApartments,
  // Leases
  viewLeases,
  manageLeases,
  // Billing
  viewPayments,
  managePayments,
  generateInvoices,
  // Maintenance
  viewMaintenance,
  createMaintenance,
  assignMaintenance,
  resolveMaintenance,
  // Complaints
  viewComplaints,
  manageComplaints,
  // Users
  manageUsers,
  // Reports
  viewReports,
  expandBusiness,
}

class Rbac {
  static bool can(UserModel? user, Permission p) {
    if (user == null || !user.isActive) return false;
    final set = _roleMatrix[user.role] ?? const {};
    return set.contains(p);
  }

  static bool canAny(UserModel? user, List<Permission> perms) =>
      perms.any((p) => can(user, p));

  static const Map<UserRole, Set<Permission>> _roleMatrix = {
    UserRole.admin: {
      Permission.viewTenants,
      Permission.createTenant,
      Permission.editTenant,
      Permission.deleteTenant,
      Permission.viewApartments,
      Permission.manageApartments,
      Permission.viewLeases,
      Permission.manageLeases,
      Permission.viewPayments,
      Permission.managePayments,
      Permission.generateInvoices,
      Permission.viewMaintenance,
      Permission.createMaintenance,
      Permission.assignMaintenance,
      Permission.resolveMaintenance,
      Permission.viewComplaints,
      Permission.manageComplaints,
      Permission.manageUsers,
      Permission.viewReports,
      Permission.expandBusiness,
    },
    UserRole.manager: {
      Permission.viewTenants,
      Permission.viewApartments,
      Permission.manageApartments,
      Permission.viewLeases,
      Permission.manageLeases,
      Permission.viewPayments,
      Permission.viewMaintenance,
      Permission.viewComplaints,
      Permission.viewReports,
      Permission.expandBusiness,
    },
    UserRole.finance: {
      Permission.viewTenants,
      Permission.viewApartments,
      Permission.viewLeases,
      Permission.viewPayments,
      Permission.managePayments,
      Permission.generateInvoices,
      Permission.viewReports,
    },
    UserRole.maintenance: {
      Permission.viewApartments,
      Permission.viewTenants,
      Permission.viewMaintenance,
      Permission.assignMaintenance,
      Permission.resolveMaintenance,
    },
    UserRole.frontDesk: {
      Permission.viewTenants,
      Permission.createTenant,
      Permission.editTenant,
      Permission.viewApartments,
      Permission.viewLeases,
      Permission.viewPayments,
      Permission.viewMaintenance,
      Permission.createMaintenance,
      Permission.viewComplaints,
      Permission.manageComplaints,
    },
  };
}
