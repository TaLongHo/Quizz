import 'dart:math';
import 'package:flutter/material.dart';
import '../Models/Lesson.dart';
import '../Models/Question.dart';
import '../Database/lesson_repo.dart';
import '../Database/user_repo.dart';
import '../Service/ThemeService.dart';
import 'ResultScreen.dart';

class FillQuizScreen extends StatefulWidget {
  final Lesson lesson;
  const FillQuizScreen({super.key, required this.lesson});

  @override
  State<FillQuizScreen> createState() => _FillQuizScreenState();
}

class _FillQuizScreenState extends State<FillQuizScreen> {
  final LessonRepo _lessonRepo = LessonRepo();
  final UserRepo _userRepo = UserRepo();
  final TextEditingController _answerController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  List<Question> _remainingQuestions = [];
  Map<int, int> _wrongAttempts = {};

  int _totalOriginalCount = 0;
  double _accumulatedScore = 0;
  bool _isFinished = false;

  bool? _isCurrentAnswerCorrect;
  bool _isReviewing = false;
  String _currentCorrectDisplay = "";

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    var data = await _lessonRepo.getQuestionsByLesson(widget.lesson.id!);
    if (data.isNotEmpty) {
      data.shuffle();
      setState(() {
        _remainingQuestions = data;
        _totalOriginalCount = data.length;
      });
      _autoFocus();
    }
  }

  void _autoFocus() {
    if (mounted) {
      Future.delayed(
          const Duration(milliseconds: 100), () => _focusNode.requestFocus());
    }
  }

  void _handleAction() {
    if (_isReviewing) {
      _checkReviewAnswer();
    } else {
      _checkInitialAnswer();
    }
  }

  void _checkInitialAnswer() {
    if (_answerController.text.trim().isEmpty) return;
    final currentQ = _remainingQuestions[0];
    String userAnswer = _answerController.text.trim().toLowerCase();
    String correctAnswer = currentQ.answer.trim().toLowerCase();

    if (userAnswer == correctAnswer) {
      setState(() {
        _isCurrentAnswerCorrect = true;
        int attempts = _wrongAttempts[currentQ.id] ?? 0;
        double scoreForThisQ = max(0.1, 1.0 - (attempts * 0.3));
        _accumulatedScore += scoreForThisQ;
        _remainingQuestions.removeAt(0);
      });
      Future.delayed(const Duration(milliseconds: 600), () => _nextStep());
    } else {
      setState(() {
        _isCurrentAnswerCorrect = false;
        _isReviewing = true;
        _currentCorrectDisplay = currentQ.answer;
        _wrongAttempts[currentQ.id!] = (_wrongAttempts[currentQ.id] ?? 0) + 1;
        _answerController.clear();
      });
      _autoFocus();
    }
  }

  void _checkReviewAnswer() {
    if (_answerController.text.trim().isEmpty) return;
    final currentQ = _remainingQuestions[0];
    String userAnswer = _answerController.text.trim().toLowerCase();
    String correctAnswer = currentQ.answer.trim().toLowerCase();

    if (userAnswer == correctAnswer) {
      Question failedQ = _remainingQuestions.removeAt(0);
      if (_remainingQuestions.isEmpty) {
        _remainingQuestions.add(failedQ);
      } else {
        int nextPos = Random().nextInt(_remainingQuestions.length) + 1;
        _remainingQuestions.insert(
            min(nextPos, _remainingQuestions.length), failedQ);
      }
      _nextStep();
    } else {
      _answerController.clear();
      _autoFocus();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Nhập lại đáp án đúng nhé!"),
          duration: Duration(seconds: 1)));
    }
  }

  void _nextStep() {
    if (mounted) {
      if (_remainingQuestions.isEmpty) {
        _finishQuiz();
      } else {
        setState(() {
          _answerController.clear();
          _isCurrentAnswerCorrect = null;
          _isReviewing = false;
        });
        _autoFocus();
      }
    }
  }

  void _finishQuiz() async {
    double finalScorePercent = (_accumulatedScore / _totalOriginalCount) * 100;
    await _userRepo.updateStudyProgress(
        widget.lesson.userId, min(100, finalScorePercent));
    setState(() => _isFinished = true);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeService.isDark;

    if (_totalOriginalCount == 0 ||
        (_remainingQuestions.isEmpty && !_isFinished)) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_isFinished) {
      final totalWrong = _wrongAttempts.values.fold(0, (a, b) => a + b);
      final correctRounded =
      (_accumulatedScore).clamp(0, _totalOriginalCount).round();
      return ResultScreen(
        data: ResultData(
          correctCount: correctRounded,
          totalCount: _totalOriginalCount,
          wrongAttempts: totalWrong,
          lessonTitle: widget.lesson.title,
          lessonType: 'fill',
        ),
      );
    }

    final currentQ = _remainingQuestions[0];
    final Color primaryBrandColor =
    isDark ? const Color(0xFF1A237E) : Colors.green[800]!;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "Điền từ: ${((_totalOriginalCount - _remainingQuestions.length) / _totalOriginalCount * 100).toInt()}%",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryBrandColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            LinearProgressIndicator(
              value: (_totalOriginalCount - _remainingQuestions.length) /
                  _totalOriginalCount,
              backgroundColor: isDark ? Colors.white10 : Colors.grey[200],
              color: Colors.greenAccent,
            ),
            const SizedBox(height: 30),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(20),
                border:
                Border.all(color: _getFeedbackColor().withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Text(
                    _isReviewing ? "HÃY NHẬP LẠI CHO ĐÚNG" : "NỘI DUNG CÂU HỎI",
                    style: TextStyle(
                        color: _isReviewing ? Colors.orange : Colors.grey,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2),
                  ),
                  const SizedBox(height: 15),
                  Text(currentQ.content,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: _answerController,
              focusNode: _focusNode,
              onSubmitted: (_) => _handleAction(),
              textAlign: TextAlign.center,
              style:
              const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                filled: true,
                fillColor: Theme.of(context).cardColor,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide:
                    BorderSide(color: _getFeedbackColor(), width: 2)),
              ),
            ),
            const SizedBox(height: 20),
            if (_isReviewing)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    const Text("Bạn đã nhập sai rồi!",
                        style: TextStyle(
                            color: Colors.redAccent,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text("Đáp án đúng: $_currentCorrectDisplay",
                        style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 20)),
                  ],
                ),
              ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _handleAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _getFeedbackColor(),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                ),
                child: Text(_isReviewing ? "TIẾP TỤC" : "XÁC NHẬN",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getFeedbackColor() {
    if (_isReviewing) return Colors.orange;
    if (_isCurrentAnswerCorrect == true) return Colors.green;
    return ThemeService.isDark ? const Color(0xFF1A237E) : Colors.green[800]!;
  }
}