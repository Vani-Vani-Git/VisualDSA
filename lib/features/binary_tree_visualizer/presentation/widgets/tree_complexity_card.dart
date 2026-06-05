import 'package:flutter/material.dart';

class TreeComplexityCard extends StatelessWidget {
  final String operation;
  const TreeComplexityCard({super.key, required this.operation});

  static const _data = {
    'insert': {
      'time': 'O(n)',
      'space': 'O(n)',
      'best': 'O(1)',
      'worst': 'O(n)',
      'note':
          'Insertion uses BFS (level-order) to find the first available position. '
          'In the worst case, all nodes must be visited. Space O(n) for the BFS queue.',
      'steps': [
        'Start BFS from root.',
        'For each node, check left child first.',
        'If left is null → insert here.',
        'Else check right child.',
        'If right is null → insert here.',
        'Otherwise enqueue children and continue.',
      ],
    },
    'delete': {
      'time': 'O(n)',
      'space': 'O(n)',
      'best': 'O(1)',
      'worst': 'O(n)',
      'note':
          'Deletion requires two BFS passes: one to find the target node, '
          'one to find the deepest rightmost node. Value is swapped, deepest removed.',
      'steps': [
        'BFS to find the target node.',
        'BFS continues to find deepest rightmost node.',
        'Copy deepest node\'s value into target node.',
        'Remove the deepest node from the tree.',
        'Tree structure is preserved.',
      ],
    },
    'inorder': {
      'time': 'O(n)',
      'space': 'O(h)',
      'best': 'O(n)',
      'worst': 'O(n)',
      'note':
          'Inorder traversal visits Left → Root → Right. '
          'For a BST this produces sorted output. '
          'Space O(h) where h is the tree height due to recursive call stack.',
      'steps': [
        'Recursively traverse left subtree.',
        'Visit (process) the current node.',
        'Recursively traverse right subtree.',
        'Result: sorted order for BST.',
      ],
    },
    'preorder': {
      'time': 'O(n)',
      'space': 'O(h)',
      'best': 'O(n)',
      'worst': 'O(n)',
      'note':
          'Preorder visits Root → Left → Right. Useful for copying a tree '
          'or generating prefix expressions. Root is always processed first.',
      'steps': [
        'Visit (process) the current node.',
        'Recursively traverse left subtree.',
        'Recursively traverse right subtree.',
        'Result: root always appears first.',
      ],
    },
    'postorder': {
      'time': 'O(n)',
      'space': 'O(h)',
      'best': 'O(n)',
      'worst': 'O(n)',
      'note':
          'Postorder visits Left → Right → Root. Useful for deleting a tree '
          'or evaluating postfix expressions. Root is always processed last.',
      'steps': [
        'Recursively traverse left subtree.',
        'Recursively traverse right subtree.',
        'Visit (process) the current node.',
        'Result: root always appears last.',
      ],
    },
  };

  @override
  Widget build(BuildContext context) {
    final info = _data[operation];
    if (info == null) return const SizedBox();

    final cells = [
      {'label': 'Time', 'val': info['time'] as String},
      {'label': 'Space', 'val': info['space'] as String},
      {'label': 'Best Case', 'val': info['best'] as String},
      {'label': 'Worst Case', 'val': info['worst'] as String},
    ];

    final steps = info['steps'] as List<String>;

    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Column(
        children: [
          // Complexity grid
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 2.4,
            children: cells.map((c) {
              return Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF161B22),
                  border: Border.all(color: const Color(0xFF21262D)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(c['label']!,
                        style: const TextStyle(
                          color: Color(0xFF8B949E),
                          fontSize: 11,
                          fontFamily: 'monospace',
                        )),
                    const SizedBox(height: 4),
                    Text(c['val']!,
                        style: const TextStyle(
                          color: Color(0xFF3B82F6),
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'monospace',
                        )),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 10),

          // Note
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF161B22),
              border: Border.all(color: const Color(0xFF21262D)),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              info['note'] as String,
              style: const TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 12,
                fontFamily: 'monospace',
                height: 1.6,
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Step-by-step
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
                const Text(
                  'How it works:',
                  style: TextStyle(
                    color: Color(0xFF3B82F6),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(height: 8),
                ...steps.asMap().entries.map(
                  (e) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            color: const Color(0xFF3B82F6).withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${e.key + 1}',
                              style: const TextStyle(
                                color: Color(0xFF3B82F6),
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            e.value,
                            style: const TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 12,
                              fontFamily: 'monospace',
                              height: 1.5,
                            ),
                          ),
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