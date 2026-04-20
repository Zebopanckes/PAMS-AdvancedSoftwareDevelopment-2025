// Author: PAMS Development Team
// File: database_service.dart
// Purpose: SQLite database bootstrap and schema management for PAMS.

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// Singleton database accessor for the PAMS application.
///
/// Schema is aligned to the PAMS specification:
///   * Users (role-based: admin, manager, finance, maintenance, front-desk)
///   * Tenants (NI number, references, apartment requirements, lease period)
///   * Apartments (city/location, type, rent, rooms)
///   * Lease agreements (start/end, deposit, early-termination penalty)
///   * Invoices + Payments (billing lifecycle)
///   * Maintenance requests (with cost and time tracking)
///   * Complaints (tenant grievances, tracked by front-desk)
///   * Audit logs (security/compliance evidence)
class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  static const int _schemaVersion = 2;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('pams.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return openDatabase(
      path,
      version: _schemaVersion,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Dev-friendly migration: drop all known tables and recreate.
    const tables = [
      'audit_logs',
      'complaints',
      'maintenance_requests',
      'payments',
      'invoices',
      'lease_agreements',
      'apartments',
      'tenants',
      'users',
    ];
    for (final t in tables) {
      await db.execute('DROP TABLE IF EXISTS $t');
    }
    await _createDB(db, newVersion);
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        username TEXT UNIQUE NOT NULL,
        email TEXT UNIQUE NOT NULL,
        password_hash TEXT NOT NULL,
        role TEXT NOT NULL,
        full_name TEXT NOT NULL,
        phone TEXT,
        city TEXT,
        is_active INTEGER DEFAULT 1,
        mfa_enabled INTEGER DEFAULT 0,
        failed_login_attempts INTEGER DEFAULT 0,
        locked_until TEXT,
        last_login TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE tenants (
        id TEXT PRIMARY KEY,
        ni_number TEXT UNIQUE NOT NULL,
        full_name TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        phone TEXT NOT NULL,
        occupation TEXT,
        references_info TEXT,
        apartment_requirements TEXT,
        lease_period_months INTEGER,
        city TEXT NOT NULL,
        emergency_contact TEXT,
        status TEXT NOT NULL,
        move_in_date TEXT,
        move_out_date TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE apartments (
        id TEXT PRIMARY KEY,
        apartment_number TEXT NOT NULL,
        city TEXT NOT NULL,
        location TEXT NOT NULL,
        type TEXT NOT NULL,
        floor INTEGER NOT NULL,
        bedrooms INTEGER NOT NULL,
        bathrooms INTEGER NOT NULL,
        area_sqft REAL NOT NULL,
        rent_amount REAL NOT NULL,
        status TEXT NOT NULL,
        description TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        UNIQUE(apartment_number, city)
      )
    ''');

    await db.execute('''
      CREATE TABLE lease_agreements (
        id TEXT PRIMARY KEY,
        tenant_id TEXT NOT NULL,
        apartment_id TEXT NOT NULL,
        start_date TEXT NOT NULL,
        end_date TEXT NOT NULL,
        rent_amount REAL NOT NULL,
        deposit_amount REAL NOT NULL,
        status TEXT NOT NULL,
        terms TEXT,
        early_termination_notice_date TEXT,
        early_termination_penalty REAL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (tenant_id) REFERENCES tenants (id) ON DELETE CASCADE,
        FOREIGN KEY (apartment_id) REFERENCES apartments (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE invoices (
        id TEXT PRIMARY KEY,
        invoice_number TEXT UNIQUE NOT NULL,
        lease_id TEXT NOT NULL,
        tenant_id TEXT NOT NULL,
        period_label TEXT NOT NULL,
        amount REAL NOT NULL,
        issue_date TEXT NOT NULL,
        due_date TEXT NOT NULL,
        status TEXT NOT NULL,
        notes TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (lease_id) REFERENCES lease_agreements (id) ON DELETE CASCADE,
        FOREIGN KEY (tenant_id) REFERENCES tenants (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE payments (
        id TEXT PRIMARY KEY,
        invoice_id TEXT,
        tenant_id TEXT NOT NULL,
        lease_id TEXT NOT NULL,
        amount REAL NOT NULL,
        payment_date TEXT NOT NULL,
        due_date TEXT NOT NULL,
        payment_method TEXT NOT NULL,
        status TEXT NOT NULL,
        reference_number TEXT,
        notes TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (invoice_id) REFERENCES invoices (id) ON DELETE SET NULL,
        FOREIGN KEY (tenant_id) REFERENCES tenants (id) ON DELETE CASCADE,
        FOREIGN KEY (lease_id) REFERENCES lease_agreements (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE maintenance_requests (
        id TEXT PRIMARY KEY,
        apartment_id TEXT NOT NULL,
        tenant_id TEXT,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        priority TEXT NOT NULL,
        status TEXT NOT NULL,
        assigned_to TEXT,
        reported_date TEXT NOT NULL,
        scheduled_date TEXT,
        completed_date TEXT,
        resolution_notes TEXT,
        hours_spent REAL,
        cost REAL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (apartment_id) REFERENCES apartments (id) ON DELETE CASCADE,
        FOREIGN KEY (tenant_id) REFERENCES tenants (id) ON DELETE SET NULL,
        FOREIGN KEY (assigned_to) REFERENCES users (id) ON DELETE SET NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE complaints (
        id TEXT PRIMARY KEY,
        tenant_id TEXT NOT NULL,
        subject TEXT NOT NULL,
        description TEXT NOT NULL,
        status TEXT NOT NULL,
        logged_by TEXT,
        logged_date TEXT NOT NULL,
        resolved_date TEXT,
        resolution TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (tenant_id) REFERENCES tenants (id) ON DELETE CASCADE,
        FOREIGN KEY (logged_by) REFERENCES users (id) ON DELETE SET NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE audit_logs (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        action TEXT NOT NULL,
        entity_type TEXT NOT NULL,
        entity_id TEXT,
        details TEXT,
        ip_address TEXT,
        timestamp TEXT NOT NULL
      )
    ''');

    await db.execute('CREATE INDEX idx_tenants_city ON tenants(city)');
    await db.execute('CREATE INDEX idx_apartments_city ON apartments(city)');
    await db.execute('CREATE INDEX idx_apartments_status ON apartments(status)');
    await db.execute('CREATE INDEX idx_leases_status ON lease_agreements(status)');
    await db.execute('CREATE INDEX idx_payments_status ON payments(status)');
    await db.execute('CREATE INDEX idx_maintenance_status ON maintenance_requests(status)');

    await _createDefaultAdmin(db);
  }

  Future<void> _createDefaultAdmin(Database db) async {
    final now = DateTime.now().toIso8601String();
    // Default password: admin123 (SHA-256).
    const passwordHash =
        '240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9';

    await db.insert('users', {
      'id': 'admin-001',
      'username': 'admin',
      'email': 'admin@pams.com',
      'password_hash': passwordHash,
      'role': 'admin',
      'full_name': 'System Administrator',
      'phone': '',
      'city': 'Bristol',
      'is_active': 1,
      'mfa_enabled': 0,
      'failed_login_attempts': 0,
      'created_at': now,
      'updated_at': now,
    });
  }

  /// Convenience wipe of business data (keeps users).
  Future<void> wipeBusinessData() async {
    final db = await database;
    await db.delete('audit_logs');
    await db.delete('complaints');
    await db.delete('maintenance_requests');
    await db.delete('payments');
    await db.delete('invoices');
    await db.delete('lease_agreements');
    await db.delete('apartments');
    await db.delete('tenants');
  }

  Future<void> close() async {
    final db = await instance.database;
    await db.close();
    _database = null;
  }
}
