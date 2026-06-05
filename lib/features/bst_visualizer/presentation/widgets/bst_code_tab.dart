import 'package:flutter/material.dart';

class BSTCodeTab extends StatefulWidget {
  final String operation;
  final void Function(String language)? onLanguageChanged;

  const BSTCodeTab({
    super.key,
    required this.operation,
    this.onLanguageChanged,
  });

  @override
  State<BSTCodeTab> createState() => _BSTCodeTabState();
}

class _BSTCodeTabState extends State<BSTCodeTab> {
  String _lang = 'Python';
  bool _open = false;
  static const _langs = ['Python', 'Java', 'C', 'C++'];

  static const Map<String, Map<String, String>> _snippets = {
    // ── INSERT ──────────────────────────────────────────────────────────────
    'insert': {
      'Python': '''class Node:
    def __init__(self, val):
        self.val = val
        self.left = None
        self.right = None

def insert(root, val):
    # Base case: empty spot found
    if root is None:
        return Node(val)
    # Key smaller → go left
    if val < root.val:
        root.left = insert(root.left, val)
    # Key larger → go right
    elif val > root.val:
        root.right = insert(root.right, val)
    # Duplicate: do nothing
    return root''',
      'Java': '''class Node {
    int val;
    Node left, right;
    Node(int v) { val = v; }
}

Node insert(Node root, int val) {
    // Base case: empty spot found
    if (root == null)
        return new Node(val);
    // Key smaller → go left
    if (val < root.val)
        root.left = insert(root.left, val);
    // Key larger → go right
    else if (val > root.val)
        root.right = insert(root.right, val);
    // Duplicate: do nothing
    return root;
}''',
      'C': '''typedef struct Node {
    int val;
    struct Node *left, *right;
} Node;

Node* insert(Node* root, int val) {
    if (!root) {
        Node* n = malloc(sizeof(Node));
        n->val = val;
        n->left = n->right = NULL;
        return n;
    }
    if (val < root->val)
        root->left = insert(root->left, val);
    else if (val > root->val)
        root->right = insert(root->right, val);
    return root;
}''',
      'C++': '''struct Node {
    int val;
    Node *left, *right;
    Node(int v):val(v),left(nullptr),right(nullptr){}
};

Node* insert(Node* root, int val) {
    if (!root) return new Node(val);
    if (val < root->val)
        root->left = insert(root->left, val);
    else if (val > root->val)
        root->right = insert(root->right, val);
    return root;
}''',
    },

    // ── DELETE ──────────────────────────────────────────────────────────────
    'delete': {
      'Python': '''def find_min(node):
    curr = node
    while curr.left:
        curr = curr.left
    return curr

def delete(root, key):
    if root is None:
        return None
    if key < root.val:
        root.left = delete(root.left, key)
    elif key > root.val:
        root.right = delete(root.right, key)
    else:
        # Case 1: Leaf node
        if not root.left and not root.right:
            return None
        # Case 2: One child
        if not root.left:
            return root.right
        if not root.right:
            return root.left
        # Case 3: Two children
        # Find inorder successor (temp)
        temp = find_min(root.right)
        root.val = temp.val
        root.right = delete(root.right, temp.val)
    return root''',
      'Java': '''Node findMin(Node node) {
    Node curr = node;
    while (curr.left != null)
        curr = curr.left;
    return curr;
}

Node delete(Node root, int key) {
    if (root == null) return null;
    if (key < root.val)
        root.left = delete(root.left, key);
    else if (key > root.val)
        root.right = delete(root.right, key);
    else {
        // Case 1: Leaf
        if (root.left==null && root.right==null)
            return null;
        // Case 2: One child
        if (root.left == null) return root.right;
        if (root.right == null) return root.left;
        // Case 3: Two children
        Node temp = findMin(root.right);
        root.val = temp.val;
        root.right = delete(root.right, temp.val);
    }
    return root;
}''',
      'C': '''Node* findMin(Node* node) {
    Node* curr = node;
    while (curr->left) curr = curr->left;
    return curr;
}

Node* delete(Node* root, int key) {
    if (!root) return NULL;
    if (key < root->val)
        root->left = delete(root->left, key);
    else if (key > root->val)
        root->right = delete(root->right, key);
    else {
        if (!root->left && !root->right) {
            free(root); return NULL;
        }
        if (!root->left) return root->right;
        if (!root->right) return root->left;
        Node* temp = findMin(root->right);
        root->val = temp->val;
        root->right = delete(root->right, temp->val);
    }
    return root;
}''',
      'C++': '''Node* findMin(Node* node) {
    Node* curr = node;
    while (curr->left) curr = curr->left;
    return curr;
}

Node* deleteNode(Node* root, int key) {
    if (!root) return nullptr;
    if (key < root->val)
        root->left = deleteNode(root->left, key);
    else if (key > root->val)
        root->right = deleteNode(root->right, key);
    else {
        if (!root->left && !root->right) {
            delete root; return nullptr;
        }
        if (!root->left) return root->right;
        if (!root->right) return root->left;
        Node* temp = findMin(root->right);
        root->val = temp->val;
        root->right = deleteNode(root->right, temp->val);
    }
    return root;
}''',
    },

    // ── SEARCH ──────────────────────────────────────────────────────────────
    'search': {
      'Python': '''def search(root, key):
    # Base: not found or found
    if root is None:
        return None   # not found
    if root.val == key:
        return root   # found!
    # Key smaller → search left
    if key < root.val:
        return search(root.left, key)
    # Key larger → search right
    return search(root.right, key)''',
      'Java': '''Node search(Node root, int key) {
    // Base case: not found or found
    if (root == null) return null;
    if (root.val == key) return root;
    // Key smaller → search left subtree
    if (key < root.val)
        return search(root.left, key);
    // Key larger → search right subtree
    return search(root.right, key);
}''',
      'C': '''Node* search(Node* root, int key) {
    if (!root) return NULL;
    if (root->val == key) return root;
    if (key < root->val)
        return search(root->left, key);
    return search(root->right, key);
}''',
      'C++': '''Node* search(Node* root, int key) {
    if (!root) return nullptr;
    if (root->val == key) return root;
    if (key < root->val)
        return search(root->left, key);
    return search(root->right, key);
}''',
    },
  };

  static const _keywords = [
    'def', 'return', 'if', 'elif', 'else', 'while', 'for', 'in',
    'class', 'None', 'not', 'and', 'or', 'True', 'False',
    'int', 'void', 'struct', 'typedef', 'nullptr', 'null', 'NULL',
    'new', 'delete', 'free', 'malloc', 'using', 'namespace',
    'Node', 'curr', 'temp', 'root', 'left', 'right', 'val',
  ];

  List<TextSpan> _colorize(String line) {
    final trimmed = line.trimLeft();
    if (trimmed.startsWith('#') || trimmed.startsWith('//')) {
      return [
        TextSpan(
            text: line,
            style: const TextStyle(color: Color(0xFF6B7280)))
      ];
    }
    final spans = <TextSpan>[];
    final tokenRx = RegExp(r'([A-Za-z_]\w*|\d+|[^\w\s]|\s+)');
    for (final m in tokenRx.allMatches(line)) {
      final tok = m.group(0)!;
      final t = tok.trim();
      Color color;
      if (_keywords.contains(t)) {
        color = const Color(0xFFC084FC);
      } else if (RegExp(r'^\d+$').hasMatch(t)) {
        color = const Color(0xFFFB923C);
      } else if (t == 'null' || t == 'NULL' || t == 'nullptr' || t == 'None') {
        color = const Color(0xFFFB923C);
      } else {
        color = const Color(0xFFE2E8F0);
      }
      spans.add(TextSpan(text: tok, style: TextStyle(color: color)));
    }
    return spans;
  }

  @override
  Widget build(BuildContext context) {
    final code = _snippets[widget.operation]?[_lang] ?? '// Not available';
    final lines = code.split('\n');

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Language dropdown
          GestureDetector(
            onTap: () => setState(() => _open = !_open),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              decoration: BoxDecoration(
                color: const Color(0xFF161B22),
                border: Border.all(color: const Color(0xFF30363D)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.code,
                          color: Color(0xFF4CAF50), size: 14),
                      const SizedBox(width: 6),
                      Text(_lang,
                          style: const TextStyle(
                            color: Color(0xFFE2E8F0),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'monospace',
                          )),
                    ],
                  ),
                  Icon(
                    _open
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: const Color(0xFF8B949E),
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
          if (_open)
            Container(
              margin: const EdgeInsets.only(top: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF1C2128),
                border: Border.all(color: const Color(0xFF30363D)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: _langs.map((l) {
                  final sel = l == _lang;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _lang = l;
                        _open = false;
                      });
                      widget.onLanguageChanged?.call(l);
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 9),
                      color: sel
                          ? const Color(0xFF21262D)
                          : Colors.transparent,
                      child: Text(l,
                          style: TextStyle(
                            color: sel
                                ? const Color(0xFF4CAF50)
                                : const Color(0xFFE2E8F0),
                            fontSize: 13,
                            fontFamily: 'monospace',
                            fontWeight: sel
                                ? FontWeight.w700
                                : FontWeight.normal,
                          )),
                    ),
                  );
                }).toList(),
              ),
            ),
          const SizedBox(height: 10),
          // Code block
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF161B22),
              border: Border.all(color: const Color(0xFF21262D)),
              borderRadius: BorderRadius.circular(10),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(lines.length, (i) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 24,
                          child: Text('${i + 1}',
                              style: const TextStyle(
                                color: Color(0xFFEF4444),
                                fontSize: 11,
                                fontFamily: 'monospace',
                              )),
                        ),
                        const SizedBox(width: 6),
                        RichText(
                          text: TextSpan(
                            style: const TextStyle(
                              fontSize: 11,
                              fontFamily: 'monospace',
                              height: 1.6,
                            ),
                            children: _colorize(lines[i]),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}