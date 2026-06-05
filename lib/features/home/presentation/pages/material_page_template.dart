import 'dart:math';
import 'package:flutter/material.dart';

// ─────────────────────────────────────────────
//  DATA MODELS
// ─────────────────────────────────────────────

class FlashCardData {
  final String front;
  final String back;
  const FlashCardData({required this.front, required this.back});
}

class OperationData {
  final String name;
  final String definition;
  final String complexity;
  const OperationData({
    required this.name,
    required this.definition,
    required this.complexity,
  });
}

class MaterialPageData {
  final String title;
  final Color accentColor;
  final IconData icon;
  final String definition;
  final String howItWorks;
  final List<OperationData> operations;
  final List<String> realWorldApps;
  final List<FlashCardData> keyTakeaways;

  const MaterialPageData({
    required this.title,
    required this.accentColor,
    required this.icon,
    required this.definition,
    required this.howItWorks,
    required this.operations,
    required this.realWorldApps,
    required this.keyTakeaways,
  });
}

// ─────────────────────────────────────────────
//  GLITTER PAINTER
// ─────────────────────────────────────────────

class GlitterPainter extends CustomPainter {
  final double progress;
  final Color color;
  final List<Offset> _dots;

  GlitterPainter({required this.progress, required this.color})
      : _dots = List.generate(28, (i) {
          final rng = Random(i * 7 + 13);
          return Offset(rng.nextDouble(), rng.nextDouble());
        });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    for (int i = 0; i < _dots.length; i++) {
      final phase = (progress + i / _dots.length) % 1.0;
      final opacity = (sin(phase * pi * 2) * 0.5 + 0.5);
      paint.color = color.withOpacity(opacity * 0.85);
      final sparkSize = 1.5 + sin(phase * pi) * 2.5;
      canvas.drawCircle(
        Offset(_dots[i].dx * size.width, _dots[i].dy * size.height),
        sparkSize,
        paint,
      );
    }
    // Animated border glow
    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..shader = SweepGradient(
        startAngle: progress * pi * 2,
        endAngle: progress * pi * 2 + pi,
        colors: [
          color.withOpacity(0.0),
          color.withOpacity(0.9),
          color.withOpacity(0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(20),
      ),
      borderPaint,
    );
  }

  @override
  bool shouldRepaint(GlitterPainter old) => old.progress != progress;
}

// ─────────────────────────────────────────────
//  GLITTER FLIP CARD
// ─────────────────────────────────────────────

class GlitterFlipCard extends StatefulWidget {
  final FlashCardData data;
  final Color accentColor;

  const GlitterFlipCard({
    super.key,
    required this.data,
    required this.accentColor,
  });

  @override
  State<GlitterFlipCard> createState() => _GlitterFlipCardState();
}

class _GlitterFlipCardState extends State<GlitterFlipCard>
    with TickerProviderStateMixin {
  late AnimationController _flipController;
  late AnimationController _glitterController;
  late Animation<double> _flipAnimation;
  bool _isFlipped = false;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _glitterController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOutBack),
    );
  }

  @override
  void dispose() {
    _flipController.dispose();
    _glitterController.dispose();
    super.dispose();
  }

  void _toggle() {
    if (_isFlipped) {
      _flipController.reverse();
    } else {
      _flipController.forward();
    }
    setState(() => _isFlipped = !_isFlipped);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggle,
      child: AnimatedBuilder(
        animation: Listenable.merge([_flipAnimation, _glitterController]),
        builder: (context, _) {
          final angle = _flipAnimation.value * pi;
          final isFront = angle <= pi / 2;
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(angle),
            child: SizedBox(
              width: 200,
              height: 140,
              child: Stack(
                children: [
                  // Card body
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF161B22),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: widget.accentColor.withOpacity(0.25),
                      ),
                    ),
                  ),
                  // Glitter overlay
                  Positioned.fill(
                    child: CustomPaint(
                      painter: GlitterPainter(
                        progress: _glitterController.value,
                        color: widget.accentColor,
                      ),
                    ),
                  ),
                  // Content
                  Positioned.fill(
                    child: Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..rotateY(isFront ? 0 : pi),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (isFront) ...[
                              Icon(
                                Icons.lightbulb_outline_rounded,
                                color: widget.accentColor,
                                size: 22,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                widget.data.front,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white.withOpacity(0.9),
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tap to reveal',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: widget.accentColor.withOpacity(0.7),
                                ),
                              ),
                            ] else ...[
                              Text(
                                widget.data.back,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade300,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  MATERIAL DETAIL PAGE
// ─────────────────────────────────────────────

class DSAMaterialPage extends StatelessWidget {
  final MaterialPageData data;

  const DSAMaterialPage({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      body: CustomScrollView(
        slivers: [
          // Hero AppBar
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            backgroundColor: const Color(0xFF0D1117),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                data.title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      data.accentColor.withOpacity(0.3),
                      const Color(0xFF0D1117),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Icon(
                    data.icon,
                    size: 72,
                    color: data.accentColor.withOpacity(0.25),
                  ),
                ),
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.all(18),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // ── Definition ──
                _SectionHeader(
                    label: '📖 Definition', accentColor: data.accentColor),
                const SizedBox(height: 10),
                _InfoCard(text: data.definition, accentColor: data.accentColor),

                const SizedBox(height: 28),

                // ── How It Works ──
                _SectionHeader(
                    label: '⚙️ How It Works', accentColor: data.accentColor),
                const SizedBox(height: 10),
                _InfoCard(
                    text: data.howItWorks, accentColor: data.accentColor),

                const SizedBox(height: 28),

                // ── Operations ──
                _SectionHeader(
                    label: '🔧 Operations', accentColor: data.accentColor),
                const SizedBox(height: 10),
                ...data.operations.map((op) => _OperationCard(
                      operation: op,
                      accentColor: data.accentColor,
                    )),

                const SizedBox(height: 28),

                // ── Real World Apps ──
                _SectionHeader(
                    label: '🌍 Real World Applications',
                    accentColor: data.accentColor),
                const SizedBox(height: 10),
                _RealWorldCard(
                    apps: data.realWorldApps, accentColor: data.accentColor),

                const SizedBox(height: 28),

                // ── Key Takeaways ──
                _SectionHeader(
                    label: '✨ Key Takeaways', accentColor: data.accentColor),
                const SizedBox(height: 6),
                Text(
                  'Tap each card to reveal the answer',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  height: 160,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: data.keyTakeaways.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 14),
                    itemBuilder: (context, i) => GlitterFlipCard(
                      data: data.keyTakeaways[i],
                      accentColor: data.accentColor,
                    ),
                  ),
                ),

                const SizedBox(height: 40),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  SHARED SECTION WIDGETS
// ─────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String label;
  final Color accentColor;
  const _SectionHeader({required this.label, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 22,
          decoration: BoxDecoration(
            color: accentColor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String text;
  final Color accentColor;
  const _InfoCard({required this.text, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.05),
            blurRadius: 12,
          ),
        ],
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey.shade300,
          height: 1.7,
        ),
      ),
    );
  }
}

class _OperationCard extends StatelessWidget {
  final OperationData operation;
  final Color accentColor;
  const _OperationCard(
      {required this.operation, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              operation.complexity,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: accentColor,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  operation.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  operation.definition,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade400,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RealWorldCard extends StatelessWidget {
  final List<String> apps;
  final Color accentColor;
  const _RealWorldCard({required this.apps, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: apps
            .map(
              (app) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 5, right: 10),
                      child: Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: accentColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        app,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade300,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}