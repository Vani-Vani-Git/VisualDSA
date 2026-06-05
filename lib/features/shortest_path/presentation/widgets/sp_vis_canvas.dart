import 'dart:math';
import 'package:flutter/material.dart';
import '../models/sp_graph_model.dart';

class SpVisCanvas extends StatelessWidget {
  final SpGraphModel graph;
  final SpAnimStep? step;
  final int? srcNode;
  final int? dstNode;

  const SpVisCanvas({
    super.key,
    required this.graph,
    this.step,
    this.srcNode,
    this.dstNode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 260,
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        border: Border.all(color: const Color(0xFF21262D)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: LayoutBuilder(builder: (_, c) {
          return CustomPaint(
            size: Size(c.maxWidth, 260),
            painter: _VisPainter(
              graph: graph,
              step: step,
              srcNode: srcNode,
              dstNode: dstNode,
              canvasSize: Size(c.maxWidth, 260),
            ),
          );
        }),
      ),
    );
  }
}

// ── Distance table overlay ────────────────────────────────────────────────────
class SpDistTable extends StatelessWidget {
  final SpAnimStep? step;
  final List<SpVertex> vertices;

  const SpDistTable({super.key, this.step, required this.vertices});

  @override
  Widget build(BuildContext context) {
    if (step == null) return const SizedBox();
    final dist = step!.dist;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        border: Border.all(color: const Color(0xFF21262D)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Row(
              children: [
                const Text('Node',
                    style: TextStyle(
                        color: Color(0xFF8B949E),
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'monospace')),
                const Spacer(),
                const Text('Dist',
                    style: TextStyle(
                        color: Color(0xFF8B949E),
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'monospace')),
                const SizedBox(width: 16),
                const Text('Via',
                    style: TextStyle(
                        color: Color(0xFF8B949E),
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'monospace')),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFF21262D)),
          ...vertices.map((v) {
            final d = dist[v.id] ?? 999999;
            final inPath = step!.inPath.contains(v.id);
            final isCurrent = v.id == step!.currentNode ||
                v.id == step!.fromNode ||
                v.id == step!.toNode;
            final isFinalized = step!.visited.contains(v.id);
            final prev = step!.prev[v.id];

            Color rowColor = Colors.transparent;
            Color textColor = const Color(0xFFE2E8F0);
            if (inPath) {
              rowColor = const Color(0xFF22C55E).withOpacity(0.10);
              textColor = const Color(0xFF22C55E);
            } else if (isCurrent) {
              rowColor = const Color(0xFFF59E0B).withOpacity(0.08);
              textColor = const Color(0xFFFBBF24);
            } else if (isFinalized) {
              rowColor = const Color(0xFF3B82F6).withOpacity(0.06);
              textColor = const Color(0xFF60A5FA);
            }

            return Container(
              color: rowColor,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: Row(
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: textColor.withOpacity(0.15),
                      border: Border.all(color: textColor.withOpacity(0.5)),
                    ),
                    child: Center(
                      child: Text(
                        v.label,
                        style: TextStyle(
                            color: textColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'monospace'),
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    d >= 999999 ? '∞' : '$d',
                    style: TextStyle(
                        color: textColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'monospace'),
                  ),
                  const SizedBox(width: 16),
                  SizedBox(
                    width: 24,
                    child: Text(
                      prev != null ? '$prev' : '-',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: textColor.withOpacity(0.7),
                          fontSize: 11,
                          fontFamily: 'monospace'),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ── Painter ───────────────────────────────────────────────────────────────────
class _VisPainter extends CustomPainter {
  final SpGraphModel graph;
  final SpAnimStep? step;
  final int? srcNode;
  final int? dstNode;
  final Size canvasSize;

  static const _origSize = Size(300, 260);

  _VisPainter({
    required this.graph,
    this.step,
    this.srcNode,
    this.dstNode,
    required this.canvasSize,
  });

  Offset _scale(Offset p) {
    final sx = canvasSize.width / _origSize.width;
    final sy = canvasSize.height / _origSize.height;
    return Offset(p.dx * sx, p.dy * sy);
  }

  Offset _pos(int id) {
    final v = graph.vertices.firstWhere((v) => v.id == id);
    return _scale(v.position);
  }

  bool _isPathEdge(int from, int to) {
    if (step == null) return false;
    return step!.pathEdges.contains('$from-$to') ||
        step!.pathEdges.contains('$to-$from');
  }

  bool _isActiveEdge(int from, int to) {
    if (step == null) return false;
    return (step!.fromNode == from && step!.toNode == to) ||
        (!graph.properties.directed &&
            step!.fromNode == to &&
            step!.toNode == from);
  }

  bool _isRelaxedEdge(int from, int to) {
    if (step == null) return false;
    return step!.type == SpStepType.edgeRelaxed &&
        (step!.fromNode == from && step!.toNode == to);
  }

  @override
  void paint(Canvas canvas, Size size) {
    // ── Draw edges ────────────────────────────────────────────────────────────
    for (final e in graph.edges) {
      final p1 = _pos(e.from);
      final p2 = _pos(e.to);

      Color edgeColor;
      double strokeW;

      if (_isPathEdge(e.from, e.to)) {
        edgeColor = const Color(0xFF22C55E);
        strokeW = 3.0;
      } else if (_isRelaxedEdge(e.from, e.to)) {
        edgeColor = const Color(0xFF4ADE80);
        strokeW = 2.5;
      } else if (_isActiveEdge(e.from, e.to)) {
        edgeColor = const Color(0xFFF59E0B);
        strokeW = 2.5;
      } else {
        edgeColor = const Color(0xFF374151);
        strokeW = 1.8;
      }

      final paint = Paint()
        ..color = edgeColor
        ..strokeWidth = strokeW
        ..style = PaintingStyle.stroke;

      if (graph.properties.directed) {
        _drawArrow(canvas, p1, p2, paint, edgeColor);
      } else {
        canvas.drawLine(p1, p2, paint);
      }

      // Weight label
      final mid = Offset((p1.dx + p2.dx) / 2, (p1.dy + p2.dy) / 2);
      final dx = p2.dx - p1.dx;
      final dy = p2.dy - p1.dy;
      final len = sqrt(dx * dx + dy * dy);
      final px = len > 0 ? -dy / len * 12 : 0.0;
      final py = len > 0 ? dx / len * 12 : -12.0;
      final labelPos = Offset(mid.dx + px, mid.dy + py);

      _drawWeightLabel(canvas, '${e.weight}', labelPos, edgeColor);
    }

    // ── Draw vertices ─────────────────────────────────────────────────────────
    for (final v in graph.vertices) {
      final p = _pos(v.id);
      _drawVertex(canvas, v, p);
    }
  }

  void _drawVertex(Canvas canvas, SpVertex v, Offset p) {
    if (step == null) {
      // No animation: default styling
      _drawNodeCircle(canvas, p, v.label,
          fill: const Color(0xFF1D4ED8).withOpacity(0.20),
          stroke: const Color(0xFF3B82F6),
          textColor: const Color(0xFFE2E8F0));
      return;
    }

    final isPath = step!.inPath.contains(v.id);
    final isCurrent = v.id == step!.currentNode;
    final isActive =
        v.id == step!.fromNode || v.id == step!.toNode;
    final isFinalized = step!.visited.contains(v.id);
    final isSrc = v.id == srcNode;
    final isDst = v.id == dstNode;

    Color fill, stroke, textColor;

    if (isPath) {
      fill = const Color(0xFF22C55E).withOpacity(0.30);
      stroke = const Color(0xFF22C55E);
      textColor = const Color(0xFF22C55E);
    } else if (isCurrent) {
      fill = const Color(0xFFF59E0B).withOpacity(0.28);
      stroke = const Color(0xFFF59E0B);
      textColor = const Color(0xFFFBBF24);
    } else if (isActive) {
      fill = const Color(0xFF9333EA).withOpacity(0.22);
      stroke = const Color(0xFFA855F7);
      textColor = const Color(0xFFD8B4FE);
    } else if (isFinalized) {
      fill = const Color(0xFF3B82F6).withOpacity(0.22);
      stroke = const Color(0xFF3B82F6);
      textColor = const Color(0xFF93C5FD);
    } else {
      fill = const Color(0xFF1D4ED8).withOpacity(0.15);
      stroke = const Color(0xFF374151);
      textColor = const Color(0xFF6B7280);
    }

    // Src / Dst special outer ring
    if (isSrc || isDst) {
      canvas.drawCircle(
          p,
          26,
          Paint()
            ..color = (isSrc ? const Color(0xFFF59E0B) : const Color(0xFFEC4899))
                .withOpacity(0.25)
            ..style = PaintingStyle.fill);
      canvas.drawCircle(
          p,
          26,
          Paint()
            ..color = isSrc ? const Color(0xFFF59E0B) : const Color(0xFFEC4899)
            ..strokeWidth = 1.5
            ..style = PaintingStyle.stroke);
    }

    _drawNodeCircle(canvas, p, v.label,
        fill: fill, stroke: stroke, textColor: textColor);

    // Distance label above node
    final d = step!.dist[v.id] ?? 999999;
    final distStr = d >= 999999 ? '∞' : '$d';
    _drawDistBadge(canvas, distStr, p, isPath || isCurrent);
  }

  void _drawNodeCircle(Canvas canvas, Offset p, String label,
      {required Color fill,
      required Color stroke,
      required Color textColor}) {
    canvas.drawCircle(p, 20, Paint()..color = fill);
    canvas.drawCircle(
        p,
        20,
        Paint()
          ..color = stroke
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2);
    _text(canvas, label, p, color: textColor, fontSize: 12, bold: true);
  }

  void _drawDistBadge(Canvas canvas, String text, Offset p, bool highlight) {
    final badgePos = Offset(p.dx, p.dy - 30);
    final color = highlight ? const Color(0xFFFBBF24) : const Color(0xFF8B949E);
    final tp = TextPainter(
      text: TextSpan(
          text: text,
          style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              fontFamily: 'monospace')),
      textDirection: TextDirection.ltr,
    )..layout();
    final bg = RRect.fromRectAndRadius(
        Rect.fromCenter(
            center: badgePos, width: tp.width + 6, height: tp.height + 3),
        const Radius.circular(3));
    canvas.drawRRect(bg, Paint()..color = const Color(0xFF0D1117));
    canvas.drawRRect(
        bg,
        Paint()
          ..color = color.withOpacity(0.4)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1);
    tp.paint(canvas, badgePos - Offset(tp.width / 2, tp.height / 2));
  }

  void _drawWeightLabel(Canvas canvas, String text, Offset pos, Color edgeColor) {
    final tp = TextPainter(
      text: TextSpan(
          text: text,
          style: TextStyle(
              color: edgeColor == const Color(0xFF374151)
                  ? const Color(0xFF8B949E)
                  : const Color(0xFFE2E8F0),
              fontSize: 10,
              fontWeight: FontWeight.w700,
              fontFamily: 'monospace')),
      textDirection: TextDirection.ltr,
    )..layout();
    final bg = RRect.fromRectAndRadius(
        Rect.fromCenter(center: pos, width: tp.width + 6, height: tp.height + 3),
        const Radius.circular(3));
    canvas.drawRRect(bg, Paint()..color = const Color(0xFF0D1117));
    tp.paint(canvas, pos - Offset(tp.width / 2, tp.height / 2));
  }

  void _drawArrow(
      Canvas canvas, Offset p1, Offset p2, Paint paint, Color color) {
    const r = 20.0;
    final dx = p2.dx - p1.dx;
    final dy = p2.dy - p1.dy;
    final len = sqrt(dx * dx + dy * dy);
    if (len < 1) return;
    final ux = dx / len, uy = dy / len;
    final start = Offset(p1.dx + ux * r, p1.dy + uy * r);
    final end = Offset(p2.dx - ux * r, p2.dy - uy * r);
    canvas.drawLine(start, end, paint);
    const aLen = 10.0;
    const aAng = 0.42;
    final a = atan2(dy, dx);
    final ap1 = Offset(end.dx - aLen * cos(a - aAng), end.dy - aLen * sin(a - aAng));
    final ap2 = Offset(end.dx - aLen * cos(a + aAng), end.dy - aLen * sin(a + aAng));
    canvas.drawPath(
        Path()
          ..moveTo(end.dx, end.dy)
          ..lineTo(ap1.dx, ap1.dy)
          ..lineTo(ap2.dx, ap2.dy)
          ..close(),
        Paint()
          ..color = color
          ..style = PaintingStyle.fill);
  }

  void _text(Canvas canvas, String text, Offset c,
      {Color color = Colors.white, double fontSize = 12, bool bold = false}) {
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
    tp.paint(canvas, c - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(_VisPainter old) => true;
}