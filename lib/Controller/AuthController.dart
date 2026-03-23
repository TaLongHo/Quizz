import '../Models/User.dart';
import '../Database/user_repo.dart';

class AuthController {
  final UserRepo _userRepo = UserRepo();

  /// Trả về:
  /// - User object nếu login thành công
  /// - null nếu sai thông tin
  /// - Ném String 'BLOCKED' nếu tài khoản bị khóa
  Future<User?> handleLogin(String username, String password) async {
    try {
      if (username.isEmpty || password.isEmpty) return null;

      // 1. Thử đăng nhập bình thường (chỉ active mới qua được)
      final user = await _userRepo.login(username, password);

      if (user != null) return user;

      // 2. Nếu thất bại, kiểm tra xem có phải do bị block không
      final isBlocked = await _userRepo.isUserBlocked(username);
      if (isBlocked) {
        throw 'BLOCKED'; // Controller ném exception đặc biệt
      }

      return null; // Sai mật khẩu hoặc không tồn tại
    } catch (e) {
      rethrow;
    }
  }

  Future<String?> handleRegister(User newUser) async {
    try {
      int result = await _userRepo.register(newUser);
      if (result > 0) return null;
      return "Đăng ký thất bại, vui lòng thử lại!";
    } catch (e) {
      if (e.toString().contains('UNIQUE')) {
        return "Tên đăng nhập đã tồn tại!";
      }
      return "Lỗi hệ thống: $e";
    }
  }
}