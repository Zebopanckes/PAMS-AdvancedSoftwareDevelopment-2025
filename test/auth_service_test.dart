import 'package:flutter_test/flutter_test.dart';
import 'package:pams/core/services/auth_service.dart';

void main() {
  group('AuthService password hashing (bcrypt)', () {
    late AuthService authService;

    setUp(() {
      authService = AuthService();
    });

    test('hashPassword produces a bcrypt-format hash, not plaintext', () {
      const password = 'testPassword123';
      final hash = authService.hashPassword(password);

      expect(hash, isNot(equals(password)));
      // bcrypt hashes begin with $2a$ / $2b$ / $2y$ followed by the cost.
      expect(RegExp(r'^\$2[aby]\$\d{2}\$').hasMatch(hash), isTrue,
          reason: 'Expected a bcrypt-formatted hash, got: $hash');
    });

    test('hashPassword uses a fresh salt per call (non-deterministic)', () {
      const password = 'testPassword123';
      final hash1 = authService.hashPassword(password);
      final hash2 = authService.hashPassword(password);

      expect(hash1, isNot(equals(hash2)),
          reason:
              'bcrypt must produce a new salt per call; identical output indicates a missing salt.');
    });

    test('verifyPassword returns true for the correct password', () {
      const password = 'correct horse battery staple';
      final hash = authService.hashPassword(password);

      expect(authService.verifyPassword(password, hash), isTrue);
    });

    test('verifyPassword returns false for an incorrect password', () {
      final hash = authService.hashPassword('password1');

      expect(authService.verifyPassword('password2', hash), isFalse);
    });

    test('verifyPassword tolerates malformed stored hashes', () {
      expect(authService.verifyPassword('anything', 'not-a-bcrypt-hash'),
          isFalse);
    });
  });
}
