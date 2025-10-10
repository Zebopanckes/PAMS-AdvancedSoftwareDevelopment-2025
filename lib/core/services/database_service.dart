import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('pams.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // Users table
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        username TEXT UNIQUE NOT NULL,
        email TEXT UNIQUE NOT NULL,
        password_hash TEXT NOT NULL,
        role TEXT NOT NULL,
        full_name TEXT NOT NULL,
        phone TEXT,
        is_active INTEGER DEFAULT 1,
        mfa_enabled INTEGER DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Tenants table
    await db.execute('''
      CREATE TABLE tenants (
        id TEXT PRIMARY KEY,
        full_name TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        phone TEXT NOT NULL,
        id_number TEXT UNIQUE NOT NULL,
        emergency_contact TEXT,
        status TEXT NOT NULL,
        move_in_date TEXT,
        move_out_date TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Apartments table
    await db.execute('''
      CREATE TABLE apartments (
        id TEXT PRIMARY KEY,
        apartment_number TEXT UNIQUE NOT NULL,
        location TEXT NOT NULL,
        floor INTEGER NOT NULL,
        bedrooms INTEGER NOT NULL,
        bathrooms INTEGER NOT NULL,
        area_sqft REAL NOT NULL,
        rent_amount REAL NOT NULL,
        status TEXT NOT NULL,
        description TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Lease Agreements table
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
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (tenant_id) REFERENCES tenants (id),
        FOREIGN KEY (apartment_id) REFERENCES apartments (id)
      )
    ''');

    // Payments table
    await db.execute('''
      CREATE TABLE payments (
        id TEXT PRIMARY KEY,
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
        FOREIGN KEY (tenant_id) REFERENCES tenants (id),
        FOREIGN KEY (lease_id) REFERENCES lease_agreements (id)
      )
    ''');

    // Maintenance Requests table
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
        cost REAL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (apartment_id) REFERENCES apartments (id),
        FOREIGN KEY (tenant_id) REFERENCES tenants (id),
        FOREIGN KEY (assigned_to) REFERENCES users (id)
      )
    ''');

    // Audit Log table
    await db.execute('''
      CREATE TABLE audit_logs (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        action TEXT NOT NULL,
        entity_type TEXT NOT NULL,
        entity_id TEXT,
        details TEXT,
        ip_address TEXT,
        timestamp TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    // Create default admin user
    await _createDefaultAdmin(db);
  }

  Future<void> _createDefaultAdmin(Database db) async {
    final now = DateTime.now().toIso8601String();
    // Default password: admin123 (should be changed on first login)
    const passwordHash = '240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9'; // SHA-256 hash
    
    await db.insert('users', {
      'id': 'admin-001',
      'username': 'admin',
      'email': 'admin@pams.com',
      'password_hash': passwordHash,
      'role': 'admin',
      'full_name': 'System Administrator',
      'phone': '',
      'is_active': 1,
      'mfa_enabled': 0,
      'created_at': now,
      'updated_at': now,
    });
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
