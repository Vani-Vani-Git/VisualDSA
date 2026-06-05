import 'dart:math';
import 'package:flutter/material.dart';
import '../models/heap_step.dart';

class HeapCanvas extends StatefulWidget {
  final HeapStep? step;

  const HeapCanvas({super.key, this.step});

  @override
  State<HeapCanvas> createState() => _HeapCanvasState();
}

class _HeapCanvasState extends State<HeapCanvas>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600))
      ..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.88, end: 1.0)
        .animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.step;
    final heap = s?.heap ?? [];

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatusBanner(s),
          const SizedBox(height: 10),
          if (heap.isEmpty)
            _buildEmptyState(s)
          else
            _buildTree(heap, s),
          if ((s?.sortedArray ?? []).isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildSortedRow(s!.sortedArray),
          ],
        ],
      ),
    );
  }

  // ── Status banner ──────────────────────────────────────────────────────────
  Widget _buildStatusBanner(HeapStep? s) {
    Color bg, tc;
    IconData icon;
    switch (s?.phase) {
      case 'inserted':
      case 'updated':
        bg   = const Color(0xFF22C55E).withOpacity(0.14);
        tc   = const Color(0xFF22C55E);
        icon = Icons.check_circle_outline;
        break;
      case 'deleted':
        bg   = const Color(0xFFF59E0B).withOpacity(0.14);
        tc   = const Color(0xFFF59E0B);
        icon = Icons.delete_outline;
        break;
      case 'sorted':
        bg   = const Color(0xFF22C55E).withOpacity(0.14);
        tc   = const Color(0xFF22C55E);
        icon = Icons.done_all;
        break;
      case 'swapping_up':
      case 'swapping_down':
        bg   = const Color(0xFFEF4444).withOpacity(0.12);
        tc   = const Color(0xFFEF4444);
        icon = Icons.swap_vert;
        break;
      case 'heapify_up':
      case 'heapify_down':
        bg   = const Color(0xFF3B82F6).withOpacity(0.12);
        tc   = const Color(0xFF93C5FD);
        icon = Icons.unfold_more;
        break;
      case 'sorting':
        bg   = const Color(0xFFF59E0B).withOpacity(0.12);
        tc   = const Color(0xFFF59E0B);
        icon = Icons.sort;
        break;
      case 'inserting':
        bg   = const Color(0xFF3B82F6).withOpacity(0.10);
        tc   = const Color(0xFF93C5FD);
        icon = Icons.add_circle_outline;
        break;
      case 'overflow':
      case 'underflow':
        bg   = const Color(0xFFEF4444).withOpacity(0.14);
        tc   = const Color(0xFFEF4444);
        icon = Icons.warning_amber_rounded;
        break;
      default:
        bg   = const Color(0xFF3B82F6).withOpacity(0.07);
        tc   = const Color(0xFF8B949E);
        icon = Icons.info_outline;
    }
    final msg = s?.statusMsg.isNotEmpty == true
        ? s!.statusMsg
        : 'Apply an array or select an operation to begin.';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: tc.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: tc, size: 15),
          const SizedBox(width: 8),
          Expanded(
            child: Text(msg,
                style: TextStyle(
                    color: tc,
                    fontSize: 11,
                    fontFamily: 'monospace',
                    height: 1.4)),
          ),
        ],
      ),
    );
  }

  // ── Empty state ────────────────────────────────────────────────────────────
  Widget _buildEmptyState(HeapStep? s) {
    return Container(
      height: 160,
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.account_tree_outlined,
              color: const Color(0xFF30363D), size: 44),
          const SizedBox(height: 8),
          Text(
            s?.heapType == 'min'
                ? 'Min-Heap — Empty'
                : 'Max-Heap — Empty',
            style: const TextStyle(
                color: Color(0xFF4B5563),
                fontSize: 13,
                fontFamily: 'monospace'),
          ),
        ],
      ),
    );
  }

  // ── Tree widget ────────────────────────────────────────────────────────────
  Widget _buildTree(List<int> heap, HeapStep? s) {
    return LayoutBuilder(builder: (_, constraints) {
      final maxW = constraints.maxWidth;
      final levels = (log(heap.length + 1) / log(2)).ceil();
      // Tighter node size for mobile
      const nodeR = 20.0;
      const levelH = 56.0;
      final totalH = levels * levelH + nodeR * 2;

      return SizedBox(
        height: totalH.clamp(80.0, 320.0),
        child: AnimatedBuilder(
          animation: _pulse,
          builder: (_, __) {
            return CustomPaint(
              size: Size(maxW, totalH.clamp(80.0, 320.0)),
              painter: _HeapTreePainter(
                heap: heap,
                step: s,
                nodeRadius: nodeR,
                levelHeight: levelH,
                pulseScale: _pulse.value,
              ),
            );
          },
        ),
      );
    });
  }

  // ── Sorted array row (heap sort) ───────────────────────────────────────────
  Widget _buildSortedRow(List<int> sorted) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFF22C55E).withOpacity(0.08),
        border: Border.all(color: const Color(0xFF22C55E).withOpacity(0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Text('Sorted: ',
              style: TextStyle(
                  color: Color(0xFF22C55E),
                  fontSize: 11,
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.w700)),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: sorted
                    .map((v) => Container(
                          margin: const EdgeInsets.only(right: 4),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color:
                                const Color(0xFF22C55E).withOpacity(0.18),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                                color: const Color(0xFF22C55E)
                                    .withOpacity(0.5)),
                          ),
                          child: Text('$v',
                              style: const TextStyle(
                                  color: Color(0xFF22C55E),
                                  fontSize: 12,
                                  fontFamily: 'monospace',
                                  fontWeight: FontWeight.w700)),
                        ))
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Custom painter for the heap tree ──────────────────────────────────────────
class _HeapTreePainter extends CustomPainter {
  final List<int> heap;
  final HeapStep? step;
  final double nodeRadius;
  final double levelHeight;
  final double pulseScale;

  _HeapTreePainter({
    required this.heap,
    required this.step,
    required this.nodeRadius,
    required this.levelHeight,
    required this.pulseScale,
  });

  // Compute x position of node i
  Offset _nodePos(int i, double totalW) {
    final level = (log(i + 1) / log(2)).floor();
    final posInLevel = i - ((1 << level) - 1);
    final nodesInLevel = (1 << level);
    final segW = totalW / nodesInLevel;
    final x = segW * posInLevel + segW / 2;
    final y = level * levelHeight + nodeRadius + 4;
    return Offset(x, y);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final n = heap.length;
    final s = step;
    final hA = s?.highlightA;
    final hB = s?.highlightB;
    final sorted = s?.sortedIndices ?? {};

    // ── Draw edges first ───────────────────────────────────────────────
    for (int i = 0; i < n; i++) {
      final left  = 2 * i + 1;
      final right = 2 * i + 2;

      for (final child in [left, right]) {
        if (child >= n) continue;
        final p1 = _nodePos(i, size.width);
        final p2 = _nodePos(child, size.width);

        final isSorted = sorted.contains(i) || sorted.contains(child);
        final isActive = (i == hA && child == hB) ||
            (i == hB && child == hA);

        final edgePaint = Paint()
          ..color = isSorted
              ? const Color(0xFF22C55E).withOpacity(0.35)
              : isActive
                  ? const Color(0xFFEF4444).withOpacity(0.8)
                  : const Color(0xFF4B5563)
          ..strokeWidth = isActive ? 2.0 : 1.5
          ..style = PaintingStyle.stroke;

        canvas.drawLine(p1, p2, edgePaint);

        // Draw swap symbol on active edge
        if (isActive && (s?.showSwap ?? false)) {
          final mid = Offset((p1.dx + p2.dx) / 2, (p1.dy + p2.dy) / 2);
          final tp = TextPainter(
            text: TextSpan(
              text: s?.swapSymbol ?? '≥',
              style: const TextStyle(
                color: Color(0xFFEF4444),
                fontSize: 14,
                fontWeight: FontWeight.w900,
                fontFamily: 'monospace',
              ),
            ),
            textDirection: TextDirection.ltr,
          )..layout();
          tp.paint(canvas,
              Offset(mid.dx - tp.width / 2, mid.dy - tp.height / 2));
        }
      }
    }

    // ── Draw nodes ─────────────────────────────────────────────────────
    for (int i = 0; i < n; i++) {
      final pos = _nodePos(i, size.width);
      final isSorted  = sorted.contains(i);
      final isHighA   = i == hA;
      final isHighB   = i == hB;
      final isSwap    = (isHighA || isHighB) &&
          (s?.phase == 'swapping_up' || s?.phase == 'swapping_down' ||
              (s?.phase == 'sorting' && s?.showSwap == true));
      final isSettled = isHighA &&
          (s?.phase == 'inserted' || s?.phase == 'updated' ||
              s?.phase == 'heapify_up' || s?.phase == 'heapify_down');

      // Determine colour
      Color fillColor, borderColor, textColor;
      if (isSorted) {
        fillColor   = const Color(0xFF22C55E).withOpacity(0.25);
        borderColor = const Color(0xFF22C55E);
        textColor   = const Color(0xFF22C55E);
      } else if (isSwap) {
        fillColor   = const Color(0xFFEF4444).withOpacity(0.85);
        borderColor = const Color(0xFFEF4444);
        textColor   = Colors.white;
      } else if (isSettled) {
        fillColor   = const Color(0xFF22C55E).withOpacity(0.80);
        borderColor = const Color(0xFF22C55E);
        textColor   = Colors.white;
      } else if (isHighA && s?.phase == 'sorting') {
        // Root being extracted
        fillColor   = const Color(0xFFF59E0B).withOpacity(0.85);
        borderColor = const Color(0xFFF59E0B);
        textColor   = Colors.white;
      } else if (isHighA || isHighB) {
        fillColor   = const Color(0xFF3B82F6).withOpacity(0.22);
        borderColor = const Color(0xFF3B82F6);
        textColor   = const Color(0xFF93C5FD);
      } else {
        fillColor   = const Color(0xFF1C2128);
        borderColor = const Color(0xFF4B5563);
        textColor   = const Color(0xFFE2E8F0);
      }

      // Scale for pulse on swap nodes
      double scale = 1.0;
      if (isSwap) scale = pulseScale;

      canvas.save();
      canvas.translate(pos.dx, pos.dy);
      canvas.scale(scale);

      // Circle
      final fillPaint = Paint()
        ..color = fillColor
        ..style = PaintingStyle.fill;
      final borderPaint = Paint()
        ..color = borderColor
        ..strokeWidth = isSwap || isSettled ? 2.2 : 1.5
        ..style = PaintingStyle.stroke;

      canvas.drawCircle(Offset.zero, nodeRadius, fillPaint);
      canvas.drawCircle(Offset.zero, nodeRadius, borderPaint);

      // Value text
      final tp = TextPainter(
        text: TextSpan(
          text: '${heap[i]}',
          style: TextStyle(
            color: textColor,
            fontSize: heap[i] > 99 ? 9 : 11,
            fontWeight: FontWeight.w800,
            fontFamily: 'monospace',
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(
          canvas, Offset(-tp.width / 2, -tp.height / 2));

      canvas.restore();

      // Index label below node (red, like videos)
      final idxPainter = TextPainter(
        text: TextSpan(
          text: '$i',
          style: const TextStyle(
            color: Color(0xFFEF4444),
            fontSize: 9,
            fontFamily: 'monospace',
            fontWeight: FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      idxPainter.paint(
          canvas,
          Offset(pos.dx - idxPainter.width / 2,
              pos.dy + nodeRadius + 2));
    }
  }

  @override
  bool shouldRepaint(_HeapTreePainter old) => true;
}