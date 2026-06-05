import 'package:flutter/material.dart';

class BinaryTreePreview extends StatefulWidget {

  const BinaryTreePreview({
    super.key,
  });

  @override
  State<BinaryTreePreview> createState() =>
      _BinaryTreePreviewState();
}

class _BinaryTreePreviewState
    extends State<BinaryTreePreview> {

  int activeNode = 0;

  final List<Offset> nodes = [

    // ROOT
    const Offset(60, 12),

    // LEVEL 2
    const Offset(28, 42),
    const Offset(92, 42),

    // LEVEL 3
    const Offset(14, 72),
    const Offset(42, 72),

    const Offset(78, 72),
    const Offset(106, 72),
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

      width: 120,
      height: 95,

      child: CustomPaint(

        painter: _TreePainter(

          nodes: nodes,

          edges: edges,

          activeNode:
              activeNode,
        ),
      ),
    );
  }
}

class _TreePainter
    extends CustomPainter {

  final List<Offset> nodes;

  final List<List<int>> edges;

  final int activeNode;

  _TreePainter({

    required this.nodes,

    required this.edges,

    required this.activeNode,
  });

  final List<String> _nodeValues = [

    '15',
    '35',
    '40',

    '3',
    '6',
    '5',
    '7',
  ];

  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {

    final edgePaint = Paint()

      ..color =
          Colors.white.withOpacity(
              0.8)

      ..strokeWidth = 1.5;

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

      final isLeaf =
          i >= 3;

      final fillPaint = Paint()

        ..color = isActive

            ? Colors.white

            : isLeaf

                ? const Color(
                    0xFFB7E4A5)

                : const Color(
                    0xFFD9D9D9)

        ..style = PaintingStyle.fill;

      final borderPaint = Paint()

        ..color = Colors.black54

        ..strokeWidth = 1

        ..style = PaintingStyle.stroke;

      // GLOW EFFECT
      if (isActive) {

        final glow = Paint()

          ..color =
              Colors.white.withOpacity(
                  0.25)

          ..maskFilter =
              const MaskFilter.blur(

            BlurStyle.normal,
            8,
          );

        canvas.drawCircle(
          nodes[i],
          10,
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

      // NODE VALUE
      final textPainter = TextPainter(

        text: TextSpan(

          text: _nodeValues[i],

          style: const TextStyle(

            color: Colors.black,

            fontSize: 6,

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

          nodes[i].dx -
              textPainter.width / 2,

          nodes[i].dy -
              textPainter.height / 2,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(
      covariant CustomPainter oldDelegate) {

    return true;
  }
}