import 'package:flutter/material.dart';
import 'package:quizz/Controller/QuizController.dart';
import 'package:quizz/Models/Lesson.dart';
import 'package:quizz/Views/AdminFillLessonDetailScreen.dart';
import 'package:quizz/Views/LessonDetailsScreenAdmin.dart';

class ManageQuizScreen extends StatefulWidget {
  const ManageQuizScreen({super.key});

  @override
  State<ManageQuizScreen> createState() => _ManageQuizScreenState();
}

class _ManageQuizScreenState extends State<ManageQuizScreen> {
  final Quizcontroller _controller = Quizcontroller();
  Key _refreshKey = UniqueKey();

  void _refreshData() => setState(() => _refreshKey = UniqueKey());

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        appBar: AppBar(
          title: const Text(
            'Quản lý câu hỏi',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.blue[900],
          foregroundColor: Colors.white,
          elevation: 0,
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white54,
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            tabs: [
              Tab(icon: Icon(Icons.quiz_outlined), text: 'Trắc nghiệm'),
              Tab(icon: Icon(Icons.text_fields), text: 'Điền từ'),
            ],
          ),
        ),
        body: FutureBuilder<Map<String, List<Lesson>>>(
          key: _refreshKey,
          future: _controller.getCategorizedLessonsAdmin(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return const Center(child: Text('Lỗi tải dữ liệu'));
            }

            final data = snapshot.data ?? {};
            final quizLessons = data['quiz'] ?? [];
            final fillLessons = data['fill'] ?? [];

            return TabBarView(
              children: [
                // Tab Trắc nghiệm
                _buildLessonList(
                  lessons: quizLessons,
                  type: 'quiz',
                  emptyMessage: 'Chưa có bộ trắc nghiệm nào',
                ),
                // Tab Điền từ
                _buildLessonList(
                  lessons: fillLessons,
                  type: 'fill',
                  emptyMessage: 'Chưa có bộ điền từ nào',
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ─── DANH SÁCH HỌC PHẦN ──────────────────────────────────────────────────
  Widget _buildLessonList({
    required List<Lesson> lessons,
    required String type,
    required String emptyMessage,
  }) {
    if (lessons.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              type == 'fill' ? Icons.text_fields : Icons.quiz_outlined,
              size: 64,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: TextStyle(color: Colors.grey[500], fontSize: 16),
            ),
          ],
        ),
      );
    }

    final Color themeColor =
    type == 'fill' ? Colors.green[700]! : Colors.blue[900]!;

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      itemCount: lessons.length,
      itemBuilder: (context, index) {
        final lesson = lessons[index];
        return _buildLessonCard(lesson, themeColor);
      },
    );
  }

  // ─── CARD HỌC PHẦN ───────────────────────────────────────────────────────
  Widget _buildLessonCard(Lesson lesson, Color color) {
    final isFill = lesson.type == 'fill';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            isFill ? Icons.text_fields : Icons.quiz_outlined,
            color: color,
            size: 24,
          ),
        ),
        title: Text(
          lesson.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        subtitle: Text(
          'ID: ${lesson.id}  •  ${isFill ? "Điền từ" : "Trắc nghiệm"}',
          style: TextStyle(color: Colors.grey[500], fontSize: 12),
        ),
        trailing: Icon(Icons.arrow_forward_ios,
            size: 14, color: Colors.grey[400]),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        onTap: () async {
          // Điều hướng đến màn hình tương ứng
          final deleted = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (context) => isFill
                  ? AdminFillLessonDetailScreen(lesson: lesson)
                  : LessonDetailsScreenAdmin(lesson: lesson),
            ),
          );

          // Nếu admin vừa xóa học phần → reload danh sách
          if (deleted == true) {
            _refreshData();
          }
        },
      ),
    );
  }
}