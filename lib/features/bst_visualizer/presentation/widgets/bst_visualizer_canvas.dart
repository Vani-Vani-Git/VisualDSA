import 'package:flutter/material.dart';
import '../models/bst_node.dart';

// ── Layout helper ─────────────────────────────────────────────────────────────
class _LNode {
  final BSTNode node;
  double x;
  double y;
  _LNode? left;
  _LNode? right;
  _LNode(this.node, this.x, this.y);
}

class BSTVisualizerCanvas extends StatelessWidget {
  final BSTNode? root;
  final BSTStep? step;
  final double height;

  const BSTVisualizerCanvas({
    super.key,
    required this.root,
    this.step,
    this.height = 270,
  });

  @override
  Widget build(BuildContext context) {
    if (root == null && step?.root == null) {
      return Container(
        height: height,
        margin: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFEEEEEE),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFCCCCCC)),
        ),
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.account_tree_outlined,
                  color: Color(0xFFAAAAAA), size: 38),
              SizedBox(height: 8),
              Text(
                'No tree yet.\nEnter values and press Apply.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF888888),
                  fontSize: 13,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
        ),
      );
    }

    final displayRoot = step?.root ?? root;

    return Container(
      height: height,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        // Light gray canvas exactly like the video background
        color: const Color(0xFFEAEAEA),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFCCCCCC)),
      ),
      clipBehavior: Clip.hardEdge,
      child: LayoutBuilder(builder: (_, constraints) {
        return CustomPaint(
          size: Size(constraints.maxWidth, height),
          painter: _BSTPainter(
            root: displayRoot!,
            step: step,
          ),
        );
      }),
    );
  }
}

class _BSTPainter extends CustomPainter {
  final BSTNode root;
  final BSTStep? step;

  _BSTPainter({required this.root, this.step});

  int _depth(BSTNode? n) {
    if (n == null) return 0;
    final l = _depth(n.left);
    final r = _depth(n.right);
    return 1 + (l > r ? l : r);
  }

  // Assign x positions using in-order counter for even spacing
  int _xCounter = 0;
  void _assignX(_LNode? ln, double cellW) {
    if (ln == null) return;
    _assignX(ln.left, cellW);
    ln.x = _xCounter * cellW + cellW / 2;
    _xCounter++;
    _assignX(ln.right, cellW);
  }

  _LNode _buildLayout(BSTNode node, double y, double levelH) {
    final ln = _LNode(node, 0, y);
    if (node.left != null) {
      ln.left = _buildLayout(node.left!, y + levelH, levelH);
    }
    if (node.right != null) {
      ln.right = _buildLayout(node.right!, y + levelH, levelH);
    }
    return ln;
  }

  int _countNodes(BSTNode? n) {
    if (n == null) return 0;
    return 1 + _countNodes(n.left) + _countNodes(n.right);
  }

  void _drawEdges(Canvas canvas, _LNode ln, Paint p) {
    if (ln.left != null) {
      canvas.drawLine(Offset(ln.x, ln.y), Offset(ln.left!.x, ln.left!.y), p);
      _drawEdges(canvas, ln.left!, p);
    }
    if (ln.right != null) {
      canvas.drawLine(Offset(ln.x, ln.y), Offset(ln.right!.x, ln.right!.y), p);
      _drawEdges(canvas, ln.right!, p);
    }
  }

  void _collectNodes(_LNode ln, List<_LNode> list) {
    list.add(ln);
    if (ln.left != null) _collectNodes(ln.left!, list);
    if (ln.right != null) _collectNodes(ln.right!, list);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final s = step;
    final depth = _depth(root).clamp(1, 7);
    final nodeCount = _countNodes(root).clamp(1, 63);
    final levelH = (size.height - 32) / depth;
    final radius = (levelH * 0.28).clamp(16.0, 26.0);

    // Cell width for evenly spaced in-order layout
    final cellW = (size.width / (nodeCount + 1)).clamp(28.0, 54.0);

    _xCounter = 0;
    final layout = _buildLayout(root, radius + 14, levelH);
    _assignX(layout, cellW);

    // Center the whole tree
    final allNodes = <_LNode>[];
    _collectNodes(layout, allNodes);
    if (allNodes.isEmpty) return;
    final minX = allNodes.map((n) => n.x).reduce((a, b) => a < b ? a : b);
    final maxX = allNodes.map((n) => n.x).reduce((a, b) => a > b ? a : b);
    final treeW = maxX - minX;
    final offsetX = (size.width - treeW) / 2 - minX;
    for (final n in allNodes) n.x += offsetX;

    // Draw dashed edge for deleted node
    if (s?.deletedNode != null) {
      final dashedPaint = Paint()
        ..color = const Color(0xFF999999)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke;
      _drawDashedEdges(canvas, layout, s!.deletedNode!, dashedPaint);
    }

    // Draw normal edges
    final edgePaint = Paint()
      ..color = const Color(0xFF555555)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    _drawEdgesExcluding(canvas, layout, s?.deletedNode, edgePaint);

    // Draw nodes
    for (final ln in allNodes) {
      _drawNode(canvas, ln, radius, s, size);
    }
  }

  void _drawEdgesExcluding(
      Canvas canvas, _LNode ln, int? excludeVal, Paint p) {
    if (ln.left != null) {
      final skipLeft = ln.left!.node.value == excludeVal;
      if (!skipLeft) {
        canvas.drawLine(
            Offset(ln.x, ln.y), Offset(ln.left!.x, ln.left!.y), p);
        _drawEdgesExcluding(canvas, ln.left!, excludeVal, p);
      }
    }
    if (ln.right != null) {
      final skipRight = ln.right!.node.value == excludeVal;
      if (!skipRight) {
        canvas.drawLine(
            Offset(ln.x, ln.y), Offset(ln.right!.x, ln.right!.y), p);
        _drawEdgesExcluding(canvas, ln.right!, excludeVal, p);
      }
    }
  }

  void _drawDashedEdges(Canvas canvas, _LNode ln, int deletedVal, Paint p) {
    void drawDashed(Offset p1, Offset p2) {
      const dashLen = 5.0;
      const gapLen = 4.0;
      final dx = p2.dx - p1.dx;
      final dy = p2.dy - p1.dy;
      final dist = (dx * dx + dy * dy) * 0.5;
      if (dist == 0) return;
      final ux = dx / dist;
      final uy = dy / dist;
      double d = 0;
      bool drawing = true;
      while (d < dist) {
        final end = (d + (drawing ? dashLen : gapLen)).clamp(0, dist);
        if (drawing) {
          canvas.drawLine(
            Offset(p1.dx + ux * d, p1.dy + uy * d),
            Offset(p1.dx + ux * end, p1.dy + uy * end),
            p,
          );
        }
        d = end as double;
        drawing = !drawing;
      }
    }

    if (ln.right != null && ln.right!.node.value == deletedVal) {
      drawDashed(Offset(ln.x, ln.y), Offset(ln.right!.x, ln.right!.y));
    }
    if (ln.left != null && ln.left!.node.value == deletedVal) {
      drawDashed(Offset(ln.x, ln.y), Offset(ln.left!.x, ln.left!.y));
    }
    if (ln.left != null) _drawDashedEdges(canvas, ln.left!, deletedVal, p);
    if (ln.right != null) _drawDashedEdges(canvas, ln.right!, deletedVal, p);
  }

  void _drawNode(Canvas canvas, _LNode ln, double radius, BSTStep? s, Size size) {
    final val = ln.node.value;
    final isCurr = s?.currNode == val;
    final isTemp = s?.tempNode == val;
    final isDeleted = s?.deletedNode == val;
    final isNew = s?.newNode == val;
    final isVisited = s?.visitedPath.contains(val) ?? false;
    final isFound = s?.phase == BSTPhase.found && s?.currNode == val;

    // Node fill color — matching video: light green for visited/active, white-ish idle
    Color fill;
    Color border;

    if (isDeleted) {
      fill = const Color(0xFFFFFFFF).withOpacity(0.4);
      border = const Color(0xFF999999);
    } else if (isFound) {
      fill = const Color(0xFF81C784); // brighter green for found
      border = const Color(0xFF388E3C);
    } else if (isNew) {
      fill = const Color(0xFFA5D6A7);
      border = const Color(0xFF4CAF50);
    } else if (isCurr) {
      fill = const Color(0xFFA5D6A7);
      border = const Color(0xFF4CAF50);
    } else if (isVisited) {
      fill = const Color(0xFFC8E6C9);
      border = const Color(0xFF66BB6A);
    } else {
      // Idle nodes — light green fill like video
      fill = const Color(0xFFD4EDDA);
      border = const Color(0xFF7CB97E);
    }

    final nodeRadius = isCurr || isNew || isFound ? radius + 1.5 : radius;

    // Deleted node — dashed circle
    if (isDeleted) {
      final dashedCirclePaint = Paint()
        ..color = const Color(0xFF888888)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      _drawDashedCircle(canvas, Offset(ln.x, ln.y), nodeRadius, dashedCirclePaint);
    } else {
      // Shadow for active node
      if (isCurr || isNew || isFound) {
        canvas.drawCircle(
          Offset(ln.x + 1, ln.y + 2),
          nodeRadius,
          Paint()..color = Colors.black.withOpacity(0.10),
        );
      }
      // Fill
      canvas.drawCircle(Offset(ln.x, ln.y), nodeRadius,
          Paint()..color = fill);
      // Border
      canvas.drawCircle(
        Offset(ln.x, ln.y),
        nodeRadius,
        Paint()
          ..color = border
          ..style = PaintingStyle.stroke
          ..strokeWidth = isCurr || isFound ? 2.0 : 1.5,
      );
    }

    // Value text
    final textColor = isDeleted
        ? const Color(0xFFAAAAAA)
        : const Color(0xFF1A1A1A);

    final tp = TextPainter(
      text: TextSpan(
        text: '$val',
        style: TextStyle(
          color: textColor,
          fontSize: nodeRadius * 0.78,
          fontWeight: FontWeight.w700,
          fontFamily: 'Roboto',
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(ln.x - tp.width / 2, ln.y - tp.height / 2));

    // ── currNode arrow label ─────────────────────────────────────────────
    if (isCurr) {
      _drawArrowLabel(
        canvas,
        label: 'currNode',
        nodeCenter: Offset(ln.x, ln.y),
        nodeRadius: nodeRadius,
        fromLeft: ln.x > size.width / 2,
        labelColor: const Color(0xFF1A1A1A),
      );
    }

    // ── temp arrow label ─────────────────────────────────────────────────
    if (isTemp && !isCurr) {
      _drawArrowLabel(
        canvas,
        label: 'temp',
        nodeCenter: Offset(ln.x, ln.y),
        nodeRadius: nodeRadius,
        fromLeft: false, // temp always points from right ← like video
        arrowFromRight: true,
        labelColor: const Color(0xFF1A1A1A),
      );
    }
  }

  void _drawArrowLabel(
    Canvas canvas, {
    required String label,
    required Offset nodeCenter,
    required double nodeRadius,
    required bool fromLeft,
    bool arrowFromRight = false,
    required Color labelColor,
  }) {
    const arrowLen = 36.0;
    const gap = 4.0;

    final tp = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          color: labelColor,
          fontSize: 10,
          fontWeight: FontWeight.w600,
          fontFamily: 'Roboto',
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final paint = Paint()
      ..color = labelColor
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;

    if (arrowFromRight) {
      // "temp ←" pointing left into node from right side
      final arrowEnd = Offset(nodeCenter.dx + nodeRadius + gap, nodeCenter.dy);
      final arrowStart = Offset(arrowEnd.dx + arrowLen, arrowEnd.dy);
      canvas.drawLine(arrowStart, arrowEnd, paint);
      // Arrowhead pointing left
      _drawArrowHead(canvas, arrowEnd, arrowStart, paint..color = labelColor);
      tp.paint(canvas,
          Offset(arrowStart.dx + 4, arrowStart.dy - tp.height / 2));
    } else {
      // "currNode →" pointing right into node from left side
      final arrowEnd = Offset(nodeCenter.dx - nodeRadius - gap, nodeCenter.dy);
      final arrowStart = Offset(arrowEnd.dx - arrowLen, arrowEnd.dy);
      canvas.drawLine(arrowStart, arrowEnd, paint);
      // Arrowhead pointing right
      _drawArrowHead(canvas, arrowEnd, arrowStart, paint..color = labelColor);
      tp.paint(canvas,
          Offset(arrowStart.dx - tp.width - 4, arrowStart.dy - tp.height / 2));
    }
  }

  void _drawArrowHead(Canvas canvas, Offset tip, Offset from, Paint paint) {
    final dx = tip.dx - from.dx;
    final dy = tip.dy - from.dy;
    final len = (dx * dx + dy * dy) * 0.5;
    if (len == 0) return;
    final ux = dx / len;
    final uy = dy / len;
    const size = 7.0;
    const angle = 0.45;
    final p1 = Offset(
      tip.dx - size * (ux * _cos(angle) - uy * _sin(angle)),
      tip.dy - size * (uy * _cos(angle) + ux * _sin(angle)),
    );
    final p2 = Offset(
      tip.dx - size * (ux * _cos(angle) + uy * _sin(angle)),
      tip.dy - size * (uy * _cos(angle) - ux * _sin(angle)),
    );
    canvas.drawLine(tip, p1, paint..style = PaintingStyle.stroke);
    canvas.drawLine(tip, p2, paint);
  }

  double _cos(double a) => a < 0.5 ? 1 - a * a : 0.877;
  double _sin(double a) => a < 0.5 ? a * 1.8 : 0.479;

  void _drawDashedCircle(
      Canvas canvas, Offset center, double radius, Paint paint) {
    const segments = 20;
    const dashRatio = 0.6;
    for (int i = 0; i < segments; i++) {
      if (i % 2 == 0) {
        final startAngle = (i / segments) * 2 * 3.14159;
        final sweepAngle = (dashRatio / segments) * 2 * 3.14159;
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          startAngle,
          sweepAngle,
          false,
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_BSTPainter old) => true;
}