import 'package:flutter/material.dart';
import '../models/bst_node.dart';

class BSTStepHeader extends StatelessWidget {
  final BSTStep? step;

  const BSTStepHeader({super.key, this.step});

  @override
  Widget build(BuildContext context) {
    final s = step;

    Color phaseColor;
    switch (s?.phase) {
      case BSTPhase.found:
        phaseColor = const Color(0xFF22C55E);
        break;
      case BSTPhase.notFound:
        phaseColor = const Color(0xFFEF4444);
        break;
      case BSTPhase.inserting:
        phaseColor = const Color(0xFF22C55E);
        break;
      case BSTPhase.deleting:
        phaseColor = const Color(0xFFEF4444);
        break;
      case BSTPhase.tempNode:
        phaseColor = const Color(0xFFF59E0B);
        break;
      case BSTPhase.goLeft:
      case BSTPhase.goRight:
        phaseColor = const Color(0xFF3B82F6);
        break;
      case BSTPhase.done:
        phaseColor = const Color(0xFF22C55E);
        break;
      default:
        phaseColor = const Color(0xFF4CAF50);
    }

    if (s == null) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF161B22),
          border: Border.all(color: const Color(0xFF21262D)),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            // Step badge placeholder
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFF21262D),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Center(
                child: Text('--',
                    style: TextStyle(
                      color: Color(0xFF4B5563),
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      fontFamily: 'monospace',
                    )),
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Select an operation and run to begin visualization.',
                style: TextStyle(
                  color: Color(0xFF8B949E),
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

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        border: Border.all(color: phaseColor.withOpacity(0.35)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step badge — matching video: bold green number + "Step" label
          Container(
            width: 46,
            padding: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              color: phaseColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: phaseColor.withOpacity(0.4)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  s.stepNumber,
                  style: TextStyle(
                    color: phaseColor,
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                    fontFamily: 'monospace',
                    height: 1.1,
                  ),
                ),
                Text(
                  'Step',
                  style: TextStyle(
                    color: phaseColor.withOpacity(0.7),
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.stepTitle,
                  style: const TextStyle(
                    color: Color(0xFFE2E8F0),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'monospace',
                    height: 1.4,
                  ),
                ),
                if (s.sideNote.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    s.sideNote,
                    style: TextStyle(
                      color: phaseColor.withOpacity(0.85),
                      fontSize: 11,
                      fontFamily: 'monospace',
                      height: 1.4,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}