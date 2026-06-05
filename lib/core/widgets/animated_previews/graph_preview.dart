import 'package:flutter/material.dart';

class GraphPreview extends StatefulWidget {

  const GraphPreview({
    super.key,
  });

  @override
  State<GraphPreview> createState() =>
      _GraphPreviewState();
}

class _GraphPreviewState
    extends State<GraphPreview> {

  int activeNode = 0;

  final List<Offset> nodes = [

    const Offset(20, 20),
    const Offset(70, 20),
    const Offset(120, 20),

    const Offset(20, 65),
    const Offset(70, 65),
    const Offset(120, 65),

    const Offset(45, 105),
  ];

  final List<List<int>> edges = [

    [0, 1],
    [1, 2],

    [0, 3],
    [1, 4],

    [3, 4],

    [3, 6],
    [4, 6],

    [2, 5],
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
              milliseconds: 500),
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

      width: 150,
      height: 120,

      child: CustomPaint(

        painter: _GraphPainter(

          nodes: nodes,

          edges: edges,

          activeNode:
              activeNode,
        ),
      ),
    );
  }
}

class _GraphPainter
    extends CustomPainter {

  final List<Offset> nodes;

  final List<List<int>> edges;

  final int activeNode;

  _GraphPainter({

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

      ..color = Colors.white

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

      final paint = Paint()

        ..color = isActive

            ? const Color.fromARGB(255, 246, 242, 242)

            : const Color.fromARGB(0, 248, 104, 104)

        ..style = PaintingStyle.fill;

      final borderPaint = Paint()

        ..color = const Color.fromARGB(255, 243, 35, 35)
        
        ..strokeWidth = 2

        ..style = PaintingStyle.fill;

      // GLOW EFFECT
      if (isActive) {

        final glow = Paint()

          ..color =
              const Color.fromARGB(255, 246, 243, 243).withOpacity(
                  0.3)

          ..maskFilter =
              const MaskFilter.blur(

            BlurStyle.normal,
            10,
          );

        canvas.drawCircle(
          nodes[i],
          12,
          glow,
        );
      }

      // FILLED NODE
      canvas.drawCircle(
        nodes[i],
        8,
        paint,
      );

      // NODE BORDER
      canvas.drawCircle(
        nodes[i],
        8,
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