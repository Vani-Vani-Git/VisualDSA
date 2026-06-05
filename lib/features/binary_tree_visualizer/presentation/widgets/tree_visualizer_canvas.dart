import 'package:flutter/material.dart';
import '../models/tree_node.dart';

// ── Layout node for painting ─────────────────────────────────────────────────
class _LayoutNode {
  final TreeNode node;
  final double x;
  final double y;
  _LayoutNode? leftChild;
  _LayoutNode? rightChild;
  _LayoutNode(this.node, this.x, this.y);
}

class TreeVisualizerCanvas extends StatelessWidget {
  final TreeNode? root;
  final int? highlightNode;
  final int? secondaryNode;
  final List<int> visitedOrder;
  final List<int> highlightPath;
  final TreePhase phase;
  final double height;

  const TreeVisualizerCanvas({
    super.key,
    required this.root,
    this.highlightNode,
    this.secondaryNode,
    this.visitedOrder = const [],
    this.highlightPath = const [],
    this.phase = TreePhase.idle,
    this.height = 260,
  });

  @override
  Widget build(BuildContext context) {
    if (root == null) {
      return Container(
        height: height,
        margin: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF161B22),
          border: Border.all(color: const Color(0xFF21262D)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.account_tree_outlined,
                  color: Color(0xFF30363D), size: 40),
              SizedBox(height: 8),
              Text(
                'No tree yet.\nEnter values and press Apply.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF4B5563),
                  fontSize: 13,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      height: height,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        border: Border.all(color: const Color(0xFF21262D)),
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.hardEdge,
      child: LayoutBuilder(
        builder: (_, constraints) {
          return CustomPaint(
            size: Size(constraints.maxWidth, height),
            painter: _TreePainter(
              root: root!,
              highlightNode: highlightNode,
              secondaryNode: secondaryNode,
              visitedOrder: visitedOrder,
              highlightPath: highlightPath,
              phase: phase,
            ),
          );
        },
      ),
    );
  }
}

class _TreePainter extends CustomPainter {
  final TreeNode root;
  final int? highlightNode;
  final int? secondaryNode;
  final List<int> visitedOrder;
  final List<int> highlightPath;
  final TreePhase phase;

  _TreePainter({
    required this.root,
    this.highlightNode,
    this.secondaryNode,
    required this.visitedOrder,
    required this.highlightPath,
    required this.phase,
  });

  // Tree depth helper
  int _depth(TreeNode? n) {
    if (n == null) return 0;
    return 1 + [_depth(n.left), _depth(n.right)].reduce((a, b) => a > b ? a : b);
  }

  // Build layout recursively
  _LayoutNode _buildLayout(
    TreeNode node,
    double x,
    double y,
    double hSpread,
    double levelH,
  ) {
    final ln = _LayoutNode(node, x, y);
    if (node.left != null) {
      ln.leftChild = _buildLayout(node.left!, x - hSpread, y + levelH, (hSpread *0.65).clamp(22.0,120.0), levelH);
    }
    if (node.right != null) {
      ln.rightChild = _buildLayout(node.right!, x + hSpread, y + levelH, (hSpread *0.65).clamp(22.0,120.0), levelH);
    }
    return ln;
  }

  void _drawEdges(Canvas canvas, _LayoutNode ln, Paint edgePaint) {
    if (ln.leftChild != null) {
      canvas.drawLine(
        Offset(ln.x, ln.y),
        Offset(ln.leftChild!.x, ln.leftChild!.y),
        edgePaint,
      );
      _drawEdges(canvas, ln.leftChild!, edgePaint);
    }
    if (ln.rightChild != null) {
      canvas.drawLine(
        Offset(ln.x, ln.y),
        Offset(ln.rightChild!.x, ln.rightChild!.y),
        edgePaint,
      );
      _drawEdges(canvas, ln.rightChild!, edgePaint);
    }
  }

  Color _nodeColor(_LayoutNode ln) {
    final v = ln.node.value;
    final isVisited = visitedOrder.contains(v);

    if (v == highlightNode) {
      switch (phase) {
        case TreePhase.inserting:
          return const Color(0xFF22C55E);
        case TreePhase.deleting:
          return const Color(0xFFEF4444);
        case TreePhase.replacing:
          return const Color(0xFF22C55E);
        case TreePhase.removingDeepest:
          return const Color(0xFFF59E0B);
        case TreePhase.visiting:
          return const Color(0xFF3B82F6);
        case TreePhase.comparing:
          return const Color(0xFFA78BFA);
        default:
          return const Color(0xFF3B82F6);
      }
    }
    if (v == secondaryNode && phase == TreePhase.replacing) {
      return const Color(0xFFF97316);
    }
    if (highlightPath.contains(v)) {
      return const Color(0xFF4B5563);
    }
    if (isVisited) {
      return const Color(0xFF22C55E);
    }
    return const Color(0xFF1C2128);
  }

  Color _nodeBorder(_LayoutNode ln) {
    final v = ln.node.value;
    if (v == highlightNode) {
      switch (phase) {
        case TreePhase.inserting:
          return const Color(0xFF22C55E);
        case TreePhase.deleting:
          return const Color(0xFFEF4444);
        case TreePhase.visiting:
          return const Color(0xFF3B82F6);
        case TreePhase.comparing:
          return const Color(0xFFA78BFA);
        default:
          return const Color(0xFF3B82F6);
      }
    }
    if (v == secondaryNode) return const Color(0xFFF97316);
    if (visitedOrder.contains(v)) return const Color(0xFF22C55E);
    if (highlightPath.contains(v)) return const Color(0xFF6B7280);
    return const Color(0xFF30363D);
  }

  void _drawNodes(Canvas canvas, _LayoutNode ln, double radius) {
    if (ln.leftChild != null) _drawNodes(canvas, ln.leftChild!, radius);
    if (ln.rightChild != null) _drawNodes(canvas, ln.rightChild!, radius);

    final bg = _nodeColor(ln);
    final border = _nodeBorder(ln);

    // Shadow glow for active node
    if (ln.node.value == highlightNode) {
      final glowPaint = Paint()
        ..color = border.withOpacity(0.25)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawCircle(Offset(ln.x, ln.y), radius + 4, glowPaint);
    }

    // Fill
    canvas.drawCircle(
      Offset(ln.x, ln.y),
      radius,
      Paint()..color = bg.withOpacity(0.95),
    );
    // Border
    canvas.drawCircle(
      Offset(ln.x, ln.y),
      radius,
      Paint()
        ..color = border
        ..style = PaintingStyle.stroke
        ..strokeWidth = ln.node.value == highlightNode ? 2.5 : 1.5,
    );

    // Value text
    final textColor = ln.node.value == highlightNode ||
            visitedOrder.contains(ln.node.value)
        ? Colors.white
        : const Color(0xFFE2E8F0);

    final tp = TextPainter(
      text: TextSpan(
        text: '${ln.node.value}',
        style: TextStyle(
          color: textColor,
          fontSize: radius * 0.72,
          fontWeight: FontWeight.w700,
          fontFamily: 'monospace',
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(
      canvas,
      Offset(ln.x - tp.width / 2, ln.y - tp.height / 2),
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final depth = _depth(root).clamp(1, 6);
    final levelH = (size.height - 40) / depth;
    final initSpread = size.width / (depth*1.8);
    final radius = (levelH * 0.32).clamp(18.0, 28.0);
    final topY = radius + 14;

    final layout = _buildLayout(root, size.width / 2, topY, initSpread, levelH);

    final edgePaint = Paint()
      ..color = const Color(0xFF30363D)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    _drawEdges(canvas, layout, edgePaint);
    _drawNodes(canvas, layout, radius);
  }

  @override
  bool shouldRepaint(_TreePainter old) => true;
}