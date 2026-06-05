import 'package:flutter/material.dart';

class ComplexityCard extends StatelessWidget {
  final String operation;

  const ComplexityCard({super.key, required this.operation});

  static const _data = {
    'sort': {
      'time': 'O(n²)',
      'space': 'O(1)',
      'best': 'O(n)',
      'worst': 'O(n²)',
      'note':
          'Bubble sort repeatedly swaps adjacent elements. Best case O(n) when array is already sorted (with early termination). Worst case O(n²) for reverse-sorted input.',
    },
    'insert': {
      'time': 'O(n)',
      'space': 'O(1)',
      'best': 'O(1)',
      'worst': 'O(n)',
      'note':
          'Inserting at index i requires shifting all elements from i to end right by one position. Best case O(1) when inserting at the end.',
    },
    'update': {
      'time': 'O(1)',
      'space': 'O(1)',
      'best': 'O(1)',
      'worst': 'O(1)',
      'note':
          'Direct index access in arrays is always constant time regardless of array size.',
    },
    'delete': {
      'time': 'O(n)',
      'space': 'O(1)',
      'best': 'O(1)',
      'worst': 'O(n)',
      'note':
          'Deleting at index i requires shifting all elements from i+1 to end left by one. Best case O(1) when deleting the last element.',
    },
  };

  @override
  Widget build(BuildContext context) {
    final info = _data[operation];
    if (info == null) return const SizedBox();

    final cards = [
      {'label': 'Time (Avg)', 'val': info['time']!},
      {'label': 'Space', 'val': info['space']!},
      {'label': 'Best Case', 'val': info['best']!},
      {'label': 'Worst Case', 'val': info['worst']!},
    ];

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
            childAspectRatio: 2.2,
            children: cards.map((c) {
              return Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF161B22),
                  border: Border.all(color: const Color(0xFF21262D)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      c['label']!,
                      style: const TextStyle(
                        color: Color(0xFF8B949E),
                        fontSize: 11,
                        fontFamily: 'monospace',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      c['val']!,
                      style: const TextStyle(
                        color: Color(0xFF3B82F6),
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 10),
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
                fontSize: 13,
                fontFamily: 'monospace',
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}