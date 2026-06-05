/// One animation frame for any heap operation.
///
/// [heap]          — array representation of the heap (index 0 = root)
/// [heapType]      — 'max' | 'min'
/// [phase]         — 'idle'|'inserting'|'inserted'|'heapify_up'|'swapping_up'
///                   |'deleting'|'heapify_down'|'swapping_down'|'deleted'
///                   |'sorting'|'sorted'|'overflow'|'underflow'|'updated'
/// [highlightA]    — first node index involved in current comparison/swap
/// [highlightB]    — second node index involved in current comparison/swap
/// [sortedIndices] — indices already placed in sorted position (green, heap-sort)
/// [swapSymbol]    — '≥' for max-heap, '≤' for min-heap (shown on edge)
/// [showSwap]      — whether to show the swap symbol between highlightA & B
/// [statusMsg]     — text shown in the status banner
/// [stepNumber]    — step counter
/// [operation]     — 'insert'|'delete'|'update'|'sort'|'build'|'none'
/// [sortedArray]   — final sorted output (only for sort phase)
class HeapStep {
  final List<int> heap;
  final String heapType;
  final String phase;
  final int? highlightA;
  final int? highlightB;
  final Set<int> sortedIndices;
  final String swapSymbol;
  final bool showSwap;
  final String statusMsg;
  final int stepNumber;
  final String operation;
  final List<int> sortedArray;

  const HeapStep({
    required this.heap,
    this.heapType = 'max',
    this.phase = 'idle',
    this.highlightA,
    this.highlightB,
    this.sortedIndices = const {},
    this.swapSymbol = '≥',
    this.showSwap = false,
    this.statusMsg = '',
    this.stepNumber = 0,
    this.operation = 'none',
    this.sortedArray = const [],
  });
}