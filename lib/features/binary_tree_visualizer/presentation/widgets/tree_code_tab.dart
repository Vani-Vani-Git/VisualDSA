import 'package:flutter/material.dart';

class TreeCodeTabSection extends StatefulWidget {
  final String operation;
  final void Function(String language)? onLanguageChanged;

  const TreeCodeTabSection({
    super.key,
    required this.operation,
    this.onLanguageChanged,
  });

  @override
  State<TreeCodeTabSection> createState() => _TreeCodeTabSectionState();
}

class _TreeCodeTabSectionState extends State<TreeCodeTabSection> {
  String _lang = 'Python';
  bool _langOpen = false;

  static const _langs = ['Python', 'Java', 'C', 'C++'];

  static const Map<String, Map<String, String>> _snippets = {
    // ── INSERT ──────────────────────────────────────────────────────────────
    'insert': {
      'Python': '''from collections import deque

class Node:
    def __init__(self, val):
        self.val = val
        self.left = None
        self.right = None

def insert(root, val):
    new_node = Node(val)
    if root is None:
        return new_node
    queue = deque([root])
    while queue:
        node = queue.popleft()
        if node.left is None:
            node.left = new_node
            return root
        else:
            queue.append(node.left)
        if node.right is None:
            node.right = new_node
            return root
        else:
            queue.append(node.right)
    return root''',
      'Java': '''import java.util.LinkedList;
import java.util.Queue;

class Node {
    int val;
    Node left, right;
    Node(int v) { val = v; }
}

Node insert(Node root, int val) {
    Node newNode = new Node(val);
    if (root == null) return newNode;
    Queue<Node> q = new LinkedList<>();
    q.add(root);
    while (!q.isEmpty()) {
        Node node = q.poll();
        if (node.left == null) {
            node.left = newNode;
            return root;
        } else q.add(node.left);
        if (node.right == null) {
            node.right = newNode;
            return root;
        } else q.add(node.right);
    }
    return root;
}''',
      'C': '''#include <stdlib.h>

typedef struct Node {
    int val;
    struct Node *left, *right;
} Node;

Node* newNode(int v) {
    Node* n = malloc(sizeof(Node));
    n->val = v; n->left = n->right = NULL;
    return n;
}

Node* insert(Node* root, int val) {
    Node* node = newNode(val);
    if (!root) return node;
    Node* queue[100]; int f=0, r=0;
    queue[r++] = root;
    while (f < r) {
        Node* cur = queue[f++];
        if (!cur->left) { cur->left=node; return root; }
        else queue[r++] = cur->left;
        if (!cur->right) { cur->right=node; return root; }
        else queue[r++] = cur->right;
    }
    return root;
}''',
      'C++': '''#include <queue>
using namespace std;

struct Node {
    int val;
    Node *left, *right;
    Node(int v): val(v), left(nullptr), right(nullptr){}
};

Node* insert(Node* root, int val) {
    Node* newNode = new Node(val);
    if (!root) return newNode;
    queue<Node*> q;
    q.push(root);
    while (!q.empty()) {
        Node* node = q.front(); q.pop();
        if (!node->left) {
            node->left = newNode;
            return root;
        } else q.push(node->left);
        if (!node->right) {
            node->right = newNode;
            return root;
        } else q.push(node->right);
    }
    return root;
}''',
    },

    // ── DELETE ──────────────────────────────────────────────────────────────
    'delete': {
      'Python': '''from collections import deque

def delete_node(root, val):
    if root is None:
        return None
    if root.left is None and root.right is None:
        return None if root.val == val else root
    target = None
    last, last_parent = None, None
    queue = deque([root])
    while queue:
        node = queue.popleft()
        if node.val == val:
            target = node
        if node.left:
            last_parent, last = node, node.left
            queue.append(node.left)
        if node.right:
            last_parent, last = node, node.right
            queue.append(node.right)
    if target:
        target.val = last.val
        if last_parent.right == last:
            last_parent.right = None
        else:
            last_parent.left = None
    return root''',
      'Java': '''Node deleteNode(Node root, int val) {
    if (root == null) return null;
    if (root.left == null && root.right == null)
        return root.val == val ? null : root;
    Queue<Node> q = new LinkedList<>();
    q.add(root);
    Node target = null, last = null, lastPar = null;
    while (!q.isEmpty()) {
        Node node = q.poll();
        if (node.val == val) target = node;
        if (node.left != null) {
            lastPar = node; last = node.left;
            q.add(node.left);
        }
        if (node.right != null) {
            lastPar = node; last = node.right;
            q.add(node.right);
        }
    }
    if (target != null) {
        target.val = last.val;
        if (lastPar.right == last)
            lastPar.right = null;
        else lastPar.left = null;
    }
    return root;
}''',
      'C': '''Node* deleteNode(Node* root, int val) {
    if (!root) return NULL;
    Node* queue[100]; int f=0, r=0;
    queue[r++] = root;
    Node* target=NULL, *last=NULL, *lastPar=NULL;
    while (f < r) {
        Node* node = queue[f++];
        if (node->val == val) target = node;
        if (node->left) {
            lastPar=node; last=node->left;
            queue[r++]=node->left;
        }
        if (node->right) {
            lastPar=node; last=node->right;
            queue[r++]=node->right;
        }
    }
    if (target) {
        target->val = last->val;
        if (lastPar->right==last) lastPar->right=NULL;
        else lastPar->left=NULL;
        free(last);
    }
    return root;
}''',
      'C++': '''Node* deleteNode(Node* root, int val) {
    if (!root) return nullptr;
    queue<Node*> q;
    q.push(root);
    Node* target=nullptr, *last=nullptr, *lastPar=nullptr;
    while (!q.empty()) {
        Node* node = q.front(); q.pop();
        if (node->val == val) target = node;
        if (node->left) {
            lastPar=node; last=node->left;
            q.push(node->left);
        }
        if (node->right) {
            lastPar=node; last=node->right;
            q.push(node->right);
        }
    }
    if (target) {
        target->val = last->val;
        if (lastPar->right==last) lastPar->right=nullptr;
        else lastPar->left=nullptr;
        delete last;
    }
    return root;
}''',
    },

    // ── INORDER ─────────────────────────────────────────────────────────────
    'inorder': {
      'Python': '''def inorder(root, result=[]):
    if root is None:
        return
    inorder(root.left, result)   # Left
    result.append(root.val)      # Root
    inorder(root.right, result)  # Right
    return result''',
      'Java': '''void inorder(Node root, List<Integer> res) {
    if (root == null) return;
    inorder(root.left, res);   // Left
    res.add(root.val);         // Root
    inorder(root.right, res);  // Right
}''',
      'C': '''void inorder(Node* root, int* res, int* idx) {
    if (!root) return;
    inorder(root->left, res, idx);
    res[(*idx)++] = root->val;
    inorder(root->right, res, idx);
}''',
      'C++': '''void inorder(Node* root, vector<int>& res) {
    if (!root) return;
    inorder(root->left, res);   // Left
    res.push_back(root->val);   // Root
    inorder(root->right, res);  // Right
}''',
    },

    // ── PREORDER ────────────────────────────────────────────────────────────
    'preorder': {
      'Python': '''def preorder(root, result=[]):
    if root is None:
        return
    result.append(root.val)       # Root
    preorder(root.left, result)   # Left
    preorder(root.right, result)  # Right
    return result''',
      'Java': '''void preorder(Node root, List<Integer> res) {
    if (root == null) return;
    res.add(root.val);          // Root
    preorder(root.left, res);   // Left
    preorder(root.right, res);  // Right
}''',
      'C': '''void preorder(Node* root, int* res, int* idx) {
    if (!root) return;
    res[(*idx)++] = root->val;
    preorder(root->left, res, idx);
    preorder(root->right, res, idx);
}''',
      'C++': '''void preorder(Node* root, vector<int>& res) {
    if (!root) return;
    res.push_back(root->val);    // Root
    preorder(root->left, res);   // Left
    preorder(root->right, res);  // Right
}''',
    },

    // ── POSTORDER ───────────────────────────────────────────────────────────
    'postorder': {
      'Python': '''def postorder(root, result=[]):
    if root is None:
        return
    postorder(root.left, result)   # Left
    postorder(root.right, result)  # Right
    result.append(root.val)        # Root
    return result''',
      'Java': '''void postorder(Node root, List<Integer> res) {
    if (root == null) return;
    postorder(root.left, res);   // Left
    postorder(root.right, res);  // Right
    res.add(root.val);           // Root
}''',
      'C': '''void postorder(Node* root, int* res, int* idx) {
    if (!root) return;
    postorder(root->left, res, idx);
    postorder(root->right, res, idx);
    res[(*idx)++] = root->val;
}''',
      'C++': '''void postorder(Node* root, vector<int>& res) {
    if (!root) return;
    postorder(root->left, res);   // Left
    postorder(root->right, res);  // Right
    res.push_back(root->val);     // Root
}''',
    },
  };

  static const _keywords = [
    'def', 'return', 'if', 'else', 'elif', 'while', 'for', 'in', 'from',
    'import', 'None', 'class', 'void', 'int', 'struct', 'Node', 'null',
    'nullptr', 'new', 'delete', 'free', 'malloc', 'using', 'namespace',
    'include', 'queue', 'Queue', 'List', 'vector', 'true', 'false',
    'typedef', 'return', 'push_back', 'push', 'pop', 'empty', 'front',
    'add', 'poll', 'isEmpty', 'append', 'popleft', 'deque',
  ];

  List<TextSpan> _colorize(String line) {
    final spans = <TextSpan>[];
    if (line.trimLeft().startsWith('#') || line.trimLeft().startsWith('//')) {
      return [
        TextSpan(
            text: line,
            style: const TextStyle(color: Color(0xFF6B7280)))
      ];
    }
    final tokenRegex = RegExp(r'([A-Za-z_]\w*|\d+|[^\w\s]|\s+)');
    for (final m in tokenRegex.allMatches(line)) {
      final token = m.group(0)!;
      final trimmed = token.trim();
      Color color;
      if (_keywords.contains(trimmed)) {
        color = const Color(0xFFC084FC);
      } else if (RegExp(r'^\d+$').hasMatch(trimmed)) {
        color = const Color(0xFFFB923C);
      } else {
        color = const Color(0xFFE2E8F0);
      }
      spans.add(TextSpan(text: token, style: TextStyle(color: color)));
    }
    return spans;
  }

  @override
  Widget build(BuildContext context) {
    final code =
        _snippets[widget.operation]?[_lang] ?? '// Not available';
    final lines = code.split('\n');

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Language dropdown
          GestureDetector(
            onTap: () => setState(() => _langOpen = !_langOpen),
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
                  Text(_lang,
                      style: const TextStyle(
                        color: Color(0xFFE2E8F0),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'monospace',
                      )),
                  Icon(
                    _langOpen
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: const Color(0xFF8B949E),
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
          if (_langOpen)
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
                        _langOpen = false;
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
                                ? const Color(0xFF3B82F6)
                                : const Color(0xFFE2E8F0),
                            fontSize: 13,
                            fontFamily: 'monospace',
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
                          width: 22,
                          child: Text(
                            '${i + 1}',
                            style: const TextStyle(
                              color: Color(0xFFEF4444),
                              fontSize: 11,
                              fontFamily: 'monospace',
                            ),
                          ),
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