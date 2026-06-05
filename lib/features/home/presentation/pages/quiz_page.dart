// quiz_page.dart
// Place at: features/home/presentation/pages/quiz_page.dart
import 'package:flutter/material.dart';
import 'quiz_data_part1.dart';
import 'quiz_data_part2.dart';
import 'quiz_screen.dart';

class _QuizTopic {
  final String algorithm;
  final List<String> subtopics;
  final IconData icon;
  final Color accentColor;

  const _QuizTopic({
    required this.algorithm,
    required this.subtopics,
    required this.icon,
    required this.accentColor,
  });
}

class QuizPage extends StatefulWidget {
  const QuizPage({super.key});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  static const List<_QuizTopic> _topics = [
    _QuizTopic(algorithm: 'Array', subtopics: ['Indexing', 'Traversal', 'Insertion', 'Deletion', 'Update', 'Search'], icon: Icons.grid_view_rounded, accentColor: Colors.blue),
    _QuizTopic(algorithm: 'Sorting', subtopics: ['Bubble Sort', 'Selection Sort', 'Insertion Sort', 'Merge Sort', 'Quick Sort', 'Heap Sort'], icon: Icons.sort_rounded, accentColor: Colors.purple),
    _QuizTopic(algorithm: 'Searching', subtopics: ['Linear Search', 'Binary Search', 'Jump Search', 'Interpolation Search'], icon: Icons.search_rounded, accentColor: Colors.green),
    _QuizTopic(algorithm: 'Graph', subtopics: ['Directed', 'Undirected', 'Weighted', 'Bipartite', 'DAG', 'Adjacency Matrix', 'Adjacency List'], icon: Icons.hub_rounded, accentColor: Colors.orange),
    _QuizTopic(algorithm: 'Graph Traversal', subtopics: ['BFS', 'DFS', 'Level Order', 'Topological Sort'], icon: Icons.account_tree_rounded, accentColor: Colors.teal),
    _QuizTopic(algorithm: 'Binary Tree', subtopics: ['In-order', 'Pre-order', 'Post-order', 'Level Order', 'Height', 'Insertion'], icon: Icons.device_hub_rounded, accentColor: Colors.cyan),
    _QuizTopic(algorithm: 'Binary Search Tree', subtopics: ['Insert', 'Delete', 'Search', 'Min/Max', 'Successor', 'Predecessor'], icon: Icons.schema_rounded, accentColor: Colors.indigo),
    _QuizTopic(algorithm: 'Linked List', subtopics: ['Singly Linked', 'Doubly Linked', 'Circular', 'Insert at Head', 'Insert at Tail', 'Delete Node', 'Reverse'], icon: Icons.linear_scale_rounded, accentColor: Colors.pink),
    _QuizTopic(algorithm: 'Stack', subtopics: ['Push', 'Pop', 'Peek', 'isEmpty', 'Stack Overflow', 'Applications'], icon: Icons.layers_rounded, accentColor: Colors.amber),
    _QuizTopic(algorithm: 'Queue', subtopics: ['Enqueue', 'Dequeue', 'Front', 'Rear', 'Circular Queue', 'Priority Queue', 'Deque'], icon: Icons.queue_rounded, accentColor: Colors.lightBlue),
    _QuizTopic(algorithm: 'Heap', subtopics: ['Min Heap', 'Max Heap', 'Heapify', 'Insert', 'Extract Min/Max', 'Priority Queue'], icon: Icons.filter_list_rounded, accentColor: Colors.deepOrange),
    _QuizTopic(algorithm: 'Shortest Path', subtopics: ["Dijkstra's", 'Bellman-Ford', 'Floyd-Warshall', 'A* Search'], icon: Icons.route_rounded, accentColor: Colors.lime),
    _QuizTopic(algorithm: 'Minimum Spanning Tree', subtopics: ["Prim's Algorithm", "Kruskal's Algorithm", 'Cut Property', 'Cycle Property'], icon: Icons.park_rounded, accentColor: Colors.greenAccent),
    _QuizTopic(algorithm: 'Huffman Coding', subtopics: ['Greedy Approach', 'Frequency Table', 'Huffman Tree', 'Encoding', 'Decoding', 'Compression Ratio'], icon: Icons.compress_rounded, accentColor: Colors.red),
  ];

  List<_QuizTopic> get _filteredTopics {
    if (_searchQuery.isEmpty) return _topics;
    return _topics.where((t) =>
        t.algorithm.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        t.subtopics.any((s) => s.toLowerCase().contains(_searchQuery.toLowerCase()))
    ).toList();
  }

  void _openSubtopicSheet(BuildContext context, _QuizTopic topic) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF161B22),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.5,
          minChildSize: 0.35,
          maxChildSize: 0.85,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: topic.accentColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: Icon(topic.icon, color: topic.accentColor, size: 22),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(topic.algorithm, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                            Text('${topic.subtopics.length} subtopics', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Choose a subtopic:', style: TextStyle(fontSize: 13, color: Colors.grey.shade400)),
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: topic.subtopics.length,
                    itemBuilder: (context, index) {
                      final subtopic = topic.subtopics[index];
                      final data = quizDataMap[topic.algorithm]?[subtopic];
                      final questionCount = data?.questions.length ?? 0;
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 2),
                        leading: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(color: topic.accentColor, shape: BoxShape.circle),
                        ),
                        title: Text(subtopic, style: const TextStyle(fontSize: 15, color: Colors.white)),
                        subtitle: questionCount > 0
                            ? Text('$questionCount questions', style: TextStyle(fontSize: 11, color: Colors.grey.shade600))
                            : null,
                        trailing: Icon(Icons.arrow_forward_ios_rounded, size: 13, color: Colors.grey.shade600),
                        onTap: () {
                          Navigator.pop(context);
                          if (data != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => QuizScreen(
                                  data: data,
                                  accentColor: topic.accentColor,
                                  icon: topic.icon,
                                ),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Quiz for "$subtopic" coming soon!'),
                                backgroundColor: const Color(0xFF161B22),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            );
                          }
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quiz'), automaticallyImplyLeading: false),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Test Yourself 🧠', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text('Pick a topic and challenge your knowledge', style: TextStyle(color: Colors.grey.shade400, fontSize: 14)),
            const SizedBox(height: 20),
            TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                hintText: 'Search topics...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: const Color(0xFF161B22),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.separated(
                itemCount: _filteredTopics.length,
                separatorBuilder: (_, __) => const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  final topic = _filteredTopics[index];
                  return _QuizTopicCard(topic: topic, onTap: () => _openSubtopicSheet(context, topic));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuizTopicCard extends StatelessWidget {
  final _QuizTopic topic;
  final VoidCallback onTap;

  const _QuizTopicCard({required this.topic, required this.onTap});

  int get _totalQuestions {
    int count = 0;
    for (final sub in topic.subtopics) {
      count += quizDataMap[topic.algorithm]?[sub]?.questions.length ?? 0;
    }
    return count;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF161B22),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white10),
          boxShadow: [BoxShadow(color: topic.accentColor.withOpacity(0.06), blurRadius: 12, spreadRadius: 1)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(color: topic.accentColor.withOpacity(0.15), borderRadius: BorderRadius.circular(11)),
                  child: Icon(topic.icon, color: topic.accentColor, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(topic.algorithm, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                      const SizedBox(height: 2),
                      Text('$_totalQuestions questions · ${topic.subtopics.length} subtopics', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: topic.accentColor.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                  child: Text('Start', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: topic.accentColor)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: topic.subtopics.map((s) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.06), borderRadius: BorderRadius.circular(6)),
                child: Text(s, style: const TextStyle(fontSize: 11, color: Colors.white60)),
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }
}