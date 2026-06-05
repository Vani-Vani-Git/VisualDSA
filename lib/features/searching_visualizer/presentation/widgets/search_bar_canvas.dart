import 'dart:math';
import 'package:flutter/material.dart';
import '../models/search_step.dart';

class SearchBarCanvas extends StatelessWidget {
  final List<int> array;
  final String algorithm;
  final SearchStep? step;
  final int target;

  const SearchBarCanvas({
    super.key,
    required this.array,
    required this.algorithm,
    required this.target,
    this.step,
  });

  @override
  Widget build(BuildContext context) {
    final displayArray = step?.array ?? array;
    if (displayArray.isEmpty) return const SizedBox(height: 180);

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status message
          _buildStatusBanner(),
          const SizedBox(height: 10),
          // Key pointer row (linear/binary)
          if (algorithm != 'jump_search') _buildKeyPointer(displayArray),
          // Array cells
          _buildArrayRow(displayArray),
          const SizedBox(height: 4),
          // Pointer labels row (Low / Mid / High for binary; Cur for linear)
          _buildPointerLabels(displayArray),
          // Jump arcs (jump search only)
          if (algorithm == 'jump_search') _buildJumpArcArea(displayArray),
        ],
      ),
    );
  }

  // ── Status banner ──────────────────────────────────────────────────────────
  Widget _buildStatusBanner() {
    Color bg, textColor;
    IconData icon;

    switch (step?.phase) {
      case 'found':
        bg = const Color(0xFF22C55E).withOpacity(0.15);
        textColor = const Color(0xFF22C55E);
        icon = Icons.check_circle_outline;
        break;
      case 'not_found':
        bg = const Color(0xFFEF4444).withOpacity(0.15);
        textColor = const Color(0xFFEF4444);
        icon = Icons.cancel_outlined;
        break;
      case 'jumping':
        bg = const Color(0xFFF59E0B).withOpacity(0.15);
        textColor = const Color(0xFFF59E0B);
        icon = Icons.double_arrow;
        break;
      case 'scanning':
        bg = const Color(0xFF22D3EE).withOpacity(0.15);
        textColor = const Color(0xFF22D3EE);
        icon = Icons.search;
        break;
      default:
        bg = const Color(0xFF3B82F6).withOpacity(0.12);
        textColor = const Color(0xFF93C5FD);
        icon = Icons.info_outline;
    }

    final msg = step?.statusMsg.isNotEmpty == true
        ? step!.statusMsg
        : 'Enter a target and press Search to begin.';

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
          Icon(icon, color: textColor, size: 16),
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

  // ── Key pointer (shows target value floating above current cell) ───────────
  Widget _buildKeyPointer(List<int> displayArray) {
    final ci = step?.currentIdx;
    final n = displayArray.length;
    if (ci == null) return const SizedBox(height: 36);

    final isFound = step?.phase == 'found';
    final color = isFound ? const Color(0xFF22C55E) : const Color(0xFFEF4444);
    final label = isFound ? 'Equal ✓' : 'Not Equal';

    return LayoutBuilder(builder: (_, constraints) {
      final cellW = (constraints.maxWidth / n).clamp(28.0, 56.0);
      final offset = ci * cellW + cellW / 2;

      return SizedBox(
        height: 52,
        child: Stack(
          children: [
            Positioned(
              left: offset - 42,
              top: 0,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Key',
                          style: TextStyle(
                              color: color,
                              fontSize: 10,
                              fontFamily: 'monospace',
                              fontWeight: FontWeight.w700)),
                      const SizedBox(height: 2),
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: color, width: 2),
                          color: color.withOpacity(0.1),
                        ),
                        child: Center(
                          child: Text(
                            '$target',
                            style: TextStyle(
                                color: color,
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                fontFamily: 'monospace'),
                          ),
                        ),
                      ),
                      // Downward arrow
                      CustomPaint(
                        size: const Size(2, 8),
                        painter: _ArrowPainter(color),
                      ),
                    ],
                  ),
                  const SizedBox(width: 6),
                  Text(label,
                      style: TextStyle(
                          color: color,
                          fontSize: 11,
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  // ── Array row ──────────────────────────────────────────────────────────────
  Widget _buildArrayRow(List<int> displayArray) {
    final n = displayArray.length;
    return LayoutBuilder(builder: (_, constraints) {
      final cellW = (constraints.maxWidth / n).clamp(28.0, 56.0);
      final totalW = cellW * n;

      return SizedBox(
        width: totalW,
        child: Row(
          children: List.generate(n, (i) {
            return _buildCell(displayArray, i, cellW);
          }),
        ),
      );
    });
  }

  Widget _buildCell(List<int> arr, int i, double cellW) {
    final s = step;
    Color bgColor = const Color(0xFF1C2128);
    Color borderColor = const Color(0xFF30363D);
    Color textColor = const Color(0xFFE2E8F0);
    bool isActive = false;

    if (s != null) {
      final eliminated = s.eliminatedIndices.contains(i);

      if (s.foundIdx == i) {
        bgColor = const Color(0xFF22C55E).withOpacity(0.22);
        borderColor = const Color(0xFF22C55E);
        textColor = const Color(0xFF22C55E);
        isActive = true;
      } else if (s.mid == i && algorithm == 'binary_search') {
        bgColor = const Color(0xFF3B82F6).withOpacity(0.18);
        borderColor = const Color(0xFF3B82F6);
        textColor = const Color(0xFF93C5FD);
        isActive = true;
      } else if (s.currentIdx == i && s.phase == 'comparing') {
        bgColor = const Color(0xFFA78BFA).withOpacity(0.18);
        borderColor = const Color(0xFFA78BFA);
        textColor = const Color(0xFFA78BFA);
        isActive = true;
      } else if (s.currentIdx == i && s.phase == 'jumping') {
        bgColor = const Color(0xFFF59E0B).withOpacity(0.18);
        borderColor = const Color(0xFFF59E0B);
        textColor = const Color(0xFFF59E0B);
        isActive = true;
      } else if (s.currentIdx == i && s.phase == 'scanning') {
        bgColor = const Color(0xFF22D3EE).withOpacity(0.18);
        borderColor = const Color(0xFF22D3EE);
        textColor = const Color(0xFF22D3EE);
        isActive = true;
      } else if (s.linearScanRange != null &&
          i >= s.linearScanRange![0] &&
          i <= s.linearScanRange![1]) {
        bgColor = const Color(0xFF22D3EE).withOpacity(0.07);
        borderColor = const Color(0xFF22D3EE).withOpacity(0.4);
        textColor = const Color(0xFF22D3EE);
      } else if (s.jumpBlocks.contains(i)) {
        bgColor = const Color(0xFFF59E0B).withOpacity(0.07);
        borderColor = const Color(0xFFF59E0B).withOpacity(0.5);
        textColor = const Color(0xFFF59E0B);
      } else if (eliminated) {
        bgColor = const Color(0xFF161B22);
        borderColor = const Color(0xFF21262D);
        textColor = const Color(0xFF4B5563);
      }
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      width: cellW,
      height: cellW.clamp(36.0, 52.0),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: borderColor, width: isActive ? 2 : 1),
      ),
      child: Center(
        child: Text(
          '${arr[i]}',
          style: TextStyle(
            color: textColor,
            fontSize: cellW > 44 ? 14 : 11,
            fontWeight: FontWeight.w700,
            fontFamily: 'monospace',
          ),
        ),
      ),
    );
  }

  // ── Pointer labels below array ─────────────────────────────────────────────
  Widget _buildPointerLabels(List<int> displayArray) {
    final n = displayArray.length;
    final s = step;

    return LayoutBuilder(builder: (_, constraints) {
      final cellW = (constraints.maxWidth / n).clamp(28.0, 56.0);

      return SizedBox(
        height: 26,
        width: cellW * n,
        child: Stack(
          children: [
            // Index numbers
            ...List.generate(n, (i) {
              return Positioned(
                left: i * cellW,
                width: cellW,
                top: 0,
                child: Text(
                  '$i',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFFEF4444),
                    fontSize: 10,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }),
            // Algorithm-specific labels
            if (algorithm == 'binary_search' && s != null) ...[
              if (s.low != null)
                _pointerLabel(s.low!, cellW, 'Low=${s.low}',
                    const Color(0xFF22C55E)),
              if (s.high != null)
                _pointerLabel(s.high!, cellW, 'High=${s.high}',
                    const Color(0xFFEF4444)),
              if (s.mid != null)
                _pointerLabel(
                    s.mid!, cellW, 'Mid=${s.mid}', const Color(0xFF3B82F6)),
            ],
            if (algorithm == 'linear_search' && s?.currentIdx != null)
              _pointerLabel(s!.currentIdx!, cellW, 'Cur',
                  const Color(0xFFA78BFA)),
          ],
        ),
      );
    });
  }

  Widget _pointerLabel(int idx, double cellW, String label, Color color) {
    return Positioned(
      left: idx * cellW,
      width: cellW * (label.length > 6 ? 2 : 1),
      bottom: 0,
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontFamily: 'monospace',
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  // ── Jump arc area ──────────────────────────────────────────────────────────
  Widget _buildJumpArcArea(List<int> displayArray) {
    final n = displayArray.length;
    final blocks = step?.jumpBlocks ?? [];

    return LayoutBuilder(builder: (_, constraints) {
      final cellW = (constraints.maxWidth / n).clamp(28.0, 56.0);
      return SizedBox(
        height: 48,
        width: cellW * n,
        child: CustomPaint(
          painter: _JumpArcPainter(
            blocks: blocks,
            cellWidth: cellW,
            color: const Color(0xFFEF4444),
          ),
        ),
      );
    });
  }
}

// ── Arrow painter (key pointer downward stem) ──────────────────────────────
class _ArrowPainter extends CustomPainter {
  final Color color;
  _ArrowPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(size.width / 2, 0),
        Offset(size.width / 2, size.height), paint);
  }

  @override
  bool shouldRepaint(_ArrowPainter old) => old.color != color;
}

// ── Jump arc painter ───────────────────────────────────────────────────────
// Draws curved arcs between each consecutive pair of jump block boundaries,
// exactly like the video: red rounded arcs above the cells.
class _JumpArcPainter extends CustomPainter {
  final List<int> blocks;
  final double cellWidth;
  final Color color;

  _JumpArcPainter({
    required this.blocks,
    required this.cellWidth,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (blocks.length < 2) return;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < blocks.length - 1; i++) {
      final x1 = blocks[i] * cellWidth + cellWidth / 2;
      final x2 = blocks[i + 1] * cellWidth + cellWidth / 2;
      final midX = (x1 + x2) / 2;
      final arcH = min(size.height * 0.8, (x2 - x1) * 0.4);

      final path = Path()
        ..moveTo(x1, size.height)
        ..quadraticBezierTo(midX, size.height - arcH, x2, size.height);
      canvas.drawPath(path, paint);

      // Draw small circle at each boundary
      canvas.drawCircle(Offset(x1, size.height), 4, Paint()..color = color);
    }
    // Last block dot
    if (blocks.isNotEmpty) {
      canvas.drawCircle(
          Offset(blocks.last * cellWidth + cellWidth / 2, size.height),
          4,
          Paint()..color = color);
    }
  }

  @override
  bool shouldRepaint(_JumpArcPainter old) =>
      old.blocks != blocks || old.cellWidth != cellWidth;
}