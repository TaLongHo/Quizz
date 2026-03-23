import '../Database/user_repo.dart';
import '../Models/User.dart';

class LeaderboardController {
  final UserRepo _userRepo = UserRepo();

  Future<List<User>> getLeaderboardData() async {
    // Giả lập delay một chút để tạo hiệu ứng load chuyên nghiệp
    await Future.delayed(const Duration(milliseconds: 500));
    return await _userRepo.getLeaderboard();
  }

  // Logic gán danh hiệu dựa trên thành tích
  String getRankTitle(int streak) {
    if (streak >= 30) return "Thánh Học 👑";
    if (streak >= 21) return "Huyền Thoại 🔥";
    if (streak >= 14) return "Chuyên Gia ⚡";
    if (streak >= 7) return "Chăm Chỉ 🌟";
    return "Người Mới 🌱";
  }
}