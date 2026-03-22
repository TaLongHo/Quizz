import 'package:flutter/material.dart';
import '../Models/Lesson.dart';
import '../Models/Question.dart';
import '../Database/lesson_repo.dart';
import '../Service/ThemeService.dart';

class UpdateQuizScreen extends StatefulWidget {
  final Lesson lesson;
  final Question? question;

  const UpdateQuizScreen({super.key, required this.lesson, this.question});

  @override
  State<UpdateQuizScreen> createState() => _UpdateQuizScreenState();
}

class _UpdateQuizScreenState extends State<UpdateQuizScreen> {
  final _repo = LessonRepo();
  late TextEditingController _qController;
  late TextEditingController _a1Controller;
  late TextEditingController _a2Controller;
  late TextEditingController _a3Controller;
  late TextEditingController _a4Controller;

  @override
  void initState() {
    super.initState();
    _qController = TextEditingController(text: widget.question?.content ?? "");

    // Tách chuỗi options "A|B|C|D"
    List<String> opts = widget.question?.options?.split('|') ?? ["", "", "", ""];
    _a1Controller = TextEditingController(text: opts.length > 0 ? opts[0] : "");
    _a2Controller = TextEditingController(text: opts.length > 1 ? opts[1] : "");
    _a3Controller = TextEditingController(text: opts.length > 2 ? opts[2] : "");
    _a4Controller = TextEditingController(text: opts.length > 3 ? opts[3] : "");
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeService.isDark;
    final brandGradient = isDark
        ? [const Color(0xFF1A237E), const Color(0xFF4A148C)]
        : [const Color(0xFF0D47A1), const Color(0xFF6A1B9A)];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Chỉnh sửa câu hỏi", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(gradient: LinearGradient(colors: brandGradient)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildEditCard(isDark),
            const SizedBox(height: 30),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildEditCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[200]!,
        ),
      ),
      child: Column(
        children: [
          _buildInputField(_qController, "Nội dung câu hỏi", Icons.help_outline, isDark, maxLines: 2),
          const SizedBox(height: 25),
          _buildInputField(_a1Controller, "Đáp án ĐÚNG", Icons.check_circle, isDark, accentColor: Colors.green),
          const SizedBox(height: 15),
          _buildInputField(_a2Controller, "Đáp án sai 1", Icons.close, isDark, accentColor: Colors.redAccent),
          const SizedBox(height: 15),
          _buildInputField(_a3Controller, "Đáp án sai 2", Icons.close, isDark, accentColor: Colors.redAccent),
          const SizedBox(height: 15),
          _buildInputField(_a4Controller, "Đáp án sai 3", Icons.close, isDark, accentColor: Colors.redAccent),
        ],
      ),
    );
  }

  Widget _buildInputField(TextEditingController controller, String label, IconData icon, bool isDark, {Color? accentColor, int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: accentColor ?? (isDark ? Colors.blue[200] : Colors.blue[900])),
        filled: true,
        fillColor: isDark ? Colors.white.withOpacity(0.03) : Colors.grey[50],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: accentColor ?? Colors.blue, width: 2),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: _saveUpdate,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue[800],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        child: const Text("CẬP NHẬT", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  void _saveUpdate() async {
    if (_qController.text.isEmpty || _a1Controller.text.isEmpty) return;

    String optionsArr = "${_a1Controller.text}|${_a2Controller.text}|${_a3Controller.text}|${_a4Controller.text}";

    Question updatedQ = Question(
      id: widget.question?.id,
      lessonId: widget.lesson.id!, // FIX LỖI Ở ĐÂY
      content: _qController.text,
      answer: _a1Controller.text,
      options: optionsArr,
    );

    await _repo.updateQuestion(updatedQ);
    if (mounted) Navigator.pop(context, true);
  }
}