import 'dart:convert';
import 'package:crypto/crypto.dart';

/// Hash [input] dengan SHA-256, kembalikan hex string (64 karakter).
///
/// Deterministik: input sama → output sama. One-way: hash tidak bisa dibalik
/// ke plaintext. Cocok untuk verifikasi password offline (single-device).
/// Untuk production multi-user sebaiknya pakai bcrypt/argon2 dengan salt.
String hashPassword(String input) {
  final bytes = utf8.encode(input);
  return sha256.convert(bytes).toString();
}
