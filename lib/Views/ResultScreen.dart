import 'dart:math';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';

// ══════════════════════════════════════════════════════════════════════════════
// MODEL
// ══════════════════════════════════════════════════════════════════════════════

class ResultData {
  final int correctCount;
  final int totalCount;
  final int wrongAttempts;
  final String lessonTitle;
  final String lessonType;

  const ResultData({
    required this.correctCount,
    required this.totalCount,
    required this.lessonTitle,
    required this.lessonType,
    this.wrongAttempts = 0,
  });

  double get percent => totalCount == 0 ? 0 : correctCount / totalCount;
  int get percentInt => (percent * 100).toInt();
}

// ══════════════════════════════════════════════════════════════════════════════
// RESULT SCREEN
// ══════════════════════════════════════════════════════════════════════════════

class ResultScreen extends StatefulWidget {
  final ResultData data;
  const ResultScreen({super.key, required this.data});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen>
    with TickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AnimationController _fadeInController;
  late AnimationController _scoreController;
  late AnimationController _cardSlideController;
  late AnimationController _pulseController;

  late Animation<double> _fadeIn;
  late Animation<double> _scoreAnim;
  late Animation<Offset> _cardSlide;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();

    _confettiController =
        ConfettiController(duration: const Duration(seconds: 4));

    _fadeInController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _fadeIn =
        CurvedAnimation(parent: _fadeInController, curve: Curves.easeOut);

    _scoreController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1400));
    _scoreAnim = Tween<double>(begin: 0, end: widget.data.percent).animate(
        CurvedAnimation(
            parent: _scoreController, curve: Curves.easeOutExpo));

    _cardSlideController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _cardSlide =
        Tween<Offset>(begin: const Offset(0, 0.35), end: Offset.zero)
            .animate(CurvedAnimation(
            parent: _cardSlideController,
            curve: Curves.easeOutCubic));

    _pulseController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 900),
        lowerBound: 0.92,
        upperBound: 1.08)
      ..repeat(reverse: true);
    _pulse = _pulseController;

    _fadeInController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _scoreController.forward();
      _cardSlideController.forward();
      if (widget.data.percent >= 0.7 && mounted) {
        _confettiController.play();
      }
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _fadeInController.dispose();
    _scoreController.dispose();
    _cardSlideController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  _Tier get _tier {
    final p = widget.data.percentInt;
    if (p >= 90) return _Tier.excellent;
    if (p >= 70) return _Tier.good;
    if (p >= 50) return _Tier.ok;
    return _Tier.poor;
  }

  List<Color> get _gradientColors {
    switch (_tier) {
      case _Tier.excellent:
        return [const Color(0xFFFF6B35), const Color(0xFFFF8E00), const Color(0xFFFFD700)];
      case _Tier.good:
        return [const Color(0xFF11998E), const Color(0xFF38EF7D)];
      case _Tier.ok:
        return [const Color(0xFF4776E6), const Color(0xFF8E54E9)];
      case _Tier.poor:
        return [const Color(0xFF373B44), const Color(0xFF4286F4)];
    }
  }

  Color get _accentColor => _gradientColors.last;

  String get _emoji {
    switch (_tier) {
      case _Tier.excellent: return '🏆';
      case _Tier.good:      return '🌟';
      case _Tier.ok:        return '👍';
      case _Tier.poor:      return '💪';
    }
  }

  String get _headline {
    switch (_tier) {
      case _Tier.excellent: return 'XUẤT SẮC!';
      case _Tier.good:      return 'RẤT TỐT!';
      case _Tier.ok:        return 'KHÁ ĐẤY!';
      case _Tier.poor:      return 'CỐ LÊN NÀO!';
    }
  }

  String get _subline {
    switch (_tier) {
      case _Tier.excellent: return 'Trí nhớ siêu phàm — bạn thật tuyệt vời!';
      case _Tier.good:      return 'Bạn đang tiến bộ rất nhanh đó.';
      case _Tier.ok:        return 'Ôn thêm một chút nữa là hoàn hảo!';
      case _Tier.poor:      return 'Luyện tập thêm, bạn chắc chắn làm được!';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: FadeTransition(
        opacity: _fadeIn,
        child: Stack(
          children: [
            _buildBackground(),
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                numberOfParticles: 30,
                maxBlastForce: 30,
                minBlastForce: 10,
                gravity: 0.25,
                colors: [..._gradientColors, Colors.white, Colors.pinkAccent],
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  _buildTopBar(),
                  const SizedBox(height: 28),
                  _buildScoreRing(),
                  const SizedBox(height: 32),
                  Expanded(
                    child: SlideTransition(
                      position: _cardSlide,
                      child: _buildBottomCard(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackground() {
    return Stack(
      children: [
        Container(color: const Color(0xFF0D0D0D)),
        Positioned(
          top: -80, left: -60,
          child: _buildOrb(220, _gradientColors.first.withOpacity(0.30)),
        ),
        Positioned(
          top: 160, right: -80,
          child: _buildOrb(200, _accentColor.withOpacity(0.20)),
        ),
        Positioned(
          bottom: -60, left: 60,
          child: _buildOrb(180, _gradientColors.first.withOpacity(0.15)),
        ),
      ],
    );
  }

  Widget _buildOrb(double size, Color color) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context, true),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withOpacity(0.12)),
              ),
              child: const Icon(Icons.close_rounded,
                  color: Colors.white70, size: 18),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              widget.data.lessonTitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  color: Colors.white60,
                  fontSize: 14,
                  fontWeight: FontWeight.w500),
            ),
          ),
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: _gradientColors),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              widget.data.lessonType == 'quiz' ? 'TRẮC NGHIỆM' : 'ĐIỀN TỪ',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreRing() {
    return Column(
      children: [
        ScaleTransition(
          scale: _pulse,
          child: Text(_emoji, style: const TextStyle(fontSize: 52)),
        ),
        const SizedBox(height: 20),
        AnimatedBuilder(
          animation: _scoreAnim,
          builder: (_, __) {
            return SizedBox(
              width: 176, height: 176,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox.expand(
                    child: CircularProgressIndicator(
                      value: 1,
                      strokeWidth: 10,
                      color: Colors.white.withOpacity(0.07),
                    ),
                  ),
                  SizedBox.expand(
                    child: _GradientCircularProgress(
                      value: _scoreAnim.value,
                      gradient: LinearGradient(colors: _gradientColors),
                      strokeWidth: 10,
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ShaderMask(
                        shaderCallback: (b) =>
                            LinearGradient(colors: _gradientColors)
                                .createShader(b),
                        child: Text(
                          '${(_scoreAnim.value * 100).toInt()}%',
                          style: const TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              height: 1),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ĐIỂM SỐ',
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white.withOpacity(0.4),
                            letterSpacing: 2),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 20),
        Text(
          _headline,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            foreground: Paint()
              ..shader = LinearGradient(colors: _gradientColors)
                  .createShader(const Rect.fromLTWH(0, 0, 200, 40)),
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          _subline,
          style: TextStyle(
              fontSize: 13, color: Colors.white.withOpacity(0.55)),
        ),
      ],
    );
  }

  Widget _buildBottomCard() {
    final isQuiz = widget.data.lessonType == 'quiz';
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF181818),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      // FIX: dùng SingleChildScrollView thay Padding + Column có Spacer
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(28, 28, 28, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'KẾT QUẢ CHI TIẾT',
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.white.withOpacity(0.35),
                  letterSpacing: 2),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                if (isQuiz) ...[
                  _buildStatChip(
                      icon: Icons.check_circle_rounded,
                      label: 'Đúng',
                      value: '${widget.data.correctCount}',
                      color: const Color(0xFF38EF7D)),
                  const SizedBox(width: 12),
                  _buildStatChip(
                      icon: Icons.cancel_rounded,
                      label: 'Sai',
                      value:
                      '${widget.data.totalCount - widget.data.correctCount}',
                      color: const Color(0xFFFF6B6B)),
                  const SizedBox(width: 12),
                  _buildStatChip(
                      icon: Icons.quiz_rounded,
                      label: 'Tổng',
                      value: '${widget.data.totalCount}',
                      color: _accentColor),
                ] else ...[
                  _buildStatChip(
                      icon: Icons.emoji_events_rounded,
                      label: 'Điểm',
                      value: '${widget.data.percentInt}%',
                      color: const Color(0xFFFFD700)),
                  const SizedBox(width: 12),
                  _buildStatChip(
                      icon: Icons.repeat_rounded,
                      label: 'Lần sai',
                      value: '${widget.data.wrongAttempts}',
                      color: const Color(0xFFFF6B6B)),
                  const SizedBox(width: 12),
                  _buildStatChip(
                      icon: Icons.help_outline_rounded,
                      label: 'Câu',
                      value: '${widget.data.totalCount}',
                      color: _accentColor),
                ],
              ],
            ),
            const SizedBox(height: 20),
            _buildProgressBar(),
            // FIX: bỏ Spacer(), thay bằng SizedBox cố định
            const SizedBox(height: 20),
            _buildCTAButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatChip({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding:
        const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.18)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(value,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: color,
                    height: 1)),
            const SizedBox(height: 2),
            Text(label,
                style: TextStyle(
                    fontSize: 10,
                    color: Colors.white.withOpacity(0.45),
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Tỉ lệ hoàn thành',
                style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.45))),
            AnimatedBuilder(
              animation: _scoreAnim,
              builder: (_, __) => Text(
                '${(_scoreAnim.value * 100).toInt()}%',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: _accentColor),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: AnimatedBuilder(
            animation: _scoreAnim,
            builder: (_, __) => LinearProgressIndicator(
              value: _scoreAnim.value,
              minHeight: 8,
              backgroundColor: Colors.white.withOpacity(0.07),
              valueColor: AlwaysStoppedAnimation(_accentColor),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCTAButton() {
    return GestureDetector(
      onTap: () => Navigator.pop(context, true),
      child: Container(
        width: double.infinity,
        height: 58,
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: _gradientColors,
              begin: Alignment.centerLeft,
              end: Alignment.centerRight),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
                color: _gradientColors.first.withOpacity(0.35),
                blurRadius: 20,
                offset: const Offset(0, 8)),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_rounded, color: Colors.white, size: 20),
            SizedBox(width: 10),
            Text('XÁC NHẬN HOÀN TẤT',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2)),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// GRADIENT CIRCULAR PROGRESS
// ══════════════════════════════════════════════════════════════════════════════

class _GradientCircularProgress extends StatelessWidget {
  final double value;
  final Gradient gradient;
  final double strokeWidth;

  const _GradientCircularProgress({
    required this.value,
    required this.gradient,
    this.strokeWidth = 8,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _GradientArcPainter(
          value: value, gradient: gradient, strokeWidth: strokeWidth),
    );
  }
}

class _GradientArcPainter extends CustomPainter {
  final double value;
  final Gradient gradient;
  final double strokeWidth;

  _GradientArcPainter(
      {required this.value,
        required this.gradient,
        required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..shader = gradient.createShader(rect);

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (min(size.width, size.height) - strokeWidth) / 2;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi * value,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(_GradientArcPainter old) => old.value != value;
}

enum _Tier { excellent, good, ok, poor }