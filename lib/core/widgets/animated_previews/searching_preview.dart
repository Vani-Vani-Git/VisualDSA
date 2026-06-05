import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SearchingPreview extends StatelessWidget {
  const SearchingPreview({super.key});

  @override
  Widget build(BuildContext context) {

    return Center(

      child: Icon(
        Icons.search,
        color: Colors.green,
        size: 50,
      )

      .animate(
        onPlay: (controller) =>
            controller.repeat(),
      )

      .scale(
        duration: 1000.ms,
        begin: const Offset(0.8, 0.8),
        end: const Offset(1.2, 1.2),
      ),
    );
  }
}