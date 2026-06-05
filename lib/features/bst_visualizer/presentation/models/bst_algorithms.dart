import 'bst_node.dart';

/// Deep-clone a BST so each step snapshot is independent.
BSTNode? cloneBST(BSTNode? node) {
  if (node == null) return null;
  final n = BSTNode(node.value);
  n.left = cloneBST(node.left);
  n.right = cloneBST(node.right);
  return n;
}

class BSTAlgorithms {
  // ── Build BST from unsorted list ─────────────────────────────────────────
  static BSTNode? buildFromList(List<int> values) {
    BSTNode? root;
    for (final v in values) {
      root = _insertNode(root, v);
    }
    return root;
  }

  static BSTNode _insertNode(BSTNode? root, int value) {
    if (root == null) return BSTNode(value);
    if (value < root.value) {
      root.left = _insertNode(root.left, value);
    } else if (value > root.value) {
      root.right = _insertNode(root.right, value);
    }
    return root;
  }

  // ────────────────────────────────────────────────────────────────────────
  // INSERT — animated steps
  // ────────────────────────────────────────────────────────────────────────
  static List<BSTStep> insert(BSTNode? root, int value) {
    final steps = <BSTStep>[];
    int stepNum = 0;

    String num() => (++stepNum).toString().padLeft(2, '0');

    if (root == null) {
      final newRoot = BSTNode(value);
      steps.add(BSTStep(
        root: cloneBST(newRoot),
        currNode: value,
        newNode: value,
        stepNumber: num(),
        stepTitle: 'Tree is empty — insert $value as root',
        phase: BSTPhase.inserting,
      ));
      return steps;
    }

    // Step 1 — initial state
    steps.add(BSTStep(
      root: cloneBST(root),
      stepNumber: num(),
      stepTitle: 'Start BST Insertion  •  Key = $value',
      sideNote: 'Begin at the root node.',
      phase: BSTPhase.idle,
    ));

    // Traverse
    final path = <int>[];
    BSTNode? cur = root;
    BSTNode? parent;
    bool wentLeft = false;

    while (cur != null) {
      path.add(cur.value);
      if (value == cur.value) {
        // Duplicate — already exists
        steps.add(BSTStep(
          root: cloneBST(root),
          currNode: cur.value,
          visitedPath: List.from(path),
          stepNumber: num(),
          stepTitle: 'Node $value already exists in BST',
          sideNote: 'Duplicates not allowed in BST.',
          phase: BSTPhase.found,
        ));
        return steps;
      } else if (value < cur.value) {
        steps.add(BSTStep(
          root: cloneBST(root),
          currNode: cur.value,
          visitedPath: List.from(path),
          stepNumber: num(),
          stepTitle: 'Key $value < currNode ${cur.value}  →  go LEFT',
          sideNote:
              'Since $value is smaller than ${cur.value},\nmove to the left child.',
          phase: BSTPhase.goLeft,
        ));
        parent = cur;
        wentLeft = true;
        cur = cur.left;
      } else {
        steps.add(BSTStep(
          root: cloneBST(root),
          currNode: cur.value,
          visitedPath: List.from(path),
          stepNumber: num(),
          stepTitle: 'Key $value > currNode ${cur.value}  →  go RIGHT',
          sideNote:
              'Since $value is greater than ${cur.value},\nmove to the right child.',
          phase: BSTPhase.goRight,
        ));
        parent = cur;
        wentLeft = false;
        cur = cur.right;
      }
    }

    // Insert new node
    final newNode = BSTNode(value);
    if (parent != null) {
      if (wentLeft) {
        parent.left = newNode;
      } else {
        parent.right = newNode;
      }
    }

    steps.add(BSTStep(
      root: cloneBST(root),
      currNode: value,
      newNode: value,
      visitedPath: List.from(path),
      stepNumber: num(),
      stepTitle:
          'NULL reached  →  Insert $value as ${wentLeft ? 'left' : 'right'} child of ${parent?.value}',
      sideNote: 'New node $value inserted\nsuccessfully into the BST!',
      phase: BSTPhase.inserting,
    ));

    steps.add(BSTStep(
      root: cloneBST(root),
      newNode: value,
      visitedPath: [...path, value],
      stepNumber: num(),
      stepTitle: 'Final BST after inserting $value',
      phase: BSTPhase.done,
    ));

    return steps;
  }

  // ────────────────────────────────────────────────────────────────────────
  // SEARCH — animated steps
  // ────────────────────────────────────────────────────────────────────────
  static List<BSTStep> search(BSTNode? root, int key) {
    final steps = <BSTStep>[];
    int stepNum = 0;
    String num() => (++stepNum).toString().padLeft(2, '0');

    if (root == null) {
      steps.add(BSTStep(
        root: null,
        stepNumber: num(),
        stepTitle: 'Tree is empty — cannot search',
        phase: BSTPhase.notFound,
      ));
      return steps;
    }

    steps.add(BSTStep(
      root: cloneBST(root),
      stepNumber: num(),
      stepTitle: 'Consider the following BST  •  Key = $key',
      sideNote: 'Start search from root.',
      phase: BSTPhase.idle,
    ));

    final path = <int>[];
    BSTNode? cur = root;

    while (cur != null) {
      path.add(cur.value);

      if (key == cur.value) {
        steps.add(BSTStep(
          root: cloneBST(root),
          currNode: cur.value,
          visitedPath: List.from(path),
          stepNumber: num(),
          stepTitle:
              'Compare key with currNode ${cur.value}  →  $key == ${cur.value}  ✓  FOUND!',
          sideNote: 'As $key is equal to\ncurrNode(${cur.value}),\nwe have found the key.',
          phase: BSTPhase.found,
        ));
        steps.add(BSTStep(
          root: cloneBST(root),
          currNode: cur.value,
          visitedPath: List.from(path),
          stepNumber: (stepNum).toString().padLeft(2, '0'),
          stepTitle: 'Search complete — key $key found!',
          phase: BSTPhase.done,
        ));
        return steps;
      } else if (key < cur.value) {
        steps.add(BSTStep(
          root: cloneBST(root),
          currNode: cur.value,
          visitedPath: List.from(path),
          stepNumber: num(),
          stepTitle:
              'Compare key $key with currNode ${cur.value}  →  $key < ${cur.value}  →  go LEFT',
          sideNote:
              'Since $key is smaller than ${cur.value},\nmove pointer to left child.',
          phase: BSTPhase.goLeft,
        ));
        cur = cur.left;
      } else {
        steps.add(BSTStep(
          root: cloneBST(root),
          currNode: cur.value,
          visitedPath: List.from(path),
          stepNumber: num(),
          stepTitle:
              'Compare key $key with currNode ${cur.value}  →  $key > ${cur.value}  →  go RIGHT',
          sideNote:
              'Since $key is greater than ${cur.value},\nmove pointer to right child.',
          phase: BSTPhase.goRight,
        ));
        cur = cur.right;
      }
    }

    steps.add(BSTStep(
      root: cloneBST(root),
      visitedPath: List.from(path),
      stepNumber: num(),
      stepTitle: 'Reached NULL — key $key NOT FOUND in BST',
      sideNote: '$key does not exist in this BST.',
      phase: BSTPhase.notFound,
    ));
    return steps;
  }

  // ────────────────────────────────────────────────────────────────────────
  // DELETE — animated steps (BST delete with inorder successor)
  // ────────────────────────────────────────────────────────────────────────
  static List<BSTStep> delete(BSTNode? root, int key) {
    final steps = <BSTStep>[];
    int stepNum = 0;
    String num() => (++stepNum).toString().padLeft(2, '0');

    if (root == null) {
      steps.add(BSTStep(
        root: null,
        stepNumber: num(),
        stepTitle: 'Tree is empty — nothing to delete',
        phase: BSTPhase.notFound,
      ));
      return steps;
    }

    steps.add(BSTStep(
      root: cloneBST(root),
      stepNumber: num(),
      stepTitle: 'Start BST Deletion  •  Key = $key',
      sideNote: 'Begin from the root node.',
      phase: BSTPhase.idle,
    ));

    // Phase 1: Find the node
    final path = <int>[];
    BSTNode? cur = root;

    while (cur != null && cur.value != key) {
      path.add(cur.value);
      if (key < cur.value) {
        steps.add(BSTStep(
          root: cloneBST(root),
          currNode: cur.value,
          visitedPath: List.from(path),
          stepNumber: num(),
          stepTitle: 'Comparing key with root node',
          sideNote:
              'Since ${cur.value} is greater than\nkey ($key), move the pointer\nto the left child.',
          phase: BSTPhase.comparing,
        ));
        cur = cur.left;
      } else {
        steps.add(BSTStep(
          root: cloneBST(root),
          currNode: cur.value,
          visitedPath: List.from(path),
          stepNumber: num(),
          stepTitle: 'Comparing key with root node',
          sideNote:
              'Since ${cur.value} is smaller than\nkey ($key), move the pointer\nto the right child.',
          phase: BSTPhase.comparing,
        ));
        cur = cur.right;
      }
    }

    if (cur == null) {
      steps.add(BSTStep(
        root: cloneBST(root),
        visitedPath: List.from(path),
        stepNumber: num(),
        stepTitle: 'Key $key NOT FOUND in BST',
        phase: BSTPhase.notFound,
      ));
      return steps;
    }

    path.add(cur.value);

    // Found the node — show it
    steps.add(BSTStep(
      root: cloneBST(root),
      currNode: cur.value,
      visitedPath: List.from(path),
      stepNumber: num(),
      stepTitle: 'Node $key found  →  currNode = $key',
      sideNote: 'We have located the node\nto be deleted.',
      phase: BSTPhase.found,
    ));

    // Case 1: leaf node
    if (cur.left == null && cur.right == null) {
      steps.add(BSTStep(
        root: cloneBST(root),
        currNode: cur.value,
        deletedNode: cur.value,
        visitedPath: List.from(path),
        stepNumber: num(),
        stepTitle: 'Node $key is a leaf node  →  delete directly',
        sideNote: 'No children. Simply\nremove the node.',
        phase: BSTPhase.deleting,
      ));
      _deleteFromTree(root, key);
      steps.add(BSTStep(
        root: cloneBST(root),
        stepNumber: num(),
        stepTitle: 'Final BST after deleting $key',
        phase: BSTPhase.done,
      ));
    }
    // Case 2: one child
    else if (cur.left == null || cur.right == null) {
      final child = cur.left ?? cur.right;
      steps.add(BSTStep(
        root: cloneBST(root),
        currNode: cur.value,
        tempNode: child!.value,
        deletedNode: cur.value,
        visitedPath: List.from(path),
        stepNumber: num(),
        stepTitle:
            'Node $key has only one child  (temp = currNode->${cur.left == null ? 'right' : 'left'})',
        sideNote: 'Replace node with\nits only child.',
        phase: BSTPhase.tempNode,
      ));
      steps.add(BSTStep(
        root: cloneBST(root),
        currNode: cur.value,
        deletedNode: cur.value,
        tempNode: child.value,
        visitedPath: List.from(path),
        stepNumber: num(),
        stepTitle: 'Delete the node and return temp',
        sideNote: 'Node $key removed.\ntemp (${child.value}) takes its place.',
        phase: BSTPhase.deleting,
      ));
      _deleteFromTree(root, key);
      steps.add(BSTStep(
        root: cloneBST(root),
        stepNumber: num(),
        stepTitle: 'Final BST after deleting $key',
        phase: BSTPhase.done,
      ));
    }
    // Case 3: two children — inorder successor
    else {
      // Find inorder successor (smallest in right subtree)
      BSTNode? successor = cur.right;
      while (successor!.left != null) {
        successor = successor.left;
      }

      steps.add(BSTStep(
        root: cloneBST(root),
        currNode: cur.value,
        visitedPath: List.from(path),
        stepNumber: num(),
        stepTitle:
            'Node $key has two children  →  find inorder successor',
        sideNote:
            'Find the smallest node\nin the right subtree (temp).',
        phase: BSTPhase.comparing,
      ));

      steps.add(BSTStep(
        root: cloneBST(root),
        currNode: cur.value,
        tempNode: successor.value,
        visitedPath: List.from(path),
        stepNumber: num(),
        stepTitle:
            'Inorder successor found  →  temp = ${successor.value}',
        sideNote:
            'Node $key have two children.\n(temp = currNode->right\n leftmost = ${successor.value})',
        phase: BSTPhase.tempNode,
      ));

      steps.add(BSTStep(
        root: cloneBST(root),
        currNode: cur.value,
        deletedNode: cur.value,
        tempNode: successor.value,
        visitedPath: List.from(path),
        stepNumber: num(),
        stepTitle: 'Delete the node and return temp',
        sideNote:
            'Copy ${successor.value} into node $key,\nthen delete successor.',
        phase: BSTPhase.deleting,
      ));

      // Perform deletion
      _deleteFromTree(root, key);

      steps.add(BSTStep(
        root: cloneBST(root),
        stepNumber: num(),
        stepTitle: 'Final BST after deleting $key',
        phase: BSTPhase.done,
      ));
    }

    return steps;
  }

  /// Mutates the BST in-place (used after capturing snapshots).
  static BSTNode? _deleteFromTree(BSTNode? node, int key) {
    if (node == null) return null;
    if (key < node.value) {
      node.left = _deleteFromTree(node.left, key);
    } else if (key > node.value) {
      node.right = _deleteFromTree(node.right, key);
    } else {
      if (node.left == null) return node.right;
      if (node.right == null) return node.left;
      // Two children: find inorder successor
      BSTNode? succ = node.right;
      while (succ!.left != null) succ = succ.left;
      node.value = succ.value;
      node.right = _deleteFromTree(node.right, succ.value);
    }
    return node;
  }
}