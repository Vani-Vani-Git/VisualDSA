import 'll_step.dart';

class _LLState {
  List<String> nodes;
  _LLState(this.nodes);
  _LLState clone() => _LLState(List.from(nodes));

  List<LLNodeSnapshot> snap({
    int? predIdx,
    int? tempIdx,
    int? visitedUpTo,
    int? insertedIdx,
    int? deletingIdx,
  }) {
    return List.generate(nodes.length, (i) {
      LLNodeState state = LLNodeState.idle;
      if (visitedUpTo != null && i < visitedUpTo) state = LLNodeState.visited;
      if (insertedIdx == i) state = LLNodeState.inserted;
      if (deletingIdx == i) state = LLNodeState.deleting;
      return LLNodeSnapshot(
        value: nodes[i],
        state: state,
        isHead: i == 0,
        isTail: i == nodes.length - 1,
        showPred: predIdx == i,
        showTemp: tempIdx == i,
        showX: deletingIdx == i,
      );
    });
  }
}

class LLAlgorithms {
  // ── INSERT HEAD ──────────────────────────────────────────────────────────
  static List<LLStep> insertHead(List<String> list, String value) {
    final steps = <LLStep>[];
    final s = _LLState(List.from(list));
    steps.add(LLStep(nodes: s.snap(), statusMsg: 'Insert "$value" at the HEAD.', phase: LLPhase.insertHead));
    steps.add(LLStep(
      nodes: s.snap(),
      floatingNode: LLNodeSnapshot(value: value, state: LLNodeState.newNode),
      floatingAtIndex: 0,
      statusMsg: 'Create new node "$value".',
      phase: LLPhase.insertHead,
    ));
    steps.add(LLStep(
      nodes: s.snap(),
      floatingNode: LLNodeSnapshot(value: value, state: LLNodeState.newNode),
      floatingAtIndex: 0,
      statusMsg: 'Set new.next = head "${s.nodes.isEmpty ? "null" : s.nodes[0]}".',
      phase: LLPhase.insertHead,
    ));
    s.nodes.insert(0, value);
    steps.add(LLStep(
      nodes: s.snap(insertedIdx: 0),
      statusMsg: 'head = new node. "$value" is now the head!',
      phase: LLPhase.done,
    ));
    return steps;
  }

  // ── INSERT TAIL ──────────────────────────────────────────────────────────
  static List<LLStep> insertTail(List<String> list, String value) {
    final steps = <LLStep>[];
    final s = _LLState(List.from(list));
    final n = s.nodes.length;
    steps.add(LLStep(nodes: s.snap(), statusMsg: 'Insert "$value" at the TAIL.', phase: LLPhase.insertTail));
    for (int i = 0; i < n; i++) {
      steps.add(LLStep(
        nodes: s.snap(predIdx: i, visitedUpTo: i),
        statusMsg: i < n - 1
            ? 'pred → "${s.nodes[i]}" (idx $i). pred.next != null, move forward.'
            : 'pred → "${s.nodes[i]}" (idx $i). pred.next == null — tail reached.',
        phase: LLPhase.insertTail,
      ));
    }
    steps.add(LLStep(
      nodes: s.snap(predIdx: n - 1),
      floatingNode: LLNodeSnapshot(value: value, state: LLNodeState.newNode),
      floatingAtIndex: n,
      statusMsg: 'Create new node "$value". Set pred.next = new node.',
      phase: LLPhase.insertTail,
    ));
    s.nodes.add(value);
    steps.add(LLStep(
      nodes: s.snap(insertedIdx: s.nodes.length - 1),
      statusMsg: '"$value" appended at the tail!',
      phase: LLPhase.done,
    ));
    return steps;
  }

  // ── INSERT AT POSITION ────────────────────────────────────────────────────
  static List<LLStep> insertAt(List<String> list, String value, int index) {
    if (index <= 0) return insertHead(list, value);
    if (index >= list.length) return insertTail(list, value);
    final steps = <LLStep>[];
    final s = _LLState(List.from(list));
    steps.add(LLStep(nodes: s.snap(), statusMsg: 'Insert "$value" at position $index.', phase: LLPhase.insertMiddle));
    for (int i = 0; i < index; i++) {
      steps.add(LLStep(
        nodes: s.snap(predIdx: i, visitedUpTo: i),
        statusMsg: i < index - 1
            ? 'pred → "${s.nodes[i]}" (idx $i). Moving forward.'
            : 'pred → "${s.nodes[i]}" (idx $i). Insertion predecessor found.',
        phase: LLPhase.insertMiddle,
      ));
    }
    steps.add(LLStep(
      nodes: s.snap(predIdx: index - 1),
      floatingNode: LLNodeSnapshot(value: value, state: LLNodeState.newNode),
      floatingAtIndex: index,
      statusMsg: 'Create node "$value". Set new.next = pred.next "${s.nodes[index]}".',
      phase: LLPhase.insertMiddle,
    ));
    steps.add(LLStep(
      nodes: s.snap(predIdx: index - 1),
      floatingNode: LLNodeSnapshot(value: value, state: LLNodeState.newNode),
      floatingAtIndex: index,
      statusMsg: 'Set pred.next = "$value". Linking complete.',
      phase: LLPhase.insertMiddle,
    ));
    s.nodes.insert(index, value);
    steps.add(LLStep(
      nodes: s.snap(insertedIdx: index),
      statusMsg: '"$value" inserted at index $index!',
      phase: LLPhase.done,
    ));
    return steps;
  }

  // ── DELETE HEAD ───────────────────────────────────────────────────────────
  static List<LLStep> deleteHead(List<String> list) {
    final steps = <LLStep>[];
    final s = _LLState(List.from(list));
    if (s.nodes.isEmpty) {
      steps.add(LLStep(nodes: [], statusMsg: 'List is empty.', phase: LLPhase.notFound));
      return steps;
    }
    steps.add(LLStep(nodes: s.snap(), statusMsg: 'Delete HEAD node "${s.nodes[0]}".', phase: LLPhase.deleteHead));
    steps.add(LLStep(
      nodes: s.snap(tempIdx: 0),
      statusMsg: 'temp → head "${s.nodes[0]}".',
      phase: LLPhase.deleteHead,
    ));
    steps.add(LLStep(
      nodes: s.snap(tempIdx: 0, deletingIdx: 0),
      statusMsg: 'head = head.next "${s.nodes.length > 1 ? s.nodes[1] : "null"}". Mark "${s.nodes[0]}" ✕.',
      phase: LLPhase.deleteHead,
    ));
    final removed = s.nodes.removeAt(0);
    steps.add(LLStep(
      nodes: s.snap(),
      statusMsg: '"$removed" removed. New head: "${s.nodes.isEmpty ? "null (empty)" : s.nodes[0]}".',
      phase: LLPhase.done,
    ));
    return steps;
  }

  // ── DELETE TAIL ───────────────────────────────────────────────────────────
  static List<LLStep> deleteTail(List<String> list) {
    final steps = <LLStep>[];
    final s = _LLState(List.from(list));
    if (s.nodes.isEmpty) {
      steps.add(LLStep(nodes: [], statusMsg: 'List is empty.', phase: LLPhase.notFound));
      return steps;
    }
    final n = s.nodes.length;
    steps.add(LLStep(nodes: s.snap(), statusMsg: 'Delete TAIL node "${s.nodes.last}".', phase: LLPhase.deleteTail));
    if (n == 1) {
      steps.add(LLStep(nodes: s.snap(deletingIdx: 0), statusMsg: 'Only node — remove it. List becomes empty.', phase: LLPhase.deleteTail));
      s.nodes.removeAt(0);
      steps.add(LLStep(nodes: [], statusMsg: 'List is now empty.', phase: LLPhase.done));
      return steps;
    }
    for (int i = 0; i < n - 1; i++) {
      steps.add(LLStep(
        nodes: s.snap(predIdx: i, tempIdx: i + 1, visitedUpTo: i),
        statusMsg: i + 1 < n - 1
            ? 'pred → "${s.nodes[i]}", temp → "${s.nodes[i + 1]}". temp.next != null, move.'
            : 'pred → "${s.nodes[i]}", temp → "${s.nodes[i + 1]}" (tail).',
        phase: LLPhase.deleteTail,
      ));
    }
    steps.add(LLStep(
      nodes: s.snap(predIdx: n - 2, deletingIdx: n - 1),
      statusMsg: 'Set pred.next = null. Mark tail "${s.nodes[n - 1]}" ✕.',
      phase: LLPhase.deleteTail,
    ));
    final removed = s.nodes.removeLast();
    steps.add(LLStep(
      nodes: s.snap(),
      statusMsg: '"$removed" deleted from tail!',
      phase: LLPhase.done,
    ));
    return steps;
  }

  // ── DELETE AT POSITION ────────────────────────────────────────────────────
  static List<LLStep> deleteAt(List<String> list, int index) {
    if (index <= 0) return deleteHead(list);
    if (index >= list.length - 1) return deleteTail(list);
    final steps = <LLStep>[];
    final s = _LLState(List.from(list));
    steps.add(LLStep(
      nodes: s.snap(),
      statusMsg: 'Delete node at position $index ("${s.nodes[index]}").',
      phase: LLPhase.deleteMiddle,
    ));
    for (int i = 0; i < index; i++) {
      steps.add(LLStep(
        nodes: s.snap(predIdx: i, tempIdx: i + 1, visitedUpTo: i),
        statusMsg: i < index - 1
            ? 'pred → "${s.nodes[i]}", temp → "${s.nodes[i + 1]}". Moving forward.'
            : 'pred → "${s.nodes[i]}", temp → "${s.nodes[index]}" (target).',
        phase: LLPhase.deleteMiddle,
      ));
    }
    steps.add(LLStep(
      nodes: s.snap(predIdx: index - 1, deletingIdx: index),
      statusMsg: 'Set pred.next = temp.next "${s.nodes[index + 1]}". Mark "${s.nodes[index]}" ✕.',
      phase: LLPhase.deleteMiddle,
    ));
    final removed = s.nodes.removeAt(index);
    steps.add(LLStep(
      nodes: s.snap(),
      statusMsg: '"$removed" deleted from position $index. List reconnected!',
      phase: LLPhase.done,
    ));
    return steps;
  }

  // ── SEARCH ────────────────────────────────────────────────────────────────
  static List<LLStep> search(List<String> list, String value) {
    final steps = <LLStep>[];
    final s = _LLState(List.from(list));
    final n = s.nodes.length;
    steps.add(LLStep(nodes: s.snap(), statusMsg: 'Search for "$value". Start at head/0.', phase: LLPhase.searching));
    for (int i = 0; i < n; i++) {
      final isMatch = s.nodes[i] == value;
      steps.add(LLStep(
        nodes: List.generate(n, (j) => LLNodeSnapshot(
          value: s.nodes[j],
          state: j < i
              ? LLNodeState.visited
              : j == i
                  ? (isMatch ? LLNodeState.inserted : LLNodeState.current)
                  : LLNodeState.idle,
          isHead: j == 0,
          isTail: j == n - 1,
          showTemp: j == i,
        )),
        statusMsg: isMatch
            ? 'tmp/$i → "${s.nodes[i]}" == "$value"  ✓  FOUND at index $i!'
            : 'tmp/$i → "${s.nodes[i]}" ≠ "$value". Continue.',
        phase: isMatch ? LLPhase.found : LLPhase.searching,
      ));
      if (isMatch) {
        steps.add(LLStep(
          nodes: List.generate(n, (j) => LLNodeSnapshot(
            value: s.nodes[j],
            state: j == i ? LLNodeState.inserted : (j < i ? LLNodeState.visited : LLNodeState.idle),
            isHead: j == 0,
            isTail: j == n - 1,
          )),
          statusMsg: '"$value" found at index $i!',
          phase: LLPhase.done,
        ));
        return steps;
      }
    }
    steps.add(LLStep(
      nodes: s.snap(visitedUpTo: n),
      statusMsg: '"$value" NOT found in the list.',
      phase: LLPhase.notFound,
    ));
    return steps;
  }
}