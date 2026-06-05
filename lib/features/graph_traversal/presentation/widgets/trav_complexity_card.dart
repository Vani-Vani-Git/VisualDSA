import 'package:flutter/material.dart';

class TravComplexityCard extends StatelessWidget {
  final String algorithm;
  const TravComplexityCard({super.key, required this.algorithm});

  @override
  Widget build(BuildContext context) {
    final isBfs = algorithm == 'bfs';
    final accent = isBfs ? const Color(0xFF3B82F6) : const Color(0xFF9333EA);
    final accentLight = isBfs ? const Color(0xFF93C5FD) : const Color(0xFFC084FC);

    final cells = [
      {'label': 'Time (Adj List)', 'val': 'O(V + E)'},
      {'label': 'Time (Adj Matrix)', 'val': 'O(V²)'},
      {'label': 'Space', 'val': isBfs ? 'O(V)' : 'O(V)'},
      {'label': 'Data Structure', 'val': isBfs ? 'Queue' : 'Stack'},
    ];

    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Badge
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: accent.withOpacity(0.08),
            border: Border.all(color: accent.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(children: [
            Icon(isBfs ? Icons.waves : Icons.linear_scale, color: accent, size: 14),
            const SizedBox(width: 8),
            Expanded(child: Text(
              isBfs
                  ? 'BFS: Level-by-level exploration using a Queue'
                  : 'DFS: Deep-first exploration using a Stack',
              style: TextStyle(color: accentLight, fontSize: 11,
                  fontWeight: FontWeight.w700, fontFamily: 'monospace'),
            )),
          ]),
        ),
        const SizedBox(height: 10),

        // Grid
        GridView.count(
          crossAxisCount: 2, shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 8, mainAxisSpacing: 8, childAspectRatio: 2.2,
          children: cells.map((c) => Container(
            decoration: BoxDecoration(
              color: const Color(0xFF161B22),
              border: Border.all(color: const Color(0xFF21262D)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(c['label']!, textAlign: TextAlign.center,
                  style: const TextStyle(color: Color(0xFF8B949E), fontSize: 9, fontFamily: 'monospace')),
              const SizedBox(height: 3),
              Text(c['val']!, textAlign: TextAlign.center,
                  style: TextStyle(color: accent, fontSize: 13,
                      fontWeight: FontWeight.w700, fontFamily: 'monospace')),
            ]),
          )).toList(),
        ),
        const SizedBox(height: 10),

        // Explanation
        Container(
          width: double.infinity, padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF161B22),
            border: Border.all(color: const Color(0xFF21262D)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            isBfs
                ? 'BFS explores all neighbors at the current depth before going deeper. '
                  'It uses a Queue (FIFO) to process nodes level by level.\n\n'
                  'V = vertices, E = edges. With adjacency list: each vertex is enqueued '
                  'once O(V) and each edge is inspected once O(E) → O(V+E) total.\n\n'
                  'Space: O(V) for the visited set and queue (worst case all nodes in queue).'
                : 'DFS explores as deep as possible before backtracking. '
                  'It uses a Stack (LIFO) — either explicit (iterative) or the call stack (recursive).\n\n'
                  'V = vertices, E = edges. Each vertex is pushed/popped once → O(V+E) with adjacency list.\n\n'
                  'Space: O(V) for the stack + visited set. Recursive DFS can hit stack overflow on very deep graphs.',
            style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11,
                fontFamily: 'monospace', height: 1.6),
          ),
        ),
        const SizedBox(height: 10),

        // Use cases
        Container(
          width: double.infinity, padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF161B22),
            border: Border.all(color: const Color(0xFF21262D)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('When to use ${isBfs ? "BFS" : "DFS"}?',
                style: const TextStyle(color: Color(0xFFE2E8F0), fontSize: 11,
                    fontWeight: FontWeight.w700, fontFamily: 'monospace')),
            const SizedBox(height: 6),
            Text(
              isBfs
                  ? '• Shortest path in unweighted graphs\n'
                    '• Level-order tree traversal\n'
                    '• Finding all nodes within k hops\n'
                    '• Web crawlers (breadth-first indexing)\n'
                    '• Social network friend suggestions'
                  : '• Topological sorting of DAGs\n'
                    '• Detecting cycles in a graph\n'
                    '• Solving mazes / puzzles\n'
                    '• Connected components\n'
                    '• Generating permutations / combinations',
              style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 10,
                  fontFamily: 'monospace', height: 1.6),
            ),
          ]),
        ),
      ]),
    );
  }
}