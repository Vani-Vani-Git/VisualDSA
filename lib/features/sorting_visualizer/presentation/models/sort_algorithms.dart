import 'sort_step.dart';

class SortAlgorithms {

  // ── Bubble Sort ────────────────────────────────────────────────────────────
  // Per video: highlight adjacent pair → if out of order highlight them bold →
  // swap → move to next pair. After each pass, the rightmost unsorted element
  // is confirmed sorted and a "Sorted" bracket grows from the right.
  static List<SortStep> bubbleSort(List<int> input) {
    final steps = <SortStep>[];
    final arr = List<int>.from(input);
    final n = arr.length;

    steps.add(SortStep(
      array: List.from(arr),
      statusMsg: 'Sort the array using the Bubble Sort algorithm.',
    ));

    for (int i = 0; i < n - 1; i++) {
      for (int j = 0; j < n - i - 1; j++) {
        // Compare pair
        steps.add(SortStep(
          array: List.from(arr),
          comparing: {j, j + 1},
          sortedFromRight: i,
          statusMsg:
              'Compare elements at positions $j and ${j + 1}.',
        ));

        if (arr[j] > arr[j + 1]) {
          // Show swap highlight
          steps.add(SortStep(
            array: List.from(arr),
            swapping: {j, j + 1},
            sortedFromRight: i,
            statusMsg:
                'Swap the elements, since ${arr[j]} > ${arr[j + 1]}.',
          ));
          final tmp = arr[j]; arr[j] = arr[j + 1]; arr[j + 1] = tmp;
          steps.add(SortStep(
            array: List.from(arr),
            swapping: {j, j + 1},
            sortedFromRight: i,
            statusMsg:
                'Swap the elements, since the first element of the pair is greater than the second.',
          ));
        } else {
          steps.add(SortStep(
            array: List.from(arr),
            sortedFromRight: i,
            statusMsg:
                'Move to the next pair and compare elements at positions ${j + 1} and ${j + 2}.',
          ));
        }
      }
      // After each pass the last unsorted position is now sorted
      steps.add(SortStep(
        array: List.from(arr),
        sortedFromRight: i + 1,
        statusMsg:
            'End of pass ${i + 1}. The ${n - 1 - i} largest element is now in its correct position.',
      ));
    }

    steps.add(SortStep(
      array: List.from(arr),
      sorted: Set.from(List.generate(n, (k) => k)),
      sortedFromRight: n,
      statusMsg: 'With all elements now in their correct positions, the array is sorted.',
    ));
    return steps;
  }

  // ── Selection Sort ─────────────────────────────────────────────────────────
  // Per video: scan unsorted section left→right keeping a "min" pointer (yellow
  // speech-bubble below the current min). When a smaller element is found the
  // "min" pointer jumps to it. After scanning, swap min with the first unsorted
  // element. A "Sorted" bracket grows from the LEFT.
  static List<SortStep> selectionSort(List<int> input) {
    final steps = <SortStep>[];
    final arr = List<int>.from(input);
    final n = arr.length;

    steps.add(SortStep(
      array: List.from(arr),
      statusMsg: 'Sort the array using the Selection Sort algorithm.',
    ));

    for (int i = 0; i < n - 1; i++) {
      int minIdx = i;

      steps.add(SortStep(
        array: List.from(arr),
        minIndex: minIdx,
        sortedFromLeft: i,
        statusMsg:
            'Start scanning the unsorted part from index $i. Current minimum: ${arr[minIdx]} at index $minIdx.',
      ));

      for (int j = i + 1; j < n; j++) {
        // Scanning step
        steps.add(SortStep(
          array: List.from(arr),
          minIndex: minIdx,
          scanIndex: j,
          comparing: {minIdx, j},
          sortedFromLeft: i,
          statusMsg:
              'Scan the rest of the array for an element smaller than the current minimum.',
        ));

        if (arr[j] < arr[minIdx]) {
          minIdx = j;
          steps.add(SortStep(
            array: List.from(arr),
            minIndex: minIdx,
            sortedFromLeft: i,
            statusMsg:
                'When you find a smaller element, mark it as the new minimum.',
          ));
        }
      }

      if (minIdx != i) {
        steps.add(SortStep(
          array: List.from(arr),
          swapping: {i, minIdx},
          sortedFromLeft: i,
          statusMsg:
              'Swap the minimum element ${arr[minIdx]} with the first element of the unsorted part ${arr[i]}.',
        ));
        final tmp = arr[i]; arr[i] = arr[minIdx]; arr[minIdx] = tmp;
        steps.add(SortStep(
          array: List.from(arr),
          swapping: {i, minIdx},
          sortedFromLeft: i,
          statusMsg:
              'Since the sorted section is initially empty, swap the identified minimum element with the first element in the array.',
        ));
      } else {
        steps.add(SortStep(
          array: List.from(arr),
          sortedFromLeft: i,
          statusMsg:
              'No swap needed as the minimum element is already the leftmost in the unsorted part.',
        ));
      }

      steps.add(SortStep(
        array: List.from(arr),
        sortedFromLeft: i + 1,
        statusMsg:
            'Element ${arr[i]} is now in its correct position. Sorted section grows.',
      ));
    }

    steps.add(SortStep(
      array: List.from(arr),
      sorted: Set.from(List.generate(n, (k) => k)),
      sortedFromLeft: n,
      statusMsg: 'All elements are in their correct positions. Array is sorted.',
    ));
    return steps;
  }

  // ── Insertion Sort ─────────────────────────────────────────────────────────
  // Per video: pick the key (it leaves a blank slot in the array; the key value
  // is shown BELOW the empty slot). Shift larger elements one-by-one to the
  // right (each shift shows the empty slot moving left, key label follows).
  // Finally drop the key into the correct gap. Sorted bracket grows from LEFT.
  static List<SortStep> insertionSort(List<int> input) {
    final steps = <SortStep>[];
    final arr = List<int>.from(input);
    final n = arr.length;

    steps.add(SortStep(
      array: List.from(arr),
      statusMsg: 'Sort the array using the Insertion Sort algorithm.',
    ));

    // Index 0 is trivially sorted
    steps.add(SortStep(
      array: List.from(arr),
      sortedFromLeft: 1,
      statusMsg: 'The first element is trivially sorted.',
    ));

    for (int i = 1; i < n; i++) {
      final key = arr[i];

      // Step 1: show key being extracted — blank at position i, key shown below
      // Make a display copy with the key slot "empty" (we track emptyIndex)
      final arrWithGap = List<int>.from(arr);

      steps.add(SortStep(
        array: List.from(arrWithGap),
        keyValue: key,
        keyIndex: i,
        emptyIndex: i,
        sortedFromLeft: i,
        statusMsg: 'Store the element at position $i (value: $key) as the key.',
      ));

      int j = i - 1;
      int gapPos = i; // where the blank slot currently is

      // Step 2: shift elements right one-by-one while they are larger than key
      while (j >= 0 && arr[j] > key) {
        // Show element at j about to shift into gapPos
        steps.add(SortStep(
          array: List.from(arrWithGap),
          keyValue: key,
          keyIndex: gapPos,
          emptyIndex: gapPos,
          comparing: {j},
          sortedFromLeft: i,
          statusMsg:
              'Check if the stored value fits in the newly created space.',
        ));

        // Perform the shift in the display array
        arrWithGap[gapPos] = arr[j];
        gapPos--;

        // Show after shift: element moved right, new gap at gapPos
        steps.add(SortStep(
          array: List.from(arrWithGap),
          keyValue: key,
          keyIndex: gapPos,
          emptyIndex: gapPos,
          sortedFromLeft: i,
          statusMsg:
              'Shift the larger element one position to the right to make space.',
        ));

        arr[j] = arr[j]; // no-op; we track via arrWithGap
        j--;
      }

      // Also update arr to reflect shifts for subsequent passes
      for (int k = i; k > gapPos; k--) arr[k] = arr[k - 1];
      arr[gapPos] = key;

      // Step 3: insert key into the correct position
      final arrFinal = List<int>.from(arr);
      steps.add(SortStep(
        array: arrFinal,
        sortedFromLeft: i + 1,
        statusMsg: gapPos == 0
            ? 'Insert the stored value into the space, as it is smaller than all elements to its right.'
            : 'Insert the stored value into the space, as it is larger than all elements to its left.',
      ));
    }

    steps.add(SortStep(
      array: List.from(arr),
      sorted: Set.from(List.generate(n, (k) => k)),
      sortedFromLeft: n,
      statusMsg:
          'Insert the stored value into the space, as it is larger than all elements to its left. The array is now fully sorted.',
    ));
    return steps;
  }

  // ── Merge Sort ─────────────────────────────────────────────────────────────
  static List<SortStep> mergeSort(List<int> input) {
    final steps = <SortStep>[];
    final arr = List<int>.from(input);

    steps.add(SortStep(
      array: List.from(arr),
      statusMsg: 'Sort the array using the Merge Sort algorithm.',
    ));

    _mergeSortHelper(arr, 0, arr.length - 1, steps);

    steps.add(SortStep(
      array: List.from(arr),
      sorted: Set.from(List.generate(arr.length, (i) => i)),
      statusMsg: 'All sub-arrays merged. Array is fully sorted.',
    ));
    return steps;
  }

  static void _mergeSortHelper(
      List<int> arr, int l, int r, List<SortStep> steps) {
    if (l >= r) return;
    final mid = (l + r) ~/ 2;
    _mergeSortHelper(arr, l, mid, steps);
    _mergeSortHelper(arr, mid + 1, r, steps);
    _merge(arr, l, mid, r, steps);
  }

  static void _merge(
      List<int> arr, int l, int mid, int r, List<SortStep> steps) {
    final left = arr.sublist(l, mid + 1);
    final right = arr.sublist(mid + 1, r + 1);
    int i = 0, j = 0, k = l;

    while (i < left.length && j < right.length) {
      final li = l + i;
      final ri = mid + 1 + j;
      steps.add(SortStep(
        array: List.from(arr),
        comparing: {li, ri},
        merging: Set.from(List.generate(r - l + 1, (x) => l + x)),
        statusMsg:
            'Compare ${arr[li]} at index $li with ${arr[ri]} at index $ri.',
      ));
      if (left[i] <= right[j]) {
        arr[k] = left[i++];
      } else {
        arr[k] = right[j++];
      }
      steps.add(SortStep(
        array: List.from(arr),
        merging: Set.from(List.generate(r - l + 1, (x) => l + x)),
        statusMsg: 'Place smaller element into merged position $k.',
      ));
      k++;
    }
    while (i < left.length) arr[k++] = left[i++];
    while (j < right.length) arr[k++] = right[j++];
    steps.add(SortStep(
      array: List.from(arr),
      merging: Set.from(List.generate(r - l + 1, (x) => l + x)),
      statusMsg: 'Merge of range [$l..$r] complete.',
    ));
  }

  // ── Quick Sort ─────────────────────────────────────────────────────────────
  static List<SortStep> quickSort(List<int> input) {
    final steps = <SortStep>[];
    final arr = List<int>.from(input);

    steps.add(SortStep(
      array: List.from(arr),
      statusMsg: 'Sort the array using the Quick Sort algorithm.',
    ));

    _quickSortHelper(arr, 0, arr.length - 1, steps);

    steps.add(SortStep(
      array: List.from(arr),
      sorted: Set.from(List.generate(arr.length, (i) => i)),
      statusMsg: 'All partitions sorted. Array is fully sorted.',
    ));
    return steps;
  }

  static void _quickSortHelper(
      List<int> arr, int low, int high, List<SortStep> steps) {
    if (low < high) {
      final pi = _partition(arr, low, high, steps);
      _quickSortHelper(arr, low, pi - 1, steps);
      _quickSortHelper(arr, pi + 1, high, steps);
    }
  }

  static int _partition(
      List<int> arr, int low, int high, List<SortStep> steps) {
    final pivotVal = arr[high];
    int i = low - 1;

    steps.add(SortStep(
      array: List.from(arr),
      pivot: high,
      statusMsg:
          'Choose pivot = $pivotVal at index $high. Partition around it.',
    ));

    for (int j = low; j < high; j++) {
      steps.add(SortStep(
        array: List.from(arr),
        comparing: {j, high},
        pivot: high,
        statusMsg:
            'Compare ${arr[j]} at index $j with pivot $pivotVal.',
      ));
      if (arr[j] <= pivotVal) {
        i++;
        steps.add(SortStep(
          array: List.from(arr),
          swapping: {i, j},
          pivot: high,
          statusMsg:
              '${arr[j]} ≤ pivot. Swap index $i and index $j.',
        ));
        final tmp = arr[i]; arr[i] = arr[j]; arr[j] = tmp;
        steps.add(SortStep(
          array: List.from(arr),
          swapping: {i, j},
          pivot: high,
          statusMsg: 'Swap complete.',
        ));
      }
    }
    steps.add(SortStep(
      array: List.from(arr),
      swapping: {i + 1, high},
      pivot: high,
      statusMsg:
          'Place pivot $pivotVal in its correct position (index ${i + 1}).',
    ));
    final tmp = arr[i + 1]; arr[i + 1] = arr[high]; arr[high] = tmp;
    steps.add(SortStep(
      array: List.from(arr),
      sorted: {i + 1},
      pivot: i + 1,
      statusMsg:
          'Pivot $pivotVal is now in its final sorted position at index ${i + 1}.',
    ));
    return i + 1;
  }
}