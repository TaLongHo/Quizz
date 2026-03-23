import 'package:flutter/material.dart';
import 'package:quizz/Database/lesson_repo.dart';
import 'package:quizz/Database/study_log_repo.dart';
import 'package:quizz/Database/user_repo.dart';
import 'package:quizz/Models/Lesson.dart';
import 'package:quizz/Views/AddFillLessonScreen.dart';
import 'package:quizz/Views/AddLessonScreen.dart';
import 'package:quizz/Views/ProfileScreen.dart';
import '../Models/User.dart';
import '../Views/StreakCalendarModal.dart';
import 'package:quizz/Service/ThemeService.dart';

class HomeController {
  final LessonRepo _lessonRepo = LessonRepo();
  final StudyLogRepo _logRepo = StudyLogRepo();
  final UserRepo _userRepo = UserRepo();
  // Logic điều hướng sang trang Profile
  Future<User?> navigateToProfile(BuildContext context, User user) async {
    // await kết quả trả về từ Navigator.pop của trang Profile
    final updatedUser = await Navigator.push<User>(
      context,
      MaterialPageRoute(builder: (_) => ProfileScreen(user: user)),
    );
    return updatedUser;
  }

  // Logic điều hướng sang trang thêm câu hỏi
  Future<void> navigateToAddLesson(BuildContext context, User user, VoidCallback onRefresh) async {
    final isDark = ThemeService.isDark;

    await showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor, // Đồng bộ màu nền với App
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (bottomSheetContext) { // Đặt tên khác để tránh nhầm với context bên ngoài
        return Container(
          padding: const EdgeInsets.only(top: 15, left: 25, right: 25, bottom: 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 25),
              Text(
                "Chọn loại học phần",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 25),

              // 1. Lựa chọn Trắc nghiệm
              _buildOptionCard(
                context,
                title: "Trắc nghiệm",
                subtitle: "Câu hỏi 4 đáp án, chọn 1 đáp án đúng",
                icon: Icons.quiz_rounded,
                iconColor: Colors.blueAccent,
                onTap: () async {
                  Navigator.pop(bottomSheetContext); // Đóng BottomSheet
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => AddLessonScreen(user: user)),
                  );
                  if (result == true) onRefresh(); // Refresh khi thêm thành công
                },
              ),

              const SizedBox(height: 15),

              // 2. Lựa chọn Điền từ (FIX CHỖ NÀY)
              _buildOptionCard(
                context,
                title: "Điền từ",
                subtitle: "Tự nhập câu trả lời chính xác",
                icon: Icons.history_edu_rounded,
                iconColor: Colors.greenAccent,
                onTap: () async {
                  Navigator.pop(bottomSheetContext); // PHẢI đóng BottomSheet trước khi Push
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => AddFillLessonScreen(user: user)),
                  );
                  // Kiểm tra kết quả trả về từ AddFillLessonScreen
                  if (result == true) {
                    onRefresh(); // Kích hoạt refresh danh sách ở HomeScreen
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOptionCard(
      BuildContext context, {
        required String title,
        required String subtitle,
        required IconData icon,
        required Color iconColor,
        required VoidCallback onTap,
      }) {
    final isDark = ThemeService.isDark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? Colors.white10 : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(icon, color: iconColor, size: 28),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white60 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 14, color: isDark ? Colors.white30 : Colors.grey),
          ],
        ),
      ),
    );
  }

  // Bạn có thể thêm các hàm xử lý dữ liệu khác ở đây
  String getGreeting() {
    var hour = DateTime.now().hour;
    if (hour < 12) return "Chào buổi sáng,";
    if (hour < 18) return "Chào buổi chiều,";
    return "Chào buổi tối,";
  }

  // Hàm lấy và phân loại học phần kèm PHÂN TRANG (3 item/trang)
  // Trả về Map<String, List<Lesson>> như cũ
  Future<Map<String, List<Lesson>>> getCategorizedLessons(int userId) async {
    List<Lesson> allLessons = await _lessonRepo.getAllLessons(userId);

    List<Lesson> quizLessons = allLessons.where((l) => l.type == 'quiz').toList();
    List<Lesson> fillLessons = allLessons.where((l) => l.type == 'fill').toList();

    return {
      'quiz': quizLessons,
      'fill': fillLessons,
    };
  }

  // Trong class HomeController
  Future<bool> deleteLesson(int lessonId) async {
    try {
      await _lessonRepo.deleteLesson(lessonId);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> showStreakCalendar(BuildContext context, User user, Function(User) onRefreshUI) async {
    // 1. Lấy dữ liệu học tập
    List<String> dates = await _logRepo.getStudyDates(user.id!);

    // 2. Lấy User mới nhất để cập nhật StreakCount thực tế
    User? latestUser = await _userRepo.getUserById(user.id!);

    if (latestUser != null) {
      // Cập nhật lại UI màn hình HomeScreen thông qua callback
      onRefreshUI(latestUser);

      if (context.mounted) {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => StreakCalendarModal(
            studyDates: dates,
            streakCount: latestUser.streakCount,
          ),
        );
      }
    }
  }
  Future<List<Lesson>> getAllLessonsAdmin() => _lessonRepo.getAllLessonsAdmin();
}