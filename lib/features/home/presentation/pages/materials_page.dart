import 'package:flutter/material.dart';
import 'package:visualdsa/features/home/presentation/pages/all_material_pages.dart';

class _MaterialItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final Widget page;

  const _MaterialItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.page,
  });
}

class MaterialsPage extends StatelessWidget {
  const MaterialsPage({super.key});

  static final List<_MaterialItem> _items = [
    _MaterialItem(title: 'Array', subtitle: 'Indexing · Traversal · Static', icon: Icons.grid_view_rounded, accentColor: Colors.blue, page: const ArrayMaterialPage()),
    _MaterialItem(title: 'Sorting', subtitle: 'Bubble · Selection · Insertion', icon: Icons.sort_rounded, accentColor: Colors.purple, page: const SortingMaterialPage()),
    _MaterialItem(title: 'Searching', subtitle: 'Binary · Linear · Log N', icon: Icons.search_rounded, accentColor: Colors.green, page: const SearchingMaterialPage()),
    _MaterialItem(title: 'Graph', subtitle: 'Tree · Bipartite · DAG', icon: Icons.hub_rounded, accentColor: Colors.orange, page: const GraphMaterialPage()),
    _MaterialItem(title: 'Graph Traversal', subtitle: 'BFS · DFS · Traversal', icon: Icons.account_tree_rounded, accentColor: Colors.teal, page: const GraphTraversalMaterialPage()),
    _MaterialItem(title: 'Binary Tree', subtitle: 'In-order · Pre-order · Post-order', icon: Icons.device_hub_rounded, accentColor: Colors.cyan, page: const BinaryTreeMaterialPage()),
    _MaterialItem(title: 'Binary Search Tree', subtitle: 'BST · Search · Insert', icon: Icons.schema_rounded, accentColor: Colors.indigo, page: const BSTMaterialPage()),
    _MaterialItem(title: 'Linked List', subtitle: 'Singly · Doubly · Circular', icon: Icons.linear_scale_rounded, accentColor: Colors.pink, page: const LinkedListMaterialPage()),
    _MaterialItem(title: 'Stack', subtitle: 'LIFO · Push · Pop', icon: Icons.layers_rounded, accentColor: Colors.amber, page: const StackMaterialPage()),
    _MaterialItem(title: 'Queue', subtitle: 'FIFO · Enqueue · Dequeue', icon: Icons.queue_rounded, accentColor: Colors.lightBlue, page: const QueueMaterialPage()),
    _MaterialItem(title: 'Heap', subtitle: 'Min Heap · Max Heap · Priority', icon: Icons.filter_list_rounded, accentColor: Colors.deepOrange, page: const HeapMaterialPage()),
    _MaterialItem(title: 'Shortest Path', subtitle: 'Dijkstra · Bellman-Ford · Floyd', icon: Icons.route_rounded, accentColor: Colors.lime, page: const ShortestPathMaterialPage()),
    _MaterialItem(title: 'Minimum Spanning Tree', subtitle: 'Prim · Kruskal · MST', icon: Icons.park_rounded, accentColor: Colors.greenAccent, page: const MSTMaterialPage()),
    _MaterialItem(title: 'Huffman Coding', subtitle: 'Greedy · Encoding · Compression', icon: Icons.compress_rounded, accentColor: Colors.red, page: const HuffmanMaterialPage()),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Materials'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('All Topics 📚', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text('Explore and learn every data structure & algorithm', style: TextStyle(color: Colors.grey.shade400, fontSize: 14)),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.separated(
                itemCount: _items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) => _MaterialCard(item: _items[index]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MaterialCard extends StatelessWidget {
  final _MaterialItem item;
  const _MaterialCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => item.page)),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF161B22),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white10),
          boxShadow: [BoxShadow(color: item.accentColor.withOpacity(0.06), blurRadius: 12, spreadRadius: 1)],
        ),
        child: Row(
          children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(color: item.accentColor.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
              child: Icon(item.icon, color: item.accentColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                  const SizedBox(height: 4),
                  Text(item.subtitle, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey.shade600),
          ],
        ),
      ),
    );
  }
}