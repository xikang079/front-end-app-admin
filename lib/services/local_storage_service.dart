import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class LocalStorageService {
  static const String _tokenKey = 'token';
  static const String _userIdKey = 'user_id';
  static const String _userDataKey = 'user_data';
  static const String _lastLoginKey = 'last_login';

  static Future<void> saveToken(String token) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  static Future<String?> getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<void> clearToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  static Future<void> saveUserId(String userId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userIdKey, userId);
  }

  static Future<String?> getUserId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }

  static Future<void> clearUserId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userIdKey);
  }

  // Lưu thông tin user đầy đủ để sử dụng offline
  static Future<void> saveUserData(Map<String, dynamic> userData) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userDataKey, jsonEncode(userData));
    await prefs.setString(_lastLoginKey, DateTime.now().toIso8601String());
  }

  // Lấy thông tin user đã lưu
  static Future<String?> getUserData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userDataKey);
  }

  // Lấy thời gian đăng nhập cuối
  static Future<String?> getLastLogin() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastLoginKey);
  }

  // Kiểm tra xem có dữ liệu offline không
  static Future<bool> hasOfflineData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_userDataKey) &&
        prefs.containsKey(_tokenKey) &&
        prefs.containsKey(_userIdKey);
  }

  // Xóa tất cả dữ liệu offline
  static Future<void> clearAllData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_userDataKey);
    await prefs.remove(_lastLoginKey);
  }
}
