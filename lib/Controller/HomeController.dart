import 'package:flutter/material.dart';
import 'package:quizz/Database/lesson_repo.dart';
import 'package:quizz/Models/Lesson.dart';
import 'package:quizz/Views/AddFillLessonScreen.dart';
import 'package:quizz/Views/AddLessonScreen.dart';
import '../Models/User.dart';

class HomeController {
  final LessonRepo _lessonRepo = LessonRepo();
  // Logic điều hướng sang trang Profile
  void navigateToProfile(BuildContext context, User user) {
    print("Điều hướng tới Profile của: ${user.displayName}");
    // Sau này: Navigator.push(context, MaterialPageRoute(builder: (_) => ProfileScreen(user: user)));
  }

  // Logic điều hướng sang trang thêm câu hỏi
  Future<void> navigateToAddLesson(BuildContext context, User user) async {
    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Chọn loại học phần",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.quiz, color: Colors.blue),
                title: const Text("Trắc nghiệm (4 đáp án)"),
                onTap:  () async {
                  await Navigator.push(context, MaterialPageRoute(
                      builder: (_) => AddLessonScreen(user: user)));

                  // 2. Sau khi trang AddLesson đóng, mới đóng BottomSheet
                  if (context.mounted) Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.edit, color: Colors.green),
                title: const Text("Điền từ (Trả lời ngắn)"),
                onTap: () async {
                  await Navigator.push(context, MaterialPageRoute(
                      builder: (_) => AddFillLessonScreen(user: user)));

                  if (context.mounted) Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Bạn có thể thêm các hàm xử lý dữ liệu khác ở đây
  String getGreeting() {
    var hour = DateTime.now().hour;
    if (hour < 12) return "Chào buổi sáng,";
    if (hour < 18) return "Chào buổi chiều,";
    return "Chào buổi tối,";
  }

  // Hàm lấy và phân loại học phần
  Future<Map<String, List<Lesson>>> getCategorizedLessons(int userId) async {
    List<Lesson> allLessons = await _lessonRepo.getAllLessons(userId);

    // Phân loại
    List<Lesson> quizLessons = allLessons.where((l) => l.type == 'abc').toList();
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
}