// ── Node state for rendering ──────────────────────────────────────────────────
enum LLNodeState {
  idle,       // default white
  visited,    // orange (searching traversal trail)
  current,    // bright orange + bold (tmp pointer)
  inserted,   // green highlight — newly added
  deleting,   // red ✕ mark — about to be removed
  pred,       // yellow speech bubble (pred pointer)
  temp,       // red speech bubble (temp pointer)
  newNode,    // node created but not yet linked
}

enum LLPhase {
  idle,
  traversing,
  insertHead,
  insertTail,
  insertMiddle,
  deleteHead,
  deleteTail,
  deleteMiddle,
  searching,
  found,
  notFound,
  done,
}

// ── Snapshot of one node in the animation frame ───────────────────────────────
class LLNodeSnapshot {
  final String value;
  final LLNodeState state;
  final bool isHead;
  final bool isTail;   // shows tail/N label in searching
  final bool showPred; // yellow pred bubble
  final bool showTemp; // red temp bubble
  final bool showX;    // red ✕ for deletion

  const LLNodeSnapshot({
    required this.value,
    this.state = LLNodeState.idle,
    this.isHead = false,
    this.isTail = false,
    this.showPred = false,
    this.showTemp = false,
    this.showX = false,
  });

  LLNodeSnapshot copyWith({
    String? value,
    LLNodeState? state,
    bool? isHead,
    bool? isTail,
    bool? showPred,
    bool? showTemp,
    bool? showX,
  }) =>
      LLNodeSnapshot(
        value: value ?? this.value,
        state: state ?? this.state,
        isHead: isHead ?? this.isHead,
        isTail: isTail ?? this.isTail,
        showPred: showPred ?? this.showPred,
        showTemp: showTemp ?? this.showTemp,
        showX: showX ?? this.showX,
      );
}

// ── One animation frame ───────────────────────────────────────────────────────
class LLStep {
  /// Main list snapshot (nodes in order, left to right).
  final List<LLNodeSnapshot> nodes;

  /// A detached new node shown below/above the list (insert animation).
  final LLNodeSnapshot? floatingNode;

  /// Position of floating node (null = hidden).
  final int? floatingAtIndex;

  final String statusMsg;
  final LLPhase phase;

  const LLStep({
    required this.nodes,
    this.floatingNode,
    this.floatingAtIndex,
    required this.statusMsg,
    this.phase = LLPhase.idle,
  });
}