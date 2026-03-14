import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import '../Models/User.dart';

class AuthService {
  static const String _secretKey = "NHOM_FLUTTER_2026_SECRET"; // Dùng chung key này

  // 1. Hàm tạo Token (Ní gọi hàm này ở Login)
  static String generateToken(User user) {
    final jwt = JWT({
      'id': user.id,
      'role': user.role,
      'exp': DateTime.now().add(const Duration(days: 1)).millisecondsSinceEpoch, // Hết hạn sau 1 ngày
    });
    return jwt.sign(SecretKey(_secretKey));
  }

  // 2. Hàm kiểm tra quyền Admin (Để ní dùng cho phân quyền)
  static bool isAdmin(String token) {
    try {
      final jwt = JWT.decode(token);
      return jwt.payload['role'] == 'admin';
    } catch (e) {
      return false;
    }
  }

  // 3. Hàm kiểm tra Token còn hạn không (Bảo mật thêm)
  static bool isTokenValid(String token) {
    try {
      JWT.verify(token, SecretKey(_secretKey));
      return true;
    } catch (e) {
      return false;
    }
  }
}