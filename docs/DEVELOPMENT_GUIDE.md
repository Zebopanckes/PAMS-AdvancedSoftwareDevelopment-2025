# PAMS Development Documentation

## System Architecture

### Overview
PAMS follows a clean architecture pattern with clear separation of concerns:
- **Presentation Layer**: UI components, screens, widgets
- **Business Logic Layer**: Providers, state management
- **Data Layer**: Models, services, database

### Technology Stack
- **Frontend**: Flutter with Material Design 3
- **State Management**: Provider pattern
- **Database**: SQLite with sqflite
- **Security**: SHA-256 password hashing, audit logging
- **Animations**: flutter_animate package

## Database Schema

### Tables

#### users
- `id` (TEXT, PRIMARY KEY)
- `username` (TEXT, UNIQUE)
- `email` (TEXT, UNIQUE)
- `password_hash` (TEXT)
- `role` (TEXT) - admin, manager, finance, maintenance, frontDesk
- `full_name` (TEXT)
- `phone` (TEXT)
- `is_active` (INTEGER)
- `mfa_enabled` (INTEGER)
- `created_at` (TEXT)
- `updated_at` (TEXT)

#### tenants
- `id` (TEXT, PRIMARY KEY)
- `full_name` (TEXT)
- `email` (TEXT, UNIQUE)
- `phone` (TEXT)
- `id_number` (TEXT, UNIQUE)
- `emergency_contact` (TEXT)
- `status` (TEXT)
- `move_in_date` (TEXT)
- `move_out_date` (TEXT)
- `created_at` (TEXT)
- `updated_at` (TEXT)

#### apartments
- `id` (TEXT, PRIMARY KEY)
- `apartment_number` (TEXT, UNIQUE)
- `location` (TEXT)
- `floor` (INTEGER)
- `bedrooms` (INTEGER)
- `bathrooms` (INTEGER)
- `area_sqft` (REAL)
- `rent_amount` (REAL)
- `status` (TEXT)
- `description` (TEXT)
- `created_at` (TEXT)
- `updated_at` (TEXT)

#### lease_agreements
- Links tenants to apartments
- Tracks lease terms and dates

#### payments
- Tracks all payment transactions
- Links to tenants and leases

#### maintenance_requests
- Tracks maintenance issues
- Priority and status management

#### audit_logs
- Complete audit trail of all system actions

## User Roles and Permissions

### Admin
- Full system access
- User management
- System configuration

### Manager
- Tenant management
- Apartment allocation
- Report viewing

### Finance
- Payment processing
- Invoice generation
- Financial reports

### Maintenance
- Maintenance request management
- Work order tracking

### Front Desk
- Basic tenant information
- Payment recording
- Maintenance request creation

## Security Features

1. **Password Hashing**: SHA-256 hashing for all passwords
2. **Audit Logging**: Complete trail of all system actions
3. **Role-Based Access**: Granular permission system
4. **MFA Support**: Two-factor authentication capability
5. **Session Management**: Secure login/logout

## Development Guidelines

### Code Style
- Follow Dart/Flutter conventions
- Use meaningful variable names
- Comment complex logic
- Keep functions small and focused

### Git Workflow
1. Create feature branch from main
2. Implement feature with tests
3. Submit pull request
4. Code review
5. Merge to main

### Testing
- Write unit tests for business logic
- Integration tests for features
- Widget tests for UI components
- Aim for >80% code coverage

## Future Enhancements

1. **Notifications**: Real-time alerts for payments, maintenance
2. **Mobile App**: Cross-platform mobile version
3. **Cloud Sync**: Multi-device synchronization
4. **Analytics**: Advanced reporting and insights
5. **API Integration**: External payment gateways
6. **Document Management**: File uploads and storage
7. **Multi-language**: Internationalization support

## Troubleshooting

### Common Issues

**Database not initializing**
- Check sqflite_common_ffi is properly configured for desktop
- Verify database path permissions

**Authentication failing**
- Verify default admin credentials
- Check password hashing is consistent

**UI not updating**
- Ensure Provider is properly configured
- Check notifyListeners() is called

## Support

For issues or questions:
1. Check documentation
2. Review existing code examples
3. Create issue in repository
