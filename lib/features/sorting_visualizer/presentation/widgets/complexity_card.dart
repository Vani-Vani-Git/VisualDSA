import 'package:flutter/material.dart';

class ComplexityCard extends StatelessWidget {
  final String algorithm;
  const ComplexityCard({super.key, required this.algorithm});

  static const _data = {
    'bubble_sort': {
      'time': 'O(n²)',
      'space': 'O(1)',
      'best': 'O(n)',
      'worst': 'O(n²)',
      'stable': 'Yes',
      'note': 'Repeatedly compares and swaps adjacent elements. Efficient early-termination when no swaps occur in a pass (best case O(n)).',
    },
    'selection_sort': {
      'time': 'O(n²)',
      'space': 'O(1)',
      'best': 'O(n²)',
      'worst': 'O(n²)',
      'stable': 'No',
      'note': 'Finds the minimum element each pass and places it in position. Always O(n²) regardless of input order.',
    },
    'insertion_sort': {
      'time': 'O(n²)',
      'space': 'O(1)',
      'best': 'O(n)',
      'worst': 'O(n²)',
      'stable': 'Yes',
      'note': 'Builds the sorted array one element at a time. Very efficient for nearly-sorted data (best case O(n)).',
    },
    'merge_sort': {
      'time': 'O(n log n)',
      'space': 'O(n)',
      'best': 'O(n log n)',
      'worst': 'O(n log n)',
      'stable': 'Yes',
      'note': 'Divide-and-conquer: split, sort halves, then merge. Guaranteed O(n log n) in all cases but requires O(n) extra space.',
    },
    'quick_sort': {
      'time': 'O(n log n)',
      'space': 'O(log n)',
      'best': 'O(n log n)',
      'worst': 'O(n²)',
      'stable': 'No',
      'note': 'Partitions around a pivot. Average O(n log n) and in-place. Worst case O(n²) when pivot is always min/max (rare with random pivot).',
    },
  };

  @override
  Widget build(BuildContext context) {
    final info = _data[algorithm];
    if (info == null) return const SizedBox();

    final cells = [
      {'label': 'Average', 'val': info['time']!},
      {'label': 'Space', 'val': info['space']!},
      {'label': 'Best', 'val': info['best']!},
      {'label': 'Worst', 'val': info['worst']!},
    ];

    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Column(
        children: [
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
                        fontSize: 17,
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
          // Stable row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF161B22),
              border: Border.all(color: const Color(0xFF21262D)),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Text(
                  'Stable Sort:',
                  style: TextStyle(
                    color: Color(0xFF8B949E),
                    fontSize: 13,
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: info['stable'] == 'Yes'
                        ? const Color(0xFF22C55E).withOpacity(0.15)
                        : const Color(0xFFEF4444).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    info['stable']!,
                    style: TextStyle(
                      color: info['stable'] == 'Yes'
                          ? const Color(0xFF22C55E)
                          : const Color(0xFFEF4444),
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ],
            ),
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