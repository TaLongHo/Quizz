import 'package:flutter/material.dart';
import 'package:quizz/Database/lesson_repo.dart';
import 'package:quizz/Models/Lesson.dart';
import 'package:quizz/Models/Question.dart';

class LessonDetailsScreenAdmin extends StatefulWidget {
  final Lesson lesson;

  const LessonDetailsScreenAdmin({super.key, required this.lesson});

  @override
  State<LessonDetailsScreenAdmin> createState() =>
      _LessonDetailsScreenAdminState();
}

class _LessonDetailsScreenAdminState extends State<LessonDetailsScreenAdmin> {
  final LessonRepo _repo = LessonRepo();
  Key _refreshKey = UniqueKey();

  void _refresh() => setState(() => _refreshKey = UniqueKey());

  // ═══════════════════════════════════════════════════════════════════════════
  // XÓA TOÀN BỘ HỌC PHẦN
  // ═══════════════════════════════════════════════════════════════════════════
  Future<void> _deleteLesson() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
            SizedBox(width: 8),
            Text('Xóa học phần'),
          ],
        ),
        content: RichText(
          text: TextSpan(
            style: const TextStyle(color: Colors.black87, fontSize: 15),
            children: [
              const TextSpan(text: 'Bạn có chắc muốn xóa toàn bộ học phần\n'),
              TextSpan(
                text: '"${widget.lesson.title}"',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const TextSpan(
                text: '?\n\nTất cả câu hỏi bên trong cũng sẽ bị xóa vĩnh viễn.',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('HỦY', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(ctx, true),
            icon: const Icon(Icons.delete_forever, size: 18),
            label: const Text('XÓA TOÀN BỘ'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[700],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    await _repo.deleteLesson(widget.lesson.id!);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã xóa học phần "${widget.lesson.title}"'),
          backgroundColor: Colors.red[700],
        ),
      );
      // Trả true về ManageQuizScreen để reload danh sách
      Navigator.pop(context, true);
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // BUILD
  // ═══════════════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final Color themeColor = Colors.blue[900]!;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.lesson.title,
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Text(
              'Trắc nghiệm  •  Quản trị',
              style: TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
        backgroundColor: themeColor,
        foregroundColor: Colors.white,
        actions: [
          // Menu ⋮ chứa nút xóa học phần
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
            onSelected: (value) {
              if (value == 'delete_lesson') _deleteLesson();
            },
            itemBuilder: (ctx) => [
              const PopupMenuItem(
                value: 'delete_lesson',
                child: Row(
                  children: [
                    Icon(Icons.delete_forever, color: Colors.red, size: 20),
                    SizedBox(width: 10),
                    Text(
                      'Xóa toàn bộ học phần',
                      style: TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),

      body: FutureBuilder<List<Question>>(
        key: _refreshKey,
        future: _repo.getQuestionsByLesson(widget.lesson.id!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Lỗi tải dữ liệu'));
          }

          final questions = snapshot.data ?? [];

          if (questions.isEmpty) {
            return const Center(child: Text('Chưa có câu hỏi nào'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: questions.length,
            itemBuilder: (context, index) {
              final q = questions[index];
              return _buildQuestionCard(index + 1, q, themeColor);
            },
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Add Question
        },
        backgroundColor: themeColor,
        child: const Icon(Icons.add),
      ),
    );
  }

  // ─── CARD CÂU HỎI ────────────────────────────────────────────────────────
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
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 6, color: color),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CÂU $number',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: color),
                      ),
                      const SizedBox(height: 8),
                      Text(q.content,
                          style: const TextStyle(fontSize: 16)),
                      const Divider(),
                      Text(
                        'Đáp án: ${q.answer}',
                        style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold),
                      ),
                      if (q.options?.isNotEmpty ?? false) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Options: ${q.options}',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit,
                                color: Colors.orange),
                            onPressed: () {
                              // TODO: Edit Question
                            },
                          ),
                        ],
                      ),
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