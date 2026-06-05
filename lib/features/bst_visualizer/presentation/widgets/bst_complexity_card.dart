import 'package:flutter/material.dart';

class BSTComplexityCard extends StatelessWidget {
  final String operation;
  const BSTComplexityCard({super.key, required this.operation});

  static const _data = {
    'insert': {
      'avg': 'O(log n)',
      'worst': 'O(n)',
      'best': 'O(log n)',
      'space': 'O(h)',
      'note':
          'Average case O(log n) for a balanced BST. Worst case O(n) '
          'for a skewed BST (sorted input). Space O(h) for recursive call stack '
          'where h is tree height.',
      'steps': [
        'Start at root node.',
        'If key < currNode → move to left child.',
        'If key > currNode → move to right child.',
        'Repeat until NULL position found.',
        'Insert new node at NULL position.',
      ],
    },
    'delete': {
      'avg': 'O(log n)',
      'worst': 'O(n)',
      'best': 'O(log n)',
      'space': 'O(h)',
      'note':
          'Deletion requires finding the node (O(log n) avg), then handling '
          '3 cases: leaf node, one child, or two children (inorder successor). '
          'Worst case O(n) for skewed tree.',
      'steps': [
        'Search for node to delete.',
        'Case 1 — Leaf: remove directly.',
        'Case 2 — One child: replace with child.',
        'Case 3 — Two children: find inorder successor (temp = leftmost of right subtree).',
        'Copy successor value, delete successor node.',
      ],
    },
    'search': {
      'avg': 'O(log n)',
      'worst': 'O(n)',
      'best': 'O(1)',
      'space': 'O(h)',
      'note':
          'BST search halves the search space at each step (like binary search). '
          'Average O(log n) for balanced BST, O(n) worst case for skewed tree. '
          'Best case O(1) when root is the target.',
      'steps': [
        'Compare key with currNode (root).',
        'If key == currNode → FOUND!',
        'If key < currNode → search left subtree.',
        'If key > currNode → search right subtree.',
        'If NULL reached → NOT FOUND.',
      ],
    },
  };

  @override
  Widget build(BuildContext context) {
    final info = _data[operation];
    if (info == null) return const SizedBox();

    final cells = [
      {'label': 'Average', 'val': info['avg']!, 'color': 0xFF4CAF50},
      {'label': 'Worst Case', 'val': info['worst']!, 'color': 0xFFEF4444},
      {'label': 'Best Case', 'val': info['best']!, 'color': 0xFF22C55E},
      {'label': 'Space', 'val': info['space']!, 'color': 0xFF3B82F6},
    ];

    final steps = info['steps'] as List<String>;

    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Column(
        children: [
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 2.4,
            children: cells.map((c) {
              final color = Color(c['color'] as int);
              return Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF161B22),
                  border: Border.all(color: const Color(0xFF21262D)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(c['label'] as String,
                        style: const TextStyle(
                          color: Color(0xFF8B949E),
                          fontSize: 11,
                          fontFamily: 'monospace',
                        )),
                    const SizedBox(height: 4),
                    Text(c['val'] as String,
                        style: TextStyle(
                          color: color,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'monospace',
                        )),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 10),

          // BST property note
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF161B22),
              border: Border.all(color: const Color(0xFF21262D)),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.info_outline,
                        color: Color(0xFF4CAF50), size: 13),
                    SizedBox(width: 6),
                    Text('BST Property',
                        style: TextStyle(
                          color: Color(0xFF4CAF50),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'monospace',
                        )),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'Left subtree < Node < Right subtree',
                  style: TextStyle(
                    color: Color(0xFFE2E8F0),
                    fontSize: 12,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  info['note'] as String,
                  style: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 12,
                    fontFamily: 'monospace',
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Step by step
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF161B22),
              border: Border.all(color: const Color(0xFF21262D)),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Algorithm Steps:',
                    style: TextStyle(
                      color: Color(0xFF4CAF50),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'monospace',
                    )),
                const SizedBox(height: 8),
                ...steps.asMap().entries.map(
                  (e) => Padding(
                    padding: const EdgeInsets.only(bottom: 7),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            color: const Color(0xFF4CAF50).withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text('${e.key + 1}',
                                style: const TextStyle(
                                  color: Color(0xFF4CAF50),
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  fontFamily: 'monospace',
                                )),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(e.value,
                              style: const TextStyle(
                                color: Color(0xFF94A3B8),
                                fontSize: 12,
                                fontFamily: 'monospace',
                                height: 1.5,
                              )),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}