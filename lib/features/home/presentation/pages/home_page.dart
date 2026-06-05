import 'package:flutter/material.dart';

import '../../models/category_model.dart';
import '../widgets/category_card.dart';
import 'package:visualdsa/features/profile/presentation/pages/profile_page.dart';
import '../../../../core/widgets/animated_previews/array_preview.dart';
import '../../../../core/widgets/animated_previews/sorting_preview.dart';
import '../../../../core/widgets/animated_previews/searching_preview.dart';
import '../../../../core/widgets/animated_previews/graph_preview.dart';
import '../../../../core/widgets/animated_previews/binary_tree_preview.dart';
import '../../../../core/widgets/animated_previews/linkedlist_preview.dart';
import '../../../../core/widgets/animated_previews/stack_preview.dart';
import '../../../../core/widgets/animated_previews/queue_preview.dart';
import '../../../../core/widgets/animated_previews/heap_preview.dart';
import '../../../../core/widgets/animated_previews/bst_preview.dart';
import '../../../../core/widgets/animated_previews/graph_traversal_preview.dart';
import '../../../../core/widgets/animated_previews/shortest_path_preview.dart';
import '../../../../core/widgets/animated_previews/mst_preview.dart';
import '../../../../core/widgets/animated_previews/huffman_preview.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController searchController = TextEditingController();

  late List<CategoryModel> categories;
  List<CategoryModel> filteredCategories = [];

  void searchAlgorithms(String query) {
    final results = categories.where((category) {
      final title = category.title.toLowerCase();
      final input = query.toLowerCase();
      return title.contains(input);
    }).toList();
    setState(() {
      filteredCategories = results;
    });
  }

  @override
  void initState() {
    super.initState();

    categories = [
      CategoryModel(
        title: "Array",
        preview: const ArrayPreview(),
      ),
      CategoryModel(
        title: "Sorting",
        preview: const SortingPreview(),
      ),
      CategoryModel(
        title: "Searching",
        preview: const SearchingPreview(),
      ),
      CategoryModel(
        title: "Graph",
        preview: const GraphPreview(),
      ),
      CategoryModel(
        title: 'Graph Traversal',
        preview: const GraphTraversalPreview(),
      ),
      CategoryModel(
        title: "Binary Tree",
        preview: const BinaryTreePreview(),
      ),
      CategoryModel(
        title: "Binary Search Tree",
        preview: const BSTPreview(),
      ),
      CategoryModel(
        title: "Linked List",
        preview: const LinkedListPreview(),
      ),
      CategoryModel(
        title: "Stack",
        preview: const StackPreview(),
      ),
      CategoryModel(
        title: "Queue",
        preview: const QueuePreview(),
      ),
      CategoryModel(
        title: "Heap",
        preview: const HeapPreview(),
      ),
      CategoryModel(
        title: "Shortest Path",
        preview: const ShortestPathPreview(),
      ),
      CategoryModel(
        title: "Minimum Spanning Tree",
        preview: const MSTPreview(),
      ),
      CategoryModel(
        title: "Huffman Coding",
        preview: const HuffmanPreview(),
      ),
    ];
    filteredCategories = categories;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("VisualDSA"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Welcome Back 👋",
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Continue your DSA journey",
              style: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: searchController,
              onChanged: searchAlgorithms,
              decoration: InputDecoration(
                hintText: "Search algorithms...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: const Color(0xFF161B22),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.separated(
                itemCount: filteredCategories.length,
                separatorBuilder: (_, __) => const SizedBox(height: 18),
                itemBuilder: (context, index) {
                  return CategoryCard(category: filteredCategories[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}