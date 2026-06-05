import 'dart:math';
import 'package:flutter/material.dart';
import '../models/graph_model.dart';

class GraphCanvas extends StatelessWidget {
  final GraphModel? graph;
  final int? highlightEdgeFrom;
  final int? highlightEdgeTo;
  final int? highlightVertex;

  const GraphCanvas({
    super.key,
    this.graph,
    this.highlightEdgeFrom,
    this.highlightEdgeTo,
    this.highlightVertex,
  });

  @override
  Widget build(BuildContext context) {
    if (graph == null) {
      return Container(
        height: 220,
        decoration: BoxDecoration(
          color: const Color(0xFF161B22),
          border: Border.all(color: const Color(0xFF21262D)),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Center(
          child: Text(
            'Create or load a graph to visualize',
            style: TextStyle(
              color: Color(0xFF4B5563),
              fontSize: 13,
              fontFamily: 'monospace',
            ),
          ),
        ),
      );
    }

    return Container(
      height: 220,
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        border: Border.all(color: const Color(0xFF21262D)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: LayoutBuilder(builder: (_, constraints) {
          return CustomPaint(
            size: Size(constraints.maxWidth, 220),
            painter: _GraphPainter(
              graph: graph!,
              highlightEdgeFrom: highlightEdgeFrom,
              highlightEdgeTo: highlightEdgeTo,
              highlightVertex: highlightVertex,
              canvasSize: Size(constraints.maxWidth, 220),
            ),
          );
        }),
      ),
    );
  }
}

class _GraphPainter extends CustomPainter {
  final GraphModel graph;
  final int? highlightEdgeFrom;
  final int? highlightEdgeTo;
  final int? highlightVertex;
  final Size canvasSize;

  _GraphPainter({
    required this.graph,
    this.highlightEdgeFrom,
    this.highlightEdgeTo,
    this.highlightVertex,
    required this.canvasSize,
  });

  // Scale vertex positions to fit canvas
  Offset _scale(Offset original, Size orig) {
    final sx = canvasSize.width / orig.width;
    final sy = canvasSize.height / orig.height;
    return Offset(original.dx * sx, original.dy * sy);
  }

  @override
  void paint(Canvas canvas, Size size) {
    const origSize = Size(300, 220);
    Offset pos(int id) {
      final v = graph.vertices.firstWhere((v) => v.id == id);
      return _scale(v.position, origSize);
    }

    // Draw edges
    for (final edge in graph.edges) {
      final isHighlighted =
          edge.from == highlightEdgeFrom && edge.to == highlightEdgeTo ||
              (!graph.properties.directed &&
                  edge.from == highlightEdgeTo &&
                  edge.to == highlightEdgeFrom);

      final edgeColor =
          isHighlighted ? const Color(0xFF22C55E) : const Color(0xFF60A5FA);
      final edgePaint = Paint()
        ..color = edgeColor
        ..strokeWidth = isHighlighted ? 2.5 : 1.8
        ..style = PaintingStyle.stroke;

      if (edge.isLoop) {
        // Self-loop: small circle above vertex
        final c = pos(edge.from);
        final loopRect =
            Rect.fromCenter(center: c - const Offset(0, 20), width: 28, height: 24);
        canvas.drawOval(loopRect, edgePaint);
      } else {
        final p1 = pos(edge.from);
        final p2 = pos(edge.to);

        if (graph.properties.directed) {
          _drawArrow(canvas, p1, p2, edgePaint, edgeColor);
        } else {
          canvas.drawLine(p1, p2, edgePaint);
        }

        // Weight label — drawn ABOVE the edge midpoint
        if (graph.properties.weighted) {
          final mid = Offset((p1.dx + p2.dx) / 2, (p1.dy + p2.dy) / 2);
          // Perpendicular offset to push label above the line
          final dx = p2.dx - p1.dx;
          final dy = p2.dy - p1.dy;
          final len = sqrt(dx * dx + dy * dy);
          final perpX = len > 0 ? -dy / len * 10 : 0.0;
          final perpY = len > 0 ?  dx / len * 10 : -10.0;
          final labelPos = Offset(mid.dx + perpX, mid.dy + perpY);
          // Small white background pill
          final tp = TextPainter(
            text: TextSpan(
              text: '${edge.weight}',
              style: const TextStyle(
                color: Color(0xFFE2E8F0),
                fontSize: 10,
                fontWeight: FontWeight.w700,
                fontFamily: 'monospace',
              ),
            ),
            textDirection: TextDirection.ltr,
          )..layout();
          final bgRect = RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: labelPos,
              width: tp.width + 6,
              height: tp.height + 2,
            ),
            const Radius.circular(3),
          );
          canvas.drawRRect(bgRect, Paint()..color = const Color(0xFF0F1117));
          tp.paint(canvas, labelPos - Offset(tp.width / 2, tp.height / 2));
        }
      }
    }

    // Draw vertices
    for (final v in graph.vertices) {
      final p = pos(v.id);
      final isHighlighted = v.id == highlightVertex ||
          v.id == highlightEdgeFrom ||
          v.id == highlightEdgeTo;

      final fillColor = isHighlighted
          ? const Color(0xFF22C55E).withOpacity(0.25)
          : const Color(0xFF1D4ED8).withOpacity(0.18);
      final strokeColor =
          isHighlighted ? const Color(0xFF22C55E) : const Color(0xFF3B82F6);

      canvas.drawCircle(p, 18, Paint()..color = fillColor);
      canvas.drawCircle(
        p,
        18,
        Paint()
          ..color = strokeColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );

      _drawText(canvas, v.label, p,
          color: const Color(0xFFE2E8F0), fontSize: 13, bold: true);
    }
  }

  void _drawArrow(Canvas canvas, Offset p1, Offset p2, Paint paint, Color color) {
    const r = 18.0;
    final dx = p2.dx - p1.dx;
    final dy = p2.dy - p1.dy;
    final len = sqrt(dx * dx + dy * dy);
    if (len < 1) return;
    final ux = dx / len, uy = dy / len;

    final start = Offset(p1.dx + ux * r, p1.dy + uy * r);
    final end = Offset(p2.dx - ux * r, p2.dy - uy * r);
    canvas.drawLine(start, end, paint);

    // Arrowhead
    const arrowLen = 10.0;
    const arrowAngle = 0.4;
    final angle = atan2(dy, dx);
    final ap1 = Offset(end.dx - arrowLen * cos(angle - arrowAngle),
        end.dy - arrowLen * sin(angle - arrowAngle));
    final ap2 = Offset(end.dx - arrowLen * cos(angle + arrowAngle),
        end.dy - arrowLen * sin(angle + arrowAngle));
    final arrowPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(end.dx, end.dy)
      ..lineTo(ap1.dx, ap1.dy)
      ..lineTo(ap2.dx, ap2.dy)
      ..close();
    canvas.drawPath(path, arrowPaint);
  }

  void _drawText(Canvas canvas, String text, Offset center,
      {Color color = Colors.white, double fontSize = 12, bool bold = false}) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: bold ? FontWeight.w700 : FontWeight.normal,
          fontFamily: 'monospace',
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(_GraphPainter old) =>
      old.graph != graph ||
      old.highlightEdgeFrom != highlightEdgeFrom ||
      old.highlightEdgeTo != highlightEdgeTo;
}