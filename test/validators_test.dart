import 'package:flutter_test/flutter_test.dart';
import 'package:fit_track/core/validators.dart';

void main() {
  group('AppValidators', () {
    test('validateEmail returns null for valid emails', () {
      expect(AppValidators.validateEmail('test@example.com'), isNull);
      expect(AppValidators.validateEmail('user.name+tag@sub.domain.org'), isNull);
    });

    test('validateEmail returns error keys for invalid inputs', () {
      expect(AppValidators.validateEmail(null), 'fieldRequired');
      expect(AppValidators.validateEmail(''), 'fieldRequired');
      expect(AppValidators.validateEmail('   '), 'fieldRequired');
      expect(AppValidators.validateEmail('invalid-email'), 'emailInvalid');
      expect(AppValidators.validateEmail('user@domain'), 'emailInvalid');
    });

    test('validatePassword validates minimum 6 chars', () {
      expect(AppValidators.validatePassword(null), 'fieldRequired');
      expect(AppValidators.validatePassword(''), 'fieldRequired');
      expect(AppValidators.validatePassword('12345'), 'passwordTooShort');
      expect(AppValidators.validatePassword('123456'), isNull);
      expect(AppValidators.validatePassword('securePassword123'), isNull);
    });

    test('validatePositiveNumber validates positive doubles', () {
      expect(AppValidators.validatePositiveNumber(null), 'fieldRequired');
      expect(AppValidators.validatePositiveNumber(''), 'fieldRequired');
      expect(AppValidators.validatePositiveNumber('0'), 'positiveNumberRequired');
      expect(AppValidators.validatePositiveNumber('-5'), 'positiveNumberRequired');
      expect(AppValidators.validatePositiveNumber('abc'), 'positiveNumberRequired');
      expect(AppValidators.validatePositiveNumber('75.5'), isNull);
      expect(AppValidators.validatePositiveNumber('75,5'), isNull);
      expect(AppValidators.validatePositiveNumber('10'), isNull);
    });
  });
}
