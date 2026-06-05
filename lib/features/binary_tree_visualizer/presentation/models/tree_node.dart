/// A single node in the binary tree.
class TreeNode {
  int value;
  TreeNode? left;
  TreeNode? right;

  TreeNode(this.value);
}

/// Phase of the current animation step.
enum TreePhase {
  idle,
  comparing,   // traversing down to find position
  inserting,   // newly inserted node highlight
  deleting,    // node marked for deletion
  replacing,   // deepest node value copied
  removingDeepest, // deepest node removed
  visiting,    // traversal visit (inorder/preorder/postorder)
  done,
}

/// One animation frame for binary-tree operations.
class TreeStep {
  final TreeNode? root;             // snapshot of tree at this step
  final int? highlightNode;         // value of node being highlighted
  final int? secondaryNode;         // secondary highlight (e.g. deepest)
  final List<int> visitedOrder;     // traversal order so far
  final List<int> highlightPath;    // path from root to current node
  final String statusMsg;
  final TreePhase phase;

  const TreeStep({
    this.root,
    this.highlightNode,
    this.secondaryNode,
    this.visitedOrder = const [],
    this.highlightPath = const [],
    required this.statusMsg,
    this.phase = TreePhase.idle,
  });
}