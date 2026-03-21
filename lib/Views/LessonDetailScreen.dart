import 'package:flutter/material.dart';
import 'package:quizz/Database/lesson_repo.dart';
import 'package:quizz/Models/Lesson.dart';
import 'package:quizz/Models/Question.dart';
import 'package:quizz/Views/QuizScreen.dart';
import 'package:quizz/Views/UpdateQuizScreen.dart';

class LessonDetailScreen extends StatefulWidget {
  final Lesson lesson;

  const LessonDetailScreen({super.key, required this.lesson});

  @override
  State<LessonDetailScreen> createState() => _LessonDetailScreenState();
}

class _LessonDetailScreenState extends State<LessonDetailScreen> {
  final LessonRepo _repo = LessonRepo();
  Key _refreshKey = UniqueKey();

  void _refresh() => setState(() => _refreshKey = UniqueKey());

  // ─── DELETE QUESTION ─────────────────────────
  Future<void> _deleteQuestion(Question q) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Xóa câu hỏi"),
        content: Text('Bạn có chắc muốn xóa:\n"${q.content}" ?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text("HỦY")),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child:
              const Text("XÓA", style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm != true) return;

    await _repo.deleteQuestion(q.id!);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Đã xóa câu hỏi")),
    );

    _refresh();
  }

  @override
  Widget build(BuildContext context) {
    final String typeName =
    widget.lesson.type == 'quiz' ? "Trắc nghiệm" : "Điền từ";
    final Color themeColor = widget.lesson.type == 'quiz'
        ? Colors.blue[900]!
        : Colors.green[700]!;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.lesson.title,
                style:
                const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text("Loại: $typeName",
                style:
                const TextStyle(fontSize: 12, color: Colors.white70)),
          ],
        ),
        backgroundColor: themeColor,
      ),

      // ─── BODY ─────────────────────────
      body: FutureBuilder<List<Question>>(
        key: _refreshKey,
        future: _repo.getQuestionsByLesson(widget.lesson.id!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final questions = snapshot.data ?? [];

          if (questions.isEmpty) {
            return const Center(child: Text("Chưa có câu hỏi"));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: questions.length,
            itemBuilder: (context, index) {
              final q = questions[index];
              return _buildQuestionCard(index + 1, q, themeColor);
            },
          );
        },
      ),

      // ─── START QUIZ ─────────────────────────
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => QuizScreen(lesson: widget.lesson),
            ),
          );
        },
        label: const Text("Bắt đầu học"),
        icon: const Icon(Icons.play_arrow),
        backgroundColor: themeColor,
      ),
    );
  }

  // ─── CARD ─────────────────────────
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
          )
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("CÂU $number",
                style:
                TextStyle(fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 8),

            Text(q.content, style: const TextStyle(fontSize: 16)),

            const Divider(),

            Text("Đáp án: ${q.answer}",
                style: const TextStyle(
                    color: Colors.green, fontWeight: FontWeight.bold)),

            if (widget.lesson.type == 'quiz' &&
                (q.options?.isNotEmpty ?? false))
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text("Options: ${q.options}",
                    style: const TextStyle(color: Colors.grey)),
              ),

            const SizedBox(height: 8),

            // ─── ACTION BUTTONS ─────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // EDIT
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.orange),
                  onPressed: () async {
                    final updated = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            UpdateQuizScreen(lesson: widget.lesson),
                      ),
                    );

                    if (updated == true) {
                      _refresh();
                    }
                  },
                ),

                // DELETE
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteQuestion(q),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}