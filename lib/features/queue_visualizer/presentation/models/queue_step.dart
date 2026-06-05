/// Represents one animation frame of a queue operation.
///
/// [queue]          — current queue snapshot (index 0 = front, last = rear)
/// [highlightIdx]   — index of the element being highlighted right now
/// [floatingValue]  — value shown animating in (enqueue) or out (dequeue)
/// [floatingState]  — 'incoming' | 'landing' | 'outgoing' | 'ejected' | null
/// [phase]          — 'idle'|'enqueuing'|'enqueued'|'dequeuing'|'dequeued'
///                    |'overflow'|'underflow'
/// [statusMsg]      — description shown in the status banner
/// [stepNumber]     — step counter for progress bar
/// [operation]      — 'enqueue' | 'dequeue' | 'peek' | 'none'
/// [frontIdx]       — always 0 when queue is non-empty, else -1
/// [rearIdx]        — queue.length - 1 when non-empty, else -1
class QueueStep {
  final List<int> queue;
  final int? highlightIdx;
  final int? floatingValue;
  final String? floatingState;
  final String phase;
  final String statusMsg;
  final int stepNumber;
  final String operation;
  final int frontIdx;
  final int rearIdx;

  QueueStep({
    required this.queue,
    this.highlightIdx,
    this.floatingValue,
    this.floatingState,
    this.phase = 'idle',
    this.statusMsg = '',
    this.stepNumber = 0,
    this.operation = 'none',
  })  : frontIdx = queue.isEmpty ? -1 : 0,
        rearIdx  = queue.isEmpty ? -1 : queue.length - 1;
}