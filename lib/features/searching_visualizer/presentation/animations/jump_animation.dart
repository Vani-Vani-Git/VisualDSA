import 'package:flutter/material.dart';

/// Manages the animated drawing of jump-search arcs.
/// Each arc is drawn progressively as [progress] goes from 0→1.
class JumpAnimation extends ChangeNotifier {
  double progress = 0.0;
  bool running = false;

  Future<void> animateArc({
    Duration duration = const Duration(milliseconds: 500),
  }) async {
    running = true;
    progress = 0.0;
    notifyListeners();

    const steps = 30;
    for (int i = 1; i <= steps; i++) {
      await Future.delayed(Duration(milliseconds: duration.inMilliseconds ~/ steps));
      progress = i / steps;
      notifyListeners();
    }

    running = false;
    notifyListeners();
  }

  void reset() {
    progress = 0.0;
    running = false;
    notifyListeners();
  }
}

/// Draws a single animated arc between two x-positions.
class AnimatedArcPainter extends CustomPainter {
  final double x1;
  final double x2;
  final double progress; // 0.0 → 1.0
  final Color color;
  final double arcHeight;

  AnimatedArcPainter({
    required this.x1,
    required this.x2,
    required this.progress,
    required this.color,
    this.arcHeight = 30,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final midX = (x1 + x2) / 2;
    final path = Path()
      ..moveTo(x1, size.height)
      ..quadraticBezierTo(midX, size.height - arcHeight, x2, size.height);

    // Trim path to progress
    final metrics = path.computeMetrics().first;
    final extracted = metrics.extractPath(0, metrics.length * progress);
    canvas.drawPath(extracted, paint);
  }

  @override
  bool shouldRepaint(AnimatedArcPainter old) =>
      old.progress != progress || old.x1 != x1 || old.x2 != x2;
}