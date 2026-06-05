import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// INSERT ANIMATION
//
// Visual sequence (matches target video):
//   1. Highlight insertion index in yellow
//   2. Shift elements right one-by-one from the end down to insertIndex
//      — each shift: source cell empties (blank), target cell fills
//   3. Drop new value into the now-empty slot (green flash + scale-in)
// ─────────────────────────────────────────────────────────────────────────────

/// Holds the transient render state for the insert animation.
/// The [ArrayVisualizerCanvas] reads this to decide how to draw each cell.
class InsertAnimState {
  /// Index that is currently highlighted as the target slot (yellow)
  final int? targetIndex;

  /// Which cell is currently empty/blank during the shifting phase
  final int? emptyIndex;

  /// Which cell is currently being highlighted as "just shifted" (moving right)
  final int? shiftingIndex;

  /// The index of the newly inserted element (green glow)
  final int? insertedIndex;

  const InsertAnimState({
    this.targetIndex,
    this.emptyIndex,
    this.shiftingIndex,
    this.insertedIndex,
  });

  static const idle = InsertAnimState();
}

/// Runs the full step-by-step insert animation and calls [setState] between
/// each phase so the UI re-renders.
///
/// [array]      — the live array (will be mutated at the right moment)
/// [value]      — value to insert
/// [index]      — insertion index
/// [onState]    — called whenever the animation state changes
/// [onArrayChanged] — called with the mutated array once the insert happens
Future<void> runInsertAnimation({
  required List<int> array,
  required int value,
  required int index,
  required void Function(InsertAnimState) onState,
  required void Function(List<int>) onArrayChanged,
  Duration stepDelay = const Duration(milliseconds: 320),
}) async {
  if (index < 0 || index > array.length) return;

  // Phase 1 — highlight target index
  onState(InsertAnimState(targetIndex: index));
  await Future.delayed(stepDelay);

  // Phase 2 — shift elements right one-by-one from end → index
  // First extend the array with a placeholder at the end
  final arr = List<int>.from(array);
  arr.add(0); // temporary placeholder for the new slot

  for (int i = arr.length - 1; i > index; i--) {
    // Show element at i-1 moving into position i
    onState(InsertAnimState(
      targetIndex: index,
      emptyIndex: i - 1,
      shiftingIndex: i,
    ));
    arr[i] = arr[i - 1];
    onArrayChanged(List<int>.from(arr));
    await Future.delayed(stepDelay);
  }

  // Phase 3 — place new value into the empty slot
  arr[index] = value;
  onArrayChanged(List<int>.from(arr));
  onState(InsertAnimState(insertedIndex: index));
  await Future.delayed(const Duration(milliseconds: 600));

  // Done
  onState(InsertAnimState.idle);
}