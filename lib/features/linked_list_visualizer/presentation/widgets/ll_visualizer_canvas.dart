import 'dart:math';
import 'package:flutter/material.dart';
import '../models/ll_step.dart';

class LLVisualizerCanvas extends StatelessWidget {
  final LLStep? step;
  final List<String> defaultList;
  final double height;

  const LLVisualizerCanvas({
    super.key,
    this.step,
    required this.defaultList,
    this.height = 190,
  });

  @override
  Widget build(BuildContext context) {
    final nodes = step?.nodes ??
        defaultList.asMap().entries
            .map((e) => LLNodeSnapshot(
                  value: e.value,
                  isHead: e.key == 0,
                  isTail: e.key == defaultList.length - 1,
                ))
            .toList();

    final floatingNode = step?.floatingNode;
    final floatingAtIndex = step?.floatingAtIndex;
    final phase = step?.phase ?? LLPhase.idle;

    // ── Calculate actual content width ──────────────────────────────────────
    const double nodeH = 44.0;
    const double dataW = 38.0;
    const double ptrW  = 16.0;
    const double totalW = dataW + ptrW; // 54
    const double gap = 20.0;
    const double sidePad = 16.0;

    final n = nodes.length;
    final contentW = n > 0
        ? sidePad * 2 + n * totalW + max(0, n - 1) * gap
        : 200.0;

    return Container(
      height: height,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFD5D5D5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFBBBBBB)),
      ),
      clipBehavior: Clip.hardEdge,
      child: n == 0
          ? const Center(
              child: Text(
                'No nodes. Enter values and press Apply.',
                style: TextStyle(
                    color: Color(0xFF888888),
                    fontSize: 12,
                    fontFamily: 'monospace'),
              ),
            )
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: SizedBox(
                // Always at least screen width so short lists stay centred,
                // but grows to fit all nodes without clipping
                width: max(contentW,
                    MediaQuery.of(context).size.width - 24),
                height: height,
                child: CustomPaint(
                  painter: _LLPainter(
                    nodes: nodes,
                    floatingNode: floatingNode,
                    floatingAtIndex: floatingAtIndex,
                    phase: phase,
                  ),
                ),
              ),
            ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
class _LLPainter extends CustomPainter {
  final List<LLNodeSnapshot> nodes;
  final LLNodeSnapshot? floatingNode;
  final int? floatingAtIndex;
  final LLPhase phase;

  _LLPainter({
    required this.nodes,
    this.floatingNode,
    this.floatingAtIndex,
    required this.phase,
  });

  // ── Dimensions ─────────────────────────────────────────────────────────────
  static const double _nodeH  = 44.0;
  static const double _dataW  = 38.0;
  static const double _ptrW   = 16.0;
  static const double _totalW = _dataW + _ptrW; // 54
  static const double _gap    = 20.0;
  static const double _pad    = 16.0;

  @override
  void paint(Canvas canvas, Size size) {
    final n = nodes.length;
    if (n == 0) return;

    final hasFloat = floatingNode != null;
    final mainY = hasFloat ? size.height * 0.38 : size.height / 2;
    final startX = _pad;

    // ── Collect x positions ─────────────────────────────────────────────────
    final xs = List.generate(n, (i) => startX + i * (_totalW + _gap));

    // ── head label ──────────────────────────────────────────────────────────
    _drawHeadLabel(canvas, xs[0] + _dataW / 2, mainY - _nodeH / 2 - 22);

    // ── edges ───────────────────────────────────────────────────────────────
    for (int i = 0; i < n - 1; i++) {
      _drawArrow(
        canvas,
        Offset(xs[i] + _totalW + 2, mainY),
        Offset(xs[i + 1] - 2, mainY),
      );
    }

    // ── nodes ───────────────────────────────────────────────────────────────
    for (int i = 0; i < n; i++) {
      _drawNode(canvas, nodes[i], xs[i], mainY, i, n);
    }

    // ── floating new node ───────────────────────────────────────────────────
    if (hasFloat) {
      final fi = (floatingAtIndex ?? n).clamp(0, n);
      double fx;
      if (fi >= n) {
        fx = startX + n * (_totalW + _gap);
      } else if (fi == 0) {
        fx = startX;
      } else {
        fx = (xs[fi - 1] + _totalW + xs[fi]) / 2 - _totalW / 2;
      }
      final fy = mainY + _nodeH + 32;
      _drawNode(canvas, floatingNode!, fx, fy, -1, 0);
      _drawDashedCurve(
        canvas,
        Offset(fx + _dataW / 2, fy - _nodeH / 2 - 2),
        Offset(
          fi < n ? xs[fi] + _dataW / 2 : fx + _totalW + 8,
          mainY + _nodeH / 2 + 2,
        ),
      );
    }
  }

  // ── Node ───────────────────────────────────────────────────────────────────
  void _drawNode(Canvas canvas, LLNodeSnapshot node, double x, double cy,
      int index, int total) {
    final top = cy - _nodeH / 2;

    Color dataFill, dataBorder, textColor, ptrFill;
    switch (node.state) {
      case LLNodeState.visited:
        dataFill   = const Color(0xFFF4A234);
        dataBorder = const Color(0xFFE8920A);
        textColor  = Colors.white;
        ptrFill    = const Color(0xFFCC7A00);
        break;
      case LLNodeState.current:
        dataFill   = const Color(0xFFF57C00);
        dataBorder = const Color(0xFFE65100);
        textColor  = Colors.white;
        ptrFill    = const Color(0xFFBF6000);
        break;
      case LLNodeState.inserted:
        dataFill   = const Color(0xFF4CAF50);
        dataBorder = const Color(0xFF388E3C);
        textColor  = Colors.white;
        ptrFill    = const Color(0xFF2E7D32);
        break;
      case LLNodeState.deleting:
        dataFill   = Colors.white.withOpacity(0.5);
        dataBorder = const Color(0xFFAAAAAA);
        textColor  = const Color(0xFFAAAAAA);
        ptrFill    = const Color(0xFFCCCCCC);
        break;
      case LLNodeState.newNode:
        dataFill   = const Color(0xFFF5F5F5);
        dataBorder = const Color(0xFF888888);
        textColor  = const Color(0xFF333333);
        ptrFill    = const Color(0xFF7BBBBF);
        break;
      default:
        dataFill   = Colors.white;
        dataBorder = const Color(0xFF888888);
        textColor  = const Color(0xFF222222);
        ptrFill    = const Color(0xFF7BBBBF);
    }

    // data box
    final dataRR = RRect.fromRectAndCorners(
      Rect.fromLTWH(x, top, _dataW, _nodeH),
      topLeft: const Radius.circular(4),
      bottomLeft: const Radius.circular(4),
    );
    canvas.drawRRect(dataRR, Paint()..color = dataFill);
    canvas.drawRRect(
      dataRR,
      Paint()
        ..color = dataBorder
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );

    // ptr box
    final ptrRR = RRect.fromRectAndCorners(
      Rect.fromLTWH(x + _dataW, top, _ptrW, _nodeH),
      topRight: const Radius.circular(4),
      bottomRight: const Radius.circular(4),
    );
    canvas.drawRRect(ptrRR, Paint()..color = ptrFill);
    canvas.drawRRect(
      ptrRR,
      Paint()
        ..color = dataBorder
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );

    // dot in ptr
    if (node.state != LLNodeState.deleting) {
      canvas.drawCircle(
        Offset(x + _dataW + _ptrW / 2, cy),
        2.2,
        Paint()..color = Colors.white.withOpacity(0.75),
      );
    }

    // value text
    _text(canvas, node.value, x + _dataW / 2, cy,
        color: textColor, fontSize: 12, bold: true);

    // speech bubbles
    if (node.showPred) {
      _bubble(canvas, 'pred', x + _dataW / 2, top,
          const Color(0xFFFFD600), const Color(0xFFAA8800));
    }
    if (node.showTemp && !node.showPred) {
      _bubble(canvas, 'temp', x + _dataW / 2, top,
          const Color(0xFFFFCDD2), const Color(0xFFE53935));
    }

    // head/0 label
    if (node.isHead &&
        (node.state == LLNodeState.visited ||
            node.state == LLNodeState.current)) {
      _text(canvas, 'head/0', x + _dataW / 2, top + _nodeH + 10,
          color: const Color(0xFFCC0000), fontSize: 9, bold: true);
    }

    // tail/N label
    if (node.isTail && total > 0 && node.state != LLNodeState.idle) {
      _text(canvas, 'tail/${total - 1}', x + _dataW / 2, top + _nodeH + 10,
          color: const Color(0xFFCC0000), fontSize: 9, bold: true);
    }

    // tmp/index label
    if (node.showTemp && index >= 0 && !node.showPred) {
      _text(canvas, 'tmp/$index', x + _dataW / 2, top + _nodeH + 10,
          color: const Color(0xFFCC0000), fontSize: 9, bold: true);
    }

    // red ✕
    if (node.showX) _drawX(canvas, x + _dataW / 2, top - 11);
  }

  // ── Head label ─────────────────────────────────────────────────────────────
  void _drawHeadLabel(Canvas canvas, double cx, double y) {
    final rr = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, y), width: 44, height: 18),
      const Radius.circular(9),
    );
    canvas.drawRRect(rr, Paint()..color = Colors.white.withOpacity(0.85));
    canvas.drawRRect(
      rr,
      Paint()
        ..color = const Color(0xFF888888)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );
    _text(canvas, 'head', cx, y,
        color: const Color(0xFF333333), fontSize: 10);
    // curved arrow down
    final path = Path()
      ..moveTo(cx, y + 9)
      ..quadraticBezierTo(cx - 14, y + 18, cx - 10, y + 26);
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFF555555)
        ..strokeWidth = 1.2
        ..style = PaintingStyle.stroke,
    );
    _arrowHead(canvas, Offset(cx - 10, y + 26), const Color(0xFF555555));
  }

  // ── Arrow (dashed) ─────────────────────────────────────────────────────────
  void _drawArrow(Canvas canvas, Offset from, Offset to) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.85)
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;
    final dx = to.dx - from.dx;
    double d = 0;
    bool on = true;
    while (d < dx) {
      final end = d + (on ? 4.0 : 3.0);
      if (on) {
        canvas.drawLine(
          Offset(from.dx + d, from.dy),
          Offset(from.dx + min(end, dx), from.dy),
          paint,
        );
      }
      d = end;
      on = !on;
    }
    _arrowHead(canvas, to, Colors.white.withOpacity(0.85));
  }

  void _arrowHead(Canvas canvas, Offset tip, Color color) {
    final p = Paint()
      ..color = color
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;
    canvas.drawLine(tip, tip + const Offset(-6, -4), p);
    canvas.drawLine(tip, tip + const Offset(-6, 4), p);
  }

  // ── Dashed curve for floating node ─────────────────────────────────────────
  void _drawDashedCurve(Canvas canvas, Offset from, Offset to) {
    final path = Path()
      ..moveTo(from.dx, from.dy)
      ..quadraticBezierTo(
          (from.dx + to.dx) / 2, from.dy - 16, to.dx, to.dy);
    final metrics = path.computeMetrics().first;
    final paint = Paint()
      ..color = const Color(0xFF666666)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    double d = 0;
    bool on = true;
    while (d < metrics.length) {
      final end = d + (on ? 5.0 : 4.0);
      if (on) {
        canvas.drawPath(
            metrics.extractPath(d, min(end, metrics.length)), paint);
      }
      d = end;
      on = !on;
    }
  }

  // ── Speech bubble ──────────────────────────────────────────────────────────
  void _bubble(Canvas canvas, String label, double cx, double topY,
      Color fill, Color border) {
    const bw = 38.0, bh = 17.0, tailH = 5.0;
    final by = topY - bh - tailH - 2;
    final rr = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, by + bh / 2), width: bw, height: bh),
      const Radius.circular(4),
    );
    final path = Path()
      ..addRRect(rr)
      ..moveTo(cx - 4, by + bh)
      ..lineTo(cx, topY - 2)
      ..lineTo(cx + 4, by + bh)
      ..close();
    canvas.drawPath(path, Paint()..color = fill);
    canvas.drawPath(
      path,
      Paint()
        ..color = border
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8,
    );
    _text(canvas, label, cx, by + bh / 2,
        color: const Color(0xFF333333), fontSize: 9, bold: true);
  }

  // ── Red ✕ ──────────────────────────────────────────────────────────────────
  void _drawX(Canvas canvas, double cx, double cy) {
    canvas.drawCircle(
        Offset(cx, cy), 8, Paint()..color = const Color(0xFFFFCDD2));
    final p = Paint()
      ..color = const Color(0xFFE53935)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(Offset(cx, cy), 8, p);
    canvas.drawLine(Offset(cx - 4, cy - 4), Offset(cx + 4, cy + 4), p);
    canvas.drawLine(Offset(cx + 4, cy - 4), Offset(cx - 4, cy + 4), p);
  }

  // ── Text helper ────────────────────────────────────────────────────────────
  void _text(Canvas canvas, String text, double cx, double cy,
      {Color color = Colors.black,
      double fontSize = 12,
      bool bold = false}) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: bold ? FontWeight.w700 : FontWeight.normal,
          fontFamily: 'Roboto',
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(cx - tp.width / 2, cy - tp.height / 2));
  }

  @override
  bool shouldRepaint(_LLPainter old) => true;
}