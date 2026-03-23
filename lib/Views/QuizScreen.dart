import 'package:flutter/material.dart';
import '../Models/Lesson.dart';
import '../Models/Question.dart';
import '../Database/lesson_repo.dart';
import '../Database/user_repo.dart';
import '../Service/ThemeService.dart';
import 'ResultScreen.dart';

class QuizScreen extends StatefulWidget {
  final Lesson lesson;
  const QuizScreen({super.key, required this.lesson});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final LessonRepo _lessonRepo = LessonRepo();
  final UserRepo _userRepo = UserRepo();

  List<Question> _questions = [];
  int _currentIndex = 0;
  int _correctCount = 0;
  bool _isFinished = false;

  List<String> _shuffledOptions = [];
  String? _selectedOption;
  bool _canInteract = true;
  List<Question> _wrongQuestions = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    var data = await _lessonRepo.getQuestionsByLesson(widget.lesson.id!);
    data.shuffle();
    setState(() {
      _questions = data;
      _prepareQuestion();
    });
  }

  void _prepareQuestion() {
    if (_questions.isEmpty) return;
    String raw = _questions[_currentIndex].options ?? "";
    List<String> opts = raw.split('|').where((s) => s.isNotEmpty).toList();
    opts.shuffle();
    setState(() {
      _shuffledOptions = opts;
      _selectedOption = null;
      _canInteract = true;
    });
  }

  void _handleAnswer(String option) {
    if (!_canInteract) return;
    setState(() {
      _selectedOption = option;
      _canInteract = false;
      if (option == _questions[_currentIndex].answer) {
        _correctCount++;
      } else {
        _wrongQuestions.add(_questions[_currentIndex]);
      }
    });
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) {
        if (_currentIndex < _questions.length - 1) {
          setState(() {
            _currentIndex++;
            _prepareQuestion();
          });
        } else {
          _finishQuiz();
        }
      }
    });
  }

  void _finishQuiz() async {
    double finalScore = (_correctCount / _questions.length) * 100;
    await _userRepo.updateStudyProgress(widget.lesson.userId, finalScore);
    setState(() => _isFinished = true);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeService.isDark;

    if (_questions.isEmpty) {
      return Scaffold(
          body: Center(
              child: CircularProgressIndicator(
                  color: Theme.of(context).primaryColor)));
    }

    if (_isFinished) {
      return ResultScreen(
        data: ResultData(
          correctCount: _correctCount,
          totalCount: _questions.length,
          lessonTitle: widget.lesson.title,
          lessonType: 'quiz',
        ),
      );
    }

    final currentQ = _questions[_currentIndex];
    final brandGradient = isDark
        ? [const Color(0xFF1A237E), const Color(0xFF4A148C)]
        : [const Color(0xFF0D47A1), const Color(0xFF6A1B9A)];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("Câu ${_currentIndex + 1}/${_questions.length}",
            style: const TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context)),
        flexibleSpace: Container(
            decoration:
            BoxDecoration(gradient: LinearGradient(colors: brandGradient))),
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: (_currentIndex + 1) / _questions.length,
            backgroundColor: isDark ? Colors.white10 : Colors.grey[200],
            color: isDark ? Colors.blue[400] : Colors.blue[900],
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Text(currentQ.content,
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87)),
                  const SizedBox(height: 40),
                  ..._shuffledOptions.map(
                          (opt) => _buildOptionCard(opt, currentQ.answer, isDark)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionCard(String option, String correctAnswer, bool isDark) {
    bool isSelected = _selectedOption == option;
    bool isCorrectAnswer = option == correctAnswer;

    Color borderColor =
    isDark ? Colors.white.withOpacity(0.1) : Colors.grey[300]!;
    Color bgColor = Theme.of(context).cardColor;
    Color textColor = isDark ? Colors.white70 : Colors.black87;

    if (_selectedOption != null) {
      if (isCorrectAnswer) {
        borderColor = Colors.greenAccent;
        bgColor = Colors.green.withOpacity(isDark ? 0.2 : 0.1);
        textColor = isDark ? Colors.greenAccent : Colors.green[800]!;
      } else if (isSelected) {
        borderColor = Colors.redAccent;
        bgColor = Colors.red.withOpacity(isDark ? 0.2 : 0.1);
        textColor = isDark ? Colors.redAccent : Colors.red[800]!;
      }
    }

    return GestureDetector(
      onTap: () => _handleAnswer(option),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: borderColor, width: 2),
          boxShadow: [
            if (!isDark)
              BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4))
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
                child: Text(option,
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: textColor))),
            if (_selectedOption != null && isCorrectAnswer)
              const Icon(Icons.check_circle_rounded, color: Colors.greenAccent),
            if (_selectedOption != null && isSelected && !isCorrectAnswer)
              const Icon(Icons.cancel_rounded, color: Colors.redAccent),
          ],
        ),
      ),
    );
  }
}