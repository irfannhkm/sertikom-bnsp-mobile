import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/crypto.dart';

/// Akses data autentikasi via SharedPreferences (key-value).
///
/// Menyimpan: `username` (plaintext), `password_hash` (SHA-256), dan
/// `is_logged_in` (flag session). Tidak ada server—single user per device.
///
/// Kredensial default dibaca dari `.env` (lihat [DEFAULT_USERNAME] dan
/// [DEFAULT_PASSWORD]). Untuk testing, lewatkan nilai eksplisit via parameter
/// constructor agar tidak bergantung pada dotenv.
class AuthRepository {
  static const _kUsername = 'username';
  static const _kPasswordHash = 'password_hash';
  static const _kIsLoggedIn = 'is_logged_in';

  final String _defaultUsername;
  final String _defaultPassword;

  AuthRepository({String? defaultUsername, String? defaultPassword})
    : _defaultUsername =
          defaultUsername ?? dotenv.env['DEFAULT_USERNAME'] ?? 'admin',
      _defaultPassword =
          defaultPassword ?? dotenv.env['DEFAULT_PASSWORD'] ?? 'admin';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  /// Buat user default kalau key `username` belum ada di SharedPreferences.
  /// Aman dipanggil tiap kali aplikasi start—tidak menimpa data yang ada.
  Future<void> seedDefaultUserIfMissing() async {
    final prefs = await _prefs;
    if (!prefs.containsKey(_kUsername)) {
      await prefs.setString(_kUsername, _defaultUsername);
      await prefs.setString(_kPasswordHash, hashPassword(_defaultPassword));
    }
  }

  /// Ambil username tersimpan, null kalau belum di-seed.
  Future<String?> getUsername() async {
    final prefs = await _prefs;
    return prefs.getString(_kUsername);
  }

  /// Verifikasi pasangan username+password.
  /// Hash input dibandingkan dengan hash tersimpan—bukan plaintext.
  Future<bool> verify(String username, String password) async {
    final prefs = await _prefs;
    final storedUser = prefs.getString(_kUsername);
    final storedHash = prefs.getString(_kPasswordHash);
    if (storedUser == null || storedHash == null) return false;
    return storedUser == username && storedHash == hashPassword(password);
  }

  /// Ganti password. Validasi [oldPassword] dulu sebelum tulis hash baru.
  /// Return false kalau password lama salah atau belum ada user tersimpan.
  Future<bool> changePassword(String oldPassword, String newPassword) async {
    final prefs = await _prefs;
    final storedHash = prefs.getString(_kPasswordHash);
    if (storedHash == null) return false;
    if (storedHash != hashPassword(oldPassword)) return false;
    await prefs.setString(_kPasswordHash, hashPassword(newPassword));
    return true;
  }

  /// Cek apakah ada session aktif.
  Future<bool> isLoggedIn() async {
    final prefs = await _prefs;
    return prefs.getBool(_kIsLoggedIn) ?? false;
  }

  /// Set flag session.
  Future<void> setLoggedIn(bool value) async {
    final prefs = await _prefs;
    await prefs.setBool(_kIsLoggedIn, value);
  }

  /// Akhiri session (set is_logged_in=false).
  Future<void> logout() async => setLoggedIn(false);
}
