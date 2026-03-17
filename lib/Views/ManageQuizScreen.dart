import 'package:flutter/material.dart';
import 'package:quizz/Controller/QuizController.dart';
import 'package:quizz/Models/Lesson.dart';
import 'package:quizz/Views/LessonDetailsScreenAdmin.dart';

class ManageQuizScreen extends StatefulWidget {
  const ManageQuizScreen({super.key});

  @override
  State<ManageQuizScreen> createState() => _ManageQuizScreenState();
}

class _ManageQuizScreenState extends State<ManageQuizScreen> {
  final Quizcontroller _controller = Quizcontroller();
  Key _refreshKey = UniqueKey();

  void _refreshData() {
    setState(() {
      _refreshKey = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),

        appBar: AppBar(
          title: const Text("Quản lý câu hỏi"),
          backgroundColor: Colors.blue[900],
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(text: "Quiz"),
              Tab(text: "Fill"),
            ],
          ),
        ),

        body: Padding(
          padding: const EdgeInsets.all(16),
          child: FutureBuilder<Map<String, List<Lesson>>>(
            key: _refreshKey,
            future: _controller.getCategorizedLessonsAdmin(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return const Center(child: Text("Lỗi tải dữ liệu"));
              }

              final data = snapshot.data ?? {};
              final quizLessons = data['quiz'] ?? [];
              final fillLessons = data['fill'] ?? [];

              if (quizLessons.isEmpty && fillLessons.isEmpty) {
                return const Center(
                  child: Text("Không có dữ liệu"),
                );
              }

              return TabBarView(
                children: [
                  _buildLessonList(quizLessons),
                  _buildLessonList(fillLessons),
                ],
              );
            },
          ),
        ),

        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // TODO: thêm câu hỏi
          },
          backgroundColor: Colors.white,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  // 🔥 Widget hiển thị danh sách lesson
  Widget _buildLessonList(List<Lesson> lessons) {
    if (lessons.isEmpty) {
      return const Center(child: Text("Không có dữ liệu"));
    }

    return ListView.builder(
      itemCount: lessons.length,
      itemBuilder: (context, index) {
        final lesson = lessons[index];

        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: ListTile(
            title: Text(
              lesson.title ?? "No Title",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text("Lesson ID: ${lesson.id}"),
            leading: const Icon(Icons.book, color: Colors.white),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),

            // 👉 theo yêu cầu của bạn: click mở lại chính nó
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LessonDetailsScreenAdmin(lesson: lesson),
                ),
              );
            },
          ),
        );
      },
    );
  }
}