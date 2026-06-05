import 'package:flutter/material.dart';

class TagChip extends StatelessWidget {

  final String text;

  const TagChip({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {

    return Container(

      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),

      decoration: BoxDecoration(

        color: Colors.white.withOpacity(0.08),

        borderRadius:
            BorderRadius.circular(8),
      ),

      child: Text(

        text,
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
        style: const TextStyle(
          fontSize: 12,
          color: Colors.white70,
        ),
      ),
    );
  }
}