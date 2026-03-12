import 'package:flutter/material.dart';
import 'package:quizz/Database/lesson_repo.dart';
import 'package:quizz/Models/Lesson.dart';
import 'package:quizz/Models/Question.dart';

import 'QuizScreen.dart';

class LessonDetailScreen extends StatelessWidget {
  final Lesson lesson;
  final LessonRepo _repo = LessonRepo();

  LessonDetailScreen({super.key, required this.lesson});

  @override
  Widget build(BuildContext context) {
    // Xác định tên loại để hiển thị lên AppBar
    final String typeName = lesson.type == 'abc' ? "Trắc nghiệm" : "Điền từ";
    final Color themeColor = lesson.type == 'abc' ? Colors.blue[900]! : Colors.green[700]!;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5), // Nền xám nhạt cho đỡ mỏi mắt
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(lesson.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(
                "Loại: $typeName",
                style: const TextStyle(fontSize: 12, color: Colors.white70, fontWeight: FontWeight.normal)
            ),
          ],
        ),
        backgroundColor: themeColor,
        elevation: 0,
      ),
      body: FutureBuilder<List<Question>>(
        future: _repo.getQuestionsByLesson(lesson.id!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final questions = snapshot.data ?? [];
          if (questions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notes_rounded, size: 60, color: Colors.grey[400]),
                  const SizedBox(height: 10),
                  const Text("Học phần này chưa có câu hỏi nào.", style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          // XỬ LÝ NHIỀU CÂU HỎI: Sử dụng ListView.builder giúp tối ưu bộ nhớ
          // Chỉ những câu hỏi đang hiện trên màn hình mới được render.
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
            itemCount: questions.length,
            // Thêm hiệu ứng vật lý để cuộn mượt hơn trên mobile
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              final q = questions[index];
              return _buildQuestionCard(index + 1, q, themeColor);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => QuizScreen(lesson: lesson), // Chuyển sang màn hình làm bài
            ),
          );
        },
        label: const Text("Bắt đầu học ngay"),
        icon: const Icon(Icons.play_lesson),
        backgroundColor: themeColor,
      ),
    );
  }

  // Tách Widget Card ra để code sạch sẽ, dễ bảo trì
  Widget _buildQuestionCard(int number, Question q, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: IntrinsicHeight( // Giúp thanh màu bên cạnh cao bằng Card
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Thanh màu chỉ thị bên trái
              Container(width: 6, color: color),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("CÂU HỎI $number",
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
                          const Icon(Icons.check_circle_outline, size: 16, color: Colors.green),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        q.content,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Divider(height: 1),
                      ),
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(fontSize: 14, color: Colors.black87),
                          children: [
                            const TextSpan(text: "Đáp án: ", style: TextStyle(fontWeight: FontWeight.bold)),
                            TextSpan(text: q.answer, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),

                      // Hiển thị lựa chọn nếu là trắc nghiệm và có dữ liệu
                      if (lesson.type == 'abc' && (q.options?.isNotEmpty ?? false)) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            "Gợi ý: ${q.options}",
                            style: TextStyle(fontSize: 13, color: Colors.grey[600], fontStyle: FontStyle.italic),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}