import 'stack_step.dart';

class StackOperations {
  static const int maxSize = 8;

  // ── PUSH ───────────────────────────────────────────────────────────────────
  // Generates frames: floating value incoming → lands on top
  static List<StackStep> push(List<int> currentStack, int value) {
    final steps = <StackStep>[];

    // Overflow check
    if (currentStack.length >= maxSize) {
      steps.add(StackStep(
        stack: List.from(currentStack),
        phase: 'overflow',
        statusMsg: 'Stack Overflow! Cannot push $value — stack is full (max $maxSize).',
        stepNumber: 1,
        operation: 'push',
      ));
      return steps;
    }

    // Step 1: Show value floating above stack (incoming)
    steps.add(StackStep(
      stack: List.from(currentStack),
      floatingValue: value,
      floatingState: 'incoming',
      phase: 'pushing',
      statusMsg: 'Push($value): New element $value is ready to enter the stack from the top.',
      stepNumber: 1,
      operation: 'push',
    ));

    // Step 2: Element landing — highlight top slot
    final newStack = [...currentStack, value];
    steps.add(StackStep(
      stack: List.from(newStack),
      highlightIdx: newStack.length - 1,
      floatingValue: value,
      floatingState: 'landing',
      phase: 'pushing',
      statusMsg: 'Push($value): Placing $value on top of the stack. top pointer moves up.',
      stepNumber: 2,
      operation: 'push',
    ));

    // Step 3: Settled — highlight fades
    steps.add(StackStep(
      stack: List.from(newStack),
      highlightIdx: newStack.length - 1,
      phase: 'pushed',
      statusMsg: 'Push($value): Done! $value is now the top of the stack. Stack size = ${newStack.length}.',
      stepNumber: 3,
      operation: 'push',
    ));

    return steps;
  }

  // ── POP ────────────────────────────────────────────────────────────────────
  // Generates frames: top highlighted → flies out above → stack shrinks
  static List<StackStep> pop(List<int> currentStack) {
    final steps = <StackStep>[];

    // Underflow check
    if (currentStack.isEmpty) {
      steps.add(StackStep(
        stack: [],
        phase: 'underflow',
        statusMsg: 'Stack Underflow! Cannot pop — stack is empty.',
        stepNumber: 1,
        operation: 'pop',
      ));
      return steps;
    }

    final topValue = currentStack.last;

    // Step 1: Highlight top element
    steps.add(StackStep(
      stack: List.from(currentStack),
      highlightIdx: currentStack.length - 1,
      phase: 'popping',
      statusMsg: 'Pop(): Top element is $topValue. It will be removed from the stack.',
      stepNumber: 1,
      operation: 'pop',
    ));

    // Step 2: Element flying out (still in stack visually but flagged outgoing)
    steps.add(StackStep(
      stack: List.from(currentStack),
      highlightIdx: currentStack.length - 1,
      floatingValue: topValue,
      floatingState: 'outgoing',
      phase: 'popping',
      statusMsg: 'Pop(): $topValue is leaving the stack. top pointer moves down.',
      stepNumber: 2,
      operation: 'pop',
    ));

    // Step 3: Stack shrinks, value gone
    final newStack = currentStack.sublist(0, currentStack.length - 1);
    steps.add(StackStep(
      stack: List.from(newStack),
      phase: 'popped',
      floatingValue: topValue,
      floatingState: 'ejected',
      statusMsg: 'Pop(): Done! $topValue has been removed. Stack size = ${newStack.length}.',
      stepNumber: 3,
      operation: 'pop',
    ));

    return steps;
  }

  // ── PUSH ALL (used when Apply / Random fills the stack from array input) ───
  // Generates a chained sequence of push frames for every element in [values].
  // Each element animates: floating → landing → settled, then the next begins.
  // stepNumber is global across the whole sequence so the progress bar is smooth.
  static List<StackStep> pushAll(List<int> values) {
    final steps = <StackStep>[];
    List<int> current = [];
    int stepNum = 0;

    // Opening idle frame — empty stack, shows "Loading array..."
    steps.add(StackStep(
      stack: [],
      phase: 'idle',
      statusMsg: 'Loading array [${values.join(', ')}] into stack — pushing elements one by one.',
      stepNumber: stepNum,
      operation: 'push',
    ));

    for (int i = 0; i < values.length; i++) {
      final value = values[i];

      if (current.length >= maxSize) {
        // Overflow: stop here, show warning for remaining elements
        steps.add(StackStep(
          stack: List.from(current),
          phase: 'overflow',
          statusMsg:
              'Stack Overflow! Stopped at element $value — stack is full (max $maxSize). '
              '${values.length - i} element(s) skipped.',
          stepNumber: ++stepNum,
          operation: 'push',
        ));
        break;
      }

      // Frame A — element floating above
      steps.add(StackStep(
        stack: List.from(current),
        floatingValue: value,
        floatingState: 'incoming',
        phase: 'pushing',
        statusMsg:
            'Push($value): Element ${i + 1} of ${values.length} — '
            '$value is entering the stack.',
        stepNumber: ++stepNum,
        operation: 'push',
      ));

      // Frame B — landing (stack already contains the new value)
      current = [...current, value];
      steps.add(StackStep(
        stack: List.from(current),
        highlightIdx: current.length - 1,
        floatingValue: value,
        floatingState: 'landing',
        phase: 'pushing',
        statusMsg:
            'Push($value): Placing $value on top. top pointer → [${current.length - 1}].',
        stepNumber: ++stepNum,
        operation: 'push',
      ));

      // Frame C — settled
      steps.add(StackStep(
        stack: List.from(current),
        highlightIdx: current.length - 1,
        phase: 'pushed',
        statusMsg:
            'Push($value): Done! Stack size = ${current.length}/${maxSize}.',
        stepNumber: ++stepNum,
        operation: 'push',
      ));
    }

    // Final idle frame — full stack, no highlight
    if (steps.last.phase != 'overflow') {
      steps.add(StackStep(
        stack: List.from(current),
        phase: 'idle',
        statusMsg:
            'Array loaded! Stack contains [${current.join(', ')}] — '
            'top: ${current.isNotEmpty ? current.last : '–'}. '
            'Now select an operation below.',
        stepNumber: ++stepNum,
        operation: 'push',
      ));
    }

    return steps;
  }

  // ── PEEK ───────────────────────────────────────────────────────────────────
  static List<StackStep> peek(List<int> currentStack) {
    if (currentStack.isEmpty) {
      return [
        StackStep(
          stack: [],
          phase: 'underflow',
          statusMsg: 'Peek(): Stack is empty — nothing to peek at.',
          stepNumber: 1,
          operation: 'peek',
        )
      ];
    }
    return [
      StackStep(
        stack: List.from(currentStack),
        highlightIdx: currentStack.length - 1,
        phase: 'pushed',
        statusMsg: 'Peek(): Top element is ${currentStack.last}. No element is removed.',
        stepNumber: 1,
        operation: 'peek',
      )
    ];
  }
}