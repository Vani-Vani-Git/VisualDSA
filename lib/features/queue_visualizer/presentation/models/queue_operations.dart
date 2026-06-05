import 'queue_step.dart';

class QueueOperations {
  static const int maxSize = 7;

  // ── ENQUEUE ────────────────────────────────────────────────────────────────
  // Frames: element slides in from right → lands at rear → settled
  static List<QueueStep> enqueue(List<int> current, int value) {
    final steps = <QueueStep>[];

    if (current.length >= maxSize) {
      steps.add(QueueStep(
        queue: List.from(current),
        phase: 'overflow',
        statusMsg:
            'Queue Full! Cannot enqueue $value — queue has reached max size ($maxSize).',
        stepNumber: 1,
        operation: 'enqueue',
      ));
      return steps;
    }

    // Frame 1 — element floating to the right of the queue (incoming)
    steps.add(QueueStep(
      queue: List.from(current),
      floatingValue: value,
      floatingState: 'incoming',
      phase: 'enqueuing',
      statusMsg:
          'Enqueue($value): New element $value is ready to join at the REAR of the queue.',
      stepNumber: 1,
      operation: 'enqueue',
    ));

    // Frame 2 — element landing at rear (queue now contains it)
    final newQueue = [...current, value];
    steps.add(QueueStep(
      queue: List.from(newQueue),
      highlightIdx: newQueue.length - 1,
      floatingValue: value,
      floatingState: 'landing',
      phase: 'enqueuing',
      statusMsg:
          'Enqueue($value): $value is placed at rear[${newQueue.length - 1}]. '
          'rear pointer moves right.',
      stepNumber: 2,
      operation: 'enqueue',
    ));

    // Frame 3 — settled, highlight stays briefly
    steps.add(QueueStep(
      queue: List.from(newQueue),
      highlightIdx: newQueue.length - 1,
      phase: 'enqueued',
      statusMsg:
          'Enqueue($value): Done! Queue size = ${newQueue.length}/$maxSize. '
          'front=${newQueue.first}  rear=${newQueue.last}.',
      stepNumber: 3,
      operation: 'enqueue',
    ));

    return steps;
  }

  // ── DEQUEUE ────────────────────────────────────────────────────────────────
  // Frames: front highlighted → slides out left → queue shrinks, front pointer moves
  static List<QueueStep> dequeue(List<int> current) {
    final steps = <QueueStep>[];

    if (current.isEmpty) {
      steps.add(QueueStep(
        queue: [],
        phase: 'underflow',
        statusMsg: 'Queue Empty! Cannot dequeue — the queue has no elements.',
        stepNumber: 1,
        operation: 'dequeue',
      ));
      return steps;
    }

    final frontValue = current.first;

    // Frame 1 — highlight front element
    steps.add(QueueStep(
      queue: List.from(current),
      highlightIdx: 0,
      phase: 'dequeuing',
      statusMsg:
          'Dequeue(): front element is $frontValue at index [0]. '
          'It will be removed.',
      stepNumber: 1,
      operation: 'dequeue',
    ));

    // Frame 2 — element flying out to the left
    steps.add(QueueStep(
      queue: List.from(current),
      highlightIdx: 0,
      floatingValue: frontValue,
      floatingState: 'outgoing',
      phase: 'dequeuing',
      statusMsg:
          'Dequeue(): $frontValue is leaving from the FRONT. '
          'front pointer moves right.',
      stepNumber: 2,
      operation: 'dequeue',
    ));

    // Frame 3 — queue shrinks, front pointer now points to new front
    final newQueue = current.sublist(1);
    steps.add(QueueStep(
      queue: List.from(newQueue),
      floatingValue: frontValue,
      floatingState: 'ejected',
      phase: 'dequeued',
      statusMsg: newQueue.isEmpty
          ? 'Dequeue(): Done! $frontValue removed. Queue is now empty.'
          : 'Dequeue(): Done! $frontValue removed. '
              'New front=${newQueue.first}. Queue size = ${newQueue.length}/$maxSize.',
      stepNumber: 3,
      operation: 'dequeue',
    ));

    return steps;
  }

  // ── PEEK ───────────────────────────────────────────────────────────────────
  static List<QueueStep> peek(List<int> current) {
    if (current.isEmpty) {
      return [
        QueueStep(
          queue: [],
          phase: 'underflow',
          statusMsg: 'Peek(): Queue is empty — nothing to peek at.',
          stepNumber: 1,
          operation: 'peek',
        )
      ];
    }
    return [
      QueueStep(
        queue: List.from(current),
        highlightIdx: 0,
        phase: 'enqueued',
        statusMsg:
            'Peek(): Front element is ${current.first}. '
            'No element is removed.',
        stepNumber: 1,
        operation: 'peek',
      )
    ];
  }

  // ── ENQUEUE ALL (Apply / Random — fills queue from array input) ─────────────
  // Chains sequential enqueue animations for every element.
  static List<QueueStep> enqueueAll(List<int> values) {
    final steps = <QueueStep>[];
    List<int> current = [];
    int stepNum = 0;

    // Opening frame — empty queue
    steps.add(QueueStep(
      queue: [],
      phase: 'idle',
      statusMsg:
          'Loading [${values.join(', ')}] into queue — '
          'enqueuing elements one by one from the rear.',
      stepNumber: stepNum,
      operation: 'enqueue',
    ));

    for (int i = 0; i < values.length; i++) {
      final value = values[i];

      if (current.length >= maxSize) {
        steps.add(QueueStep(
          queue: List.from(current),
          phase: 'overflow',
          statusMsg:
              'Queue Full! Stopped at $value — max size $maxSize reached. '
              '${values.length - i} element(s) skipped.',
          stepNumber: ++stepNum,
          operation: 'enqueue',
        ));
        break;
      }

      // Frame A — incoming from right
      steps.add(QueueStep(
        queue: List.from(current),
        floatingValue: value,
        floatingState: 'incoming',
        phase: 'enqueuing',
        statusMsg:
            'Enqueue($value): Element ${i + 1} of ${values.length} — '
            '$value approaching from the right.',
        stepNumber: ++stepNum,
        operation: 'enqueue',
      ));

      // Frame B — landing at rear
      current = [...current, value];
      steps.add(QueueStep(
        queue: List.from(current),
        highlightIdx: current.length - 1,
        floatingValue: value,
        floatingState: 'landing',
        phase: 'enqueuing',
        statusMsg:
            'Enqueue($value): Placed at rear[${current.length - 1}]. '
            'rear pointer → [${current.length - 1}].',
        stepNumber: ++stepNum,
        operation: 'enqueue',
      ));

      // Frame C — settled
      steps.add(QueueStep(
        queue: List.from(current),
        highlightIdx: current.length - 1,
        phase: 'enqueued',
        statusMsg:
            'Enqueue($value): Done! Queue size = ${current.length}/$maxSize.',
        stepNumber: ++stepNum,
        operation: 'enqueue',
      ));
    }

    // Final idle frame
    if (steps.last.phase != 'overflow') {
      steps.add(QueueStep(
        queue: List.from(current),
        phase: 'idle',
        statusMsg: current.isEmpty
            ? 'Queue is empty. Select an operation below.'
            : 'Array loaded! Queue: [${current.join(' ← ')}]  '
                'front=${current.first}  rear=${current.last}. '
                'Select an operation below.',
        stepNumber: ++stepNum,
        operation: 'enqueue',
      ));
    }

    return steps;
  }
}