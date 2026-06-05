import 'package:flutter/material.dart';
import '../models/queue_step.dart';

class QueueCanvas extends StatefulWidget {
  // FIX: Accept non-nullable QueueStep — dashboard always provides _displayStep
  final QueueStep step;
  final int maxSize;

  const QueueCanvas({
    super.key,
    required this.step,
    this.maxSize = 7,
  });

  @override
  State<QueueCanvas> createState() => _QueueCanvasState();
}

class _QueueCanvasState extends State<QueueCanvas>
    with TickerProviderStateMixin {
  late AnimationController _enqCtrl;
  late Animation<double>   _enqSlide;
  late Animation<double>   _enqOpacity;

  late AnimationController _deqCtrl;
  late Animation<double>   _deqSlide;
  late Animation<double>   _deqOpacity;

  late AnimationController _settleCtrl;
  late Animation<double>   _settle;

  late AnimationController _pulseCtrl;
  late Animation<double>   _pulse;

  String? _lastPhase;
  String? _lastFloatingState;

  @override
  void initState() {
    super.initState();

    _enqCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _enqSlide = Tween<double>(begin: 1.0, end: 0.0)
        .animate(CurvedAnimation(parent: _enqCtrl, curve: Curves.easeOut));
    _enqOpacity = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _enqCtrl, curve: Curves.easeIn));

    _deqCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 480));
    _deqSlide = Tween<double>(begin: 0.0, end: -1.2)
        .animate(CurvedAnimation(parent: _deqCtrl, curve: Curves.easeIn));
    _deqOpacity = Tween<double>(begin: 1.0, end: 0.0)
        .animate(CurvedAnimation(parent: _deqCtrl, curve: Curves.easeIn));

    _settleCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 360));
    _settle = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.16), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 1.16, end: 0.94), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 0.94, end: 1.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _settleCtrl, curve: Curves.easeOut));

    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 550))
      ..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.88, end: 1.0)
        .animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
  }

  @override
  void didUpdateWidget(QueueCanvas old) {
    super.didUpdateWidget(old);
    final s     = widget.step;
    final fs    = s.floatingState;
    final phase = s.phase;

    if (fs == 'incoming' && _lastFloatingState != 'incoming') {
      _enqCtrl.forward(from: 0);
      _deqCtrl.reset();
    }
    if (phase == 'enqueued' && _lastPhase != 'enqueued') {
      _settleCtrl.forward(from: 0);
      _enqCtrl.reset();
    }
    if (phase == 'dequeuing' && _lastPhase != 'dequeuing') {
      _pulseCtrl.repeat(reverse: true);
    }
    if (fs == 'outgoing' && _lastFloatingState != 'outgoing') {
      _deqCtrl.forward(from: 0);
    }
    if (phase == 'dequeued' && _lastPhase != 'dequeued') {
      _pulseCtrl.stop();
      _deqCtrl.reset();
    }
    // Reset animations when op changes (idle phase from new _displayStep)
    if (phase == 'idle' && _lastPhase != 'idle') {
      _enqCtrl.reset();
      _deqCtrl.reset();
      _settleCtrl.reset();
      _pulseCtrl.stop();
    }

    _lastPhase         = phase;
    _lastFloatingState = fs;
  }

  @override
  void dispose() {
    _enqCtrl.dispose();
    _deqCtrl.dispose();
    _settleCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s     = widget.step;
    final queue = s.queue;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min, // FIX: don't expand beyond needed height
        children: [
          _buildStatusBanner(s),
          const SizedBox(height: 14),
          _buildQueueArea(queue, s),
          const SizedBox(height: 6),
          const Center(
            child: Text(
              'Queue  (front → rear)',
              style: TextStyle(
                color: Color(0xFF8B949E),
                fontSize: 11,
                fontFamily: 'monospace',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Status banner ──────────────────────────────────────────────────────────
  Widget _buildStatusBanner(QueueStep s) {
    Color bg, textColor;
    IconData icon;
    switch (s.phase) {
      case 'enqueued':
        bg        = const Color(0xFF22C55E).withOpacity(0.14);
        textColor = const Color(0xFF22C55E);
        icon      = Icons.check_circle_outline;
        break;
      case 'dequeued':
        bg        = const Color(0xFFF59E0B).withOpacity(0.14);
        textColor = const Color(0xFFF59E0B);
        icon      = Icons.output_rounded;
        break;
      case 'overflow':
      case 'underflow':
        bg        = const Color(0xFFEF4444).withOpacity(0.14);
        textColor = const Color(0xFFEF4444);
        icon      = Icons.warning_amber_rounded;
        break;
      case 'enqueuing':
        bg        = const Color(0xFF3B82F6).withOpacity(0.12);
        textColor = const Color(0xFF93C5FD);
        icon      = Icons.arrow_forward_rounded;
        break;
      case 'dequeuing':
        bg        = const Color(0xFFA78BFA).withOpacity(0.12);
        textColor = const Color(0xFFA78BFA);
        icon      = Icons.arrow_back_rounded;
        break;
      default: // idle
        bg        = const Color(0xFF3B82F6).withOpacity(0.07);
        textColor = const Color(0xFF8B949E);
        icon      = Icons.info_outline;
    }
    final msg = s.statusMsg.isNotEmpty
        ? s.statusMsg
        : 'Select an operation and press its button to begin.';
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
                  height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  // ── Full queue area ────────────────────────────────────────────────────────
  Widget _buildQueueArea(List<int> queue, QueueStep s) {
    return LayoutBuilder(builder: (_, constraints) {
      final maxW = constraints.maxWidth;
      const gap  = 4.0;
      final cellW =
          ((maxW - gap * (widget.maxSize - 1)) / widget.maxSize).clamp(34.0, 56.0);
      final cellH = cellW.clamp(42.0, 52.0);

      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildPointerRow(queue, s, cellW, gap),
          const SizedBox(height: 4),
          _buildRail(queue, s, cellW, cellH, gap),
          const SizedBox(height: 4),
          _buildIndexRow(queue, cellW, gap),
        ],
      );
    });
  }

  // ── Pointer labels ─────────────────────────────────────────────────────────
  Widget _buildPointerRow(
      List<int> queue, QueueStep s, double cellW, double gap) {
    if (queue.isEmpty) return const SizedBox(height: 28);

    const frontIdx = 0;
    final rearIdx  = queue.length - 1;

    return SizedBox(
      height: 28,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: List.generate(queue.length, (i) {
          final isFront = i == frontIdx;
          final isRear  = i == rearIdx;
          final both    = isFront && isRear;

          Widget label;
          if (both) {
            label = Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text('front',
                        style: TextStyle(
                            color: Color(0xFF22C55E),
                            fontSize: 9,
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.w700)),
                    SizedBox(width: 4),
                    Text('rear',
                        style: TextStyle(
                            color: Color(0xFFEF4444),
                            fontSize: 9,
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.w700)),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.arrow_downward, size: 11, color: Color(0xFF22C55E)),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_downward, size: 11, color: Color(0xFFEF4444)),
                  ],
                ),
              ],
            );
          } else if (isFront) {
            label = Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text('front',
                    style: TextStyle(
                        color: Color(0xFF22C55E),
                        fontSize: 9,
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w700)),
                Icon(Icons.arrow_downward, size: 11, color: Color(0xFF22C55E)),
              ],
            );
          } else if (isRear) {
            label = Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text('rear',
                    style: TextStyle(
                        color: Color(0xFFEF4444),
                        fontSize: 9,
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w700)),
                Icon(Icons.arrow_downward, size: 11, color: Color(0xFFEF4444)),
              ],
            );
          } else {
            label = const SizedBox.shrink();
          }

          return SizedBox(
            width: cellW + (i < queue.length - 1 ? gap : 0),
            child: Align(alignment: Alignment.bottomCenter, child: label),
          );
        }),
      ),
    );
  }

  // ── Rail ───────────────────────────────────────────────────────────────────
  // FIX: Removed Stack(clipBehavior: Clip.none) which caused the overflow.
  // The ejected element 'out' label is now placed ABOVE the rail in a separate
  // overlay row — not inside the SizedBox(height: cellH) Row.
  Widget _buildRail(List<int> queue, QueueStep s, double cellW,
      double cellH, double gap) {
    final phase = s.phase;
    final fs    = s.floatingState;
    final fv    = s.floatingValue;

    // ── Ejected element row (shown ABOVE the rail as overlay) ──────────────
    // Placed before the rail in a Column, not inside the rail's SizedBox
    final bool showEjected = fs == 'ejected' && fv != null;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Ejected element shown separately — NO overflow
        if (showEjected)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Spacer to push "out" element to the right of queue cells
                SizedBox(width: (cellW + gap) * queue.length),
                // The ejected cell with its label
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'out',
                      style: TextStyle(
                          color: Color(0xFFF59E0B),
                          fontSize: 9,
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    _buildCell(
                      value      : fv,
                      cellW      : cellW,
                      cellH      : cellH,
                      isHighlight: true,
                      phase      : 'dequeued',
                      operation  : 'dequeue',
                    ),
                  ],
                ),
              ],
            ),
          ),

        // Main rail with top/bottom lines
        Container(
          decoration: const BoxDecoration(
            border: Border(
              top   : BorderSide(color: Color(0xFF30363D), width: 1.5),
              bottom: BorderSide(color: Color(0xFF30363D), width: 1.5),
            ),
          ),
          child: SizedBox(
            height: cellH,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Existing queue cells
                ...List.generate(queue.length, (i) {
                  final isHighlight = s.highlightIdx == i;
                  final isDequeuing = phase == 'dequeuing' && i == 0;

                  Widget cell = _buildCell(
                    value      : queue[i],
                    cellW      : cellW,
                    cellH      : cellH,
                    isHighlight: isHighlight,
                    phase      : phase,
                    operation  : s.operation,
                  );

                  // Settle animation on newly enqueued rear element
                  if (isHighlight && phase == 'enqueued' && s.operation == 'enqueue') {
                    cell = AnimatedBuilder(
                      animation: _settle,
                      builder: (_, ch) =>
                          Transform.scale(scale: _settle.value, child: ch),
                      child: cell,
                    );
                  }

                  // Slide-out animation on front element being dequeued
                  if (isDequeuing && fs == 'outgoing') {
                    cell = AnimatedBuilder(
                      animation: _deqCtrl,
                      builder: (_, ch) => Transform.translate(
                        offset: Offset(_deqSlide.value * cellW, 0),
                        child: Opacity(opacity: _deqOpacity.value, child: ch),
                      ),
                      child: cell,
                    );
                  } else if (isDequeuing) {
                    // Pulse while highlighted
                    cell = AnimatedBuilder(
                      animation: _pulse,
                      builder: (_, ch) =>
                          Transform.scale(scale: _pulse.value, child: ch),
                      child: cell,
                    );
                  }

                  return Padding(
                    padding: EdgeInsets.only(right: i < queue.length - 1 ? gap : 0),
                    child: cell,
                  );
                }),

                // Enqueue incoming element (slides in from right)
                if ((fs == 'incoming' || fs == 'landing') && fv != null)
                  AnimatedBuilder(
                    animation: _enqCtrl,
                    builder: (_, child) {
                      final dx = _enqSlide.value * (cellW + gap);
                      return Transform.translate(
                        offset: Offset(dx, 0),
                        child: Opacity(opacity: _enqOpacity.value, child: child),
                      );
                    },
                    child: Padding(
                      padding: EdgeInsets.only(left: gap),
                      child: _buildCell(
                        value      : fv,
                        cellW      : cellW,
                        cellH      : cellH,
                        isHighlight: true,
                        phase      : 'enqueuing',
                        operation  : 'enqueue',
                        isFloating : true,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Single cell ────────────────────────────────────────────────────────────
  Widget _buildCell({
    required int    value,
    required double cellW,
    required double cellH,
    required bool   isHighlight,
    required String phase,
    required String operation,
    bool isFloating = false,
  }) {
    Color bgColor     = const Color(0xFF1C2128);
    Color borderColor = const Color(0xFF30363D);
    Color textColor   = const Color(0xFFE2E8F0);

    if (isHighlight || isFloating) {
      if (phase == 'enqueuing' || phase == 'enqueued') {
        bgColor     = const Color(0xFF22C55E).withOpacity(0.22);
        borderColor = const Color(0xFF22C55E);
        textColor   = const Color(0xFF22C55E);
      } else if (phase == 'dequeuing' || phase == 'dequeued') {
        bgColor     = const Color(0xFFA78BFA).withOpacity(0.22);
        borderColor = const Color(0xFFA78BFA);
        textColor   = const Color(0xFFA78BFA);
      } else if (phase == 'idle') {
        bgColor     = const Color(0xFF22C55E).withOpacity(0.12);
        borderColor = const Color(0xFF22C55E).withOpacity(0.5);
        textColor   = const Color(0xFF22C55E);
      }
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: cellW,
      height: cellH,
      decoration: BoxDecoration(
        color : bgColor,
        border: Border.all(
            color: borderColor, width: isHighlight || isFloating ? 2 : 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          '$value',
          style: TextStyle(
            color     : textColor,
            fontSize  : cellW > 48 ? 15 : 13,
            fontWeight: FontWeight.w800,
            fontFamily: 'monospace',
          ),
        ),
      ),
    );
  }

  // ── Index labels ───────────────────────────────────────────────────────────
  Widget _buildIndexRow(List<int> queue, double cellW, double gap) {
    if (queue.isEmpty) return const SizedBox(height: 14);
    return SizedBox(
      height: 14,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(queue.length, (i) {
          return SizedBox(
            width: cellW + (i < queue.length - 1 ? gap : 0),
            child: Text(
              '[$i]',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color     : Color(0xFFEF4444),
                fontSize  : 9,
                fontFamily: 'monospace',
                fontWeight: FontWeight.w600,
              ),
            ),
          );
        }),
      ),
    );
  }
}