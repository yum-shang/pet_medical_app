import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants.dart';

class AuthStorage {
  static Future<SharedPreferences> get _prefs =>
      SharedPreferences.getInstance();

  static Future<void> saveLoginInfo({
    required String token,
    required int userId,
    required String role,
    required String username,
  }) async {
    final prefs = await _prefs;
    await prefs.setString(StorageKeys.token, token);
    await prefs.setInt(StorageKeys.userId, userId);
    await prefs.setString(StorageKeys.userRole, role);
    await prefs.setString(StorageKeys.username, username);
    await prefs.setBool(StorageKeys.isLoggedIn, true);
    await prefs.setBool(StorageKeys.isMockSession, false);
  }

  /// 保存 Mock 演示登录态（无真实 JWT）
  static Future<void> saveMockLoginInfo({
    required String token,
    required int userId,
    required String username,
  }) async {
    final prefs = await _prefs;
    await prefs.setString(StorageKeys.token, token);
    await prefs.setInt(StorageKeys.userId, userId);
    await prefs.setString(StorageKeys.userRole, 'user');
    await prefs.setString(StorageKeys.username, username);
    await prefs.setBool(StorageKeys.isLoggedIn, true);
    await prefs.setBool(StorageKeys.isMockSession, true);
  }

  static Future<bool> isMockSession() async {
    final prefs = await _prefs;
    return prefs.getBool(StorageKeys.isMockSession) ?? false;
  }

  static Future<String?> getToken() async {
    final prefs = await _prefs;
    return prefs.getString(StorageKeys.token);
  }

  static Future<int?> getUserId() async {
    final prefs = await _prefs;
    return prefs.getInt(StorageKeys.userId);
  }

  static Future<String?> getUserRole() async {
    final prefs = await _prefs;
    return prefs.getString(StorageKeys.userRole);
  }

  static Future<String?> getUsername() async {
    final prefs = await _prefs;
    return prefs.getString(StorageKeys.username);
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await _prefs;
    return prefs.getBool(StorageKeys.isLoggedIn) ?? false;
  }

  static Future<void> clearAll() async {
    final prefs = await _prefs;
    await prefs.remove(StorageKeys.token);
    await prefs.remove(StorageKeys.userId);
    await prefs.remove(StorageKeys.userRole);
    await prefs.remove(StorageKeys.username);
    await prefs.setBool(StorageKeys.isLoggedIn, false);
    await prefs.remove(StorageKeys.isMockSession);
  }
}
