import 'package:flutter/material.dart';
import '../animations/insert_animation.dart';
import '../animations/update_animation.dart';
import '../animations/delete_animation.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ArrayVisualizerCanvas
//
// Renders the array as a scrollable row of boxes.
// Handles all operation animation states:
//   • Bubble Sort  — compare (purple), swap (yellow), sorted (green)
//   • Insert       — target (yellow), shifting (orange), empty gap (blank), inserted (green)
//   • Update       — target (cyan), blank, updated (green)
//   • Delete       — target (red), empty gap, shifting (orange), done
// ─────────────────────────────────────────────────────────────────────────────

class ArrayVisualizerCanvas extends StatelessWidget {
  final List<int> array;

  // Bubble sort states
  final Set<int> compareIndices;
  final Set<int> swapIndices;
  final Set<int> sortedIndices;

  // Insert animation state
  final InsertAnimState insertState;

  // Update animation state
  final UpdateAnimState updateState;

  // Delete animation state
  final DeleteAnimState deleteState;

  const ArrayVisualizerCanvas({
    super.key,
    required this.array,
    this.compareIndices = const {},
    this.swapIndices = const {},
    this.sortedIndices = const {},
    this.insertState = InsertAnimState.idle,
    this.updateState = UpdateAnimState.idle,
    this.deleteState = DeleteAnimState.idle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Visualization',
            style: TextStyle(
              color: Color(0xFFE2E8F0),
              fontSize: 16,
              fontWeight: FontWeight.w700,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(array.length, (i) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Column(
                    children: [
                      _buildBox(i),
                      const SizedBox(height: 4),
                      Text(
                        '$i',
                        style: const TextStyle(
                          color: Color(0xFFEF4444),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBox(int i) {
    // Determine the visual state for this cell
    _CellStyle style = _resolveStyle(i);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeInOut,
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: style.bg,
        border: Border.all(color: style.border, width: style.borderWidth),
        borderRadius: BorderRadius.circular(12),
        boxShadow: style.glow
            ? [
                BoxShadow(
                  color: style.border.withOpacity(0.55),
                  blurRadius: 12,
                  spreadRadius: 2,
                )
              ]
            : null,
      ),
      child: Center(
        child: style.blank
            ? const SizedBox() // empty gap
            : AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Text(
                  '${array[i]}',
                  key: ValueKey('${i}_${array[i]}_${style.textColor.value}'),
                  style: TextStyle(
                    color: style.textColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
      ),
    );
  }

  _CellStyle _resolveStyle(int i) {
    // ── INSERT states ─────────────────────────────────────────────────────
    if (insertState.insertedIndex == i) {
      // Newly inserted — green glow
      return _CellStyle(
        bg: const Color(0xFF22C55E).withOpacity(0.22),
        border: const Color(0xFF22C55E),
        textColor: const Color(0xFF22C55E),
        glow: true,
      );
    }
    if (insertState.emptyIndex == i) {
      // Slot is empty (element just shifted out)
      return _CellStyle(
        bg: const Color(0xFF1C2128),
        border: const Color(0xFFF59E0B).withOpacity(0.4),
        textColor: Colors.transparent,
        blank: true,
      );
    }
    if (insertState.shiftingIndex == i) {
      // Element just moved here (orange highlight)
      return _CellStyle(
        bg: const Color(0xFFF59E0B).withOpacity(0.18),
        border: const Color(0xFFF59E0B),
        textColor: const Color(0xFFF59E0B),
        glow: true,
      );
    }
    if (insertState.targetIndex == i) {
      // Target insertion slot (yellow pulse)
      return _CellStyle(
        bg: const Color(0xFFF59E0B).withOpacity(0.15),
        border: const Color(0xFFF59E0B),
        textColor: const Color(0xFFE2E8F0),
        glow: true,
      );
    }

    // ── DELETE states ─────────────────────────────────────────────────────
    if (deleteState.targetIndex == i) {
      // About to be deleted — red glow
      return _CellStyle(
        bg: const Color(0xFFEF4444).withOpacity(0.22),
        border: const Color(0xFFEF4444),
        textColor: const Color(0xFFEF4444),
        glow: true,
      );
    }
    if (deleteState.emptyIndex == i) {
      // Gap — slot is empty
      return _CellStyle(
        bg: const Color(0xFF1C2128),
        border: const Color(0xFFEF4444).withOpacity(0.3),
        textColor: Colors.transparent,
        blank: true,
      );
    }
    if (deleteState.shiftingIndex == i) {
      // Element just shifted left into this position (orange)
      return _CellStyle(
        bg: const Color(0xFFF59E0B).withOpacity(0.18),
        border: const Color(0xFFF59E0B),
        textColor: const Color(0xFFF59E0B),
        glow: true,
      );
    }

    // ── UPDATE states ─────────────────────────────────────────────────────
    if (updateState.updatedIndex == i) {
      // New value just placed — green pop
      return _CellStyle(
        bg: const Color(0xFF22C55E).withOpacity(0.22),
        border: const Color(0xFF22C55E),
        textColor: const Color(0xFF22C55E),
        glow: true,
      );
    }
    if (updateState.blankIndex == i) {
      // Old value wiped — brief blank
      return _CellStyle(
        bg: const Color(0xFF1C2128),
        border: const Color(0xFF22D3EE).withOpacity(0.4),
        textColor: Colors.transparent,
        blank: true,
      );
    }
    if (updateState.targetIndex == i) {
      // Target cell highlighted cyan
      return _CellStyle(
        bg: const Color(0xFF22D3EE).withOpacity(0.18),
        border: const Color(0xFF22D3EE),
        textColor: const Color(0xFF22D3EE),
        glow: true,
      );
    }

    // ── BUBBLE SORT states ────────────────────────────────────────────────
    if (swapIndices.contains(i)) {
      return _CellStyle(
        bg: const Color(0xFFF59E0B).withOpacity(0.18),
        border: const Color(0xFFF59E0B),
        textColor: const Color(0xFFE2E8F0),
        glow: true,
      );
    }
    if (compareIndices.contains(i)) {
      return _CellStyle(
        bg: const Color(0xFFA78BFA).withOpacity(0.18),
        border: const Color(0xFFA78BFA),
        textColor: const Color(0xFFE2E8F0),
        glow: true,
      );
    }
    if (sortedIndices.contains(i)) {
      return _CellStyle(
        bg: const Color(0xFF22C55E).withOpacity(0.13),
        border: const Color(0xFF22C55E),
        textColor: const Color(0xFFE2E8F0),
      );
    }

    // ── Default ───────────────────────────────────────────────────────────
    return _CellStyle(
      bg: const Color(0xFF3B82F6).withOpacity(0.08),
      border: const Color(0xFF3B82F6),
      textColor: const Color(0xFFE2E8F0),
    );
  }
}

// Simple style data class
class _CellStyle {
  final Color bg;
  final Color border;
  final Color textColor;
  final bool glow;
  final bool blank;
  final double borderWidth;

  const _CellStyle({
    required this.bg,
    required this.border,
    required this.textColor,
    this.glow = false,
    this.blank = false,
    this.borderWidth = 2,
  });
}