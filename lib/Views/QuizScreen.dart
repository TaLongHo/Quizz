import 'package:flutter/material.dart';
import '../Models/Lesson.dart';
import '../Models/Question.dart';
import '../Database/lesson_repo.dart';

class QuizScreen extends StatefulWidget {
  final Lesson lesson;
  const QuizScreen({super.key, required this.lesson});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final LessonRepo _repo = LessonRepo();
  List<Question> _questions = [];
  int _currentIndex = 0;
  int _score = 0;
  bool _isFinished = false;
  final TextEditingController _fillController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  void _loadQuestions() async {
    var data = await _repo.getQuestionsByLesson(widget.lesson.id!);
    setState(() {
      _questions = data..shuffle(); // Trộn câu hỏi cho thú vị
    });
  }

  void _checkAnswer(String selectedAnswer) {
    if (selectedAnswer.trim().toLowerCase() == _questions[_currentIndex].answer.trim().toLowerCase()) {
      _score++;
    }

    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
        _fillController.clear();
      });
    } else {
      setState(() => _isFinished = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_isFinished) return _buildResult();

    final currentQuestion = _questions[_currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text("Câu ${_currentIndex + 1}/${_questions.length}"),
        backgroundColor: widget.lesson.type == 'abc' ? Colors.blue[900] : Colors.green[700],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            LinearProgressIndicator(
              value: (_currentIndex + 1) / _questions.length,
              backgroundColor: Colors.grey[200],
              color: Colors.orangeAccent,
            ),
            const SizedBox(height: 30),
            Text(currentQuestion.content,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            const SizedBox(height: 30),

            // Render giao diện tùy theo loại bài học
            Expanded(
              child: widget.lesson.type == 'abc'
                  ? _buildMultipleChoice(currentQuestion)
                  : _buildFillBlank(),
            ),
          ],
        ),
      ),
    );
  }

  // Giao diện trắc nghiệm
  Widget _buildMultipleChoice(Question q) {
    List<String> options = q.optionsList;
    return ListView.builder(
      itemCount: options.length,
      itemBuilder: (context, index) => Card(
        margin: const EdgeInsets.only(bottom: 10),
        child: ListTile(
          title: Text(options[index]),
          onTap: () => _checkAnswer(options[index]),
        ),
      ),
    );
  }

  // Giao diện điền từ
  Widget _buildFillBlank() {
    return Column(
      children: [
        TextField(
          controller: _fillController,
          decoration: const InputDecoration(border: OutlineInputBorder(), hintText: "Nhập đáp án của bạn"),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () => _checkAnswer(_fillController.text),
          child: const Text("Xác nhận"),
        )
      ],
    );
  }

  // Màn hình kết quả
  Widget _buildResult() {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.emoji_events, size: 100, color: Colors.orange),
            Text("Hoàn thành!", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            Text("Điểm của bạn: $_score/${_questions.length}", style: TextStyle(fontSize: 20)),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text("Quay lại")),
          ],
        ),
      ),
    );
  }
}