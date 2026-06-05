import 'package:flutter/material.dart';

class ComplexityCard extends StatelessWidget {
  final String algorithm;
  const ComplexityCard({super.key, required this.algorithm});

  static const _data = {
    'linear_search': {
      'time': 'O(n)',
      'space': 'O(1)',
      'best': 'O(1)',
      'worst': 'O(n)',
      'sorted': 'No',
      'note':
          'Scans every element one by one. Best case O(1) when target is the first element. Worst case O(n) when not found or at the end. Works on unsorted arrays.',
    },
    'binary_search': {
      'time': 'O(log n)',
      'space': 'O(1)',
      'best': 'O(1)',
      'worst': 'O(log n)',
      'sorted': 'Yes ✓',
      'note':
          'Repeatedly halves the search space by comparing with the middle element. Requires a sorted array. Very efficient for large datasets.',
    },
    'jump_search': {
      'time': 'O(√n)',
      'space': 'O(1)',
      'best': 'O(1)',
      'worst': 'O(√n)',
      'sorted': 'Yes ✓',
      'note':
          'Jumps √n steps at a time to find a block, then does a linear back-scan. More efficient than linear search (O(√n) vs O(n)), slower than binary search (O(log n)).',
    },
  };

  @override
  Widget build(BuildContext context) {
    final info = _data[algorithm];
    if (info == null) return const SizedBox();

    final cells = [
      {'label': 'Average', 'val': info['time']!},
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
          // Requires sorted row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF161B22),
              border: Border.all(color: const Color(0xFF21262D)),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Text('Requires Sorted Array:',
                    style: TextStyle(
                      color: Color(0xFF8B949E),
                      fontSize: 13,
                      fontFamily: 'monospace',
                    )),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: info['sorted']!.contains('Yes')
                        ? const Color(0xFF22C55E).withOpacity(0.15)
                        : const Color(0xFF8B949E).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    info['sorted']!,
                    style: TextStyle(
                      color: info['sorted']!.contains('Yes')
                          ? const Color(0xFF22C55E)
                          : const Color(0xFF8B949E),
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