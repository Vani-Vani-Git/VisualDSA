import 'dart:math';
import 'package:flutter/material.dart';

class HuffmanPreview extends StatefulWidget {
  const HuffmanPreview({super.key});

  @override
  State<HuffmanPreview> createState() =>
      _HuffmanPreviewState();
}

class _HuffmanPreviewState
    extends State<HuffmanPreview> {

  int activePath = 0;

  final paths = [

    [0, 1],
    [1, 3],
    [1, 4],
    [0, 2],
    [2, 5],
    [2, 6],
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

        activePath =
            (activePath + 1) %
                paths.length;
      });

      return true;
    });
  }

  @override
  Widget build(BuildContext context) {

    return SizedBox(

      width: 135,
      height: 125,

      child: CustomPaint(

        painter: _HuffmanPainter(
          activePath: activePath,
          paths: paths,
        ),
      ),
    );
  }
}

class _HuffmanPainter
    extends CustomPainter {

  final int activePath;

  final List<List<int>> paths;

  _HuffmanPainter({
    required this.activePath,
    required this.paths,
  });

  @override
  void paint(
      Canvas canvas,
      Size size) {

    final nodes = [

      Offset(size.width * 0.5,
          size.height * 0.12),

      Offset(size.width * 0.32,
          size.height * 0.42),

      Offset(size.width * 0.72,
          size.height * 0.42),

      Offset(size.width * 0.18,
          size.height * 0.78),

      Offset(size.width * 0.42,
          size.height * 0.78),

      Offset(size.width * 0.62,
          size.height * 0.78),

      Offset(size.width * 0.86,
          size.height * 0.78),
    ];

    final labels = [
      '100',
      '55',
      '45',
      'a',
      'b',
      'c',
      'd',
    ];

    final weights = [
      '',
      '',
      '',
      '5',
      '9',
      '12',
      '13',
    ];

    final edgeLabels = [
      '0',
      '1',
      '0',
      '1',
      '0',
      '1',
    ];

    final edges = [
      [0, 1],
      [0, 2],
      [1, 3],
      [1, 4],
      [2, 5],
      [2, 6],
    ];

    final inactivePaint = Paint()

      ..color =
          Colors.greenAccent
              .withOpacity(0.25)

      ..strokeWidth = 2.2

      ..strokeCap =
          StrokeCap.round;

    final activePaint = Paint()

      ..color = Colors.greenAccent

      ..strokeWidth = 3.8

      ..strokeCap =
          StrokeCap.round;

    final glowPaint = Paint()

      ..color =
          Colors.greenAccent
              .withOpacity(0.35)

      ..strokeWidth = 10

      ..strokeCap =
          StrokeCap.round

      ..maskFilter =
          const MaskFilter.blur(
        BlurStyle.normal,
        14,
      );

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
          i == activePath;

      if (isActive) {

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

      // EDGE LABELS (0 / 1)
      final mid = Offset(
        (p1.dx + p2.dx) / 2,
        (p1.dy + p2.dy) / 2,
      );

      final textPainter =
          TextPainter(

        text: TextSpan(

          text: edgeLabels[i],

          style: TextStyle(

            color: isActive

                ? Colors.greenAccent

                : Colors.greenAccent
                    .withOpacity(0.6),

            fontSize: 12,

            fontWeight:
                FontWeight.bold,
          ),
        ),

        textDirection:
            TextDirection.ltr,
      );

      textPainter.layout();

      textPainter.paint(
        canvas,
        Offset(
          mid.dx + 4,
          mid.dy - 10,
        ),
      );
    }

    // DRAW NODES
    for (int i = 0;
        i < nodes.length;
        i++) {

      final activeNode =
          paths[activePath]
              .contains(i);

      final fillPaint = Paint()

        ..color = activeNode

            ? Colors.greenAccent
                .withOpacity(0.18)

            : Colors.transparent;

      final borderPaint = Paint()

        ..color = activeNode

            ? Colors.greenAccent

            : Colors.greenAccent
                .withOpacity(0.7)

        ..strokeWidth = 2.2

        ..style =
            PaintingStyle.stroke;

      if (activeNode) {

        canvas.drawCircle(
          nodes[i],
          19,
          glowPaint,
        );
      }

      canvas.drawCircle(
        nodes[i],
        16,
        fillPaint,
      );

      canvas.drawCircle(
        nodes[i],
        16,
        borderPaint,
      );

      final tp = TextPainter(

        text: TextSpan(

          text: labels[i],

          style: TextStyle(

            color:
                Colors.greenAccent,

            fontSize: 11,

            fontWeight:
                FontWeight.bold,
          ),
        ),

        textDirection:
            TextDirection.ltr,
      );

      tp.layout();

      tp.paint(

        canvas,

        Offset(
          nodes[i].dx -
              tp.width / 2,
          nodes[i].dy -
              tp.height / 2,
        ),
      );

      // LEAF WEIGHTS
      if (weights[i]
          .isNotEmpty) {

        final wp = TextPainter(

          text: TextSpan(

            text: weights[i],

            style: TextStyle(

              color:
                  Colors.greenAccent
                      .withOpacity(0.8),

              fontSize: 9,
            ),
          ),

          textDirection:
              TextDirection.ltr,
        );

        wp.layout();

        wp.paint(

          canvas,

          Offset(
            nodes[i].dx - 4,
            nodes[i].dy + 18,
          ),
        );
      }
    }
  }

  @override
  bool shouldRepaint(
          covariant
          _HuffmanPainter
              oldDelegate) =>
      true;
}