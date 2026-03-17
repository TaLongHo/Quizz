import 'package:flutter/material.dart';
import 'package:quizz/Database/lesson_repo.dart';
import 'package:quizz/Models/Lesson.dart';
import 'package:quizz/Models/Question.dart';

class LessonDetailsScreenAdmin extends StatefulWidget {
  final Lesson lesson;

  const LessonDetailsScreenAdmin({super.key, required this.lesson});

  @override
  State<LessonDetailsScreenAdmin> createState() => _LessonDetailsScreenAdminState();
}

class _LessonDetailsScreenAdminState extends State<LessonDetailsScreenAdmin> {
  final LessonRepo _repo = LessonRepo();
  Key _refreshKey = UniqueKey();

  void _refresh() {
    setState(() {
      _refreshKey = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    final String typeName =
    widget.lesson.type == 'abc' ? "Trắc nghiệm" : "Điền từ";

    final Color themeColor =
    widget.lesson.type == 'abc' ? Colors.blue[900]! : Colors.green[700]!;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),

      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.lesson.title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text("Loại: $typeName",
                style: const TextStyle(fontSize: 12, color: Colors.white70)),
          ],
        ),
        backgroundColor: themeColor,
      ),

      body: FutureBuilder<List<Question>>(
        key: _refreshKey,
        future: _repo.getQuestionsByLesson(widget.lesson.id!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text("Lỗi tải dữ liệu"));
          }

          final questions = snapshot.data ?? [];

          if (questions.isEmpty) {
            return const Center(
              child: Text("Chưa có câu hỏi nào"),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: questions.length,
            itemBuilder: (context, index) {
              final q = questions[index];

              return Dismissible(
                key: Key(q.id.toString()),
                direction: DismissDirection.endToStart,

                confirmDismiss: (direction) async {
                  return await showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text("Xóa câu hỏi"),
                      content: Text("Bạn có chắc muốn xóa:\n\"${q.content}\" ?"),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text("Hủy"),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text("Xóa",
                              style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );
                },

                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),

                child: _buildQuestionCard(index + 1, q, themeColor),
              );
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
                      Text("CÂU $number",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: color)),

                      const SizedBox(height: 8),

                      Text(q.content,
                          style: const TextStyle(fontSize: 16)),

                      const Divider(),

                      Text("Đáp án: ${q.answer}",
                          style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold)),

                      if (widget.lesson.type == 'abc' &&
                          (q.options?.isNotEmpty ?? false)) ...[
                        const SizedBox(height: 8),
                        Text("Options: ${q.options}",
                            style: const TextStyle(color: Colors.grey)),
                      ],

                      const SizedBox(height: 10),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.orange),
                            onPressed: () {
                              // TODO: Edit Question
                            },
                          ),
                        ],
                      )
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