import 'package:flutter/material.dart';

class HeapPreview extends StatefulWidget {

  const HeapPreview({
    super.key,
  });

  @override
  State<HeapPreview> createState() =>
      _HeapPreviewState();
}

class _HeapPreviewState
    extends State<HeapPreview> {

  int activeNode = 0;

  final List<Offset> nodes = [

    // ROOT
    const Offset(70, 18),

    // LEVEL 2
    const Offset(35, 55),
    const Offset(105, 55),

    // LEVEL 3
    const Offset(18, 92),
    const Offset(52, 92),

    const Offset(88, 92),
    const Offset(122, 92),
  ];

  final List<List<int>> edges = [

    [0, 1],
    [0, 2],

    [1, 3],
    [1, 4],

    [2, 5],
    [2, 6],
  ];

  @override
  void initState() {

    super.initState();

    _animateTraversal();
  }

  Future<void>
      _animateTraversal() async {

    while (mounted) {

      for (int i = 0;
          i < nodes.length;
          i++) {

        await Future.delayed(

          const Duration(
              milliseconds: 450),
        );

        if (!mounted) return;

        setState(() {

          activeNode = i;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    return SizedBox(

      width: 145,
      height: 115,

      child: CustomPaint(

        painter: _HeapPainter(

          nodes: nodes,

          edges: edges,

          activeNode:
              activeNode,
        ),
      ),
    );
  }
}

class _HeapPainter
    extends CustomPainter {

  final List<Offset> nodes;

  final List<List<int>> edges;

  final int activeNode;

  _HeapPainter({

    required this.nodes,

    required this.edges,

    required this.activeNode,
  });

  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {

    final edgePaint = Paint()

      ..color =
          Colors.white.withOpacity(
              0.9)

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
          i == activeNode;

      final fillPaint = Paint()

        ..color = isActive

            ? const Color.fromARGB(255, 245, 246, 247)

            : const Color.fromARGB(0, 90, 160, 239)

        ..style = PaintingStyle.fill;

      final borderPaint = Paint()

        ..color = const Color.fromARGB(255, 95, 131, 232)

        ..strokeWidth = 2

        ..style = PaintingStyle.fill;

      // GLOW EFFECT
      if (isActive) {

        final glow = Paint()

          ..color =
              Colors.white.withOpacity(
                  0.25)

          ..maskFilter =
              const MaskFilter.blur(

            BlurStyle.normal,
            10,
          );

        canvas.drawCircle(
          nodes[i],
          11,
          glow,
        );
      }

      // NODE FILL
      canvas.drawCircle(
        nodes[i],
        7,
        fillPaint,
      );

      // NODE BORDER
      canvas.drawCircle(
        nodes[i],
        7,
        borderPaint,
      );
    }
  }

  @override
  bool shouldRepaint(
      covariant CustomPainter oldDelegate) {

    return true;
  }
}