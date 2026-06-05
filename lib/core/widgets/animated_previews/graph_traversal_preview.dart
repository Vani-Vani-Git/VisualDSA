import 'dart:math';

import 'package:flutter/material.dart';

class GraphTraversalPreview
    extends StatefulWidget {

  const GraphTraversalPreview({
    super.key,
  });

  @override
  State<GraphTraversalPreview>
      createState() =>
          _GraphTraversalPreviewState();
}

class _GraphTraversalPreviewState
    extends State<GraphTraversalPreview>

    with
        SingleTickerProviderStateMixin {

  late AnimationController
      _controller;

  int activeIndex = 0;

  final List<Offset> nodes = [

    const Offset(10,38),
    const Offset(55, 15),
    const Offset(100, 58),
    const Offset(55, 100),
    const Offset(118, 82),
  ];

  final List<List<int>> edges = [

    [0, 1],
    [1, 2],
    [1, 3],
    [3, 2],
    [3, 4],
  ];

  @override
  void initState() {

    super.initState();

    _controller = AnimationController(

      vsync: this,

      duration:
          const Duration(seconds: 5),
    )..repeat();

    Future.doWhile(() async {

      await Future.delayed(
        const Duration(
            milliseconds: 700),
      );

      if (!mounted) return false;

      setState(() {

        activeIndex =
            (activeIndex + 1) %
                nodes.length;
      });

      return true;
    });
  }

  @override
  void dispose() {

    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return SizedBox(

      width: 200,
      height: 170,

      child: Align(
        alignment: Alignment.topLeft,
        child: CustomPaint(
           painter: _GraphPainter(

           nodes: nodes,

           edges: edges,

           activeIndex:
              activeIndex,
          ),
        ),
      ),
    );
  }
}

class _GraphPainter
    extends CustomPainter {

  final List<Offset> nodes;

  final List<List<int>> edges;

  final int activeIndex;

  _GraphPainter({

    required this.nodes,

    required this.edges,

    required this.activeIndex,
  });

  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {

    final edgePaint = Paint()

      ..color =
          Colors.white.withOpacity(
              0.35)

      ..strokeWidth = 2;

    // DRAW EDGES
    for (final edge in edges) {

      final start =
          nodes[edge[0]];

      final end =
          nodes[edge[1]];

      canvas.drawLine(
        start,
        end,
        edgePaint,
      );
    }

    // DRAW NODES
    for (int i = 0;
        i < nodes.length;
        i++) {

      final isActive =
          i == activeIndex;

      final nodePaint = Paint()

        ..color = isActive

            ? Colors.white

            : const Color(
                0xFF38BDF8);

      canvas.drawCircle(

        nodes[i],

        isActive ? 12 : 10,

        nodePaint,
      );

      // GLOW EFFECT
      if (isActive) {

        final glowPaint = Paint()

          ..color = Colors.white
              .withOpacity(0.25)

          ..maskFilter =
              const MaskFilter.blur(
            BlurStyle.normal,
            12,
          );

        canvas.drawCircle(
          nodes[i],
          18,
          glowPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(
      covariant CustomPainter oldDelegate) {

    return true;
  }
}