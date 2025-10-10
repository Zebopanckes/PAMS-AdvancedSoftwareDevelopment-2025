import 'package:flutter_test/flutter_test.dart';
import 'package:pams/core/services/auth_service.dart';

void main() {
  group('AuthService Tests', () {
    late AuthService authService;

    setUp(() {
      authService = AuthService();
    });

    test('Password hashing should be consistent', () {
      const password = 'testPassword123';
      final hash1 = authService.hashPassword(password);
      final hash2 = authService.hashPassword(password);

      expect(hash1, equals(hash2));
      expect(hash1, isNot(equals(password)));
    });

    test('Different passwords should produce different hashes', () {
      const password1 = 'password1';
      const password2 = 'password2';

      final hash1 = authService.hashPassword(password1);
      final hash2 = authService.hashPassword(password2);

      expect(hash1, isNot(equals(hash2)));
    });

    // Add more tests as features are implemented
  });
}
