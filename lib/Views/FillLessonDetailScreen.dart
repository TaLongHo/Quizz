import 'package:flutter/material.dart';
import 'package:quizz/Views/FillQuizScreen.dart';
import '../Database/lesson_repo.dart';
import '../Models/Lesson.dart';
import '../Models/Question.dart';
import '../Service/ThemeService.dart';

class FillLessonDetailScreen extends StatefulWidget {
  final Lesson lesson;
  const FillLessonDetailScreen({super.key, required this.lesson});

  @override
  State<FillLessonDetailScreen> createState() => _FillLessonDetailScreenState();
}

class _FillLessonDetailScreenState extends State<FillLessonDetailScreen> {
  final LessonRepo _repo = LessonRepo();
  Key _refreshKey = UniqueKey();

  void _refreshData() => setState(() => _refreshKey = UniqueKey());

  void _showQuestionDialog({Question? existing}) {
    final isDark = ThemeService.isDark;
    final qCtrl = TextEditingController(text: existing?.content ?? '');
    final aCtrl = TextEditingController(text: existing?.answer ?? '');
    final isEdit = existing != null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 24, right: 24, top: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(isEdit ? 'Sửa câu hỏi' : 'Thêm câu hỏi mới', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            _buildDialogField(qCtrl, "Câu hỏi / Từ cần điền", Icons.help_outline, isDark),
            const SizedBox(height: 15),
            _buildDialogField(aCtrl, "Đáp án chính xác", Icons.check_circle_outline, isDark, accentColor: Colors.green),
            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () async {
                  if (qCtrl.text.isEmpty || aCtrl.text.isEmpty) return;
                  final q = Question(id: existing?.id, lessonId: widget.lesson.id!, content: qCtrl.text, answer: aCtrl.text, options: '');
                  isEdit ? await _repo.updateQuestion(q) : await _repo.addQuestion(q);
                  Navigator.pop(ctx);
                  _refreshData();
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[800], shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                child: Text(isEdit ? "LƯU THAY ĐỔI" : "THÊM CÂU HỎI", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildDialogField(TextEditingController ctrl, String label, IconData icon, bool isDark, {Color? accentColor}) {
    return TextField(
      controller: ctrl,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: accentColor ?? (isDark ? Colors.blue[200] : Colors.blue[900])),
        filled: true,
        fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[100],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = ThemeService.isDark;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(widget.lesson.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: isDark ? const Color(0xFF1A237E) : Colors.green[800],
        actions: [IconButton(icon: const Icon(Icons.add_circle_outline), onPressed: () => _showQuestionDialog())],
      ),
      body: FutureBuilder<List<Question>>(
        key: _refreshKey,
        future: _repo.getQuestionsByLesson(widget.lesson.id!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          final questions = snapshot.data ?? [];
          if (questions.isEmpty) return const Center(child: Text("Danh sách trống"));

          return ListView.builder(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 120),
            itemCount: questions.length,
            itemBuilder: (ctx, index) => _buildFillCard(index + 1, questions[index]),
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            heroTag: "addFillBtn",
            onPressed: () => _showQuestionDialog(),
            label: const Text("THÊM CÂU HỎI", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
            icon: const Icon(Icons.add_circle, color: Colors.white),
            backgroundColor: Colors.orange[800], // Màu cam cho nổi bật giống bên Quiz
          ),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            heroTag: "playFillBtn",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FillQuizScreen(lesson: widget.lesson), // Điều hướng sang màn hình điền từ
                ),
              );
            },
            label: const Text("BẮT ĐẦU HỌC", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
            icon: const Icon(Icons.play_arrow_rounded, color: Colors.white),
            backgroundColor: isDark ? const Color(0xFF1A237E) : Colors.green[800],
          ),
        ],
      ),
    );
  }

  Widget _buildFillCard(int number, Question q) {
    bool isDark = ThemeService.isDark;
    return Card(
      color: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: Colors.green.withOpacity(0.1), child: Text("$number", style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold))),
        title: Text(q.content, style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.w500)),
        subtitle: Text("Đáp án: ${q.answer}", style: TextStyle(color: Colors.green[400], fontSize: 13)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(icon: const Icon(Icons.edit, size: 20, color: Colors.blue), onPressed: () => _showQuestionDialog(existing: q)),
            IconButton(icon: const Icon(Icons.delete, size: 20, color: Colors.redAccent), onPressed: () async {
              await _repo.deleteQuestion(q.id!);
              _refreshData();
            }),
          ],
        ),
      ),
    );
  }
}