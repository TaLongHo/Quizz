import 'package:flutter/material.dart';
import '../Database/lesson_repo.dart';
import '../Models/Lesson.dart';
import '../Models/Question.dart';

class AdminFillLessonDetailScreen extends StatefulWidget {
  final Lesson lesson;

  const AdminFillLessonDetailScreen({super.key, required this.lesson});

  @override
  State<AdminFillLessonDetailScreen> createState() =>
      _AdminFillLessonDetailScreenState();
}

class _AdminFillLessonDetailScreenState
    extends State<AdminFillLessonDetailScreen> {
  final LessonRepo _repo = LessonRepo();
  Key _refreshKey = UniqueKey();

  void _refresh() => setState(() => _refreshKey = UniqueKey());

  static const Color _primary = Color(0xFF2E7D32);
  static const Color _accent = Color(0xFF43A047);
  static const Color _bg = Color(0xFFF1F8E9);

  // ─────────────────────────────────────────
  // XÓA LESSON
  // ─────────────────────────────────────────
  Future<void> _deleteLesson() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
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

    if (mounted) Navigator.pop(context, true);
  }

  // ─────────────────────────────────────────
  // XÓA CÂU HỎI
  // ─────────────────────────────────────────
  Future<void> _deleteQuestion(Question q) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa câu hỏi'),
        content: Text('Xóa:\n"${q.content}" ?'),
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

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã xóa câu hỏi')),
    );

    _refresh();
  }

  // ─────────────────────────────────────────
  // EDIT
  // ─────────────────────────────────────────
  void _showEditDialog(Question q) {
    final qCtrl = TextEditingController(text: q.content);
    final aCtrl = TextEditingController(text: q.answer);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Sửa câu hỏi",
                style: TextStyle(fontWeight: FontWeight.bold)),

            TextField(
              controller: qCtrl,
              decoration: const InputDecoration(labelText: "Câu hỏi"),
            ),

            TextField(
              controller: aCtrl,
              decoration: const InputDecoration(labelText: "Đáp án"),
            ),

            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: () async {
                if (qCtrl.text.isEmpty || aCtrl.text.isEmpty) return;

                final updated = Question(
                  id: q.id,
                  lessonId: q.lessonId,
                  content: qCtrl.text,
                  answer: aCtrl.text,
                  options: q.options,
                );

                await _repo.updateQuestion(updated);

                Navigator.pop(ctx);
                _refresh();
              },
              child: const Text("Lưu"),
            )
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        title: Text(widget.lesson.title),
        backgroundColor: _primary,
        actions: [
          PopupMenuButton(
            onSelected: (v) {
              if (v == 'delete') _deleteLesson();
            },
            itemBuilder: (ctx) => const [
              PopupMenuItem(
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
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final questions = snapshot.data!;

          if (questions.isEmpty) {
            return const Center(child: Text('Chưa có câu hỏi'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: questions.length,
            itemBuilder: (context, index) {
              final q = questions[index];
              return _buildCard(index + 1, q);
            },
          );
        },
      ),
    );
  }

  // ─────────────────────────────────────────
  // CARD
  // ─────────────────────────────────────────
  Widget _buildCard(int number, Question q) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Câu $number',
                style: const TextStyle(fontWeight: FontWeight.bold)),

            const SizedBox(height: 6),
            Text(q.content),

            const Divider(),

            Text('Đáp án: ${q.answer}',
                style: const TextStyle(
                    color: Colors.green, fontWeight: FontWeight.bold)),

            const SizedBox(height: 8),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // EDIT
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.orange),
                  onPressed: () => _showEditDialog(q),
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