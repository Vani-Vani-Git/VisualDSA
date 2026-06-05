import 'package:flutter/material.dart';

class ComplexityCard extends StatelessWidget {
  final String mode;
  const ComplexityCard({super.key, required this.mode});

  static const _data = {
    'adjacency_matrix': {
      'space': 'O(V²)',
      'addEdge': 'O(1)',
      'removeEdge': 'O(1)',
      'checkEdge': 'O(1)',
      'getAllNeighbours': 'O(V)',
      'note':
          'Adjacency Matrix uses V² space regardless of edges. Very fast for edge existence checks (O(1)) but slow for iterating neighbours (O(V)). Best for dense graphs.',
    },
    'adjacency_list': {
      'space': 'O(V+E)',
      'addEdge': 'O(1)',
      'removeEdge': 'O(E)',
      'checkEdge': 'O(V)',
      'getAllNeighbours': 'O(degree)',
      'note':
          'Adjacency List uses O(V+E) space — efficient for sparse graphs. Iterating all neighbours is O(degree). Preferred for most real-world graphs.',
    },
    'create_graph': {
      'space': 'O(V+E)',
      'addEdge': 'O(1)',
      'removeEdge': 'O(E)',
      'checkEdge': 'O(V)',
      'getAllNeighbours': 'O(degree)',
      'note':
          'Graph creation initialises V vertices and adds E edges. Choose adjacency matrix for dense graphs, adjacency list for sparse graphs.',
    },
  };

  @override
  Widget build(BuildContext context) {
    final info = _data[mode] ?? _data['adjacency_list']!;
    final cells = [
      {'label': 'Space', 'val': info['space']!},
      {'label': 'Add Edge', 'val': info['addEdge']!},
      {'label': 'Remove Edge', 'val': info['removeEdge']!},
      {'label': 'Check Edge', 'val': info['checkEdge']!},
      {'label': 'Get Neighbours', 'val': info['getAllNeighbours']!},
    ];

    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Column(
        children: [
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
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
                          fontSize: 10,
                          fontFamily: 'monospace',
                        )),
                    const SizedBox(height: 3),
                    Text(c['val']!,
                        style: const TextStyle(
                          color: Color(0xFF3B82F6),
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'monospace',
                        )),
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
                fontSize: 12,
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