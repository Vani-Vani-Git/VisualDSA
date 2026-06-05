import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class QueuePreview extends StatelessWidget {

  const QueuePreview({
    super.key,
  });

  Widget buildNode(
    String value,
    bool active,
  ) {

    return Container(

      width: 36,
      height: 30,

      decoration: BoxDecoration(

        color: active

            ? Colors.tealAccent
                .withOpacity(0.12)

            : Colors.transparent,

        border: Border.all(

          color: Colors.tealAccent,

          width: 1.4,
        ),

        borderRadius:
            BorderRadius.circular(6),
      ),

      child: Center(

        child: Text(

          value,

          style: const TextStyle(

            color: Colors.tealAccent,

            fontSize: 12,

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

    return Center(

      child: Transform.scale(

        scale: 0.82,

        child: Row(

          mainAxisSize:
              MainAxisSize.min,

          children: [

            buildNode(
                "10", false),

            const SizedBox(
                width: 3),

            const Icon(

              Icons.arrow_forward,

              color:
                  Colors.tealAccent,

              size: 12,
            ),

            const SizedBox(
                width: 3),

            buildNode(
                "20", false),

            const SizedBox(
                width: 3),
          ],
        ),
      ),
    );
  }
}