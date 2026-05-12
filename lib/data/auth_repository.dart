import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/crypto.dart';

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

  Future<void> seedDefaultUserIfMissing() async {
    final prefs = await _prefs;
    if (!prefs.containsKey(_kUsername)) {
      await prefs.setString(_kUsername, _defaultUsername);
      await prefs.setString(_kPasswordHash, hashPassword(_defaultPassword));
    }
  }

  Future<String?> getUsername() async {
    final prefs = await _prefs;
    return prefs.getString(_kUsername);
  }

  Future<bool> verify(String username, String password) async {
    final prefs = await _prefs;
    final storedUser = prefs.getString(_kUsername);
    final storedHash = prefs.getString(_kPasswordHash);
    if (storedUser == null || storedHash == null) return false;
    return storedUser == username && storedHash == hashPassword(password);
  }

  Future<bool> changePassword(String oldPassword, String newPassword) async {
    final prefs = await _prefs;
    final storedHash = prefs.getString(_kPasswordHash);
    if (storedHash == null) return false;
    if (storedHash != hashPassword(oldPassword)) return false;
    await prefs.setString(_kPasswordHash, hashPassword(newPassword));
    return true;
  }

  Future<bool> isLoggedIn() async {
    final prefs = await _prefs;
    return prefs.getBool(_kIsLoggedIn) ?? false;
  }

  Future<void> setLoggedIn(bool value) async {
    final prefs = await _prefs;
    await prefs.setBool(_kIsLoggedIn, value);
  }

  Future<void> logout() async => setLoggedIn(false);
}
