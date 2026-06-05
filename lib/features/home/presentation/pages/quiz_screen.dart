// quiz_screen.dart
// Place at: features/home/presentation/pages/quiz_screen.dart

import 'dart:math';
import 'package:flutter/material.dart';
import 'quiz_data_part1.dart';

class QuizScreen extends StatefulWidget {
  final QuizSubtopicData data;
  final Color accentColor;
  final IconData icon;

  const QuizScreen({
    super.key,
    required this.data,
    required this.accentColor,
    required this.icon,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> with TickerProviderStateMixin {
  int _currentIndex = 0;
  int? _selectedAnswer;
  bool _answered = false;
  final List<int?> _userAnswers = [];

  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  bool _slidingForward = true;

  @override
  void initState() {
    super.initState();
    _userAnswers.addAll(List.filled(widget.data.questions.length, null));
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));
    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  void _selectAnswer(int index) {
    if (_answered) return;
    setState(() {
      _selectedAnswer = index;
      _answered = true;
      _userAnswers[_currentIndex] = index;
    });
  }

  void _goToNext() {
    if (_currentIndex < widget.data.questions.length - 1) {
      _slidingForward = true;
      _slideAnimation = Tween<Offset>(
        begin: const Offset(1.0, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));
      _slideController.reset();
      _slideController.forward();
      setState(() {
        _currentIndex++;
        _selectedAnswer = _userAnswers[_currentIndex];
        _answered = _userAnswers[_currentIndex] != null;
      });
    } else {
      _showResults();
    }
  }

  void _goToPrevious() {
    if (_currentIndex > 0) {
      _slidingForward = false;
      _slideAnimation = Tween<Offset>(
        begin: const Offset(-1.0, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));
      _slideController.reset();
      _slideController.forward();
      setState(() {
        _currentIndex--;
        _selectedAnswer = _userAnswers[_currentIndex];
        _answered = _userAnswers[_currentIndex] != null;
      });
    }
  }

  int get _correctCount =>
      _userAnswers.asMap().entries.where((e) {
        if (e.value == null) return false;
        return e.value == widget.data.questions[e.key].correctIndex;
      }).length;

  void _showResults() {
    final total = widget.data.questions.length;
    final correct = _correctCount;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => QuizResultScreen(
          algorithm: widget.data.algorithm,
          subtopic: widget.data.subtopic,
          correct: correct,
          total: total,
          accentColor: widget.accentColor,
          icon: widget.icon,
        ),
      ),
    );
  }

  Color _optionColor(int optionIndex) {
    if (!_answered) return const Color(0xFF1E2530);
    final q = widget.data.questions[_currentIndex];
    if (optionIndex == q.correctIndex) return Colors.green.shade800;
    if (optionIndex == _selectedAnswer && _selectedAnswer != q.correctIndex) {
      return Colors.red.shade800;
    }
    return const Color(0xFF1E2530);
  }

  IconData? _optionIcon(int optionIndex) {
    if (!_answered) return null;
    final q = widget.data.questions[_currentIndex];
    if (optionIndex == q.correctIndex) return Icons.check_circle_rounded;
    if (optionIndex == _selectedAnswer && _selectedAnswer != q.correctIndex) {
      return Icons.cancel_rounded;
    }
    return null;
  }

  Color? _optionIconColor(int optionIndex) {
    if (!_answered) return null;
    final q = widget.data.questions[_currentIndex];
    if (optionIndex == q.correctIndex) return Colors.green.shade300;
    if (optionIndex == _selectedAnswer) return Colors.red.shade300;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final q = widget.data.questions[_currentIndex];
    final total = widget.data.questions.length;
    final progress = (_currentIndex + 1) / total;

    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1117),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.data.algorithm,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              widget.data.subtopic,
              style: TextStyle(fontSize: 12, color: widget.accentColor),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '${_currentIndex + 1} / $total',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: widget.accentColor,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.white10,
                valueColor: AlwaysStoppedAnimation<Color>(widget.accentColor),
                minHeight: 6,
              ),
            ),
          ),

          // Answer status chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            child: Row(
              children: List.generate(total, (i) {
                final ans = _userAnswers[i];
                Color chipColor;
                if (ans == null) {
                  chipColor = i == _currentIndex
                      ? widget.accentColor.withOpacity(0.3)
                      : Colors.white10;
                } else if (ans == widget.data.questions[i].correctIndex) {
                  chipColor = Colors.green.shade700;
                } else {
                  chipColor = Colors.red.shade700;
                }
                return Expanded(
                  child: Container(
                    height: 5,
                    margin: const EdgeInsets.symmetric(horizontal: 1.5),
                    decoration: BoxDecoration(
                      color: chipColor,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                );
              }),
            ),
          ),

          // Question card
          Expanded(
            child: SlideTransition(
              position: _slideAnimation,
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Question box
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            widget.accentColor.withOpacity(0.15),
                            const Color(0xFF161B22),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: widget.accentColor.withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: widget.accentColor.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Q${_currentIndex + 1}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: widget.accentColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            q.question,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Options
                    Expanded(
                      child: ListView.separated(
                        itemCount: q.options.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, i) {
                          final isSelected = _selectedAnswer == i;
                          final color = _optionColor(i);
                          final iconData = _optionIcon(i);
                          final iconColor = _optionIconColor(i);

                          return GestureDetector(
                            onTap: () => _selectAnswer(i),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 14),
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isSelected && !_answered
                                      ? widget.accentColor
                                      : _answered && i ==
                                              widget.data.questions[_currentIndex]
                                                  .correctIndex
                                          ? Colors.green.shade600
                                          : _answered && isSelected
                                              ? Colors.red.shade600
                                              : Colors.white10,
                                  width: isSelected || (_answered && i == widget.data.questions[_currentIndex].correctIndex) ? 1.5 : 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 30,
                                    height: 30,
                                    decoration: BoxDecoration(
                                      color: widget.accentColor.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Center(
                                      child: Text(
                                        String.fromCharCode(65 + i),
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: widget.accentColor,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      q.options[i],
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: _answered
                                            ? i == q.correctIndex
                                                ? Colors.green.shade200
                                                : isSelected
                                                    ? Colors.red.shade200
                                                    : Colors.grey.shade400
                                            : Colors.white,
                                        fontWeight: _answered && i == q.correctIndex
                                            ? FontWeight.w600
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                  if (iconData != null)
                                    Icon(iconData, color: iconColor, size: 20),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Navigation buttons
                    Row(
                      children: [
                        if (_currentIndex > 0)
                          Expanded(
                            flex: 1,
                            child: GestureDetector(
                              onTap: _goToPrevious,
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF161B22),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: Colors.white12),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.arrow_back_ios_rounded,
                                        size: 16, color: Colors.white70),
                                    SizedBox(width: 4),
                                    Text('Prev',
                                        style: TextStyle(
                                            color: Colors.white70, fontSize: 14)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        if (_currentIndex > 0) const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: GestureDetector(
                            onTap: _answered ? _goToNext : null,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                gradient: _answered
                                    ? LinearGradient(colors: [
                                        widget.accentColor,
                                        widget.accentColor.withOpacity(0.7),
                                      ])
                                    : null,
                                color: _answered ? null : Colors.white10,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Center(
                                child: Text(
                                  _currentIndex == total - 1
                                      ? 'See Results'
                                      : 'Next →',
                                  style: TextStyle(
                                    color: _answered ? Colors.white : Colors.white30,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  RESULT SCREEN
// ─────────────────────────────────────────────

class QuizResultScreen extends StatefulWidget {
  final String algorithm;
  final String subtopic;
  final int correct;
  final int total;
  final Color accentColor;
  final IconData icon;

  const QuizResultScreen({
    super.key,
    required this.algorithm,
    required this.subtopic,
    required this.correct,
    required this.total,
    required this.accentColor,
    required this.icon,
  });

  @override
  State<QuizResultScreen> createState() => _QuizResultScreenState();
}

class _QuizResultScreenState extends State<QuizResultScreen>
    with TickerProviderStateMixin {
  late AnimationController _scoreController;
  late AnimationController _particleController;
  late Animation<double> _scoreAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scoreController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    _scoreAnimation = Tween<double>(begin: 0, end: widget.correct.toDouble())
        .animate(CurvedAnimation(parent: _scoreController, curve: Curves.easeOut));
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0)
        .animate(CurvedAnimation(parent: _scoreController, curve: Curves.elasticOut));

    _scoreController.forward();
    if (widget.correct >= widget.total * 0.5) {
      _particleController.repeat();
    }
  }

  @override
  void dispose() {
    _scoreController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  double get _percentage => widget.correct / widget.total;

  String get _resultEmoji {
    if (_percentage >= 0.9) return '🎉🌸🌺';
    if (_percentage >= 0.7) return '🍦🎊✨';
    if (_percentage >= 0.5) return '😊👍';
    return '🍫💪';
  }

  String get _resultTitle {
    if (_percentage >= 0.9) return 'Outstanding!';
    if (_percentage >= 0.7) return 'Great Job!';
    if (_percentage >= 0.5) return 'Good Effort!';
    return 'Keep Practicing!';
  }

  String get _resultMessage {
    if (_percentage >= 0.9) return 'Flowers for you! You nailed it!';
    if (_percentage >= 0.7) return 'Here\'s an ice cream! Well done!';
    if (_percentage >= 0.5) return 'Decent score! Review and try again!';
    return 'Here\'s a chocolate to cheer you up! Keep going!';
  }

  Color get _resultColor {
    if (_percentage >= 0.9) return Colors.green;
    if (_percentage >= 0.7) return Colors.blue;
    if (_percentage >= 0.5) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      body: Stack(
        children: [
          // Particle burst background
          if (_percentage >= 0.5)
            AnimatedBuilder(
              animation: _particleController,
              builder: (context, _) {
                return CustomPaint(
                  painter: _ParticlePainter(
                    progress: _particleController.value,
                    color: widget.accentColor,
                    highScore: _percentage >= 0.7,
                  ),
                  size: Size.infinite,
                );
              },
            ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Trophy/result emoji animation
                  AnimatedBuilder(
                    animation: _scaleAnimation,
                    builder: (_, __) => Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Text(
                        _resultEmoji,
                        style: const TextStyle(fontSize: 64),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Score circle
                  AnimatedBuilder(
                    animation: _scoreAnimation,
                    builder: (_, __) {
                      final displayed = _scoreAnimation.value.round();
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 160,
                            height: 160,
                            child: CircularProgressIndicator(
                              value: displayed / widget.total,
                              backgroundColor: Colors.white10,
                              valueColor: AlwaysStoppedAnimation(_resultColor),
                              strokeWidth: 10,
                            ),
                          ),
                          Column(
                            children: [
                              Text(
                                '$displayed',
                                style: TextStyle(
                                  fontSize: 52,
                                  fontWeight: FontWeight.bold,
                                  color: _resultColor,
                                ),
                              ),
                              Text(
                                'out of ${widget.total}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade400,
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 28),

                  Text(
                    _resultTitle,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _resultMessage,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey.shade400,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 32),

                  // Stats row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _StatChip(
                        label: 'Correct',
                        value: '${widget.correct}',
                        color: Colors.green,
                      ),
                      const SizedBox(width: 16),
                      _StatChip(
                        label: 'Wrong',
                        value: '${widget.total - widget.correct}',
                        color: Colors.red,
                      ),
                      const SizedBox(width: 16),
                      _StatChip(
                        label: 'Score',
                        value: '${(_percentage * 100).round()}%',
                        color: widget.accentColor,
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Topic info
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF161B22),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(widget.icon, color: widget.accentColor, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          '${widget.algorithm} › ${widget.subtopic}',
                          style: TextStyle(
                            color: Colors.grey.shade300,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () =>
                              Navigator.popUntil(context, (r) => r.isFirst),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: const Color(0xFF161B22),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: Colors.white12),
                            ),
                            child: const Center(
                              child: Text(
                                'Home',
                                style: TextStyle(
                                    color: Colors.white70,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(colors: [
                                widget.accentColor,
                                widget.accentColor.withOpacity(0.7),
                              ]),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Center(
                              child: Text(
                                'Try Again',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatChip(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(value,
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: color)),
          const SizedBox(height: 2),
          Text(label,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade400)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  PARTICLE PAINTER
// ─────────────────────────────────────────────

class _ParticlePainter extends CustomPainter {
  final double progress;
  final Color color;
  final bool highScore;

  _ParticlePainter(
      {required this.progress, required this.color, required this.highScore});

  @override
  void paint(Canvas canvas, Size size) {
    final rng = Random(42);
    final paint = Paint()..style = PaintingStyle.fill;
    final count = highScore ? 60 : 30;

    for (int i = 0; i < count; i++) {
      final seed = i * 13.0;
      final angle = (seed / count) * 2 * pi + progress * pi * 2;
      final radius = (0.3 + rng.nextDouble() * 0.4) * size.width;
      final x = size.width / 2 + cos(angle) * radius * progress;
      final y = size.height / 2 + sin(angle) * radius * progress * 0.8;
      final opacity = (1.0 - progress) * 0.6;
      final particleSize = 3.0 + rng.nextDouble() * (highScore ? 6.0 : 3.0);

      if (opacity <= 0) continue;

      // Alternate between colors for high scores
      final colors = highScore
          ? [color, Colors.pink, Colors.yellow, Colors.green, Colors.blue]
          : [color, Colors.orange];
      paint.color = colors[i % colors.length].withOpacity(opacity);

      if (highScore && i % 3 == 0) {
        // Draw stars
        _drawStar(canvas, Offset(x, y), particleSize, paint);
      } else {
        canvas.drawCircle(Offset(x, y), particleSize / 2, paint);
      }
    }
  }

  void _drawStar(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    for (int i = 0; i < 5; i++) {
      final angle = (i * 4 * pi / 5) - pi / 2;
      final x = center.dx + size * cos(angle);
      final y = center.dy + size * sin(angle);
      if (i == 0) path.moveTo(x, y);
      else path.lineTo(x, y);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_ParticlePainter old) => old.progress != progress;
}