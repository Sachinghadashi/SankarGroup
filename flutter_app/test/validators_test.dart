import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/core/utils/validators.dart';

void main() {
  group('Form Input Validators Test Suite', () {
    test('Email validator accepts valid emails and rejects invalid ones', () {
      expect(Validators.validateEmail('user@example.com'), isNull);
      expect(Validators.validateEmail('admin.test@domain.co'), isNull);
      expect(Validators.validateEmail(''), 'Email address is required');
      expect(Validators.validateEmail(null), 'Email address is required');
      expect(Validators.validateEmail('invalid-email'), 'Please enter a valid email address');
      expect(Validators.validateEmail('missing@tld'), 'Please enter a valid email address');
    });

    test('Password validator checks length minimum', () {
      expect(Validators.validatePassword('123456'), isNull);
      expect(Validators.validatePassword('password123'), isNull);
      expect(Validators.validatePassword(''), 'Password is required');
      expect(Validators.validatePassword(null), 'Password is required');
      expect(Validators.validatePassword('12345'), 'Password must be at least 6 characters long');
    });

    test('Name validator checks empty and min length', () {
      expect(Validators.validateName('Sachin Ghadashi'), isNull);
      expect(Validators.validateName(''), 'Full name is required');
      expect(Validators.validateName(null), 'Full name is required');
      expect(Validators.validateName('A'), 'Name must be at least 2 characters');
    });

    test('Confirm password validator matches primary password', () {
      expect(Validators.validateConfirmPassword('secret123', 'secret123'), isNull);
      expect(Validators.validateConfirmPassword('wrong', 'secret123'), 'Passwords do not match');
      expect(Validators.validateConfirmPassword('', 'secret123'), 'Please confirm your password');
    });
  });
}
