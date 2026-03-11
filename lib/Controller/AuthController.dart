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
}