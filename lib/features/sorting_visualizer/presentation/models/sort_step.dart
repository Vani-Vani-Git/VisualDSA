/// Represents a single step in a sorting algorithm animation.
///
/// Shared fields:
/// [array]       — current array snapshot
/// [comparing]   — indices being compared (bold border highlight)
/// [swapping]    — indices being swapped (highlighted)
/// [sorted]      — indices in their final sorted position
/// [sortedCount] — how many elements are confirmed sorted from the RIGHT (bubble)
///                 or from the LEFT (selection/insertion) — used to draw the bracket
/// [statusMsg]   — descriptive message shown below the visualization
///
/// Selection Sort specific:
/// [minIndex]    — index currently holding the running minimum (shows "min" pointer)
/// [scanIndex]   — index currently being scanned/compared against min
///
/// Insertion Sort specific:
/// [keyValue]    — the value extracted as the "key" (shown below the array)
/// [keyIndex]    — position BELOW which the key value is displayed
/// [emptyIndex]  — index of the blank slot (the gap left by extracting the key)
///
/// Quick / Merge:
/// [pivot]       — pivot index (orange highlight)
/// [merging]     — indices in the merge window (cyan highlight)
class SortStep {
  final List<int> array;
  final Set<int> comparing;
  final Set<int> swapping;
  final Set<int> sorted;
  final int? pivot;
  final Set<int> merging;
  final String statusMsg;

  // Selection sort
  final int? minIndex;
  final int? scanIndex;

  // Insertion sort
  final int? keyValue;
  final int? keyIndex;
  final int? emptyIndex;

  // How many elements are in the "Sorted" bracket (used to draw bracket + label)
  // Positive = sorted from the RIGHT end (bubble sort)
  // Negative magnitude = sorted from the LEFT end (selection/insertion)
  // 0 = no bracket
  final int sortedFromRight; // bubble sort: how many confirmed at the right
  final int sortedFromLeft;  // selection/insertion: how many confirmed at the left

  const SortStep({
    required this.array,
    this.comparing = const {},
    this.swapping = const {},
    this.sorted = const {},
    this.pivot,
    this.merging = const {},
    this.statusMsg = '',
    this.minIndex,
    this.scanIndex,
    this.keyValue,
    this.keyIndex,
    this.emptyIndex,
    this.sortedFromRight = 0,
    this.sortedFromLeft = 0,
  });
}