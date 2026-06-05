import 'package:flutter/material.dart';
import 'package:visualdsa/features/binary_tree_visualizer/presentation/pages/binary_tree_dashboard_page.dart';
import 'package:visualdsa/features/graph_traversal/presentation/pages/trav_dashboard.dart';
import 'package:visualdsa/features/heap_visualizer/presentation/pages/heap_dashboard_page.dart';
import 'package:visualdsa/features/huffman/presentation/pages/huffman_dashboard.dart';
import 'package:visualdsa/features/huffman/presentation/widgets/huffman_complexity_card.dart';
import 'package:visualdsa/features/linked_list_visualizer/presentation/pages/linked_list_dashboard_page.dart';
import 'package:visualdsa/features/mst/presentation/pages/mst_dashboard.dart';
import 'package:visualdsa/features/shortest_path/presentation/pages/shortest_path_dashboard_page.dart';

import '../../models/category_model.dart';
import 'tag_chip.dart';
import '../../../array_visualizer/presentation/pages/array_dashboard_page.dart';
import '../../../sorting_visualizer/presentation/pages/sorting_dashboard_page.dart';
import '../../../searching_visualizer/presentation/pages/searching_dashboard_page.dart';
import '../../../graph_visualizer/presentation/pages/graph_dashboard_page.dart';
import '../../../bst_visualizer/presentation/pages/bst_dashboard_page.dart';
import '../../../stack_visualizer/presentation/pages/stack_dashboard_page.dart';
import '../../../queue_visualizer/presentation/pages/queue_dashboard_page.dart';
import '../../../shortest_path/presentation/pages/shortest_path_dashboard_page.dart';
class CategoryCard extends StatelessWidget {

  final CategoryModel category;

  const CategoryCard({

    super.key,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {

    return GestureDetector(

      onTap: () {
        Widget page;
        switch(category.title) {
          case 'Array':
          page = const ArrayDashboardPage();
          break;
          case 'Sorting':
          page = const SortingDashboardPage();
          break;
          case 'Searching':
          page = const SearchingDashboardPage();
          break;
          case 'Graph':
          page = const GraphDashboardPage();
          break;
          case 'Graph Traversal':
          page = const GraphTraversalDashboard();
          break;
          case 'Binary Tree' :
          page = const BinaryTreeDashboardPage();
          break;
          case 'Binary Search Tree' :
          page = const BSTDashboardPage();
          break;
          case 'Stack' :
          page = const StackDashboardPage();
          break;
          case 'Queue' :
          page = const QueueDashboardPage();
          break;
          case 'Linked List' :
          page = const LinkedListDashboardPage();
          break;
          case 'Heap' :
          page = const HeapDashboardPage();
          break;
          case 'Shortest Path' :
          page = const ShortestPathDashboard();
          break;
          case 'Minimum Spanning Tree' :
          page = const MstDashboard();
          break;
          case 'Huffman Coding':
          page = const HuffmanDashboard();
          break;
          default:
          page = const ArrayDashboardPage();
        }
        Navigator.push(
          context,
          MaterialPageRoute(
             builder: (_) => page,
          ),
        );
      },

      child: Container(

        height: 170,

        decoration: BoxDecoration(

          gradient: LinearGradient(

            colors: [

              const Color(0xFF161B22),

              Colors.black.withOpacity(0.9),
            ],

            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),

          borderRadius:
              BorderRadius.circular(24),

          border: Border.all(
            color: Colors.white10,
          ),

          boxShadow: [

            BoxShadow(

              color:
                  Colors.blue.withOpacity(0.08),

              blurRadius: 16,
              spreadRadius: 1,
            ),
          ],
        ),

        child: Row(

          children: [

            // LEFT PREVIEW
            Expanded(

              flex: 4,

              child: Padding(

                padding: const EdgeInsets.all(16),

                child: category.preview,
              ),
            ),

            // RIGHT INFO
            Expanded(

              flex: 5,

              child: Padding(

                padding:
                    const EdgeInsets.symmetric(
                  vertical: 18,
                  horizontal: 10,
                ),

                child: Column(

                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  mainAxisAlignment:
                      MainAxisAlignment.center,

                  children: [

                    Text(

                      category.title,

                      style: const TextStyle(

                        fontSize: 22,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 18),

                    Wrap(

                      spacing: 8,
                      runSpacing: 8,

                      children:

                          category.tags.map((tag) {

                        return TagChip(
                          text: tag,
                        );

                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}