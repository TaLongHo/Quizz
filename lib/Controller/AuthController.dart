import '../Models/User.dart';
import '../Database/user_repo.dart';

class AuthController {
  final UserRepo _userRepo = UserRepo();

  Future<User?> handleLogin(String username, String password) async {
    try {
      if (username.isEmpty || password.isEmpty) return null;

      // Chuyển việc truy vấn xuống Repo
      return await _userRepo.login(username, password);
    } catch (e) {
      return null;
    }
  }

  // Hàm xử lý đăng ký
  Future<String?> handleRegister(User newUser) async {
    try {
      final allUsers = await _userRepo.login(newUser.username, newUser.password);

      int result = await _userRepo.register(newUser);
      if (result > 0) return null; // Thành công
      return "Đăng ký thất bại, vui lòng thử lại!";
    } catch (e) {
      if (e.toString().contains('UNIQUE')) {
        return "Tên đăng nhập đã tồn tại!";
      }
      return "Lỗi hệ thống: $e";
    }
  }
}