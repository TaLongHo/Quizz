import 'package:flutter/material.dart';
import 'package:quizz/Database/lesson_repo.dart';
import 'package:quizz/Models/Lesson.dart';
import 'package:quizz/Models/Question.dart';

class UpdateQuizScreen extends StatefulWidget {
  final Lesson lesson;

  const UpdateQuizScreen({super.key, required this.lesson});

  @override
  State<UpdateQuizScreen> createState() => _UpdateQuizScreenState();
}

class _UpdateQuizScreenState extends State<UpdateQuizScreen> {
  final LessonRepo _repo = LessonRepo();

  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  final _o1Controller = TextEditingController();
  final _o2Controller = TextEditingController();
  final _o3Controller = TextEditingController();
  final _o4Controller = TextEditingController();

  String _selectedAnswer = "";
  Question? _question;

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.lesson.title;
    _loadData();
  }

  Future<void> _loadData() async {
    final questions =
    await _repo.getQuestionsByLesson(widget.lesson.id!);

    if (questions.isNotEmpty) {
      final q = questions.first;
      List<String> opts = (q.options ?? "").split('|');

      setState(() {
        _question = q;
        _contentController.text = q.content;

        _o1Controller.text = opts.length > 0 ? opts[0] : "";
        _o2Controller.text = opts.length > 1 ? opts[1] : "";
        _o3Controller.text = opts.length > 2 ? opts[2] : "";
        _o4Controller.text = opts.length > 3 ? opts[3] : "";

        _selectedAnswer = q.answer; // set đáp án đúng ban đầu
      });
    }
  }

  // ─── SAVE ─────────────────────────
  Future<void> _save() async {
    List<String> options = [
      _o1Controller.text.trim(),
      _o2Controller.text.trim(),
      _o3Controller.text.trim(),
      _o4Controller.text.trim(),
    ];

    // validate
    if (_selectedAnswer.isEmpty || !options.contains(_selectedAnswer)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Vui lòng chọn đáp án đúng hợp lệ"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final db = await _repo.dbCore.database;

    await db.transaction((txn) async {
      await txn.update(
        'lessons',
        {'title': _titleController.text},
        where: 'id = ?',
        whereArgs: [widget.lesson.id],
      );

      if (_question != null) {
        await txn.update(
          'questions',
          {
            'content': _contentController.text,
            'answer': _selectedAnswer,
            'options': options.join("|"),
          },
          where: 'id = ?',
          whereArgs: [_question!.id],
        );
      }
    });

    if (mounted) Navigator.pop(context, true);
  }

  // ─── OPTION UI ─────────────────────────
  Widget _buildOption(String label, TextEditingController controller) {
    return Row(
      children: [
        Radio<String>(
          value: controller.text,
          groupValue: _selectedAnswer,
          onChanged: (value) {
            setState(() {
              _selectedAnswer = value!;
            });
          },
        ),
        Expanded(
          child: TextField(
            controller: controller,
            decoration: InputDecoration(labelText: label),
            onChanged: (val) {
              setState(() {
                // nếu option bị sửa và đang là đáp án → update lại
                if (_selectedAnswer == controller.text) {
                  _selectedAnswer = val;
                }
              });
            },
          ),
        ),
      ],
    );
  }

  // ─── UI ─────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chỉnh sửa câu hỏi"),
        backgroundColor: Colors.blue[900],
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _save,
          )
        ],
      ),
      body: _question == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // TITLE
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: "Tên học phần",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            // QUESTION
            TextField(
              controller: _contentController,
              decoration: const InputDecoration(
                  labelText: "Nội dung câu hỏi"),
            ),

            const SizedBox(height: 20),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Chọn đáp án đúng:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),

            _buildOption("Option 1", _o1Controller),
            _buildOption("Option 2", _o2Controller),
            _buildOption("Option 3", _o3Controller),
            _buildOption("Option 4", _o4Controller),
          ],
        ),
      ),
    );
  }
}