import 'package:flutter/material.dart';
import 'dart:math';
import '../Models/Lesson.dart';
import '../Models/Question.dart';
import '../Database/lesson_repo.dart';
import '../Database/user_repo.dart';
import '../Service/ThemeService.dart';

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
      Future.delayed(const Duration(milliseconds: 100), () => _focusNode.requestFocus());
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
        _remainingQuestions.insert(min(nextPos, _remainingQuestions.length), failedQ);
      }
      _nextStep();
    } else {
      _answerController.clear();
      _autoFocus();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Nhập lại đáp án đúng nhé!"), duration: Duration(seconds: 1)),
      );
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
    await _userRepo.updateStudyProgress(widget.lesson.userId, min(100, finalScorePercent));
    setState(() => _isFinished = true);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeService.isDark;

    if (_totalOriginalCount == 0 || (_remainingQuestions.isEmpty && !_isFinished)) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_isFinished) return _buildResultScreen();

    final currentQ = _remainingQuestions[0];
    final Color primaryBrandColor = isDark ? const Color(0xFF1A237E) : Colors.green[800]!;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("Điền từ: ${((_totalOriginalCount - _remainingQuestions.length) / _totalOriginalCount * 100).toInt()}%", style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: primaryBrandColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            LinearProgressIndicator(
              value: (_totalOriginalCount - _remainingQuestions.length) / _totalOriginalCount,
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
                border: Border.all(color: _getFeedbackColor().withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Text(_isReviewing ? "HÃY NHẬP LẠI CHO ĐÚNG" : "NỘI DUNG CÂU HỎI",
                      style: TextStyle(color: _isReviewing ? Colors.orange : Colors.grey, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                  const SizedBox(height: 15),
                  Text(currentQ.content, textAlign: TextAlign.center, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: _answerController,
              focusNode: _focusNode,
              onSubmitted: (_) => _handleAction(),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                filled: true,
                fillColor: Theme.of(context).cardColor,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: _getFeedbackColor(), width: 2)),
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
                    const Text("Bạn đã nhập sai rồi!", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text("Đáp án đúng: $_currentCorrectDisplay", style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 20)),
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: Text(_isReviewing ? "TIẾP TỤC" : "XÁC NHẬN", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16)),
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

  Widget _buildResultScreen() {
    final isDark = ThemeService.isDark;
    int finalPercent = ((_accumulatedScore / _totalOriginalCount) * 100).toInt();

    // ĐỒNG NHẤT MÀU SẮC THEO YÊU CẦU CỦA NÍ
    final Color primaryColor = isDark ? const Color(0xFF1A237E) : Colors.green[800]!;

    String title;
    String subTitle;
    IconData icon;

    if (finalPercent >= 90) {
      title = "XUẤT SẮC!";
      subTitle = "Bạn có trí nhớ thật tuyệt vời!";
      icon = Icons.emoji_events_rounded;
    } else if (finalPercent >= 70) {
      title = "RẤT TỐT!";
      subTitle = "Bạn đang tiến bộ rất nhanh đó.";
      icon = Icons.stars_rounded;
    } else {
      title = "CỐ GẮNG LÊN!";
      subTitle = "Luyện tập thêm để ghi nhớ tốt hơn nhé.";
      icon = Icons.lightbulb_circle_rounded;
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon vẫn giữ màu Brand để đồng nhất
            Icon(icon, size: 120, color: primaryColor),
            const SizedBox(height: 20),

            Text(title, style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: primaryColor, letterSpacing: 1.5)),
            const SizedBox(height: 10),
            Text(subTitle, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, color: Colors.grey)),

            const SizedBox(height: 50),

            // Vòng tròn điểm số đồng nhất màu Xanh Navy/Xanh Lá
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                    width: 170, height: 170,
                    child: CircularProgressIndicator(
                      value: finalPercent / 100,
                      strokeWidth: 12,
                      color: primaryColor,
                      backgroundColor: primaryColor.withOpacity(0.1),
                      strokeCap: StrokeCap.round,
                    )
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("$finalPercent%", style: TextStyle(fontSize: 42, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
                    Text("ĐIỂM SỐ", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: primaryColor.withOpacity(0.6))),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 40),

            // Container thông tin phụ
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: primaryColor.withOpacity(0.1))
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle_outline, size: 20, color: primaryColor),
                  const SizedBox(width: 10),
                  Text("Lỗi sai: ${_wrongAttempts.values.fold(0, (a, b) => a + b)} lần", style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor)),
                ],
              ),
            ),

            const SizedBox(height: 60),

            // Nút xác nhận đồng nhất hoàn toàn
            SizedBox(
              width: double.infinity,
              height: 58,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  elevation: 0,
                ),
                child: const Text("XÁC NHẬN HOÀN TẤT", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }
}