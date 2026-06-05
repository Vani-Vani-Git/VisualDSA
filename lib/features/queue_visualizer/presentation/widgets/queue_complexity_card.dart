import 'package:flutter/material.dart';

class QueueComplexityCard extends StatelessWidget {
  final String operation;
  const QueueComplexityCard({super.key, required this.operation});

  static const _data = {
    'enqueue': {
      'time' : 'O(1)',
      'space': 'O(1)',
      'best' : 'O(1)',
      'worst': 'O(1)',
      'note' :
          'Enqueue always inserts at the REAR of the queue. No traversal needed. '
          'Direct access — constant time and space regardless of queue size. '
          'Only limited by available memory (queue overflow if full).',
    },
    'dequeue': {
      'time' : 'O(1)',
      'space': 'O(1)',
      'best' : 'O(1)',
      'worst': 'O(1)',
      'note' :
          'Dequeue always removes from the FRONT of the queue. Direct access — '
          'no scanning required. Constant time and space. '
          'Queue underflow occurs when the queue is already empty.',
    },
    'peek': {
      'time' : 'O(1)',
      'space': 'O(1)',
      'best' : 'O(1)',
      'worst': 'O(1)',
      'note' :
          'Peek reads the FRONT element without removing it. '
          'Always O(1) — direct access. Useful for checking the next element '
          'before deciding to dequeue. No modification to the queue.',
    },
  };

  static const _overview = {
    'Principle'   : 'FIFO — First In, First Out',
    'Access'      : 'O(n)',
    'Search'      : 'O(n)',
    'Enqueue'     : 'O(1)',
    'Dequeue'     : 'O(1)',
    'Applications': 'BFS, Scheduling, Buffers',
  };

  @override
  Widget build(BuildContext context) {
    final info = _data[operation] ?? _data['enqueue']!;

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
                const Icon(Icons.queue_outlined,
                    color: Color(0xFF22C55E), size: 15),
                const SizedBox(width: 8),
                Text(
                  '${operation[0].toUpperCase()}${operation.substring(1)} — Complexity',
                  style: const TextStyle(
                    color: Color(0xFF22C55E),
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
                        style: const TextStyle(
                            color: Color(0xFF22C55E),
                            fontSize: 18,
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

          // Queue overview table
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
                const Text('Queue — General Overview',
                    style: TextStyle(
                        color: Color(0xFF22C55E),
                        fontSize: 12,
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                ..._overview.entries.map((e) => Padding(
                      padding: const EdgeInsets.only(bottom: 5),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 100,
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