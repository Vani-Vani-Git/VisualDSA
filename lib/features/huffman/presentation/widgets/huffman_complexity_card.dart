import 'package:flutter/material.dart';

class HuffmanComplexityCard extends StatelessWidget {
  const HuffmanComplexityCard({super.key});

  @override
  Widget build(BuildContext context) {
    final cells = [
      {'label': 'Build Tree', 'val': 'O(n log n)'},
      {'label': 'Encode String', 'val': 'O(n)'},
      {'label': 'Decode String', 'val': 'O(n)'},
      {'label': 'Space', 'val': 'O(n)'},
    ];

    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Badge
          Container(
            width: double.infinity,
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF9333EA).withOpacity(0.08),
              border: Border.all(
                  color: const Color(0xFF9333EA).withOpacity(0.3)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Icon(Icons.compress, color: Color(0xFF9333EA), size: 14),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Huffman Coding: Optimal prefix-free lossless compression',
                    style: TextStyle(
                        color: Color(0xFFC084FC),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'monospace'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Grid
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
                        style: const TextStyle(
                            color: Color(0xFF9333EA),
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'monospace')),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 10),

          // Where n explanation
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF161B22),
              border: Border.all(color: const Color(0xFF21262D)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'n = number of unique characters in the input.\n\n'
              'Building the Huffman tree uses a min-heap: each of the '
              'n–1 merge operations takes O(log n), giving O(n log n) total.\n\n'
              'Encoding/decoding is O(L) where L = input string length '
              '(each character maps to its code in O(1) via a hash map).\n\n'
              'Space: O(n) for the tree and code table.',
              style: TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 11,
                  fontFamily: 'monospace',
                  height: 1.6),
          )),
          const SizedBox(height: 10),

          // Properties
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
                const Text('Key Properties',
                    style: TextStyle(
                        color: Color(0xFFE2E8F0),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'monospace')),
                const SizedBox(height: 6),
                ...[
                  '• Prefix-free: no code is a prefix of another',
                  '• Optimal: minimum total bits for given frequencies',
                  '• Lossless: original data fully recoverable',
                  '• Variable-length: frequent chars get shorter codes',
                  '• Used in: ZIP, JPEG, MP3, HTTP compression',
                ].map((s) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(s,
                          style: const TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 10,
                              fontFamily: 'monospace',
                              height: 1.5)),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}