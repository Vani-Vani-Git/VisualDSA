import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// DELETE ANIMATION
//
// Visual sequence (matches target video):
//   1. Highlight the deletion index in red (element still visible)
//   2. Blank out that slot (gap appears)
//   3. Shift elements LEFT one-by-one from index+1 to end
//      — each step: source fills blank, source goes empty
//   4. Last slot becomes blank (array shrinks by 1)
// ─────────────────────────────────────────────────────────────────────────────

class DeleteAnimState {
  /// Cell highlighted red before deletion
  final int? targetIndex;

  /// Cell that is blank (empty) mid-animation
  final int? emptyIndex;

  /// Cell currently being highlighted as "just shifted left"
  final int? shiftingIndex;

  const DeleteAnimState({
    this.targetIndex,
    this.emptyIndex,
    this.shiftingIndex,
  });

  static const idle = DeleteAnimState();
}

Future<void> runDeleteAnimation({
  required List<int> array,
  required int index,
  required void Function(DeleteAnimState) onState,
  required void Function(List<int>) onArrayChanged,
  Duration stepDelay = const Duration(milliseconds: 320),
}) async {
  if (index < 0 || index >= array.length) return;

  final arr = List<int>.from(array);

  // Phase 1 — highlight the element to be deleted (red)
  onState(DeleteAnimState(targetIndex: index));
  await Future.delayed(stepDelay);

  // Phase 2 — blank out the target slot
  onState(DeleteAnimState(emptyIndex: index));
  await Future.delayed(stepDelay);

  // Phase 3 — shift elements left one-by-one
  for (int i = index; i < arr.length - 1; i++) {
    // element at i+1 moves into i
    onState(DeleteAnimState(
      emptyIndex: i + 1,
      shiftingIndex: i,
    ));
    arr[i] = arr[i + 1];
    onArrayChanged(List<int>.from(arr));
    await Future.delayed(stepDelay);
  }

  // Phase 4 — remove the last (now-duplicate) element
  arr.removeLast();
  onArrayChanged(List<int>.from(arr));
  onState(DeleteAnimState.idle);
}