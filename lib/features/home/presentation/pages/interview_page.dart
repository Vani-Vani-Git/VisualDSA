// interview_page.dart
// Place at: features/home/presentation/pages/interview_page.dart

import 'package:flutter/material.dart';
import 'interview_question_pages.dart';

class _InterviewItem {
  final String title;
  final String difficulty;
  final Color difficultyColor;
  final List<String> commonQuestions;
  final IconData icon;
  final Color accentColor;
  final Widget page;

  const _InterviewItem({
    required this.title,
    required this.difficulty,
    required this.difficultyColor,
    required this.commonQuestions,
    required this.icon,
    required this.accentColor,
    required this.page,
  });
}

class InterviewPage extends StatefulWidget {
  const InterviewPage({super.key});

  @override
  State<InterviewPage> createState() => _InterviewPageState();
}

class _InterviewPageState extends State<InterviewPage> {
  String _selectedDifficulty = 'All';
  final List<String> _difficulties = ['All', 'Easy', 'Medium', 'Hard'];

  static final List<_InterviewItem> _items = [
    _InterviewItem(
      title: 'Array',
      difficulty: 'Easy',
      difficultyColor: Colors.green,
      commonQuestions: [
        'Find two sum in an array',
        'Rotate array by K positions',
        'Find maximum subarray (Kadane\'s)',
      ],
      icon: Icons.grid_view_rounded,
      accentColor: Colors.blue,
      page: const ArrayInterviewPage(),
    ),
    _InterviewItem(
      title: 'Sorting',
      difficulty: 'Medium',
      difficultyColor: Colors.orange,
      commonQuestions: [
        'Sort colors (Dutch national flag)',
        'Merge overlapping intervals',
        'Find kth largest element',
      ],
      icon: Icons.sort_rounded,
      accentColor: Colors.purple,
      page: const SortingInterviewPage(),
    ),
    _InterviewItem(
      title: 'Searching',
      difficulty: 'Easy',
      difficultyColor: Colors.green,
      commonQuestions: [
        'Binary search on rotated sorted array',
        'Find first and last position',
        'Search in 2D matrix',
      ],
      icon: Icons.search_rounded,
      accentColor: Colors.green,
      page: const SearchingInterviewPage(),
    ),
    _InterviewItem(
      title: 'Graph',
      difficulty: 'Hard',
      difficultyColor: Colors.red,
      commonQuestions: [
        'Detect cycle in directed graph',
        'Number of islands',
        'Clone a graph',
      ],
      icon: Icons.hub_rounded,
      accentColor: Colors.orange,
      page: const GraphInterviewPage(),
    ),
    _InterviewItem(
      title: 'Graph Traversal',
      difficulty: 'Medium',
      difficultyColor: Colors.orange,
      commonQuestions: [
        'Word ladder problem (BFS)',
        'All paths from source to target (DFS)',
        'Shortest path in unweighted graph',
      ],
      icon: Icons.account_tree_rounded,
      accentColor: Colors.teal,
      page: const GraphTraversalInterviewPage(),
    ),
    _InterviewItem(
      title: 'Binary Tree',
      difficulty: 'Medium',
      difficultyColor: Colors.orange,
      commonQuestions: [
        'Lowest common ancestor',
        'Maximum depth of binary tree',
        'Zigzag level order traversal',
      ],
      icon: Icons.device_hub_rounded,
      accentColor: Colors.cyan,
      page: const BinaryTreeInterviewPage(),
    ),
    _InterviewItem(
      title: 'Binary Search Tree',
      difficulty: 'Medium',
      difficultyColor: Colors.orange,
      commonQuestions: [
        'Validate a BST',
        'Kth smallest element in BST',
        'Convert sorted array to BST',
      ],
      icon: Icons.schema_rounded,
      accentColor: Colors.indigo,
      page: const BSTInterviewPage(),
    ),
    _InterviewItem(
      title: 'Linked List',
      difficulty: 'Medium',
      difficultyColor: Colors.orange,
      commonQuestions: [
        'Reverse a linked list',
        'Detect cycle (Floyd\'s algorithm)',
        'Merge two sorted linked lists',
      ],
      icon: Icons.linear_scale_rounded,
      accentColor: Colors.pink,
      page: const LinkedListInterviewPage(),
    ),
    _InterviewItem(
      title: 'Stack',
      difficulty: 'Easy',
      difficultyColor: Colors.green,
      commonQuestions: [
        'Valid parentheses',
        'Next greater element',
        'Min stack design',
      ],
      icon: Icons.layers_rounded,
      accentColor: Colors.amber,
      page: const StackInterviewPage(),
    ),
    _InterviewItem(
      title: 'Queue',
      difficulty: 'Easy',
      difficultyColor: Colors.green,
      commonQuestions: [
        'Implement queue using stacks',
        'Sliding window maximum',
        'Generate binary numbers using queue',
      ],
      icon: Icons.queue_rounded,
      accentColor: Colors.lightBlue,
      page: const QueueInterviewPage(),
    ),
    _InterviewItem(
      title: 'Heap',
      difficulty: 'Hard',
      difficultyColor: Colors.red,
      commonQuestions: [
        'Merge K sorted lists',
        'Find median from data stream',
        'Top K frequent elements',
      ],
      icon: Icons.filter_list_rounded,
      accentColor: Colors.deepOrange,
      page: const HeapInterviewPage(),
    ),
    _InterviewItem(
      title: 'Shortest Path',
      difficulty: 'Hard',
      difficultyColor: Colors.red,
      commonQuestions: [
        'Network delay time (Dijkstra)',
        'Cheapest flights within K stops',
        'Path with minimum effort',
      ],
      icon: Icons.route_rounded,
      accentColor: Colors.lime,
      page: const ShortestPathInterviewPage(),
    ),
    _InterviewItem(
      title: 'Minimum Spanning Tree',
      difficulty: 'Hard',
      difficultyColor: Colors.red,
      commonQuestions: [
        'Min cost to connect all points',
        'Optimize water distribution',
        'Remove max number of edges',
      ],
      icon: Icons.park_rounded,
      accentColor: Colors.greenAccent,
      page: const MSTInterviewPage(),
    ),
    _InterviewItem(
      title: 'Huffman Coding',
      difficulty: 'Hard',
      difficultyColor: Colors.red,
      commonQuestions: [
        'Build Huffman encoding',
        'Minimum cost of ropes',
        'Rearrange characters in string',
      ],
      icon: Icons.compress_rounded,
      accentColor: Colors.red,
      page: const HuffmanInterviewPage(),
    ),
  ];

  List<_InterviewItem> get _filteredItems {
    if (_selectedDifficulty == 'All') return _items;
    return _items
        .where((i) => i.difficulty == _selectedDifficulty)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Interview Questions'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Crack the Interview 💼',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              'Top DSA questions asked in tech interviews',
              style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            ),
            const SizedBox(height: 20),

            // Difficulty filter chips
            SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _difficulties.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final diff = _difficulties[index];
                  final isSelected = _selectedDifficulty == diff;
                  return GestureDetector(
                    onTap: () =>
                        setState(() => _selectedDifficulty = diff),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.blue.shade700
                            : const Color(0xFF161B22),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? Colors.blue.shade700
                              : Colors.white12,
                        ),
                      ),
                      child: Text(
                        diff,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: isSelected
                              ? Colors.white
                              : Colors.grey.shade400,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: ListView.separated(
                itemCount: _filteredItems.length,
                separatorBuilder: (_, __) => const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  final item = _filteredItems[index];
                  return _InterviewCard(item: item);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  INTERVIEW CARD
// ─────────────────────────────────────────────

class _InterviewCard extends StatelessWidget {
  final _InterviewItem item;

  const _InterviewCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => item.page),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF161B22),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white10),
          boxShadow: [
            BoxShadow(
              color: item.accentColor.withOpacity(0.06),
              blurRadius: 12,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: item.accentColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(item.icon,
                      color: item.accentColor, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: item.difficultyColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    item.difficulty,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: item.difficultyColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            ...item.commonQuestions.map((q) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding:
                            const EdgeInsets.only(top: 6, right: 10),
                        child: Container(
                          width: 5,
                          height: 5,
                          decoration: BoxDecoration(
                            color: item.accentColor.withOpacity(0.7),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          q,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade300,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'View Questions',
                  style: TextStyle(
                    fontSize: 12,
                    color: item.accentColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 11,
                  color: item.accentColor,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}