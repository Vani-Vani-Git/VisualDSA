/// A single node in the Binary Search Tree.
class BSTNode {
  int value;
  BSTNode? left;
  BSTNode? right;

  BSTNode(this.value);
}

/// Phase of current animation step.
enum BSTPhase {
  idle,
  comparing,    // traversing, comparing currNode with key
  goLeft,       // decided to go left
  goRight,      // decided to go right
  inserting,    // new node being placed
  found,        // target node found (search / delete)
  notFound,     // target not in tree
  tempNode,     // inorder successor found (temp label)
  deleting,     // node being removed
  done,         // final state
}

/// One animation frame for BST operations.
class BSTStep {
  final BSTNode? root;
  final int? currNode;        // value of node with currNode → arrow
  final int? tempNode;        // value of node with temp ← arrow
  final int? newNode;         // newly inserted node value
  final int? deletedNode;     // value being deleted (dashed circle)
  final List<int> visitedPath; // path of values visited so far (highlighted green)
  final String stepNumber;    // e.g. "01"
  final String stepTitle;     // short step label e.g. "Comparing key with root node"
  final String sideNote;      // right-side explanation text
  final BSTPhase phase;

  const BSTStep({
    this.root,
    this.currNode,
    this.tempNode,
    this.newNode,
    this.deletedNode,
    this.visitedPath = const [],
    required this.stepNumber,
    required this.stepTitle,
    this.sideNote = '',
    this.phase = BSTPhase.idle,
  });
}