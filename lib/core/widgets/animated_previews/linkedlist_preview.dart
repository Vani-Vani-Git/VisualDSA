import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class LinkedListPreview extends StatelessWidget {
  const LinkedListPreview({super.key});

  Widget node() {

    return Container(
      width: 18,
      height: 18,

      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius:
            BorderRadius.circular(5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Row(

      mainAxisAlignment:
          MainAxisAlignment.center,

      children: [

        node(),

        const Icon(
          Icons.arrow_forward,
          size: 18,
          color: Colors.white,
        ),

        node(),

        const Icon(
          Icons.arrow_forward,
          size: 18,
          color: Colors.white,
        ),

        node(),
      ],
    )

    .animate(
      onPlay: (controller) =>
          controller.repeat(reverse: true),
    )

    .moveX(
      begin: -3,
      end: 3,
      duration: 1000.ms,
    );
  }
}