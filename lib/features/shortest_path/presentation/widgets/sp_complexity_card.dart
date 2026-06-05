import 'package:flutter/material.dart';

class SpComplexityCard extends StatelessWidget {
  final String algorithm; // 'dijkstra' | 'bellman_ford'

  const SpComplexityCard({super.key, required this.algorithm});

  static const _data = {
    'dijkstra': {
      'time_best': 'O((V+E) log V)',
      'time_avg': 'O((V+E) log V)',
      'time_worst': 'O(V²)',
      'space': 'O(V)',
      'negative': '❌ No negative weights',
      'note':
          "Dijkstra's uses a min-heap (priority queue) to greedily pick "
          'the closest unvisited node. Each node is processed once, '
          'each edge is relaxed once. With a binary heap: O((V+E) log V). '
          'With an adjacency matrix (no heap): O(V²). Cannot handle '
          'negative-weight edges.',
    },
    'bellman_ford': {
      'time_best': 'O(VE)',
      'time_avg': 'O(VE)',
      'time_worst': 'O(VE)',
      'space': 'O(V)',
      'negative': '✓ Handles negative weights',
      'note':
          'Bellman-Ford relaxes ALL edges V-1 times (V = vertex count). '
          'Each pass guarantees the shortest path of at most k edges '
          'is found after k iterations. Can detect negative-weight cycles '
          '(run one extra pass — if any edge is still relaxed, a cycle '
          'exists). Slower than Dijkstra but more versatile.',
    },
  };

  @override
  Widget build(BuildContext context) {
    final info = _data[algorithm] ?? _data['dijkstra']!;
    final isDijk = algorithm == 'dijkstra';

    final cells = [
      {'label': 'Best Time', 'val': info['time_best']!},
      {'label': 'Avg Time', 'val': info['time_avg']!},
      {'label': 'Worst Time', 'val': info['time_worst']!},
      {'label': 'Space', 'val': info['space']!},
    ];

    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Negative weights badge
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isDijk
                  ? const Color(0xFFEF4444).withOpacity(0.08)
                  : const Color(0xFF22C55E).withOpacity(0.08),
              border: Border.all(
                color: isDijk
                    ? const Color(0xFFEF4444).withOpacity(0.3)
                    : const Color(0xFF22C55E).withOpacity(0.3),
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              info['negative']!,
              style: TextStyle(
                color: isDijk
                    ? const Color(0xFFF87171)
                    : const Color(0xFF4ADE80),
                fontSize: 11,
                fontWeight: FontWeight.w700,
                fontFamily: 'monospace',
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Complexity grid
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 2.2,
            children: cells.map((c) {
              return Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF161B22),
                  border: Border.all(color: const Color(0xFF21262D)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(c['label']!,
                        style: const TextStyle(
                            color: Color(0xFF8B949E),
                            fontSize: 9,
                            fontFamily: 'monospace')),
                    const SizedBox(height: 3),
                    Text(c['val']!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: Color(0xFF3B82F6),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'monospace')),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 10),

          // Explanation note
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF161B22),
              border: Border.all(color: const Color(0xFF21262D)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              info['note']!,
              style: const TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 11,
                fontFamily: 'monospace',
                height: 1.6,
              ),
            ),
          ),

          const SizedBox(height: 10),

          // Comparison row
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF161B22),
              border: Border.all(color: const Color(0xFF21262D)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('When to use?',
                    style: TextStyle(
                        color: Color(0xFFE2E8F0),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'monospace')),
                const SizedBox(height: 6),
                Text(
                  isDijk
                      ? '• Non-negative weights only\n'
                          '• GPS / routing systems\n'
                          '• Network shortest paths\n'
                          '• Faster than Bellman-Ford'
                      : '• Handles negative-weight edges\n'
                          '• Can detect negative cycles\n'
                          '• Distributed routing (e.g. RIP)\n'
                          '• Smaller graphs (V·E manageable)',
                  style: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 10,
                    fontFamily: 'monospace',
                    height: 1.6,
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