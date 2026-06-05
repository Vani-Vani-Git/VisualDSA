import 'dart:math';
import 'package:flutter/material.dart';
import '../models/huffman_model.dart';

class HuffmanTreeCanvas extends StatelessWidget {
  final HuffStep? step;
  final double height;

  const HuffmanTreeCanvas({
    super.key,
    this.step,
    this.height = 300,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        border: Border.all(color: const Color(0xFF21262D)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: step == null ||
                (step!.type == HuffStepType.init && step!.root == null)
            ? const Center(
                child: Text(
                  'Enter a string and press Apply\nto visualize Huffman coding.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF4B5563),
                    fontSize: 12,
                    fontFamily: 'monospace',
                  ),
                ),
              )
            : LayoutBuilder(builder: (_, c) {
                return CustomPaint(
                  size: Size(c.maxWidth, height),
                  painter: _HuffPainter(
                    step: step!,
                    canvasSize: Size(c.maxWidth, height),
                  ),
                );
              }),
      ),
    );
  }
}

// ── Queue node row shown during build phase ───────────────────────────────────
class HuffQueueRow extends StatelessWidget {
  final HuffStep step;

  const HuffQueueRow({super.key, required this.step});

  @override
  Widget build(BuildContext context) {
    if (step.queue.isEmpty) return const SizedBox();
    // Sort by freq for display
    final sorted = List<HuffNode>.from(step.queue)
      ..sort((a, b) => a.freq.compareTo(b.freq));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Priority Queue (sorted by freq):',
            style: TextStyle(
                color: Color(0xFF8B949E),
                fontSize: 10,
                fontFamily: 'monospace')),
        const SizedBox(height: 4),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: sorted.map((n) {
              final isHL = step.highlightIds.contains(n.id);
              final color = isHL
                  ? const Color(0xFFF59E0B)
                  : n.isLeaf
                      ? const Color(0xFF3B82F6)
                      : const Color(0xFF9333EA);

              return Container(
                margin: const EdgeInsets.only(right: 6),
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  border: Border.all(
                      color: color, width: isHL ? 2 : 1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      n.char != null ? "'${n.char}'" : '●',
                      style: TextStyle(
                          color: color,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'monospace'),
                    ),
                    Text(
                      '${n.freq}',
                      style: TextStyle(
                          color: color.withOpacity(0.8),
                          fontSize: 10,
                          fontFamily: 'monospace'),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

// ── CustomPainter ─────────────────────────────────────────────────────────────
class _HuffPainter extends CustomPainter {
  final HuffStep step;
  final Size canvasSize;

  _HuffPainter({required this.step, required this.canvasSize});

  @override
  void paint(Canvas canvas, Size size) {
    // If tree is built, draw it
    final root = step.root;
    if (root == null) {
      // Draw queue cards during build phase
      _drawQueueCards(canvas, size);
      return;
    }

    // Layout the tree
    HuffmanGenerator.layoutTree(root, size.width, size.height);
    // Draw edges first
    _drawEdges(canvas, root);
    // Draw nodes
    _drawNodes(canvas, root);
  }

  void _drawQueueCards(Canvas canvas, Size size) {
    final sorted = List<HuffNode>.from(step.queue)
      ..sort((a, b) => a.freq.compareTo(b.freq));

    final count = sorted.length;
    if (count == 0) return;

    const cardW = 52.0;
    const cardH = 60.0;
    const gap = 10.0;
    final totalW = count * cardW + (count - 1) * gap;
    double x = max(8.0, (size.width - totalW) / 2);
    final y = (size.height - cardH) / 2;

    for (final n in sorted) {
      final isHL = step.highlightIds.contains(n.id);
      final isNew = step.newNode?.id == n.id;

      Color color;
      if (isNew) {
        color = const Color(0xFF22C55E);
      } else if (isHL) {
        color = const Color(0xFFF59E0B);
      } else if (n.isLeaf) {
        color = const Color(0xFF3B82F6);
      } else {
        color = const Color(0xFF9333EA);
      }

      final rect = RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, cardW, cardH),
          const Radius.circular(8));

      canvas.drawRRect(rect, Paint()..color = color.withOpacity(0.15));
      canvas.drawRRect(
          rect,
          Paint()
            ..color = color
            ..style = PaintingStyle.stroke
            ..strokeWidth = isHL || isNew ? 2.5 : 1.5);

      // Char label
      if (n.char != null) {
        _text(canvas, "'${n.char}'", Offset(x + cardW / 2, y + 18),
            color: color, fontSize: 13, bold: true);
      } else {
        _text(canvas, '●', Offset(x + cardW / 2, y + 18),
            color: color, fontSize: 12);
      }
      // Freq
      _text(canvas, '${n.freq}', Offset(x + cardW / 2, y + 38),
          color: color.withOpacity(0.85), fontSize: 12, bold: true);

      x += cardW + gap;
    }
  }

  void _drawEdges(Canvas canvas, HuffNode node) {
    const edgePadding = 20.0;

    void drawEdge(HuffNode parent, HuffNode child, String label) {
      final isHL = step.highlightIds.contains(parent.id) &&
          step.highlightIds.contains(child.id);

      final dx = child.x - parent.x;
      final dy = child.y - parent.y;
      final len = sqrt(dx * dx + dy * dy);
      if (len < 1) return;

      final ux = dx / len;
      final uy = dy / len;
      final start =
          Offset(parent.x + ux * edgePadding, parent.y + uy * edgePadding);
      final end =
          Offset(child.x - ux * edgePadding, child.y - uy * edgePadding);

      final color = isHL
          ? const Color(0xFFF59E0B)
          : step.type == HuffStepType.done ||
                  step.type == HuffStepType.assignCodes
              ? const Color(0xFF22C55E).withOpacity(0.6)
              : const Color(0xFF374151);

      canvas.drawLine(
          start,
          end,
          Paint()
            ..color = color
            ..strokeWidth = isHL ? 2.5 : 1.8
            ..style = PaintingStyle.stroke);

      // 0/1 label on edge
      final mid = Offset(
        (start.dx + end.dx) / 2,
        (start.dy + end.dy) / 2,
      );
      // Perpendicular offset
      final perpX = -uy * 10;
      final perpY = ux * 10;
      _text(
        canvas,
        label,
        Offset(mid.dx + perpX, mid.dy + perpY),
        color: isHL ? const Color(0xFFFBBF24) : const Color(0xFF6B7280),
        fontSize: 10,
        bold: true,
      );
    }

    void traverse(HuffNode n) {
      if (n.left != null) {
        drawEdge(n, n.left!, '0');
        traverse(n.left!);
      }
      if (n.right != null) {
        drawEdge(n, n.right!, '1');
        traverse(n.right!);
      }
    }

    traverse(node);
  }

  void _drawNodes(Canvas canvas, HuffNode root) {
    const nodeR = 20.0;

    void traverse(HuffNode n) {
      final isHL = step.highlightIds.contains(n.id);
      final isDone = step.type == HuffStepType.done;

      Color fill, stroke, textColor;

      if (isDone && n.isLeaf) {
        fill = const Color(0xFF22C55E).withOpacity(0.25);
        stroke = const Color(0xFF22C55E);
        textColor = const Color(0xFF4ADE80);
      } else if (isHL && n.isLeaf) {
        fill = const Color(0xFFF59E0B).withOpacity(0.25);
        stroke = const Color(0xFFF59E0B);
        textColor = const Color(0xFFFBBF24);
      } else if (isHL) {
        fill = const Color(0xFF9333EA).withOpacity(0.22);
        stroke = const Color(0xFFA855F7);
        textColor = const Color(0xFFD8B4FE);
      } else if (n.isLeaf) {
        fill = const Color(0xFF3B82F6).withOpacity(0.20);
        stroke = const Color(0xFF3B82F6);
        textColor = const Color(0xFF93C5FD);
      } else {
        fill = const Color(0xFF1D4ED8).withOpacity(0.12);
        stroke = const Color(0xFF374151);
        textColor = const Color(0xFF8B949E);
      }

      final pos = Offset(n.x, n.y);

      canvas.drawCircle(pos, nodeR, Paint()..color = fill);
      canvas.drawCircle(
          pos,
          nodeR,
          Paint()
            ..color = stroke
            ..style = PaintingStyle.stroke
            ..strokeWidth = isHL ? 2.5 : 2.0);

      // Freq inside circle
      _text(canvas, '${n.freq}', pos,
          color: textColor, fontSize: 11, bold: true);

      // Char label below leaf nodes
      if (n.isLeaf && n.char != null) {
        _text(
            canvas,
            "'${n.char}'",
            Offset(pos.dx, pos.dy + nodeR + 12),
            color: isDone
                ? const Color(0xFF4ADE80)
                : const Color(0xFF93C5FD),
            fontSize: 10,
            bold: true);
      }

      // Code label for done/assignCodes steps
      if (n.isLeaf && step.codes.containsKey(n.char)) {
        _text(
            canvas,
            step.codes[n.char]!,
            Offset(pos.dx, pos.dy + nodeR + 24),
            color: const Color(0xFFF59E0B),
            fontSize: 9,
            bold: true);
      }

      if (n.left != null) traverse(n.left!);
      if (n.right != null) traverse(n.right!);
    }

    traverse(root);
  }

  void _text(Canvas canvas, String text, Offset center,
      {Color color = Colors.white,
      double fontSize = 12,
      bool bold = false}) {
    final tp = TextPainter(
      text: TextSpan(
          text: text,
          style: TextStyle(
              color: color,
              fontSize: fontSize,
              fontWeight: bold ? FontWeight.w700 : FontWeight.normal,
              fontFamily: 'monospace')),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(_HuffPainter old) => true;
}