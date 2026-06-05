import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ShortestPathPreview extends StatefulWidget {
  const ShortestPathPreview({super.key});

  @override
  State<ShortestPathPreview> createState() =>
      _ShortestPathPreviewState();
}

class _ShortestPathPreviewState
    extends State<ShortestPathPreview> {

  int activeEdge = 0;

  final List<List<int>> edges = [
    [0, 1],
    [1, 2],
    [2, 3],
    [0, 3],
    [1, 3],
  ];

  @override
  void initState() {
    super.initState();

    Future.doWhile(() async {

      await Future.delayed(
        const Duration(milliseconds: 700),
      );

      if (!mounted) return false;

      setState(() {

        activeEdge =
            (activeEdge + 1) %
                edges.length;
      });

      return true;
    });
  }

  @override
  Widget build(BuildContext context) {

    return SizedBox(

      width: 120,
      height: 120,

      child: CustomPaint(

        painter: _ShortestPathPainter(
          activeEdge: activeEdge,
          edges: edges,
        ),
      ),
    );
  }
}

class _ShortestPathPainter
    extends CustomPainter {

  final int activeEdge;

  final List<List<int>> edges;

  _ShortestPathPainter({
    required this.activeEdge,
    required this.edges,
  });

  @override
  void paint(
      Canvas canvas,
      Size size) {

    final paintLine = Paint()

      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final glowPaint = Paint()

      ..color =
          Colors.greenAccent
              .withOpacity(0.25)

      ..maskFilter =
          const MaskFilter.blur(
        BlurStyle.normal,
        12,
      );

    final nodes = [

      Offset(size.width * 0.18,
          size.height * 0.25),

      Offset(size.width * 0.78,
          size.height * 0.12),

      Offset(size.width * 0.68,
          size.height * 0.78),

      Offset(size.width * 0.42,
          size.height * 0.48),
    ];

    // DRAW EDGES
    for (int i = 0;
        i < edges.length;
        i++) {

      final edge = edges[i];

      final p1 =
          nodes[edge[0]];

      final p2 =
          nodes[edge[1]];

      final isActive =
          i == activeEdge;

      paintLine.color = isActive

          ? const Color.fromARGB(255, 249, 250, 249)

          : Colors.white24;

      paintLine.strokeWidth =
          isActive ? 3.2 : 2;

      if (isActive) {

        canvas.drawLine(
          p1,
          p2,
          glowPaint,
        );
      }

      canvas.drawLine(
        p1,
        p2,
        paintLine,
      );

      // ARROW
      _drawArrow(
        canvas,
        p1,
        p2,
        isActive,
      );
    }

    // DRAW NODES
    for (int i = 0;
        i < nodes.length;
        i++) {

      final isVisited =
          i <= activeEdge;

      final nodePaint = Paint()

        ..color = isVisited

            ? const Color.fromARGB(255, 251, 58, 20)

            : const Color.fromARGB(179, 252, 250, 249);

      final borderPaint = Paint()

        ..color = isVisited

            ? Colors.white

            : Colors.white54

        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke;

      if (isVisited) {

        canvas.drawCircle(
          nodes[i],
          16,
          glowPaint,
        );
      }

      canvas.drawCircle(
        nodes[i],
        12,
        nodePaint,
      );

      canvas.drawCircle(
        nodes[i],
        12,
        borderPaint,
      );
    }
  }

  void _drawArrow(
    Canvas canvas,
    Offset start,
    Offset end,
    bool active,
  ) {

    final paint = Paint()

      ..color = active

          ? const Color.fromARGB(255, 236, 103, 19)

          : Colors.white54

      ..strokeWidth = 2;

    const arrowSize = 8.0;

    final angle = atan2(
      end.dy - start.dy,
      end.dx - start.dx,
    );

    final arrowP1 = Offset(

      end.dx -
          arrowSize *
              cos(angle - pi / 6),

      end.dy -
          arrowSize *
              sin(angle - pi / 6),
    );

    final arrowP2 = Offset(

      end.dx -
          arrowSize *
              cos(angle + pi / 6),

      end.dy -
          arrowSize *
              sin(angle + pi / 6),
    );

    canvas.drawLine(
      end,
      arrowP1,
      paint,
    );

    canvas.drawLine(
      end,
      arrowP2,
      paint,
    );
  }

  @override
  bool shouldRepaint(
          covariant
          _ShortestPathPainter
              oldDelegate) =>
      true;
}