import 'package:flutter/material.dart';
import '../models/stack_step.dart';

class StackCanvas extends StatefulWidget {
  final StackStep? step;
  final int maxSize;

  const StackCanvas({
    super.key,
    this.step,
    this.maxSize = 8,
  });

  @override
  State<StackCanvas> createState() => _StackCanvasState();
}

class _StackCanvasState extends State<StackCanvas>
    with TickerProviderStateMixin {
  // Floating element animation (push incoming / pop outgoing)
  late AnimationController _floatCtrl;
  late Animation<double> _floatY;
  late Animation<double> _floatOpacity;

  // Highlight pulse on top element
  late AnimationController _pulseCtrl;
  late Animation<double> _pulse;

  // Scale pop when element settles (push done)
  late AnimationController _settleCtrl;
  late Animation<double> _settle;

  String? _lastPhase;
  String? _lastFloatingState;

  @override
  void initState() {
    super.initState();

    _floatCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 520));
    _floatY = Tween<double>(begin: -80, end: 0).animate(
        CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut));
    _floatOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _floatCtrl, curve: Curves.easeIn));

    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600))
      ..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.85, end: 1.0).animate(
        CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    _settleCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 380));
    _settle = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.15), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 1.15, end: 0.95), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 0.95, end: 1.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _settleCtrl, curve: Curves.easeOut));
  }

  @override
  void didUpdateWidget(StackCanvas old) {
    super.didUpdateWidget(old);
    final s = widget.step;
    if (s == null) return;

    if (s.floatingState == 'incoming' && _lastFloatingState != 'incoming') {
      _floatCtrl.forward(from: 0);
    }
    if (s.phase == 'pushed' && _lastPhase != 'pushed') {
      _settleCtrl.forward(from: 0);
      _floatCtrl.reset();
    }
    if (s.phase == 'popping' && _lastPhase != 'popping') {
      _pulseCtrl.repeat(reverse: true);
    }
    if (s.phase == 'popped' && _lastPhase != 'popped') {
      _pulseCtrl.stop();
      _floatCtrl.reverse(from: 1.0);
    }

    _lastPhase = s.phase;
    _lastFloatingState = s.floatingState;
  }

  @override
  void dispose() {
    _floatCtrl.dispose();
    _pulseCtrl.dispose();
    _settleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.step;
    final stack = s?.stack ?? [];
    final phase = s?.phase ?? 'idle';

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Status Banner ───────────────────────────────────────────────
          _buildStatusBanner(s),
          const SizedBox(height: 12),

          // ── Stack visualization ─────────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left: floating element + stack column
              Expanded(
                child: Column(
                  children: [
                    // Floating element area (push incoming / pop outgoing)
                    _buildFloatingArea(s),
                    const SizedBox(height: 4),
                    // Stack column
                    _buildStackColumn(stack, s, phase),
                    // "Stack" label
                    const SizedBox(height: 6),
                    const Text(
                      'Stack',
                      style: TextStyle(
                        color: Color(0xFF8B949E),
                        fontSize: 12,
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Status Banner ──────────────────────────────────────────────────────────
  Widget _buildStatusBanner(StackStep? s) {
    Color bg, textColor;
    IconData icon;

    switch (s?.phase) {
      case 'pushed':
        bg = const Color(0xFF22C55E).withOpacity(0.15);
        textColor = const Color(0xFF22C55E);
        icon = Icons.check_circle_outline;
        break;
      case 'popped':
        bg = const Color(0xFFF59E0B).withOpacity(0.15);
        textColor = const Color(0xFFF59E0B);
        icon = Icons.output_rounded;
        break;
      case 'overflow':
      case 'underflow':
        bg = const Color(0xFFEF4444).withOpacity(0.15);
        textColor = const Color(0xFFEF4444);
        icon = Icons.warning_amber_rounded;
        break;
      case 'pushing':
        bg = const Color(0xFF3B82F6).withOpacity(0.12);
        textColor = const Color(0xFF93C5FD);
        icon = Icons.arrow_downward_rounded;
        break;
      case 'popping':
        bg = const Color(0xFFA78BFA).withOpacity(0.12);
        textColor = const Color(0xFFA78BFA);
        icon = Icons.arrow_upward_rounded;
        break;
      default:
        bg = const Color(0xFF3B82F6).withOpacity(0.08);
        textColor = const Color(0xFF8B949E);
        icon = Icons.info_outline;
    }

    final msg = s?.statusMsg.isNotEmpty == true
        ? s!.statusMsg
        : 'Select an operation and press Play to begin.';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: textColor.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: textColor, size: 15),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              msg,
              style: TextStyle(
                color: textColor,
                fontSize: 12,
                fontFamily: 'monospace',
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Floating element (push in / pop out) ───────────────────────────────────
  Widget _buildFloatingArea(StackStep? s) {
    final fv = s?.floatingValue;
    final fs = s?.floatingState;
    final phase = s?.phase ?? 'idle';

    if (fv == null) return const SizedBox(height: 54);

    Widget floatingBox(Color border, Color bg, Color text) {
      return Container(
        width: 110,
        height: 44,
        decoration: BoxDecoration(
          color: bg,
          border: Border.all(color: border, width: 2),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
                color: border.withOpacity(0.25), blurRadius: 10, spreadRadius: 1)
          ],
        ),
        child: Center(
          child: Text(
            '$fv',
            style: TextStyle(
              color: text,
              fontSize: 18,
              fontWeight: FontWeight.w800,
              fontFamily: 'monospace',
            ),
          ),
        ),
      );
    }

    // PUSH incoming: animate sliding down
    if (fs == 'incoming' || fs == 'landing') {
      return SizedBox(
        height: 54,
        child: Center(
          child: AnimatedBuilder(
            animation: _floatCtrl,
            builder: (_, child) => Transform.translate(
              offset: Offset(0, _floatY.value),
              child: Opacity(opacity: _floatOpacity.value, child: child),
            ),
            child: floatingBox(
              const Color(0xFF3B82F6),
              const Color(0xFF3B82F6).withOpacity(0.15),
              const Color(0xFF93C5FD),
            ),
          ),
        ),
      );
    }

    // POP outgoing: animate moving up
    if (fs == 'outgoing' || fs == 'ejected') {
      final isEjected = fs == 'ejected';
      return SizedBox(
        height: 54,
        child: Center(
          child: AnimatedBuilder(
            animation: _floatCtrl,
            builder: (_, child) {
              final t = isEjected ? 1.0 - _floatCtrl.value : 0.0;
              return Transform.translate(
                offset: Offset(0, -60 * t),
                child: Opacity(
                    opacity: isEjected ? _floatCtrl.value : 1.0, child: child),
              );
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Popped!',
                  style: TextStyle(
                    color: const Color(0xFFF59E0B),
                    fontSize: 10,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                floatingBox(
                  const Color(0xFFF59E0B),
                  const Color(0xFFF59E0B).withOpacity(0.15),
                  const Color(0xFFF59E0B),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Peek: show value floating with no animation
    if (phase == 'pushed' && s?.operation == 'peek') {
      return const SizedBox(height: 54);
    }

    return const SizedBox(height: 54);
  }

  // ── Stack column ───────────────────────────────────────────────────────────
  Widget _buildStackColumn(List<int> stack, StackStep? s, String phase) {
    // Build slots from top (displayed first) to bottom
    // We always show maxSize slots; empty ones are ghost cells
    final displaySlots = List.generate(widget.maxSize, (i) {
      // i=0 → top slot, i=maxSize-1 → bottom slot
      final stackIdx = (stack.length - 1) - i; // index into stack list
      return stackIdx;
    });

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Left: "top →" label column
        SizedBox(
          width: 52,
          child: Column(
            children: List.generate(widget.maxSize, (i) {
              final stackIdx = (stack.length - 1) - i;
              final isTop = stackIdx == stack.length - 1 && stack.isNotEmpty;
              return SizedBox(
                height: 46,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: isTop
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Text(
                              'top',
                              style: TextStyle(
                                color: Color(0xFF3B82F6),
                                fontSize: 11,
                                fontFamily: 'monospace',
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(width: 3),
                            Icon(Icons.arrow_forward,
                                size: 13, color: Color(0xFF3B82F6)),
                          ],
                        )
                      : const SizedBox.shrink(),
                ),
              );
            }),
          ),
        ),

        // Center: stack cells inside a U-shaped border
        Stack(
          children: [
            // U-shape border
            Positioned.fill(
              child: CustomPaint(painter: _UBorderPainter()),
            ),
            // Cells
            Padding(
              padding: const EdgeInsets.only(left: 2, right: 2),
              child: Column(
                children: List.generate(widget.maxSize, (i) {
                  final stackIdx = (stack.length - 1) - i;
                  final hasValue = stackIdx >= 0 && stackIdx < stack.length;
                  return _buildSlot(
                    value: hasValue ? stack[stackIdx] : null,
                    isHighlight: hasValue &&
                        s?.highlightIdx == stackIdx,
                    phase: phase,
                    operation: s?.operation ?? 'none',
                    settleAnim: _settle,
                    pulseAnim: _pulse,
                    isTop: hasValue && stackIdx == stack.length - 1,
                  );
                }),
              ),
            ),
          ],
        ),

        // Right: index labels
        SizedBox(
          width: 30,
          child: Column(
            children: List.generate(widget.maxSize, (i) {
              final stackIdx = (stack.length - 1) - i;
              return SizedBox(
                height: 46,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: stackIdx >= 0
                      ? Padding(
                          padding: const EdgeInsets.only(left: 6),
                          child: Text(
                            '[$stackIdx]',
                            style: const TextStyle(
                              color: Color(0xFFEF4444),
                              fontSize: 9,
                              fontFamily: 'monospace',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildSlot({
    required int? value,
    required bool isHighlight,
    required String phase,
    required String operation,
    required Animation<double> settleAnim,
    required Animation<double> pulseAnim,
    required bool isTop,
  }) {
    Color bgColor = value != null
        ? const Color(0xFF1C2128)
        : const Color(0xFF161B22).withOpacity(0.4);
    Color borderColor =
        value != null ? const Color(0xFF30363D) : const Color(0xFF21262D);
    Color textColor = const Color(0xFFE2E8F0);

    if (isHighlight) {
      if (phase == 'pushing' || phase == 'pushed') {
        bgColor = const Color(0xFF3B82F6).withOpacity(0.22);
        borderColor = const Color(0xFF3B82F6);
        textColor = const Color(0xFF93C5FD);
      } else if (phase == 'popping' || phase == 'popped') {
        bgColor = const Color(0xFFA78BFA).withOpacity(0.22);
        borderColor = const Color(0xFFA78BFA);
        textColor = const Color(0xFFA78BFA);
      }
    }

    Widget cell = Container(
      width: 120,
      height: 42,
      margin: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(
            color: borderColor, width: isHighlight ? 2 : 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: value != null
            ? Text(
                '$value',
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'monospace',
                ),
              )
            : const SizedBox.shrink(),
      ),
    );

    // Wrap top element in settle animation (push done)
    if (isHighlight && (phase == 'pushed') && operation == 'push') {
      cell = AnimatedBuilder(
        animation: settleAnim,
        builder: (_, child) =>
            Transform.scale(scale: settleAnim.value, child: child),
        child: cell,
      );
    }

    // Wrap top element in pulse animation (popping)
    if (isHighlight && phase == 'popping') {
      cell = AnimatedBuilder(
        animation: pulseAnim,
        builder: (_, child) =>
            Transform.scale(scale: pulseAnim.value, child: child),
        child: cell,
      );
    }

    return cell;
  }
}

// ── U-shape border painter ─────────────────────────────────────────────────
class _UBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF30363D)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    const r = 6.0;
    // Left side
    canvas.drawLine(
        const Offset(r, 0), Offset(r, size.height - r), paint);
    // Bottom
    canvas.drawLine(Offset(r, size.height - r),
        Offset(size.width - r, size.height - r), paint);
    // Right side
    canvas.drawLine(Offset(size.width - r, 0),
        Offset(size.width - r, size.height - r), paint);
  }

  @override
  bool shouldRepaint(_UBorderPainter old) => false;
}