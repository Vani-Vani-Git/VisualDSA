import 'package:flutter/material.dart';

class StackComplexityCard extends StatelessWidget {
  final String operation;
  const StackComplexityCard({super.key, required this.operation});

  static const _data = {
    'push': {
      'time': 'O(1)',
      'space': 'O(1)',
      'best': 'O(1)',
      'worst': 'O(1)',
      'note':
          'Push always inserts at the top of the stack. No traversal needed. Constant time and space regardless of stack size. Only limited by available memory (stack overflow if full).',
    },
    'pop': {
      'time': 'O(1)',
      'space': 'O(1)',
      'best': 'O(1)',
      'worst': 'O(1)',
      'note':
          'Pop always removes from the top of the stack. Direct access — no scanning required. Constant time and space. Stack underflow occurs if the stack is already empty.',
    },
    'peek': {
      'time': 'O(1)',
      'space': 'O(1)',
      'best': 'O(1)',
      'worst': 'O(1)',
      'note':
          'Peek (or Top) reads the top element without removing it. Direct access — always O(1). Useful for checking the top value before deciding to pop. No modification to the stack.',
    },
  };

  static const _stackOverview = {
    'LIFO': 'Last In, First Out',
    'Access': 'O(n)',
    'Search': 'O(n)',
    'Applications': 'Undo, Recursion, Parsing',
  };

  @override
  Widget build(BuildContext context) {
    final info = _data[operation] ?? _data['push']!;

    final cells = [
      {'label': 'Time (Avg)', 'val': info['time']!},
      {'label': 'Space', 'val': info['space']!},
      {'label': 'Best Case', 'val': info['best']!},
      {'label': 'Worst Case', 'val': info['worst']!},
    ];

    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Operation header
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF161B22),
              border: Border.all(color: const Color(0xFF21262D)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.layers_outlined,
                    color: Color(0xFF3B82F6), size: 15),
                const SizedBox(width: 8),
                Text(
                  '${operation[0].toUpperCase()}${operation.substring(1)} Operation — Complexity',
                  style: const TextStyle(
                    color: Color(0xFF93C5FD),
                    fontSize: 12,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // 2×2 complexity grid
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
              info['note']!,
              style: const TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 12,
                fontFamily: 'monospace',
                height: 1.6,
              ),
            ),
          ),

          const SizedBox(height: 10),

          // Stack general overview
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
                  'Stack — General Overview',
                  style: TextStyle(
                    color: Color(0xFF3B82F6),
                    fontSize: 12,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                ..._stackOverview.entries.map((e) => Padding(
                      padding: const EdgeInsets.only(bottom: 5),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 90,
                            child: Text(
                              e.key,
                              style: const TextStyle(
                                color: Color(0xFF8B949E),
                                fontSize: 11,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ),
                          const Text(': ',
                              style: TextStyle(
                                  color: Color(0xFF4B5563),
                                  fontFamily: 'monospace',
                                  fontSize: 11)),
                          Expanded(
                            child: Text(
                              e.value,
                              style: const TextStyle(
                                color: Color(0xFFE2E8F0),
                                fontSize: 11,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}