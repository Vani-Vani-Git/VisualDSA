import 'package:flutter/material.dart';

class HeapComplexityCard extends StatelessWidget {
  final String operation;
  final String heapType;
  const HeapComplexityCard(
      {super.key, required this.operation, required this.heapType});

  static const _data = {
    'insert': {
      'time' : 'O(log n)',
      'space': 'O(1)',
      'best' : 'O(1)',
      'worst': 'O(log n)',
      'note' :
          'Inserting adds the element at the last position (O(1)), '
          'then heapify-up compares with parent and swaps if needed. '
          'In the worst case this traverses the full height of the tree = O(log n).',
    },
    'delete': {
      'time' : 'O(log n)',
      'space': 'O(1)',
      'best' : 'O(log n)',
      'worst': 'O(log n)',
      'note' :
          'Deletion replaces the target node with the last element, '
          'removes the last node, then restores the heap with heapify-up '
          'or heapify-down — both O(log n) in the worst case.',
    },
    'update': {
      'time' : 'O(log n)',
      'space': 'O(1)',
      'best' : 'O(1)',
      'worst': 'O(log n)',
      'note' :
          'Updating changes a node\'s value, then either heapify-up '
          '(if new value is larger/smaller than parent) or heapify-down '
          '(if new value violates child property). Both O(log n).',
    },
    'sort': {
      'time' : 'O(n log n)',
      'space': 'O(1)',
      'best' : 'O(n log n)',
      'worst': 'O(n log n)',
      'note' :
          'Heap Sort: extract root (O(log n)) repeated n times → O(n log n). '
          'In-place sort with constant extra space. '
          'Not stable but optimal time complexity.',
    },
  };

  static const _overview = {
    'Structure'  : 'Complete Binary Tree',
    'Peek/Top'   : 'O(1)',
    'Insert'     : 'O(log n)',
    'Delete'     : 'O(log n)',
    'Heapify'    : 'O(n)',
    'Heap Sort'  : 'O(n log n)',
    'Space'      : 'O(n)',
  };

  @override
  Widget build(BuildContext context) {
    final info = _data[operation] ?? _data['insert']!;
    final typeLabel = heapType == 'max' ? 'Max-Heap' : 'Min-Heap';
    final typeColor = heapType == 'max'
        ? const Color(0xFFEF4444)
        : const Color(0xFF3B82F6);

    final cells = [
      {'label': 'Time (Avg)', 'val': info['time']!},
      {'label': 'Space',      'val': info['space']!},
      {'label': 'Best Case',  'val': info['best']!},
      {'label': 'Worst Case', 'val': info['worst']!},
    ];

    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
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
                Icon(Icons.account_tree_outlined,
                    color: typeColor, size: 15),
                const SizedBox(width: 8),
                Text(
                  '$typeLabel — ${operation[0].toUpperCase()}${operation.substring(1)} Complexity',
                  style: TextStyle(
                    color: typeColor,
                    fontSize: 12,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // 2×2 grid
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
                            fontFamily: 'monospace')),
                    const SizedBox(height: 4),
                    Text(c['val']!,
                        style: TextStyle(
                            color: typeColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'monospace')),
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
            child: Text(info['note']!,
                style: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 12,
                    fontFamily: 'monospace',
                    height: 1.6)),
          ),

          const SizedBox(height: 10),

          // General overview
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
                Text('Heap — General Overview',
                    style: TextStyle(
                        color: typeColor,
                        fontSize: 12,
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                ..._overview.entries.map((e) => Padding(
                      padding: const EdgeInsets.only(bottom: 5),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 90,
                            child: Text(e.key,
                                style: const TextStyle(
                                    color: Color(0xFF8B949E),
                                    fontSize: 11,
                                    fontFamily: 'monospace')),
                          ),
                          const Text(': ',
                              style: TextStyle(
                                  color: Color(0xFF4B5563),
                                  fontFamily: 'monospace',
                                  fontSize: 11)),
                          Expanded(
                            child: Text(e.value,
                                style: const TextStyle(
                                    color: Color(0xFFE2E8F0),
                                    fontSize: 11,
                                    fontFamily: 'monospace')),
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