import '../Database/lesson_repo.dart';
import '../Database/user_repo.dart';
import '../Models/Lesson.dart';
import '../Models/User.dart';

class UserManagementController {
  final UserRepo _userRepo = UserRepo();
  final LessonRepo _lessonRepo = LessonRepo();

  /// Lấy toàn bộ danh sách user (kể cả bị block)
  Future<List<User>> getAllUsers() async {
    return await _userRepo.getAllUsers();
  }

  /// Lấy danh sách bài học của 1 user
  Future<List<Lesson>> getLessonsByUser(int userId) async {
    return await _lessonRepo.getAllLessons(userId);
  }

  /// Block user (soft delete: is_active = 0)
  Future<bool> blockUser(int userId) async {
    return await _userRepo.blockUser(userId);
  }

  /// Unblock user (is_active = 1)
  Future<bool> unblockUser(int userId) async {
    return await _userRepo.unblockUser(userId);
  }

  /// Label danh hiệu theo streak
  String getRankTitle(int streak) {
    if (streak >= 30) return "Thánh Học 👑";
    if (streak >= 21) return "Huyền Thoại 🔥";
    if (streak >= 14) return "Chuyên Gia ⚡";
    if (streak >= 7) return "Chăm Chỉ 🌟";
    return "Người Mới 🌱";
  }

  String getGenderText(int gender) {
    switch (gender) {
      case 0:
        return "Nam";
      case 1:
        return "Nữ";
      default:
        return "Khác";
    }
  }
}