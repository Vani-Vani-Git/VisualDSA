import 'heap_step.dart';

class HeapOperations {
  static const int maxSize = 15;

  // ── helpers ────────────────────────────────────────────────────────────────
  static String _sym(String type) => type == 'max' ? '≥' : '≤';

  static bool _violates(String type, int parent, int child) =>
      type == 'max' ? child > parent : child < parent;

  static bool _shouldSwapDown(String type, int parent, int child) =>
      type == 'max' ? child > parent : child < parent;

  // ── BUILD from array (Apply / Random) ─────────────────────────────────────
  // Inserts elements one-by-one to show incremental tree growth + heapify-up.
  static List<HeapStep> buildHeap(List<int> values, String type) {
    final steps = <HeapStep>[];
    List<int> heap = [];
    int stepNum = 0;

    steps.add(HeapStep(
      heap: [],
      heapType: type,
      phase: 'idle',
      statusMsg:
          'Building ${type == 'max' ? 'Max' : 'Min'}-Heap from '
          '[${values.join(', ')}] — inserting one by one.',
      stepNumber: stepNum,
      operation: 'build',
    ));

    for (int i = 0; i < values.length && heap.length < maxSize; i++) {
      final val = values[i];
      heap = [...heap, val];

      // Frame: new node appended at end
      steps.add(HeapStep(
        heap: List.from(heap),
        heapType: type,
        phase: 'inserting',
        highlightA: heap.length - 1,
        statusMsg:
            'Insert($val): Added at index [${heap.length - 1}] '
            '(last position). Now heapify up.',
        stepNumber: ++stepNum,
        operation: 'build',
        swapSymbol: _sym(type),
      ));

      // Heapify up
      int idx = heap.length - 1;
      while (idx > 0) {
        final parent = (idx - 1) ~/ 2;
        if (_violates(type, heap[parent], heap[idx])) {
          // Show comparison with swap symbol
          steps.add(HeapStep(
            heap: List.from(heap),
            heapType: type,
            phase: 'swapping_up',
            highlightA: idx,
            highlightB: parent,
            showSwap: true,
            swapSymbol: _sym(type),
            statusMsg:
                'Heapify Up: heap[$idx]=${heap[idx]} ${_sym(type)} '
                'heap[$parent]=${heap[parent]} — swap!',
            stepNumber: ++stepNum,
            operation: 'build',
          ));
          // Do swap
          final tmp = heap[idx];
          heap[idx] = heap[parent];
          heap[parent] = tmp;
          steps.add(HeapStep(
            heap: List.from(heap),
            heapType: type,
            phase: 'heapify_up',
            highlightA: parent,
            highlightB: idx,
            swapSymbol: _sym(type),
            statusMsg:
                'Swapped: heap[$parent]=${heap[parent]}, '
                'heap[$idx]=${heap[idx]}. Continue up.',
            stepNumber: ++stepNum,
            operation: 'build',
          ));
          idx = parent;
        } else {
          steps.add(HeapStep(
            heap: List.from(heap),
            heapType: type,
            phase: 'heapify_up',
            highlightA: idx,
            highlightB: parent,
            swapSymbol: _sym(type),
            statusMsg:
                'Heapify Up: heap[$idx]=${heap[idx]} does not violate '
                'heap property with parent heap[$parent]=${heap[parent]}. Stop.',
            stepNumber: ++stepNum,
            operation: 'build',
          ));
          break;
        }
      }

      // Settled frame
      steps.add(HeapStep(
        heap: List.from(heap),
        heapType: type,
        phase: 'inserted',
        highlightA: 0,
        statusMsg:
            'Insert($val): Done. Heap size = ${heap.length}. '
            'Root = ${heap[0]}.',
        stepNumber: ++stepNum,
        operation: 'build',
      ));
    }

    // Final idle
    steps.add(HeapStep(
      heap: List.from(heap),
      heapType: type,
      phase: 'idle',
      statusMsg:
          '${type == 'max' ? 'Max' : 'Min'}-Heap built! '
          'Root = ${heap.isNotEmpty ? heap[0] : '–'}. '
          'Select an operation below.',
      stepNumber: ++stepNum,
      operation: 'build',
    ));

    return steps;
  }

  // ── INSERT ─────────────────────────────────────────────────────────────────
  static List<HeapStep> insert(List<int> heap, int value, String type) {
    final steps = <HeapStep>[];

    if (heap.length >= maxSize) {
      steps.add(HeapStep(
        heap: List.from(heap),
        heapType: type,
        phase: 'overflow',
        statusMsg:
            'Heap Full! Cannot insert $value — max $maxSize nodes.',
        stepNumber: 1,
        operation: 'insert',
      ));
      return steps;
    }

    List<int> h = List.from(heap);
    int stepNum = 0;

    h.add(value);
    steps.add(HeapStep(
      heap: List.from(h),
      heapType: type,
      phase: 'inserting',
      highlightA: h.length - 1,
      statusMsg:
          'Insert($value): Appended at index [${h.length - 1}]. '
          'Now heapify up.',
      stepNumber: ++stepNum,
      operation: 'insert',
      swapSymbol: _sym(type),
    ));

    int idx = h.length - 1;
    while (idx > 0) {
      final parent = (idx - 1) ~/ 2;
      if (_violates(type, h[parent], h[idx])) {
        steps.add(HeapStep(
          heap: List.from(h),
          heapType: type,
          phase: 'swapping_up',
          highlightA: idx,
          highlightB: parent,
          showSwap: true,
          swapSymbol: _sym(type),
          statusMsg:
              'Heapify Up: h[$idx]=${h[idx]} ${_sym(type)} '
              'h[$parent]=${h[parent]} — swap!',
          stepNumber: ++stepNum,
          operation: 'insert',
        ));
        final tmp = h[idx];
        h[idx] = h[parent];
        h[parent] = tmp;
        steps.add(HeapStep(
          heap: List.from(h),
          heapType: type,
          phase: 'heapify_up',
          highlightA: parent,
          swapSymbol: _sym(type),
          statusMsg:
              'Swapped → h[$parent]=${h[parent]}, h[$idx]=${h[idx]}.',
          stepNumber: ++stepNum,
          operation: 'insert',
        ));
        idx = parent;
      } else {
        steps.add(HeapStep(
          heap: List.from(h),
          heapType: type,
          phase: 'heapify_up',
          highlightA: idx,
          swapSymbol: _sym(type),
          statusMsg:
              'h[$idx]=${h[idx]} satisfies heap property. Stop.',
          stepNumber: ++stepNum,
          operation: 'insert',
        ));
        break;
      }
    }

    steps.add(HeapStep(
      heap: List.from(h),
      heapType: type,
      phase: 'inserted',
      highlightA: 0,
      statusMsg:
          'Insert($value): Complete! New root = ${h[0]}. Size = ${h.length}.',
      stepNumber: ++stepNum,
      operation: 'insert',
    ));

    return steps;
  }

  // ── DELETE by index ────────────────────────────────────────────────────────
  static List<HeapStep> delete(List<int> heap, int delIdx, String type) {
    final steps = <HeapStep>[];

    if (heap.isEmpty) {
      steps.add(HeapStep(
        heap: [],
        heapType: type,
        phase: 'underflow',
        statusMsg: 'Heap is empty — nothing to delete.',
        stepNumber: 1,
        operation: 'delete',
      ));
      return steps;
    }

    if (delIdx < 0 || delIdx >= heap.length) {
      steps.add(HeapStep(
        heap: List.from(heap),
        heapType: type,
        phase: 'underflow',
        statusMsg:
            'Invalid index $delIdx. Valid range: 0–${heap.length - 1}.',
        stepNumber: 1,
        operation: 'delete',
      ));
      return steps;
    }

    List<int> h = List.from(heap);
    int stepNum = 0;

    // Highlight target
    steps.add(HeapStep(
      heap: List.from(h),
      heapType: type,
      phase: 'deleting',
      highlightA: delIdx,
      statusMsg:
          'Delete index [$delIdx] = ${h[delIdx]}. '
          'Replace with last element = ${h.last}.',
      stepNumber: ++stepNum,
      operation: 'delete',
    ));

    // Replace with last
    final deletedVal = h[delIdx];
    h[delIdx] = h.last;
    h.removeLast();

    if (h.isEmpty) {
      steps.add(HeapStep(
        heap: [],
        heapType: type,
        phase: 'deleted',
        statusMsg: 'Deleted $deletedVal. Heap is now empty.',
        stepNumber: ++stepNum,
        operation: 'delete',
      ));
      return steps;
    }

    steps.add(HeapStep(
      heap: List.from(h),
      heapType: type,
      phase: 'deleting',
      highlightA: delIdx,
      swapSymbol: _sym(type),
      statusMsg:
          'Replaced h[$delIdx] with ${h[delIdx]}. '
          'Size = ${h.length}. Now heapify.',
      stepNumber: ++stepNum,
      operation: 'delete',
    ));

    // Try heapify up first
    int idx = delIdx;
    bool didUp = false;
    while (idx > 0) {
      final parent = (idx - 1) ~/ 2;
      if (_violates(type, h[parent], h[idx])) {
        steps.add(HeapStep(
          heap: List.from(h),
          heapType: type,
          phase: 'swapping_up',
          highlightA: idx,
          highlightB: parent,
          showSwap: true,
          swapSymbol: _sym(type),
          statusMsg:
              'Heapify Up: h[$idx]=${h[idx]} ${_sym(type)} '
              'h[$parent]=${h[parent]} — swap!',
          stepNumber: ++stepNum,
          operation: 'delete',
        ));
        final tmp = h[idx];
        h[idx] = h[parent];
        h[parent] = tmp;
        steps.add(HeapStep(
          heap: List.from(h),
          heapType: type,
          phase: 'heapify_up',
          highlightA: parent,
          swapSymbol: _sym(type),
          statusMsg: 'Swapped up → h[$parent]=${h[parent]}.',
          stepNumber: ++stepNum,
          operation: 'delete',
        ));
        idx = parent;
        didUp = true;
      } else {
        break;
      }
    }

    // Then heapify down
    idx = delIdx;
    _heapifyDown(h, idx, h.length, type, steps, stepNum, 'delete').forEach((s) {
      steps.add(s);
    });
    stepNum = steps.last.stepNumber;

    steps.add(HeapStep(
      heap: List.from(h),
      heapType: type,
      phase: 'deleted',
      highlightA: 0,
      statusMsg:
          'Deleted $deletedVal. Heap restored. Root = ${h[0]}. '
          'Size = ${h.length}.',
      stepNumber: ++stepNum,
      operation: 'delete',
    ));

    return steps;
  }

  // ── UPDATE ─────────────────────────────────────────────────────────────────
  static List<HeapStep> update(
      List<int> heap, int idx, int newVal, String type) {
    final steps = <HeapStep>[];

    if (heap.isEmpty || idx < 0 || idx >= heap.length) {
      steps.add(HeapStep(
        heap: List.from(heap),
        heapType: type,
        phase: 'underflow',
        statusMsg:
            'Invalid index $idx. Valid range: 0–${heap.length - 1}.',
        stepNumber: 1,
        operation: 'update',
      ));
      return steps;
    }

    List<int> h = List.from(heap);
    int stepNum = 0;
    final oldVal = h[idx];

    steps.add(HeapStep(
      heap: List.from(h),
      heapType: type,
      phase: 'inserting',
      highlightA: idx,
      statusMsg:
          'Update h[$idx]: $oldVal → $newVal. Now fix heap property.',
      stepNumber: ++stepNum,
      operation: 'update',
    ));

    h[idx] = newVal;
    steps.add(HeapStep(
      heap: List.from(h),
      heapType: type,
      phase: 'heapify_up',
      highlightA: idx,
      swapSymbol: _sym(type),
      statusMsg: 'Updated h[$idx] = $newVal. Heapifying…',
      stepNumber: ++stepNum,
      operation: 'update',
    ));

    // Heapify up
    int i = idx;
    while (i > 0) {
      final parent = (i - 1) ~/ 2;
      if (_violates(type, h[parent], h[i])) {
        steps.add(HeapStep(
          heap: List.from(h),
          heapType: type,
          phase: 'swapping_up',
          highlightA: i,
          highlightB: parent,
          showSwap: true,
          swapSymbol: _sym(type),
          statusMsg:
              'Heapify Up: h[$i]=${h[i]} ${_sym(type)} h[$parent]=${h[parent]} — swap!',
          stepNumber: ++stepNum,
          operation: 'update',
        ));
        final tmp = h[i];
        h[i] = h[parent];
        h[parent] = tmp;
        steps.add(HeapStep(
          heap: List.from(h),
          heapType: type,
          phase: 'heapify_up',
          highlightA: parent,
          swapSymbol: _sym(type),
          statusMsg: 'Swapped → h[$parent]=${h[parent]}.',
          stepNumber: ++stepNum,
          operation: 'update',
        ));
        i = parent;
      } else {
        break;
      }
    }

    // Heapify down from updated position
    _heapifyDown(h, i, h.length, type, steps, stepNum, 'update')
        .forEach((s) => steps.add(s));
    stepNum = steps.last.stepNumber;

    steps.add(HeapStep(
      heap: List.from(h),
      heapType: type,
      phase: 'updated',
      highlightA: 0,
      statusMsg:
          'Update complete! h[$idx] changed from $oldVal to $newVal. '
          'Root = ${h[0]}.',
      stepNumber: ++stepNum,
      operation: 'update',
    ));

    return steps;
  }

  // ── HEAP SORT ──────────────────────────────────────────────────────────────
  static List<HeapStep> sort(List<int> heap, String type) {
    final steps = <HeapStep>[];

    if (heap.isEmpty) {
      steps.add(HeapStep(
        heap: [],
        heapType: type,
        phase: 'underflow',
        statusMsg: 'Heap is empty — nothing to sort.',
        stepNumber: 1,
        operation: 'sort',
      ));
      return steps;
    }

    List<int> h = List.from(heap);
    int stepNum = 0;
    final sorted = <int>{};
    final sortedArr = <int>[];

    steps.add(HeapStep(
      heap: List.from(h),
      heapType: type,
      phase: 'sorting',
      statusMsg:
          'Heap Sort: Extract root repeatedly and heapify down. '
          'This gives ${type == 'max' ? 'ascending' : 'descending'} order.',
      stepNumber: ++stepNum,
      operation: 'sort',
      sortedIndices: Set.from(sorted),
    ));

    int heapSize = h.length;

    while (heapSize > 1) {
      // Highlight root (to be extracted)
      steps.add(HeapStep(
        heap: List.from(h),
        heapType: type,
        phase: 'sorting',
        highlightA: 0,
        statusMsg:
            'Extract root = ${h[0]} (${type == 'max' ? 'maximum' : 'minimum'}). '
            'Swap with last active node h[${heapSize - 1}] = ${h[heapSize - 1]}.',
        stepNumber: ++stepNum,
        operation: 'sort',
        sortedIndices: Set.from(sorted),
        swapSymbol: _sym(type),
        showSwap: true,
      ));

      // Swap root with last
      final tmp = h[0];
      h[0] = h[heapSize - 1];
      h[heapSize - 1] = tmp;
      heapSize--;
      sorted.add(heapSize);
      sortedArr.insert(0, h[heapSize]);

      steps.add(HeapStep(
        heap: List.from(h),
        heapType: type,
        phase: 'sorting',
        highlightA: heapSize,
        statusMsg:
            'Placed ${h[heapSize]} at sorted position [${heapSize}]. '
            'Heapify down the remaining ${heapSize} elements.',
        stepNumber: ++stepNum,
        operation: 'sort',
        sortedIndices: Set.from(sorted),
        sortedArray: List.from(sortedArr),
      ));

      // Heapify down on reduced heap
      final downSteps = _heapifyDown(
          h, 0, heapSize, type, [], stepNum, 'sort',
          sortedIndices: Set.from(sorted),
          sortedArray: List.from(sortedArr));
      for (final s in downSteps) {
        steps.add(s);
      }
      if (downSteps.isNotEmpty) stepNum = downSteps.last.stepNumber;
    }

    // Last element
    sorted.add(0);
    sortedArr.insert(0, h[0]);
    steps.add(HeapStep(
      heap: List.from(h),
      heapType: type,
      phase: 'sorted',
      highlightA: 0,
      sortedIndices: Set.from(sorted),
      sortedArray: List.from(sortedArr),
      statusMsg:
          'Heap Sort Complete! Sorted: [${sortedArr.join(', ')}].',
      stepNumber: ++stepNum,
      operation: 'sort',
    ));

    return steps;
  }

  // ── Internal heapify down ──────────────────────────────────────────────────
  static List<HeapStep> _heapifyDown(
    List<int> h,
    int startIdx,
    int heapSize,
    String type,
    List<HeapStep> existing,
    int stepNum,
    String operation, {
    Set<int> sortedIndices = const {},
    List<int> sortedArray = const [],
  }) {
    final steps = <HeapStep>[];
    int idx = startIdx;

    while (true) {
      final left  = 2 * idx + 1;
      final right = 2 * idx + 2;
      int target  = idx;

      if (left < heapSize &&
          _shouldSwapDown(type, h[target], h[left])) {
        target = left;
      }
      if (right < heapSize &&
          _shouldSwapDown(type, h[target], h[right])) {
        target = right;
      }

      if (target == idx) {
        steps.add(HeapStep(
          heap: List.from(h),
          heapType: type,
          phase: operation == 'sort' ? 'sorting' : 'heapify_down',
          highlightA: idx,
          swapSymbol: _sym(type),
          statusMsg:
              'Heapify Down: h[$idx]=${h[idx]} satisfies heap property. Stop.',
          stepNumber: ++stepNum,
          operation: operation,
          sortedIndices: Set.from(sortedIndices),
          sortedArray: List.from(sortedArray),
        ));
        break;
      }

      steps.add(HeapStep(
        heap: List.from(h),
        heapType: type,
        phase: operation == 'sort' ? 'sorting' : 'swapping_down',
        highlightA: idx,
        highlightB: target,
        showSwap: true,
        swapSymbol: _sym(type),
        statusMsg:
            'Heapify Down: h[$idx]=${h[idx]} ${_sym(type)} '
            'h[$target]=${h[target]} — swap!',
        stepNumber: ++stepNum,
        operation: operation,
        sortedIndices: Set.from(sortedIndices),
        sortedArray: List.from(sortedArray),
      ));

      final tmp = h[idx];
      h[idx] = h[target];
      h[target] = tmp;

      steps.add(HeapStep(
        heap: List.from(h),
        heapType: type,
        phase: operation == 'sort' ? 'sorting' : 'heapify_down',
        highlightA: target,
        swapSymbol: _sym(type),
        statusMsg:
            'Swapped → h[$idx]=${h[idx]}, h[$target]=${h[target]}.',
        stepNumber: ++stepNum,
        operation: operation,
        sortedIndices: Set.from(sortedIndices),
        sortedArray: List.from(sortedArray),
      ));

      idx = target;
    }

    return steps;
  }
}