import 'package:flutter/material.dart';
import '../models/ll_step.dart';

class LLStatusBanner extends StatelessWidget {
  final LLStep? step;
  const LLStatusBanner({super.key, this.step});

  @override
  Widget build(BuildContext context) {
    Color bg, textColor;
    IconData icon;

    switch (step?.phase) {
      case LLPhase.done:
        bg = const Color(0xFF22C55E).withOpacity(0.13);
        textColor = const Color(0xFF22C55E);
        icon = Icons.check_circle_outline;
        break;
      case LLPhase.found:
        bg = const Color(0xFF22C55E).withOpacity(0.13);
        textColor = const Color(0xFF22C55E);
        icon = Icons.search;
        break;
      case LLPhase.notFound:
        bg = const Color(0xFFEF4444).withOpacity(0.13);
        textColor = const Color(0xFFEF4444);
        icon = Icons.cancel_outlined;
        break;
      case LLPhase.deleteHead:
      case LLPhase.deleteTail:
      case LLPhase.deleteMiddle:
        bg = const Color(0xFFEF4444).withOpacity(0.10);
        textColor = const Color(0xFFFC8181);
        icon = Icons.remove_circle_outline;
        break;
      case LLPhase.insertHead:
      case LLPhase.insertTail:
      case LLPhase.insertMiddle:
        bg = const Color(0xFF22C55E).withOpacity(0.10);
        textColor = const Color(0xFF86EFAC);
        icon = Icons.add_circle_outline;
        break;
      case LLPhase.searching:
        bg = const Color(0xFFF59E0B).withOpacity(0.10);
        textColor = const Color(0xFFFCD34D);
        icon = Icons.manage_search;
        break;
      default:
        bg = const Color(0xFF3B82F6).withOpacity(0.10);
        textColor = const Color(0xFF93C5FD);
        icon = Icons.info_outline;
    }

    final msg = step?.statusMsg.isNotEmpty == true
        ? step!.statusMsg
        : 'Select an operation and run to begin.';

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