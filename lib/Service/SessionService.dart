import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  static const String _keyUserId = 'user_id';
  static const String _keyToken = 'auth_token';

  // Lưu cả ID và Token khi đăng nhập thành công
  static Future<void> saveSession(int userId, String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyUserId, userId);
    await prefs.setString(_keyToken, token);
  }

  // Lấy dữ liệu session
  static Future<Map<String, dynamic>?> getSession() async {
    final prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt(_keyUserId);
    String? token = prefs.getString(_keyToken);

    if (userId != null && token != null) {
      return {'userId': userId, 'token': token};
    }
    return null;
  }

  // Xóa sạch khi Logout
  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}