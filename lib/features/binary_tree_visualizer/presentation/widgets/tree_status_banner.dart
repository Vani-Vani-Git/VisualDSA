import 'package:flutter/material.dart';
import '../models/tree_node.dart';

class TreeStatusBanner extends StatelessWidget {
  final String message;
  final TreePhase phase;

  const TreeStatusBanner({
    super.key,
    required this.message,
    required this.phase,
  });

  @override
  Widget build(BuildContext context) {
    Color bg, textColor;
    IconData icon;

    switch (phase) {
      case TreePhase.inserting:
        bg = const Color(0xFF22C55E).withOpacity(0.13);
        textColor = const Color(0xFF22C55E);
        icon = Icons.add_circle_outline;
        break;
      case TreePhase.deleting:
        bg = const Color(0xFFEF4444).withOpacity(0.13);
        textColor = const Color(0xFFEF4444);
        icon = Icons.remove_circle_outline;
        break;
      case TreePhase.replacing:
        bg = const Color(0xFFF97316).withOpacity(0.13);
        textColor = const Color(0xFFF97316);
        icon = Icons.swap_horiz;
        break;
      case TreePhase.removingDeepest:
        bg = const Color(0xFFF59E0B).withOpacity(0.13);
        textColor = const Color(0xFFF59E0B);
        icon = Icons.delete_outline;
        break;
      case TreePhase.visiting:
        bg = const Color(0xFF3B82F6).withOpacity(0.13);
        textColor = const Color(0xFF93C5FD);
        icon = Icons.visibility_outlined;
        break;
      case TreePhase.comparing:
        bg = const Color(0xFFA78BFA).withOpacity(0.13);
        textColor = const Color(0xFFA78BFA);
        icon = Icons.search;
        break;
      case TreePhase.done:
        bg = const Color(0xFF22C55E).withOpacity(0.13);
        textColor = const Color(0xFF22C55E);
        icon = Icons.check_circle_outline;
        break;
      default:
        bg = const Color(0xFF3B82F6).withOpacity(0.10);
        textColor = const Color(0xFF93C5FD);
        icon = Icons.info_outline;
    }

    final msg = message.isNotEmpty
        ? message
        : 'Select an operation and press Run / Insert / Delete.';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: textColor.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: textColor, size: 15),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              msg,
              style: TextStyle(
                color: textColor,
                fontSize: 12,
                fontFamily: 'monospace',
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}