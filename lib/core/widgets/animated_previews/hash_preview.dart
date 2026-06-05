import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class HashPreview extends StatelessWidget {
  const HashPreview({super.key});

  Widget buildCell(String value) {

    return Container(

      width: 36,
      height: 36,

      decoration: BoxDecoration(

        border: Border.all(
          color: Colors.amber,
        ),
      ),

      child: Center(

        child: Text(

          value,

          style: const TextStyle(
            color: Colors.amber,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Row(

      mainAxisAlignment:
          MainAxisAlignment.center,

      children: [

        Column(

          children: const [

            Text("key1",
                style:
                    TextStyle(color: Colors.amber)),

            SizedBox(height: 8),

            Text("key2",
                style:
                    TextStyle(color: Colors.amber)),

            SizedBox(height: 8),

            Text("key3",
                style:
                    TextStyle(color: Colors.amber)),
          ],
        ),

        const SizedBox(width: 12),

        Column(

          children: [

            buildCell("0"),

            buildCell("1")
                .animate(
                  onPlay: (controller) =>
                      controller.repeat(
                          reverse: true),
                )
                .scale(
                  duration: 900.ms,
                  begin: const Offset(1, 1),
                  end: const Offset(1.08, 1.08),
                ),

            buildCell("2"),
          ],
        ),
      ],
    );
  }
}