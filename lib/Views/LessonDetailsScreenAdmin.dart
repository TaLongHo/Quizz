import 'package:flutter/material.dart';
import 'package:quizz/Database/lesson_repo.dart';
import 'package:quizz/Models/Lesson.dart';
import 'package:quizz/Models/Question.dart';
import 'package:quizz/Views/UpdateQuizScreen.dart';

class LessonDetailsScreenAdmin extends StatefulWidget {
  final Lesson lesson;

  const LessonDetailsScreenAdmin({super.key, required this.lesson});

  @override
  State<LessonDetailsScreenAdmin> createState() =>
      _LessonDetailsScreenAdminState();
}

class _LessonDetailsScreenAdminState
    extends State<LessonDetailsScreenAdmin> {
  final LessonRepo _repo = LessonRepo();
  Key _refreshKey = UniqueKey();

  void _refresh() => setState(() => _refreshKey = UniqueKey());

  // ─── XÓA CẢ LESSON ─────────────────────────────────────────
  Future<void> _deleteLesson() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Text('Xóa học phần'),
        content: Text('Xóa "${widget.lesson.title}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    await _repo.deleteLesson(widget.lesson.id!);

    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  // ─── XÓA 1 CÂU HỎI ─────────────────────────────────────────
  Future<void> _deleteQuestion(Question q) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Text('Xóa câu hỏi'),
        content: Text('Bạn có chắc muốn xóa:\n"${q.content}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    await _repo.deleteQuestion(q.id!);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã xóa câu hỏi')),
      );
      _refresh();
    }
  }

  // ─── BUILD ─────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final Color themeColor = Colors.blue[900]!;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        title: Text(widget.lesson.title),
        backgroundColor: themeColor,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'delete') _deleteLesson();
            },
            itemBuilder: (ctx) => [
              const PopupMenuItem(
                value: 'delete',
                child: Text('Xóa học phần',
                    style: TextStyle(color: Colors.red)),
              )
            ],
          )
        ],
      ),

      body: FutureBuilder<List<Question>>(
        key: _refreshKey,
        future: _repo.getQuestionsByLesson(widget.lesson.id!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final questions = snapshot.data ?? [];

          if (questions.isEmpty) {
            return const Center(child: Text('Chưa có câu hỏi'));
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

      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: themeColor,
        child: const Icon(Icons.add),
      ),
    );
  }

  // ─── CARD CÂU HỎI ─────────────────────────────────────────
  Widget _buildQuestionCard(int number, Question q, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
          )
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Câu $number',
                style:
                TextStyle(fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 6),
            Text(q.content, style: const TextStyle(fontSize: 16)),
            const Divider(),
            Text('Đáp án: ${q.answer}',
                style: const TextStyle(
                    color: Colors.green, fontWeight: FontWeight.bold)),

            if (q.options != null && q.options!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text('Options: ${q.options}',
                    style: const TextStyle(color: Colors.grey)),
              ),

            const SizedBox(height: 8),

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
                        builder: (context) => UpdateQuizScreen(lesson: widget.lesson),
                      ),
                    );

                    // Nếu update xong → reload lại danh sách
                    if (updated == true) {
                      _refresh();
                    }
                  },
                ),

                // DELETE
                Container(
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteQuestion(q),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}