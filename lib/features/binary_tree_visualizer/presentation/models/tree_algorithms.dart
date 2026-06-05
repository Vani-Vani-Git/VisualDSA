import 'dart:collection';
import 'tree_node.dart';

/// Deep-clones a tree so each step snapshot is independent.
TreeNode? cloneTree(TreeNode? node) {
  if (node == null) return null;
  final n = TreeNode(node.value);
  n.left = cloneTree(node.left);
  n.right = cloneTree(node.right);
  return n;
}

class TreeAlgorithms {
  // ── Build tree from list (level-order) ──────────────────────────────────
  static TreeNode? buildFromList(List<int> values) {
    if (values.isEmpty) return null;
    final root = TreeNode(values[0]);
    final queue = Queue<TreeNode>()..add(root);
    int i = 1;
    while (queue.isNotEmpty && i < values.length) {
      final node = queue.removeFirst();
      if (i < values.length) {
        node.left = TreeNode(values[i++]);
        queue.add(node.left!);
      }
      if (i < values.length) {
        node.right = TreeNode(values[i++]);
        queue.add(node.right!);
      }
    }
    return root;
  }

  // ── INSERT ───────────────────────────────────────────────────────────────
  // BFS level-order insert (standard BT insert, NOT BST)
  static List<TreeStep> insert(TreeNode? root, int value) {
    final steps = <TreeStep>[];

    if (root == null) {
      final newRoot = TreeNode(value);
      steps.add(TreeStep(
        root: cloneTree(newRoot),
        highlightNode: value,
        statusMsg: 'Tree is empty. Insert $value as root.',
        phase: TreePhase.inserting,
        visitedOrder: [value],
      ));
      return steps;
    }

    // Show initial state
    steps.add(TreeStep(
      root: cloneTree(root),
      statusMsg: 'Insert $value using level-order (BFS). Start at root.',
      phase: TreePhase.idle,
    ));

    final queue = Queue<TreeNode>();
    queue.add(root);
    final path = <int>[];

    while (queue.isNotEmpty) {
      final node = queue.removeFirst();
      path.add(node.value);

      steps.add(TreeStep(
        root: cloneTree(root),
        highlightNode: node.value,
        highlightPath: List.from(path),
        statusMsg: 'Visiting node ${node.value}. Checking for empty child slot.',
        phase: TreePhase.comparing,
        visitedOrder: [],
      ));

      if (node.left == null) {
        node.left = TreeNode(value);
        steps.add(TreeStep(
          root: cloneTree(root),
          highlightNode: value,
          highlightPath: List.from(path),
          statusMsg: 'Node ${node.value} has no left child. Insert $value here!',
          phase: TreePhase.inserting,
          visitedOrder: [value],
        ));
        return steps;
      } else {
        queue.add(node.left!);
      }

      if (node.right == null) {
        node.right = TreeNode(value);
        steps.add(TreeStep(
          root: cloneTree(root),
          highlightNode: value,
          highlightPath: List.from(path),
          statusMsg: 'Node ${node.value} has no right child. Insert $value here!',
          phase: TreePhase.inserting,
          visitedOrder: [value],
        ));
        return steps;
      } else {
        queue.add(node.right!);
      }
    }
    return steps;
  }

  // ── DELETE ───────────────────────────────────────────────────────────────
  // Standard BT delete: replace target with deepest-rightmost node, then remove deepest.
  static List<TreeStep> delete(TreeNode? root, int value) {
    final steps = <TreeStep>[];
    if (root == null) {
      steps.add(TreeStep(
        root: null,
        statusMsg: 'Tree is empty. Nothing to delete.',
        phase: TreePhase.idle,
      ));
      return steps;
    }

    steps.add(TreeStep(
      root: cloneTree(root),
      highlightNode: value,
      statusMsg: 'Delete node $value. Using BFS to find target and deepest node.',
      phase: TreePhase.idle,
    ));

    // BFS to find target node and deepest rightmost node
    final queue = Queue<TreeNode>();
    queue.add(root);
    TreeNode? targetNode;
    TreeNode? lastNode;
    TreeNode? lastParent;
    bool lastIsLeft = false;

    while (queue.isNotEmpty) {
      final node = queue.removeFirst();

      steps.add(TreeStep(
        root: cloneTree(root),
        highlightNode: node.value,
        statusMsg: 'BFS visiting node ${node.value}.'
            '${node.value == value ? ' → This is the target!' : ''}',
        phase: TreePhase.comparing,
      ));

      if (node.value == value) targetNode = node;

      if (node.left != null) {
        lastParent = node;
        lastIsLeft = true;
        lastNode = node.left;
        queue.add(node.left!);
      }
      if (node.right != null) {
        lastParent = node;
        lastIsLeft = false;
        lastNode = node.right;
        queue.add(node.right!);
      }
    }

    if (targetNode == null) {
      steps.add(TreeStep(
        root: cloneTree(root),
        statusMsg: 'Node $value not found in tree.',
        phase: TreePhase.done,
      ));
      return steps;
    }

    final deepestVal = lastNode!.value;

    steps.add(TreeStep(
      root: cloneTree(root),
      highlightNode: targetNode.value,
      secondaryNode: deepestVal,
      statusMsg:
          'Found target node $value and deepest node $deepestVal. '
          'Replacing target value with deepest value.',
      phase: TreePhase.replacing,
    ));

    // Replace target value with deepest node value
    targetNode.value = deepestVal;

    steps.add(TreeStep(
      root: cloneTree(root),
      highlightNode: deepestVal,
      secondaryNode: deepestVal,
      statusMsg:
          'Copied $deepestVal into target position. Now remove deepest node.',
      phase: TreePhase.removingDeepest,
    ));

    // Remove deepest node
    if (lastParent != null) {
      if (lastIsLeft) {
        lastParent.left = null;
      } else {
        lastParent.right = null;
      }
    } else {
      // Only root existed
      steps.add(TreeStep(
        root: null,
        statusMsg: 'Tree is now empty after deletion.',
        phase: TreePhase.done,
      ));
      return steps;
    }

    steps.add(TreeStep(
      root: cloneTree(root),
      statusMsg: 'Deepest node removed. Deletion of $value complete!',
      phase: TreePhase.done,
    ));

    return steps;
  }

  // ── INORDER (Left → Root → Right) ────────────────────────────────────────
  static List<TreeStep> inorder(TreeNode? root) {
    final steps = <TreeStep>[];
    final visited = <int>[];

    steps.add(TreeStep(
      root: cloneTree(root),
      statusMsg: 'Inorder Traversal: Left → Root → Right',
      phase: TreePhase.idle,
      visitedOrder: [],
    ));

    void traverse(TreeNode? node) {
      if (node == null) return;
      traverse(node.left);

      visited.add(node.value);
      steps.add(TreeStep(
        root: cloneTree(root),
        highlightNode: node.value,
        visitedOrder: List.from(visited),
        statusMsg: 'Visit node ${node.value}. Order so far: [${visited.join(', ')}]',
        phase: TreePhase.visiting,
      ));

      traverse(node.right);
    }

    traverse(root);

    steps.add(TreeStep(
      root: cloneTree(root),
      visitedOrder: List.from(visited),
      statusMsg: 'Inorder complete! Result: [${visited.join(', ')}]',
      phase: TreePhase.done,
    ));

    return steps;
  }

  // ── PREORDER (Root → Left → Right) ───────────────────────────────────────
  static List<TreeStep> preorder(TreeNode? root) {
    final steps = <TreeStep>[];
    final visited = <int>[];

    steps.add(TreeStep(
      root: cloneTree(root),
      statusMsg: 'Preorder Traversal: Root → Left → Right',
      phase: TreePhase.idle,
      visitedOrder: [],
    ));

    void traverse(TreeNode? node) {
      if (node == null) return;

      visited.add(node.value);
      steps.add(TreeStep(
        root: cloneTree(root),
        highlightNode: node.value,
        visitedOrder: List.from(visited),
        statusMsg: 'Visit node ${node.value}. Order so far: [${visited.join(', ')}]',
        phase: TreePhase.visiting,
      ));

      traverse(node.left);
      traverse(node.right);
    }

    traverse(root);

    steps.add(TreeStep(
      root: cloneTree(root),
      visitedOrder: List.from(visited),
      statusMsg: 'Preorder complete! Result: [${visited.join(', ')}]',
      phase: TreePhase.done,
    ));

    return steps;
  }

  // ── POSTORDER (Left → Right → Root) ──────────────────────────────────────
  static List<TreeStep> postorder(TreeNode? root) {
    final steps = <TreeStep>[];
    final visited = <int>[];

    steps.add(TreeStep(
      root: cloneTree(root),
      statusMsg: 'Postorder Traversal: Left → Right → Root',
      phase: TreePhase.idle,
      visitedOrder: [],
    ));

    void traverse(TreeNode? node) {
      if (node == null) return;
      traverse(node.left);
      traverse(node.right);

      visited.add(node.value);
      steps.add(TreeStep(
        root: cloneTree(root),
        highlightNode: node.value,
        visitedOrder: List.from(visited),
        statusMsg: 'Visit node ${node.value}. Order so far: [${visited.join(', ')}]',
        phase: TreePhase.visiting,
      ));
    }

    traverse(root);

    steps.add(TreeStep(
      root: cloneTree(root),
      visitedOrder: List.from(visited),
      statusMsg: 'Postorder complete! Result: [${visited.join(', ')}]',
      phase: TreePhase.done,
    ));

    return steps;
  }
}