import 'dart:math';
import 'package:flutter/material.dart';

class MSTPreview extends StatefulWidget {
  const MSTPreview({super.key});

  @override
  State<MSTPreview> createState() =>
      _MSTPreviewState();
}

class _MSTPreviewState
    extends State<MSTPreview> {

  int activeStep = 0;

  // MST edge animation order
  final mstEdges = [
    [0, 1],
    [1, 2],
    [2, 4],
    [2, 3],
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

        activeStep =
            (activeStep + 1) %
                (mstEdges.length + 1);
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

        painter: _MSTPainter(
          activeStep: activeStep,
          mstEdges: mstEdges,
        ),
      ),
    );
  }
}

class _MSTPainter
    extends CustomPainter {

  final int activeStep;

  final List<List<int>> mstEdges;

  _MSTPainter({
    required this.activeStep,
    required this.mstEdges,
  });

  @override
  void paint(
      Canvas canvas,
      Size size) {

    final nodes = [

      Offset(size.width * 0.15,
          size.height * 0.18),

      Offset(size.width * 0.52,
          size.height * 0.34),

      Offset(size.width * 0.82,
          size.height * 0.16),

      Offset(size.width * 0.22,
          size.height * 0.78),

      Offset(size.width * 0.78,
          size.height * 0.76),
    ];

    // ALL GRAPH EDGES
    final allEdges = [

      [0, 1],
      [1, 2],
      [0, 3],
      [3, 1],
      [3, 4],
      [2, 4],
      [1, 4],
      [2, 3],
    ];

    final inactivePaint = Paint()

      ..color = Colors.white24
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final activePaint = Paint()

      ..color = Colors.white
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final glowPaint = Paint()

      ..color =
          Colors.orangeAccent
              .withOpacity(0.35)

      ..strokeWidth = 10

      ..strokeCap = StrokeCap.round

      ..maskFilter =
          const MaskFilter.blur(
        BlurStyle.normal,
        14,
      );

    // DRAW ALL EDGES
    for (final edge in allEdges) {

      final p1 =
          nodes[edge[0]];

      final p2 =
          nodes[edge[1]];

      bool isMST = false;

      for (int i = 0;
          i < activeStep &&
              i < mstEdges.length;
          i++) {

        final mst =
            mstEdges[i];

        if ((mst[0] == edge[0] &&
                mst[1] == edge[1]) ||

            (mst[0] == edge[1] &&
                mst[1] == edge[0])) {

          isMST = true;
        }
      }

      if (isMST) {

        canvas.drawLine(
          p1,
          p2,
          glowPaint,
        );

        canvas.drawLine(
          p1,
          p2,
          activePaint,
        );
      } else {

        canvas.drawLine(
          p1,
          p2,
          inactivePaint,
        );
      }
    }

    // DRAW NODES
    for (int i = 0;
        i < nodes.length;
        i++) {

      bool activeNode = false;

      for (int j = 0;
          j < activeStep &&
              j < mstEdges.length;
          j++) {

        if (mstEdges[j]
                .contains(i)) {

          activeNode = true;
        }
      }

      final fillPaint = Paint()

        ..color = activeNode

            ? Colors.white

            : Colors.white70;

      final borderPaint = Paint()

        ..color = activeNode

            ? Colors.orangeAccent

            : Colors.white54

        ..strokeWidth = 2.5

        ..style =
            PaintingStyle.stroke;

      if (activeNode) {

        canvas.drawCircle(
          nodes[i],
          16,
          Paint()

            ..color =
                Colors.orangeAccent
                    .withOpacity(0.3)

            ..maskFilter =
                const MaskFilter.blur(
              BlurStyle.normal,
              14,
            ),
        );
      }

      canvas.drawCircle(
        nodes[i],
        11,
        fillPaint,
      );

      canvas.drawCircle(
        nodes[i],
        11,
        borderPaint,
      );
    }
  }

  @override
  bool shouldRepaint(
          covariant
          _MSTPainter oldDelegate) =>
      true;
}