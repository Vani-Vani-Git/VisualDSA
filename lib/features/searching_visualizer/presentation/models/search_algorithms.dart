import 'dart:math';
import 'search_step.dart';

class SearchAlgorithms {
  // ── Linear Search ──────────────────────────────────────────────────────────
  // Scans element by element left→right.
  // Key pointer shown above current element; "Not Equal" in red, "Equal" in green.
  static List<SearchStep> linearSearch(List<int> array, int target) {
    final steps = <SearchStep>[];
    final n = array.length;

    for (int i = 0; i < n; i++) {
      final isMatch = array[i] == target;
      steps.add(SearchStep(
        array: List.from(array),
        currentIdx: i,
        stepNumber: i + 1,
        statusMsg: isMatch
            ? 'Step ${i + 1}: arr[$i] = ${array[i]} == $target  ✓ Equal — Found!'
            : 'Step ${i + 1}: arr[$i] = ${array[i]} ≠ $target  — Not Equal',
        phase: isMatch ? 'found' : 'comparing',
        foundIdx: isMatch ? i : null,
      ));
      if (isMatch) return steps;
    }

    // Not found
    steps.add(SearchStep(
      array: List.from(array),
      stepNumber: n + 1,
      statusMsg: 'Target $target not found in array.',
      phase: 'not_found',
    ));
    return steps;
  }

  // ── Binary Search ──────────────────────────────────────────────────────────
  // Array MUST be sorted. Shows Low / Mid / High pointers below the array.
  // Eliminated halves are greyed out.
  static List<SearchStep> binarySearch(List<int> array, int target) {
    final steps = <SearchStep>[];
    final sorted = List<int>.from(array)..sort();
    int low = 0, high = sorted.length - 1, stepNum = 0;
    final eliminated = <int>{};

    // Initial state
    steps.add(SearchStep(
      array: List.from(sorted),
      low: low,
      high: high,
      stepNumber: 0,
      statusMsg: 'Initially: Find Key = $target using Binary Search',
      phase: 'comparing',
    ));

    while (low <= high) {
      stepNum++;
      final mid = (low + high) ~/ 2;

      if (sorted[mid] == target) {
        steps.add(SearchStep(
          array: List.from(sorted),
          currentIdx: mid,
          foundIdx: mid,
          low: low,
          high: high,
          mid: mid,
          eliminatedIndices: Set.from(eliminated),
          stepNumber: stepNum,
          statusMsg:
              'Step $stepNum: Key matches mid element arr[$mid] = ${sorted[mid]}. Element Found!',
          phase: 'found',
        ));
        return steps;
      } else if (sorted[mid] < target) {
        steps.add(SearchStep(
          array: List.from(sorted),
          currentIdx: mid,
          low: low,
          high: high,
          mid: mid,
          eliminatedIndices: Set.from(eliminated),
          stepNumber: stepNum,
          statusMsg:
              'Step $stepNum: Key ($target) > mid element (${sorted[mid]}). Search space moves right.',
          phase: 'comparing',
        ));
        for (int i = low; i <= mid; i++) eliminated.add(i);
        low = mid + 1;
      } else {
        steps.add(SearchStep(
          array: List.from(sorted),
          currentIdx: mid,
          low: low,
          high: high,
          mid: mid,
          eliminatedIndices: Set.from(eliminated),
          stepNumber: stepNum,
          statusMsg:
              'Step $stepNum: Key ($target) < mid element (${sorted[mid]}). Search space moves left.',
          phase: 'comparing',
        ));
        for (int i = mid; i <= high; i++) eliminated.add(i);
        high = mid - 1;
      }
    }

    steps.add(SearchStep(
      array: List.from(sorted),
      eliminatedIndices: Set.from(eliminated),
      stepNumber: stepNum + 1,
      statusMsg: 'Target $target not found in array.',
      phase: 'not_found',
    ));
    return steps;
  }

  // ── Jump Search ────────────────────────────────────────────────────────────
  // Array MUST be sorted. Jumps √n steps at a time to find a block,
  // then does a linear back-scan within that block.
  // Shows: jump arcs connecting boundary indices, then linear scan highlight.
  static List<SearchStep> jumpSearch(List<int> array, int target) {
    final steps = <SearchStep>[];
    final sorted = List<int>.from(array)..sort();
    final n = sorted.length;
    final step = sqrt(n).floor();
    final visitedBlocks = <int>[]; // boundary indices of completed jumps
    int prev = 0;
    int stepNum = 0;

    // Initial state
    steps.add(SearchStep(
      array: List.from(sorted),
      stepNumber: 0,
      statusMsg:
          'Jump Search: n=$n, jump size m=√$n=${step}. Start from index 0.',
      phase: 'comparing',
      jumpBlocks: [],
    ));

    // Jump phase
    while (prev < n && sorted[min(step - 1 + prev ~/ 1, n - 1)] < target) {
      // The block boundary we are jumping to
      final jumpTo = min(prev + step - 1, n - 1);
      stepNum++;
      visitedBlocks.add(prev);

      steps.add(SearchStep(
        array: List.from(sorted),
        currentIdx: jumpTo,
        stepNumber: stepNum,
        statusMsg:
            'Jump to index $jumpTo: arr[$jumpTo]=${sorted[jumpTo]} < $target. Jump again.',
        phase: 'jumping',
        jumpBlocks: List.from(visitedBlocks),
      ));
      prev += step;
      if (prev >= n) break;
    }

    // The block boundary that may contain the target
    final blockEnd = min(prev + step - 1, n - 1);
    visitedBlocks.add(prev);

    // Linear back-scan phase
    final scanStart = max(prev - step, 0);
    final scanEnd = min(blockEnd, n - 1);

    for (int i = scanStart; i <= scanEnd; i++) {
      stepNum++;
      final isMatch = sorted[i] == target;
      steps.add(SearchStep(
        array: List.from(sorted),
        currentIdx: i,
        foundIdx: isMatch ? i : null,
        stepNumber: stepNum,
        statusMsg: isMatch
            ? 'Linear scan: arr[$i]=${sorted[i]} == $target. Found!'
            : 'Linear scan: arr[$i]=${sorted[i]} ≠ $target. Continue.',
        phase: isMatch ? 'found' : 'scanning',
        jumpBlocks: List.from(visitedBlocks),
        linearScanRange: [scanStart, scanEnd],
      ));
      if (isMatch) return steps;
    }

    steps.add(SearchStep(
      array: List.from(sorted),
      stepNumber: stepNum + 1,
      statusMsg: 'Target $target not found in array.',
      phase: 'not_found',
      jumpBlocks: List.from(visitedBlocks),
    ));
    return steps;
  }
}