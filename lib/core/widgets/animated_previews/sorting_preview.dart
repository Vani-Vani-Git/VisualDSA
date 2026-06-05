import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SortingPreview extends StatelessWidget {
  const SortingPreview({super.key});

  @override
  Widget build(BuildContext context) {

    final bars = [40.0, 70.0, 55.0, 90.0, 35.0];

    return SizedBox(
      height: 90,

      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceEvenly,

        crossAxisAlignment:
            CrossAxisAlignment.end,

        children: List.generate(

          bars.length,

          (index) {

            return Container(
              width: 14,
              height: bars[index],

              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius:
                    BorderRadius.circular(6),
              ),
            )

            .animate(
              onPlay: (controller) =>
                  controller.repeat(
                    reverse: true,
                  ),
            )

            .scaleY(
              duration: 700.ms,
              begin: 0.7,
              end: 1.1,

              delay: (index * 100).ms,
            );
          },
        ),
      ),
    );
  }
}