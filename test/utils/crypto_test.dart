import 'package:agenda_nusantara/utils/crypto.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('hashPassword', () {
    test('returns SHA-256 hex of input', () {
      expect(
        hashPassword('user'),
        '04f8996da763b7a969b1028ee3007569eaf3a635486ddab211d512c85b9df8fb',
      );
    });

    test('different inputs produce different hashes', () {
      expect(hashPassword('user'), isNot(equals(hashPassword('User'))));
    });

    test('empty string still hashes', () {
      expect(hashPassword('').length, 64);
    });
  });
}
