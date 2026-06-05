import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class BSTPreview extends StatelessWidget {

  const BSTPreview({
    super.key,
  });

  Widget node(
    String value,
    bool active,
  ) {

    return Container(

      width: 38,
      height: 38,

      decoration: BoxDecoration(

        shape: BoxShape.circle,

        color: active

            ? Colors.cyan.withOpacity(
                0.2)

            : Colors.transparent,

        border: Border.all(
          color: Colors.cyan,
        ),
      ),

      child: Center(

        child: Text(

          value,

          style: const TextStyle(

            color: Colors.cyan,

            fontWeight:
                FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(
      BuildContext context) {

    return SizedBox(

      width: 120,
      height: 100,

      child: Stack(

        alignment: Alignment.center,

        children: [

          // TREE LINES
          CustomPaint(

            size:
                const Size(120, 100),

            painter:
                _BSTLinePainter(),
          ),

          // TREE NODES
          Column(

            mainAxisAlignment:
                MainAxisAlignment.center,

            children: [

              node(
                  "50", false),

              const SizedBox(
                  height: 12),

              Row(

                mainAxisAlignment:
                    MainAxisAlignment
                        .center,

                children: [

                  node(
                    "30",
                    true,
                  )

                      .animate(
                        onPlay:
                            (controller) =>
                                controller
                                    .repeat(
                          reverse: true,
                        ),
                      )

                      .scale(

                        duration:
                            1000.ms,

                        begin:
                            const Offset(
                                1, 1),

                        end:
                            const Offset(
                                1.08,
                                1.08),
                      ),

                  const SizedBox(
                      width: 40),

                  node(
                      "70", false),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BSTLinePainter
    extends CustomPainter {

  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {

    final paint = Paint()

      ..color =
          Colors.white.withOpacity(
              0.6)

      ..strokeWidth = 1.5;

    // LEFT LINE
    canvas.drawLine(

      const Offset(60, 30),

      const Offset(35, 62),

      paint,
    );

    // RIGHT LINE
    canvas.drawLine(

      const Offset(60, 30),

      const Offset(85, 62),

      paint,
    );
  }

  @override
  bool shouldRepaint(
      covariant CustomPainter oldDelegate) {

    return false;
  }
}