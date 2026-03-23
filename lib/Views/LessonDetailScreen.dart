import 'package:flutter/material.dart';
import 'package:quizz/Database/lesson_repo.dart';
import 'package:quizz/Models/Lesson.dart';
import 'package:quizz/Models/Question.dart';
import 'package:quizz/Views/QuizScreen.dart';
import 'package:quizz/Views/UpdateQuizScreen.dart';
import 'package:quizz/Service/ThemeService.dart';

class LessonDetailScreen extends StatefulWidget {
  final Lesson lesson;
  final bool isOwner; // true = có quyền edit/xóa, false = chỉ xem & chơi
  const LessonDetailScreen({super.key, required this.lesson, this.isOwner = true});

  @override
  State<LessonDetailScreen> createState() => _LessonDetailScreenState();
}

class _LessonDetailScreenState extends State<LessonDetailScreen> {
  final LessonRepo _repo = LessonRepo();
  Key _refreshKey = UniqueKey();

  final _qController = TextEditingController();
  final _a1Controller = TextEditingController();
  final _a2Controller = TextEditingController();
  final _a3Controller = TextEditingController();
  final _a4Controller = TextEditingController();

  void _refresh() => setState(() => _refreshKey = UniqueKey());

  void _showAddQuestionSheet() {
    final isDark = ThemeService.isDark;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        ),
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom + 20, left: 20, right: 20, top: 20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey[400], borderRadius: BorderRadius.circular(10))),
              const SizedBox(height: 20),
              Text("THÊM CÂU HỎI MỚI", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: isDark ? Colors.blue[300] : Colors.blue[900])),
              const SizedBox(height: 20),
              _buildQuestionCard(isDark),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  onPressed: () => _handleAddNewQuestion(ctx),
                  icon: const Icon(Icons.add_task_rounded, color: Colors.white),
                  label: const Text("XÁC NHẬN THÊM", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green[700], shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[200]!),
        boxShadow: [if (!isDark) BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        children: [
          _buildInputField(controller: _qController, label: "Nội dung câu hỏi", icon: Icons.help_outline, isDark: isDark, maxLines: 2),
          const SizedBox(height: 20),
          _buildInputField(controller: _a1Controller, label: "Đáp án ĐÚNG", icon: Icons.check_circle, isDark: isDark, accentColor: Colors.green),
          const SizedBox(height: 12),
          _buildInputField(controller: _a2Controller, label: "Đáp án sai 1", icon: Icons.cancel, isDark: isDark, accentColor: Colors.redAccent),
          const SizedBox(height: 12),
          _buildInputField(controller: _a3Controller, label: "Đáp án sai 2", icon: Icons.cancel, isDark: isDark, accentColor: Colors.redAccent),
          const SizedBox(height: 12),
          _buildInputField(controller: _a4Controller, label: "Đáp án sai 3", icon: Icons.cancel, isDark: isDark, accentColor: Colors.redAccent),
        ],
      ),
    );
  }

  Widget _buildInputField({required TextEditingController controller, required String label, required IconData icon, required bool isDark, Color? accentColor, int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: accentColor ?? (isDark ? Colors.blue[200] : Colors.blue[900])),
        prefixIcon: Icon(icon, color: accentColor ?? (isDark ? Colors.white30 : Colors.grey)),
        filled: true,
        fillColor: isDark ? Colors.white.withOpacity(0.03) : Colors.grey[50],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: accentColor ?? Colors.blue)),
      ),
    );
  }

  void _handleAddNewQuestion(BuildContext ctx) async {
    if (_qController.text.isEmpty || _a1Controller.text.isEmpty) return;
    String options = "${_a1Controller.text}|${_a2Controller.text}|${_a3Controller.text}|${_a4Controller.text}";
    final newQ = Question(
      lessonId: widget.lesson.id!,
      content: _qController.text.trim(),
      answer: _a1Controller.text.trim(),
      options: options,
    );
    await _repo.addQuestion(newQ);
    _qController.clear(); _a1Controller.clear(); _a2Controller.clear(); _a3Controller.clear(); _a4Controller.clear();
    if (mounted) Navigator.pop(ctx);
    _refresh();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Đã thêm câu hỏi thành công!")));
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = ThemeService.isDark;
    final brandGradient = isDark
        ? [const Color(0xFF1A237E), const Color(0xFF4A148C)]
        : [const Color(0xFF0D47A1), const Color(0xFF6A1B9A)];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.lesson.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(
              widget.isOwner ? "Chế độ: Trắc nghiệm" : "Chỉ xem • Trắc nghiệm",
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
        flexibleSpace: Container(decoration: BoxDecoration(gradient: LinearGradient(colors: brandGradient))),
      ),
      body: FutureBuilder<List<Question>>(
        key: _refreshKey,
        future: _repo.getQuestionsByLesson(widget.lesson.id!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          final questions = snapshot.data ?? [];
          if (questions.isEmpty) return Center(child: Text("Chưa có câu hỏi nào", style: TextStyle(color: isDark ? Colors.white30 : Colors.grey)));
          return ListView.builder(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 100),
            itemCount: questions.length,
            itemBuilder: (context, index) => _buildQuestionCardDisplay(index + 1, questions[index], isDark),
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Nút THÊM CÂU HỎI: chỉ hiện khi là owner
          if (widget.isOwner) ...[
            FloatingActionButton.extended(
              heroTag: "addBtn",
              onPressed: _showAddQuestionSheet,
              label: const Text("THÊM CÂU HỎI", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              icon: const Icon(Icons.add_circle, color: Colors.white),
              backgroundColor: Colors.orange[800],
            ),
            const SizedBox(height: 12),
          ],
          FloatingActionButton.extended(
            heroTag: "playBtn",
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => QuizScreen(lesson: widget.lesson))),
            label: const Text("BẮT ĐẦU HỌC", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
            icon: const Icon(Icons.play_arrow_rounded, color: Colors.white),
            backgroundColor: isDark ? Colors.blue[700] : Colors.blue[900],
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCardDisplay(int number, Question q, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("CÂU $number", style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.blue[300] : Colors.blue[900], fontSize: 12)),
                // Nút edit/xóa: chỉ hiện khi là owner
                if (widget.isOwner)
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.orange, size: 20),
                        onPressed: () async {
                          final updated = await Navigator.push<bool>(context, MaterialPageRoute(builder: (_) => UpdateQuizScreen(lesson: widget.lesson, question: q)));
                          if (updated == true) _refresh();
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                        onPressed: () => _deleteQuestion(q),
                      ),
                    ],
                  ),
              ],
            ),
            Text(q.content, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: isDark ? Colors.white : Colors.black87)),
            const Divider(height: 24),
            Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 16),
                const SizedBox(width: 8),
                Expanded(child: Text(q.answer, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteQuestion(Question q) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(ctx).cardColor,
        title: const Text("Xóa câu hỏi"),
        content: Text('Bạn có chắc muốn xóa:\n"${q.content}" ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("HỦY")),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("XÓA", style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm == true) {
      await _repo.deleteQuestion(q.id!);
      _refresh();
    }
  }
}