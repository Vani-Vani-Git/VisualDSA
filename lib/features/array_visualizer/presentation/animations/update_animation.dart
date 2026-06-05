import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// UPDATE ANIMATION
//
// Visual sequence:
//   1. Highlight target cell in cyan (pulse)
//   2. Flash old value out (cell goes blank briefly)
//   3. New value appears with green color + scale-in pop
//   4. Return to normal
// ─────────────────────────────────────────────────────────────────────────────

class UpdateAnimState {
  /// Cell being targeted (cyan pulse)
  final int? targetIndex;

  /// Cell is blank (old value wiped)
  final int? blankIndex;

  /// Cell just received new value (green pop)
  final int? updatedIndex;

  const UpdateAnimState({
    this.targetIndex,
    this.blankIndex,
    this.updatedIndex,
  });

  static const idle = UpdateAnimState();
}

Future<void> runUpdateAnimation({
  required List<int> array,
  required int value,
  required int index,
  required void Function(UpdateAnimState) onState,
  required void Function(List<int>) onArrayChanged,
  Duration stepDelay = const Duration(milliseconds: 350),
}) async {
  if (index < 0 || index >= array.length) return;

  // Phase 1 — highlight target (cyan)
  onState(UpdateAnimState(targetIndex: index));
  await Future.delayed(stepDelay);

  // Phase 2 — blank out old value
  onState(UpdateAnimState(blankIndex: index));
  await Future.delayed(stepDelay);

  // Phase 3 — set new value and show green pop
  final arr = List<int>.from(array);
  arr[index] = value;
  onArrayChanged(arr);
  onState(UpdateAnimState(updatedIndex: index));
  await Future.delayed(const Duration(milliseconds: 600));

  // Done
  onState(UpdateAnimState.idle);
}