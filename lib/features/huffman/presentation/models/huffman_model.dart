import 'dart:math';

// ── Huffman Tree Node ─────────────────────────────────────────────────────────
class HuffNode {
  final String? char;   // null = internal node
  final int freq;
  HuffNode? left;
  HuffNode? right;
  // Layout position (assigned during tree layout pass)
  double x = 0;
  double y = 0;
  final int id; // unique id for animation tracking

  HuffNode({
    this.char,
    required this.freq,
    this.left,
    this.right,
    required this.id,
  });

  bool get isLeaf => left == null && right == null;

  String get label => char != null ? "'${char!}'" : '${freq}';
}

// ── Animation Step ────────────────────────────────────────────────────────────
enum HuffStepType {
  init,             // show initial nodes (sorted by freq)
  pickTwo,          // highlight the two smallest
  merge,            // show merged parent node
  addBack,          // re-add merged node to queue
  buildComplete,    // tree fully built
  assignCodes,      // show code assignment travelling down
  done,             // show final coded table
}

class HuffStep {
  final HuffStepType type;
  final List<HuffNode> queue;        // current priority queue snapshot
  final Set<int> highlightIds;       // nodes being highlighted
  final HuffNode? newNode;           // newly merged node
  final HuffNode? root;              // root once tree is built
  final Map<String, String> codes;   // char → binary code
  final int? codeNodeId;             // node being labelled during assign
  final String statusMsg;

  const HuffStep({
    required this.type,
    required this.queue,
    this.highlightIds = const {},
    this.newNode,
    this.root,
    this.codes = const {},
    this.codeNodeId,
    this.statusMsg = '',
  });
}

// ── Character frequency entry ─────────────────────────────────────────────────
class CharFreq {
  final String char;
  final int freq;
  CharFreq(this.char, this.freq);
}

// ── Result table row ──────────────────────────────────────────────────────────
class HuffResult {
  final String char;
  final int freq;
  final String code;
  final int bits;          // freq * code.length
  HuffResult(this.char, this.freq, this.code, this.bits);
}

// ── Huffman Generator ─────────────────────────────────────────────────────────
class HuffmanGenerator {
  int _idCounter = 0;
  int _nextId() => _idCounter++;

  /// Build frequency map from input string
  static Map<String, int> buildFreqMap(String input) {
    final map = <String, int>{};
    for (final ch in input.split('')) {
      map[ch] = (map[ch] ?? 0) + 1;
    }
    return map;
  }

  /// Sort chars by freq ascending
  static List<CharFreq> sortedFreqs(Map<String, int> freqMap) {
    final list = freqMap.entries
        .map((e) => CharFreq(e.key, e.value))
        .toList()
      ..sort((a, b) => a.freq != b.freq
          ? a.freq.compareTo(b.freq)
          : a.char.compareTo(b.char));
    return list;
  }

  /// Generate all animation steps
  List<HuffStep> generate(String input) {
    _idCounter = 0;
    final steps = <HuffStep>[];

    if (input.isEmpty) return steps;

    final freqMap = HuffmanGenerator.buildFreqMap(input);
    final sorted = HuffmanGenerator.sortedFreqs(freqMap);

    // Initial leaf nodes
    var queue = sorted
        .map((cf) => HuffNode(char: cf.char, freq: cf.freq, id: _nextId()))
        .toList();

    steps.add(HuffStep(
      type: HuffStepType.init,
      queue: _copyQueue(queue),
      statusMsg:
          'Step 1: Count character frequencies and sort by frequency (ascending).',
    ));

    // Build tree
    while (queue.length > 1) {
      // Sort queue by freq
      queue.sort((a, b) =>
          a.freq != b.freq ? a.freq.compareTo(b.freq) : a.id.compareTo(b.id));

      final n1 = queue[0];
      final n2 = queue[1];

      steps.add(HuffStep(
        type: HuffStepType.pickTwo,
        queue: _copyQueue(queue),
        highlightIds: {n1.id, n2.id},
        statusMsg:
            'Pick two smallest: ${_nodeLabel(n1)} (${n1.freq}) and '
            '${_nodeLabel(n2)} (${n2.freq})',
      ));

      // Merge
      final merged = HuffNode(
        char: null,
        freq: n1.freq + n2.freq,
        left: n1,
        right: n2,
        id: _nextId(),
      );

      queue.removeAt(0);
      queue.removeAt(0);

      steps.add(HuffStep(
        type: HuffStepType.merge,
        queue: _copyQueue(queue),
        highlightIds: {merged.id},
        newNode: merged,
        statusMsg:
            'Merge: ${_nodeLabel(n1)}(${n1.freq}) + ${_nodeLabel(n2)}(${n2.freq}) '
            '= internal node (${merged.freq})',
      ));

      queue.add(merged);
      queue.sort((a, b) =>
          a.freq != b.freq ? a.freq.compareTo(b.freq) : a.id.compareTo(b.id));

      steps.add(HuffStep(
        type: HuffStepType.addBack,
        queue: _copyQueue(queue),
        highlightIds: {merged.id},
        newNode: merged,
        statusMsg:
            'Add merged node (${merged.freq}) back to queue. '
            'Queue size: ${queue.length}',
      ));
    }

    final root = queue.first;

    steps.add(HuffStep(
      type: HuffStepType.buildComplete,
      queue: [],
      root: root,
      statusMsg: 'Huffman tree built! Now assign binary codes: left=0, right=1',
    ));

    // Assign codes
    final codes = <String, String>{};
    _assignCodes(root, '', codes, steps, root);

    steps.add(HuffStep(
      type: HuffStepType.done,
      queue: [],
      root: root,
      codes: Map.from(codes),
      statusMsg: '✅ Huffman coding complete! See the encoding table below.',
    ));

    return steps;
  }

  void _assignCodes(
    HuffNode node,
    String code,
    Map<String, String> codes,
    List<HuffStep> steps,
    HuffNode root,
  ) {
    if (node.isLeaf) {
      codes[node.char!] = code.isEmpty ? '0' : code;
      steps.add(HuffStep(
        type: HuffStepType.assignCodes,
        queue: [],
        root: root,
        codes: Map.from(codes),
        codeNodeId: node.id,
        highlightIds: {node.id},
        statusMsg:
            "Assign code '${codes[node.char!]}' to '${node.char}'",
      ));
      return;
    }
    if (node.left != null) {
      steps.add(HuffStep(
        type: HuffStepType.assignCodes,
        queue: [],
        root: root,
        codes: Map.from(codes),
        codeNodeId: node.id,
        highlightIds: {node.id, node.left!.id},
        statusMsg:
            'Go left (0) from node ${node.freq} → ${node.left!.freq}',
      ));
      _assignCodes(node.left!, '${code}0', codes, steps, root);
    }
    if (node.right != null) {
      steps.add(HuffStep(
        type: HuffStepType.assignCodes,
        queue: [],
        root: root,
        codes: Map.from(codes),
        codeNodeId: node.id,
        highlightIds: {node.id, node.right!.id},
        statusMsg:
            'Go right (1) from node ${node.freq} → ${node.right!.freq}',
      ));
      _assignCodes(node.right!, '${code}1', codes, steps, root);
    }
  }

  List<HuffNode> _copyQueue(List<HuffNode> q) => List.from(q);

  String _nodeLabel(HuffNode n) =>
      n.char != null ? "'${n.char}'" : 'internal';

  /// Build result table from final codes
  static List<HuffResult> buildResults(
      Map<String, int> freqMap, Map<String, String> codes) {
    final list = freqMap.entries.map((e) {
      final code = codes[e.key] ?? '';
      return HuffResult(e.key, e.value, code, e.value * code.length);
    }).toList()
      ..sort((a, b) => b.freq.compareTo(a.freq));
    return list;
  }

  // ── Tree layout (assign x,y positions for canvas drawing) ────────────────────
  static void layoutTree(HuffNode root, double width, double height) {
    // Compute subtree widths first
    final widths = <int, int>{};
    _computeWidth(root, widths);
    // Then assign positions
    _assignPos(root, 0, width, 48.0, min(height / 6, 52.0), widths);
  }

  static int _computeWidth(HuffNode n, Map<int, int> w) {
    if (n.isLeaf) {
      w[n.id] = 1;
      return 1;
    }
    int total = 0;
    if (n.left != null) total += _computeWidth(n.left!, w);
    if (n.right != null) total += _computeWidth(n.right!, w);
    w[n.id] = total;
    return total;
  }

  static void _assignPos(HuffNode n, double xStart, double xEnd,
      double y, double levelH, Map<int, int> widths) {
    n.x = (xStart + xEnd) / 2;
    n.y = y;
    if (n.isLeaf) return;

    final totalW = widths[n.id] ?? 1;
    final leftW = widths[n.left?.id ?? -1] ?? 1;
    final split = xStart + (xEnd - xStart) * leftW / totalW;

    if (n.left != null) {
      _assignPos(n.left!, xStart, split, y + levelH, levelH, widths);
    }
    if (n.right != null) {
      _assignPos(n.right!, split, xEnd, y + levelH, levelH, widths);
    }
  }
}