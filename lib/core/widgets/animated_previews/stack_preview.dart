import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class StackPreview extends StatelessWidget {
  const StackPreview({super.key});

  Widget buildBox(String value) {

    return Container(

      width: 54,
      height: 32,

      decoration: BoxDecoration(

        border: Border.all(
          color: Colors.orange,
          width: 1.4,
        ),

        borderRadius:
            BorderRadius.circular(6),
      ),

      child: Center(

        child: Text(

          value,

          style: const TextStyle(
            color: Colors.orange,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Column(

      mainAxisAlignment:
          MainAxisAlignment.center,

      children: [

        buildBox("30"),

        const SizedBox(height: 3),

        buildBox("20"),

        const SizedBox(height: 3),

        buildBox("10")

            .animate(
              onPlay: (controller) =>
                  controller.repeat(
                      reverse: true),
            )

            .moveY(
              begin: 0,
              end: -2,
              duration: 700.ms,
            ),
      ],
    );
  }
}