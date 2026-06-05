import 'package:flutter/material.dart';

class MstComplexityCard extends StatelessWidget {
  final String algorithm; // 'prims' | 'kruskals'

  const MstComplexityCard({super.key, required this.algorithm});

  static const _data = {
    'prims': {
      'time_pq': 'O((V+E) log V)',
      'time_matrix': 'O(V²)',
      'space': 'O(V)',
      'approach': 'Greedy — grow MST from a seed vertex',
      'note':
          "Prim's algorithm grows the MST one vertex at a time. "
          'It always picks the minimum-weight edge crossing the cut '
          'between MST nodes and non-MST nodes. '
          'With a binary min-heap (priority queue): O((V+E) log V). '
          'With an adjacency matrix (no heap): O(V²). '
          'Best suited for dense graphs.',
    },
    'kruskals': {
      'time_pq': 'O(E log E)',
      'time_matrix': 'O(E log V)',
      'space': 'O(V + E)',
      'approach': 'Greedy — sort edges, add if no cycle',
      'note':
          "Kruskal's algorithm processes edges globally sorted by weight. "
          'It uses a Union-Find (Disjoint Set Union) data structure to '
          'detect cycles in O(α(V)) ≈ O(1) per operation. '
          'Total time dominated by sorting: O(E log E). '
          'Best suited for sparse graphs or when edges are already sorted.',
    },
  };

  @override
  Widget build(BuildContext context) {
    final info = _data[algorithm] ?? _data['prims']!;
    final isPrim = algorithm == 'prims';

    final cells = [
      {'label': 'With Priority Queue', 'val': info['time_pq']!},
      {'label': isPrim ? 'With Adj Matrix' : 'Simplified', 'val': info['time_matrix']!},
      {'label': 'Space', 'val': info['space']!},
      {'label': 'Approach', 'val': info['approach']!, 'small': true},
    ];

    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Algorithm badge
          Container(
            width: double.infinity,
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF22C55E).withOpacity(0.08),
              border: Border.all(
                  color: const Color(0xFF22C55E).withOpacity(0.3)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.account_tree_outlined,
                    color: Color(0xFF22C55E), size: 14),
                const SizedBox(width: 8),
                Text(
                  isPrim
                      ? "Prim's: Vertex-by-vertex MST construction"
                      : "Kruskal's: Edge-by-edge MST construction",
                  style: const TextStyle(
                      color: Color(0xFF4ADE80),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'monospace'),
                ),
              ],
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
            childAspectRatio: 2.0,
            children: cells.map((c) {
              final isSmall = c['small'] == true;
              return Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF161B22),
                  border: Border.all(color: const Color(0xFF21262D)),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 6),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(c['label'] as String,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: Color(0xFF8B949E),
                            fontSize: 9,
                            fontFamily: 'monospace')),
                    const SizedBox(height: 3),
                    Text(c['val']! as String,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: const Color(0xFF22C55E),
                            fontSize: isSmall ? 9 : 12,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'monospace')),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 10),

          // Explanation
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
                  height: 1.6),
            ),
          ),
          const SizedBox(height: 10),

          // Comparison
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
                  isPrim
                      ? '• Dense graphs (many edges)\n'
                          '• Network design (cable/pipe laying)\n'
                          '• Graph already stored as adj matrix\n'
                          '• Start from a specific vertex'
                      : '• Sparse graphs (few edges)\n'
                          '• Edges given as a list (easy to sort)\n'
                          '• Parallel processing of edges\n'
                          '• Need globally minimum edges first',
                  style: const TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 10,
                      fontFamily: 'monospace',
                      height: 1.6),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}