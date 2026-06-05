/// Represents one animation frame of a stack operation.
///
/// [stack]        — current stack snapshot (bottom index 0, top = last)
/// [highlightIdx] — index of the element being pushed/popped right now
/// [floatingValue]— value shown floating above (push) or flying out (pop)
/// [floatingState]— 'incoming' | 'outgoing' | null
/// [phase]        — 'idle' | 'pushing' | 'pushed' | 'popping' | 'popped' | 'overflow' | 'underflow'
/// [statusMsg]    — description shown in the status banner
/// [stepNumber]   — human-readable step counter
/// [operation]    — 'push' | 'pop' | 'peek' | 'none'
/// [topIdx]       — index of the top element (stack.length - 1), -1 if empty
class StackStep {
  final List<int> stack;
  final int? highlightIdx;
  final int? floatingValue;
  final String? floatingState; // 'incoming' | 'outgoing'
  final String phase;
  final String statusMsg;
  final int stepNumber;
  final String operation;
  final int topIdx;

 StackStep({
    required this.stack,
    this.highlightIdx,
    this.floatingValue,
    this.floatingState,
    this.phase = 'idle',
    this.statusMsg = '',
    this.stepNumber = 0,
    this.operation = 'none',
    int? topIdx,
  }) : topIdx = topIdx ?? (stack.isEmpty ? -1 : stack.length - 1);
}