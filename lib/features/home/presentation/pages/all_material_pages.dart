import 'package:flutter/material.dart';
import 'material_page_template.dart';

// ══════════════════════════════════════════════
//  1. ARRAY
// ══════════════════════════════════════════════
class ArrayMaterialPage extends StatelessWidget {
  const ArrayMaterialPage({super.key});
  @override
  Widget build(BuildContext context) {
    return const DSAMaterialPage(
      data: MaterialPageData(
        title: 'Array',
        accentColor: Colors.blue,
        icon: Icons.grid_view_rounded,
        definition:
            'An Array is a linear data structure that stores elements of the same data type in contiguous memory locations. Each element can be accessed directly using its index, making it one of the most fundamental and widely-used data structures in programming.',
        howItWorks:
            'Memory is allocated as a fixed-size contiguous block when the array is created. Each element occupies an equal amount of space, and the address of any element is computed as: Base Address + (Index × Element Size). This allows O(1) random access. Insertion and deletion in the middle require shifting elements, making them O(n) operations.',
        operations: [
          OperationData(name: 'Access', definition: 'Retrieve an element at a given index directly via its memory address.', complexity: 'O(1)'),
          OperationData(name: 'Search', definition: 'Scan elements one by one to find a target value (linear search).', complexity: 'O(n)'),
          OperationData(name: 'Insert at End', definition: 'Place a new element at the last position if space is available.', complexity: 'O(1)'),
          OperationData(name: 'Insert at Index', definition: 'Shift all elements after the target index right by one to make room.', complexity: 'O(n)'),
          OperationData(name: 'Delete', definition: 'Remove an element and shift subsequent elements left to fill the gap.', complexity: 'O(n)'),
          OperationData(name: 'Update', definition: 'Overwrite the value at a given index directly.', complexity: 'O(1)'),
        ],
        realWorldApps: [
          'Image pixels stored as 2D arrays of RGB color values',
          'Spreadsheets use arrays for rows and columns of data',
          'Video game boards (chess, tic-tac-toe) represented as 2D arrays',
          'Contact lists in mobile phones stored as arrays',
          'Database table rows fetched into arrays for processing',
        ],
        keyTakeaways: [
          FlashCardData(front: 'Time complexity of accessing an array element?', back: 'O(1) — direct index access using base address + offset calculation.'),
          FlashCardData(front: 'Why is array insertion slow in the middle?', back: 'All elements after the insertion point must shift right by one position — O(n) time.'),
          FlashCardData(front: 'What is a 2D array?', back: 'An array of arrays forming a matrix. Access element at row r, col c as arr[r][c].'),
          FlashCardData(front: 'Static vs Dynamic Array?', back: 'Static: fixed size at compile time. Dynamic (ArrayList/Vector): auto-resizes by doubling capacity when full.'),
          FlashCardData(front: 'When should you use an array?', back: 'When you need fast random access, cache-friendly traversal, and know the size in advance.'),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════
//  2. SORTING
// ══════════════════════════════════════════════
class SortingMaterialPage extends StatelessWidget {
  const SortingMaterialPage({super.key});
  @override
  Widget build(BuildContext context) {
    return const DSAMaterialPage(
      data: MaterialPageData(
        title: 'Sorting',
        accentColor: Colors.purple,
        icon: Icons.sort_rounded,
        definition:
            'Sorting is the process of arranging elements in a specific order — typically ascending or descending. Sorting algorithms differ in their approach, time complexity, space usage, and stability. Choosing the right algorithm depends on data size, memory constraints, and whether the data is partially sorted.',
        howItWorks:
            'Comparison-based sorts (Bubble, Selection, Insertion, Merge, Quick) compare pairs of elements to determine order. Non-comparison sorts (Counting, Radix) use element properties to sort without direct comparison. Stable sorts preserve the relative order of equal elements. In-place sorts use O(1) extra memory; Merge Sort needs O(n) auxiliary space.',
        operations: [
          OperationData(name: 'Bubble Sort', definition: 'Repeatedly swaps adjacent elements that are out of order. Simple but slow.', complexity: 'O(n²)'),
          OperationData(name: 'Selection Sort', definition: 'Finds the minimum element and places it at the start in each pass.', complexity: 'O(n²)'),
          OperationData(name: 'Insertion Sort', definition: 'Builds a sorted portion by inserting each element into its correct position.', complexity: 'O(n²)'),
          OperationData(name: 'Merge Sort', definition: 'Divides array in half recursively, then merges sorted halves. Stable.', complexity: 'O(n log n)'),
          OperationData(name: 'Quick Sort', definition: 'Picks a pivot, partitions elements around it, recursively sorts partitions.', complexity: 'O(n log n)'),
          OperationData(name: 'Heap Sort', definition: 'Builds a max-heap and repeatedly extracts the maximum element.', complexity: 'O(n log n)'),
        ],
        realWorldApps: [
          'Search engines sort results by relevance score',
          'E-commerce sites sort products by price, rating, or date',
          'Operating systems sort processes by priority in schedulers',
          'Database ORDER BY clauses use efficient sorting internally',
          'Leaderboards in games are maintained using sorted structures',
        ],
        keyTakeaways: [
          FlashCardData(front: 'Best algorithm for nearly sorted data?', back: 'Insertion Sort — runs in O(n) when the array is almost sorted.'),
          FlashCardData(front: 'What makes Merge Sort stable?', back: 'Equal left elements always come before right ones during merge — relative order is preserved.'),
          FlashCardData(front: 'Worst case of Quick Sort?', back: 'O(n²) when the pivot is always the smallest or largest element (e.g. sorted array with first-element pivot).'),
          FlashCardData(front: 'What is an in-place sorting algorithm?', back: 'One that sorts using O(1) extra memory. Examples: Bubble, Selection, Insertion, Quick, Heap Sort.'),
          FlashCardData(front: 'Why is Merge Sort preferred for linked lists?', back: 'It does not need random access and splits naturally, unlike Quick Sort which benefits from arrays.'),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════
//  3. SEARCHING
// ══════════════════════════════════════════════
class SearchingMaterialPage extends StatelessWidget {
  const SearchingMaterialPage({super.key});
  @override
  Widget build(BuildContext context) {
    return const DSAMaterialPage(
      data: MaterialPageData(
        title: 'Searching',
        accentColor: Colors.green,
        icon: Icons.search_rounded,
        definition:
            'Searching refers to finding a specific element or value within a data structure. The efficiency of a search algorithm depends heavily on whether the data is sorted and the structure being searched. The two most fundamental search algorithms are Linear Search and Binary Search.',
        howItWorks:
            'Linear Search scans every element from start to end — works on unsorted data. Binary Search works only on sorted arrays by repeatedly halving the search space: compare the middle element, discard the half that cannot contain the target, and repeat. Each step eliminates half the remaining elements, giving O(log n) performance.',
        operations: [
          OperationData(name: 'Linear Search', definition: 'Scan every element from left to right until the target is found.', complexity: 'O(n)'),
          OperationData(name: 'Binary Search', definition: 'On a sorted array, compare the middle element and halve the search space each step.', complexity: 'O(log n)'),
          OperationData(name: 'Jump Search', definition: 'Jump ahead by √n steps to find a range, then linear search within that block.', complexity: 'O(√n)'),
          OperationData(name: 'Interpolation Search', definition: 'Estimates position of target using value distribution — like a dictionary lookup.', complexity: 'O(log log n)'),
          OperationData(name: 'Exponential Search', definition: 'Find a range by doubling bounds, then apply binary search within that range.', complexity: 'O(log n)'),
        ],
        realWorldApps: [
          'Search boxes in apps use indexed search algorithms',
          'Dictionary and phonebook apps use binary-search-like lookups',
          'Git bisect uses binary search to find the commit that introduced a bug',
          'Database indexes (B-trees) use divide-and-conquer search',
          'Spell checkers search sorted word lists using binary search',
        ],
        keyTakeaways: [
          FlashCardData(front: 'Prerequisite for Binary Search?', back: 'The array must be sorted. Binary Search cannot work on unsorted data.'),
          FlashCardData(front: 'Steps to search 1 million elements with Binary Search?', back: 'About 20 steps — log₂(1,000,000) ≈ 20. That is the power of O(log n).'),
          FlashCardData(front: 'When is Linear Search better than Binary Search?', back: 'For very small arrays or unsorted data where sorting cost outweighs search savings.'),
          FlashCardData(front: 'Safe mid formula to avoid integer overflow?', back: 'mid = low + (high - low) / 2 instead of (low + high) / 2.'),
          FlashCardData(front: 'What does Interpolation Search assume?', back: 'That the data is uniformly distributed — it estimates position like finding a word in a dictionary.'),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════
//  4. GRAPH
// ══════════════════════════════════════════════
class GraphMaterialPage extends StatelessWidget {
  const GraphMaterialPage({super.key});
  @override
  Widget build(BuildContext context) {
    return const DSAMaterialPage(
      data: MaterialPageData(
        title: 'Graph',
        accentColor: Colors.orange,
        icon: Icons.hub_rounded,
        definition:
            'A Graph is a non-linear data structure consisting of vertices (nodes) and edges (connections between nodes). Graphs model relationships between entities and are one of the most versatile structures in computer science — used in social networks, maps, compilers, and more.',
        howItWorks:
            'A graph G = (V, E) where V is a set of vertices and E is a set of edges. Graphs can be directed (edges have direction) or undirected. They can be weighted (edges have costs) or unweighted. Represented using Adjacency Matrix (O(V²) space) or Adjacency List (O(V+E) space). Traversal is done via BFS or DFS.',
        operations: [
          OperationData(name: 'Add Vertex', definition: 'Add a new node to the graph.', complexity: 'O(1)'),
          OperationData(name: 'Add Edge', definition: 'Connect two vertices with an edge (directed or undirected).', complexity: 'O(1)'),
          OperationData(name: 'Remove Edge', definition: 'Delete the connection between two vertices.', complexity: 'O(E)'),
          OperationData(name: 'BFS Traversal', definition: 'Explore all neighbors level by level using a queue.', complexity: 'O(V+E)'),
          OperationData(name: 'DFS Traversal', definition: 'Explore as deep as possible before backtracking using a stack/recursion.', complexity: 'O(V+E)'),
          OperationData(name: 'Cycle Detection', definition: 'Determine if the graph contains any cycle using DFS or Union-Find.', complexity: 'O(V+E)'),
        ],
        realWorldApps: [
          'Google Maps uses weighted directed graphs for routing',
          'Social networks model friendships as undirected graphs',
          'Web crawlers use graph traversal to index pages via hyperlinks',
          'Airline route planning and network topology use graph algorithms',
          'Dependency resolution in package managers (npm, pip) uses DAGs',
        ],
        keyTakeaways: [
          FlashCardData(front: 'Adjacency Matrix vs Adjacency List?', back: 'Matrix: O(V²) space, O(1) edge lookup. List: O(V+E) space, better for sparse graphs.'),
          FlashCardData(front: 'What is a DAG?', back: 'Directed Acyclic Graph — a directed graph with no cycles. Used in task scheduling, build systems.'),
          FlashCardData(front: 'What is a bipartite graph?', back: 'Vertices split into two groups where edges only go between groups — never within a group.'),
          FlashCardData(front: 'How to detect a cycle in a directed graph?', back: 'DFS with a recursion stack — if you visit a node already in the current DFS path, a cycle exists.'),
          FlashCardData(front: 'What is graph density?', back: 'Sparse: few edges (E ≈ V). Dense: many edges (E ≈ V²). Affects choice of representation and algorithm.'),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════
//  5. GRAPH TRAVERSAL
// ══════════════════════════════════════════════
class GraphTraversalMaterialPage extends StatelessWidget {
  const GraphTraversalMaterialPage({super.key});
  @override
  Widget build(BuildContext context) {
    return const DSAMaterialPage(
      data: MaterialPageData(
        title: 'Graph Traversal',
        accentColor: Colors.teal,
        icon: Icons.account_tree_rounded,
        definition:
            'Graph Traversal refers to visiting all vertices of a graph in a systematic way. The two fundamental traversal strategies are Breadth-First Search (BFS) and Depth-First Search (DFS), each with distinct behavior, data structures, and use cases.',
        howItWorks:
            'BFS uses a Queue — it visits all neighbors of a node before moving to the next level. This guarantees shortest path in unweighted graphs. DFS uses a Stack (or recursion) — it goes as deep as possible along one path before backtracking. DFS naturally explores entire connected components and detects cycles.',
        operations: [
          OperationData(name: 'BFS', definition: 'Level-by-level traversal using a queue. Finds shortest path in unweighted graphs.', complexity: 'O(V+E)'),
          OperationData(name: 'DFS', definition: 'Deep-path traversal using stack/recursion. Used for cycle detection, topological sort.', complexity: 'O(V+E)'),
          OperationData(name: 'Topological Sort', definition: 'Linear ordering of vertices so every directed edge u→v has u before v.', complexity: 'O(V+E)'),
          OperationData(name: 'Connected Components', definition: 'Find all isolated subgraphs in an undirected graph using DFS/BFS.', complexity: 'O(V+E)'),
          OperationData(name: 'Flood Fill', definition: 'BFS/DFS from a source to mark all reachable connected cells.', complexity: 'O(V+E)'),
        ],
        realWorldApps: [
          'BFS used in peer-to-peer networks to find nearest peers',
          'DFS used in maze solving and puzzle games with backtracking',
          'Web crawlers traverse the web graph using BFS',
          'Topological sort used in build systems and course prerequisites',
          'Flood fill used in MS Paint bucket fill tool',
        ],
        keyTakeaways: [
          FlashCardData(front: 'BFS vs DFS — when to use which?', back: 'BFS: shortest path, level-order, nearby nodes. DFS: cycle detection, topological sort, exploring all paths.'),
          FlashCardData(front: 'What data structure does BFS use?', back: 'A Queue (FIFO) — ensures nodes are processed in order of discovery.'),
          FlashCardData(front: 'What data structure does DFS use?', back: 'A Stack (LIFO) — either explicit or the call stack via recursion.'),
          FlashCardData(front: 'Can topological sort work on a cyclic graph?', back: 'No — topological sort only works on Directed Acyclic Graphs (DAGs).'),
          FlashCardData(front: 'How does BFS guarantee shortest path?', back: 'It explores nodes layer by layer, so the first time a node is reached is always via the shortest route.'),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════
//  6. BINARY TREE
// ══════════════════════════════════════════════
class BinaryTreeMaterialPage extends StatelessWidget {
  const BinaryTreeMaterialPage({super.key});
  @override
  Widget build(BuildContext context) {
    return const DSAMaterialPage(
      data: MaterialPageData(
        title: 'Binary Tree',
        accentColor: Colors.cyan,
        icon: Icons.device_hub_rounded,
        definition:
            'A Binary Tree is a hierarchical data structure where each node has at most two children — referred to as the left child and the right child. It is the foundation for more specialized trees like BST, Heap, and AVL Tree. Trees are inherently recursive structures.',
        howItWorks:
            'Each node contains data and two pointers: left and right. The topmost node is the root. Nodes with no children are leaves. The height of a tree is the longest path from root to a leaf. Trees are traversed recursively — in-order visits left, root, right; pre-order visits root, left, right; post-order visits left, right, root.',
        operations: [
          OperationData(name: 'In-order Traversal', definition: 'Visit Left → Root → Right. Gives sorted output for BST.', complexity: 'O(n)'),
          OperationData(name: 'Pre-order Traversal', definition: 'Visit Root → Left → Right. Used to copy or serialize a tree.', complexity: 'O(n)'),
          OperationData(name: 'Post-order Traversal', definition: 'Visit Left → Right → Root. Used to delete a tree or evaluate expressions.', complexity: 'O(n)'),
          OperationData(name: 'Level-order (BFS)', definition: 'Visit nodes level by level using a queue.', complexity: 'O(n)'),
          OperationData(name: 'Height Calculation', definition: 'Recursively find max depth of left and right subtrees, add 1.', complexity: 'O(n)'),
          OperationData(name: 'Insert', definition: 'Add a node at the first available position using level-order for complete trees.', complexity: 'O(n)'),
        ],
        realWorldApps: [
          'File system directory structures are tree-shaped hierarchies',
          'HTML/XML DOM is a tree of elements that browsers traverse',
          'Expression trees used in compilers to evaluate arithmetic',
          'Decision trees used in machine learning for classification',
          'Huffman coding uses a binary tree to assign variable-length codes',
        ],
        keyTakeaways: [
          FlashCardData(front: 'Which traversal gives sorted output for a BST?', back: 'In-order traversal (Left → Root → Right) gives elements in ascending sorted order.'),
          FlashCardData(front: 'What is a full binary tree?', back: 'Every node has exactly 0 or 2 children — no node has exactly one child.'),
          FlashCardData(front: 'What is a complete binary tree?', back: 'All levels are fully filled except the last, which is filled from left to right.'),
          FlashCardData(front: 'Maximum nodes in a tree of height h?', back: '2^(h+1) - 1 nodes for a perfect binary tree of height h.'),
          FlashCardData(front: 'Pre-order vs Post-order use cases?', back: 'Pre-order: copying/serializing a tree. Post-order: deleting a tree or evaluating expression trees.'),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════
//  7. BST
// ══════════════════════════════════════════════
class BSTMaterialPage extends StatelessWidget {
  const BSTMaterialPage({super.key});
  @override
  Widget build(BuildContext context) {
    return const DSAMaterialPage(
      data: MaterialPageData(
        title: 'Binary Search Tree',
        accentColor: Colors.indigo,
        icon: Icons.schema_rounded,
        definition:
            'A Binary Search Tree (BST) is a binary tree where for every node, all values in the left subtree are smaller, and all values in the right subtree are larger. This property enables efficient searching, insertion, and deletion in O(log n) average time.',
        howItWorks:
            'The BST property is maintained at every node. To search: if target < node go left, if target > node go right, if equal found. Insertion follows the same logic to find the correct leaf position. Deletion has three cases: no child (simply remove), one child (replace with child), two children (replace with in-order successor).',
        operations: [
          OperationData(name: 'Search', definition: 'Navigate left or right based on comparison until target is found or null.', complexity: 'O(log n)'),
          OperationData(name: 'Insert', definition: 'Find the correct leaf position maintaining BST property and insert node.', complexity: 'O(log n)'),
          OperationData(name: 'Delete', definition: 'Remove node handling 3 cases: no child, one child, two children (use in-order successor).', complexity: 'O(log n)'),
          OperationData(name: 'Find Min/Max', definition: 'Minimum is the leftmost node; maximum is the rightmost node.', complexity: 'O(log n)'),
          OperationData(name: 'In-order Traversal', definition: 'Produces all elements in sorted ascending order.', complexity: 'O(n)'),
          OperationData(name: 'Validate BST', definition: 'Check all nodes satisfy BST property using min/max bounds recursively.', complexity: 'O(n)'),
        ],
        realWorldApps: [
          'Symbol tables in compilers use BST-like structures',
          'Database indexing uses balanced BSTs (AVL, Red-Black trees)',
          'Autocomplete and spell checking use BST-based tries',
          'Priority queues can be implemented using BSTs',
          'File system indexing for fast file lookup',
        ],
        keyTakeaways: [
          FlashCardData(front: 'Worst case for BST operations?', back: 'O(n) — when the tree becomes a skewed line from sorted insertions. Use self-balancing AVL or Red-Black trees to avoid this.'),
          FlashCardData(front: 'How to delete a node with two children?', back: 'Replace it with its in-order successor (smallest node in right subtree), then delete the successor.'),
          FlashCardData(front: 'In-order traversal of BST gives?', back: 'Elements in ascending sorted order — this is the defining property of BST.'),
          FlashCardData(front: 'How to find the kth smallest element?', back: 'Do in-order traversal and count nodes; return the node when count equals k.'),
          FlashCardData(front: 'BST vs Hash Table?', back: 'BST: ordered, O(log n) ops, supports range queries. Hash Table: unordered, O(1) average, no range queries.'),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════
//  8. LINKED LIST
// ══════════════════════════════════════════════
class LinkedListMaterialPage extends StatelessWidget {
  const LinkedListMaterialPage({super.key});
  @override
  Widget build(BuildContext context) {
    return const DSAMaterialPage(
      data: MaterialPageData(
        title: 'Linked List',
        accentColor: Colors.pink,
        icon: Icons.linear_scale_rounded,
        definition:
            'A Linked List is a linear data structure where elements (nodes) are stored in non-contiguous memory locations. Each node contains data and a pointer to the next node. Unlike arrays, linked lists allow efficient insertion and deletion without shifting elements.',
        howItWorks:
            'Nodes are dynamically allocated. A head pointer marks the start. To traverse, follow next pointers from head to null. Singly linked: one pointer (next). Doubly linked: two pointers (next and prev). Circular: last node points back to head. Insertion/deletion at head is O(1); at arbitrary position requires O(n) traversal.',
        operations: [
          OperationData(name: 'Insert at Head', definition: 'Create new node, set its next to current head, update head to new node.', complexity: 'O(1)'),
          OperationData(name: 'Insert at Tail', definition: 'Traverse to last node, set its next to the new node.', complexity: 'O(n)'),
          OperationData(name: 'Delete at Head', definition: 'Move head pointer to the second node.', complexity: 'O(1)'),
          OperationData(name: 'Delete by Value', definition: 'Traverse to find the node, update previous node next to skip it.', complexity: 'O(n)'),
          OperationData(name: 'Search', definition: 'Traverse from head, comparing each node data to the target.', complexity: 'O(n)'),
          OperationData(name: 'Reverse', definition: 'Iteratively flip next pointers while traversing — three-pointer technique.', complexity: 'O(n)'),
        ],
        realWorldApps: [
          'Browser history (back/forward) uses a doubly linked list',
          'Music playlists — next/previous song navigation',
          'Undo/redo in text editors uses linked list nodes',
          'OS memory allocation uses free-list linked lists',
          'Hash table chaining for collision resolution',
        ],
        keyTakeaways: [
          FlashCardData(front: 'Array vs Linked List — key difference?', back: 'Array: contiguous memory, O(1) access. Linked List: non-contiguous, O(n) access but O(1) head insert/delete.'),
          FlashCardData(front: 'How to detect a cycle in a linked list?', back: 'Floyd cycle detection: slow pointer moves 1 step, fast moves 2 steps — if they meet, a cycle exists.'),
          FlashCardData(front: 'How to reverse a singly linked list?', back: 'Three pointers: prev=null, curr=head. At each step: save next, flip curr.next to prev, advance both.'),
          FlashCardData(front: 'Advantage of doubly over singly linked list?', back: 'Bidirectional traversal and O(1) deletion when you have a pointer to the node.'),
          FlashCardData(front: 'How to find the middle of a linked list?', back: 'Slow/fast pointer: slow moves 1 step, fast moves 2 steps. When fast reaches end, slow is at middle.'),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════
//  9. STACK
// ══════════════════════════════════════════════
class StackMaterialPage extends StatelessWidget {
  const StackMaterialPage({super.key});
  @override
  Widget build(BuildContext context) {
    return const DSAMaterialPage(
      data: MaterialPageData(
        title: 'Stack',
        accentColor: Colors.amber,
        icon: Icons.layers_rounded,
        definition:
            'A Stack is a linear data structure that follows the Last-In First-Out (LIFO) principle — the last element added is the first one removed. Think of it like a stack of plates: you add and remove from the top only. Stacks are fundamental to recursion, parsing, and backtracking.',
        howItWorks:
            'All operations happen at one end called the "top". Push adds to the top; Pop removes from the top; Peek looks at the top without removing. Implemented using arrays (with a top index) or linked lists (head as top). Stack overflow occurs when pushing beyond capacity; underflow when popping from an empty stack.',
        operations: [
          OperationData(name: 'Push', definition: 'Add a new element to the top of the stack.', complexity: 'O(1)'),
          OperationData(name: 'Pop', definition: 'Remove and return the top element from the stack.', complexity: 'O(1)'),
          OperationData(name: 'Peek / Top', definition: 'View the top element without removing it.', complexity: 'O(1)'),
          OperationData(name: 'isEmpty', definition: 'Check whether the stack has no elements.', complexity: 'O(1)'),
          OperationData(name: 'isFull', definition: 'Check if the stack has reached maximum capacity (fixed-size stacks).', complexity: 'O(1)'),
          OperationData(name: 'Size', definition: 'Return the number of elements currently in the stack.', complexity: 'O(1)'),
        ],
        realWorldApps: [
          'Function call stack — each call is pushed, return pops it',
          'Browser back button — visited pages pushed onto a history stack',
          'Undo functionality in editors — actions pushed, undo pops them',
          'Expression evaluation and syntax parsing in compilers',
          'DFS uses a stack (either explicit or the call stack)',
        ],
        keyTakeaways: [
          FlashCardData(front: 'What does LIFO mean?', back: 'Last-In First-Out — the most recently added element is the first to be removed.'),
          FlashCardData(front: 'How is recursion related to stacks?', back: 'Each recursive call is pushed onto the call stack. When the base case is hit, calls are popped in reverse order.'),
          FlashCardData(front: 'How to check balanced parentheses using a stack?', back: 'Push every opening bracket. On closing bracket, check if stack top is the matching opener. Valid if stack is empty at end.'),
          FlashCardData(front: 'Implement a queue using two stacks?', back: 'Stack1 for enqueue (push). Stack2 for dequeue. When Stack2 is empty, pour all of Stack1 into Stack2, then pop.'),
          FlashCardData(front: 'What is the Next Greater Element problem?', back: 'Use a monotonic decreasing stack. For each element, pop while top is smaller — those elements NGE is the current element.'),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════
//  10. QUEUE
// ══════════════════════════════════════════════
class QueueMaterialPage extends StatelessWidget {
  const QueueMaterialPage({super.key});
  @override
  Widget build(BuildContext context) {
    return const DSAMaterialPage(
      data: MaterialPageData(
        title: 'Queue',
        accentColor: Colors.lightBlue,
        icon: Icons.queue_rounded,
        definition:
            'A Queue is a linear data structure that follows the First-In First-Out (FIFO) principle — elements are added at the rear and removed from the front. Think of a ticket queue: first person in line gets served first. Queues are essential for scheduling, buffering, and BFS.',
        howItWorks:
            'Two pointers — front and rear — track where to dequeue and enqueue respectively. A Circular Queue connects the end back to the beginning to reuse freed space. A Priority Queue dequeues based on priority rather than arrival order. A Deque allows insert/delete at both ends.',
        operations: [
          OperationData(name: 'Enqueue', definition: 'Add a new element to the rear of the queue.', complexity: 'O(1)'),
          OperationData(name: 'Dequeue', definition: 'Remove and return the element from the front of the queue.', complexity: 'O(1)'),
          OperationData(name: 'Front / Peek', definition: 'View the front element without removing it.', complexity: 'O(1)'),
          OperationData(name: 'Rear', definition: 'View the last element that was enqueued.', complexity: 'O(1)'),
          OperationData(name: 'isEmpty', definition: 'Check if the queue has no elements.', complexity: 'O(1)'),
          OperationData(name: 'Size', definition: 'Return the number of elements currently in the queue.', complexity: 'O(1)'),
        ],
        realWorldApps: [
          'CPU process scheduling — processes wait in a queue for CPU time',
          'Printer spooling — print jobs processed in order',
          'Keyboard input buffer — keystrokes queued before processing',
          'BFS traversal uses a queue to explore nodes level by level',
          'Network packet routing — packets queued at routers',
        ],
        keyTakeaways: [
          FlashCardData(front: 'What does FIFO mean?', back: 'First-In First-Out — the element added earliest is the first one removed.'),
          FlashCardData(front: 'Problem with simple array-based queue?', back: 'Front advances but rear cannot wrap around — wasted space. Circular Queue solves this with modulo arithmetic.'),
          FlashCardData(front: 'What is a Priority Queue?', back: 'Elements are dequeued by priority not arrival order. Implemented using a Heap for O(log n) operations.'),
          FlashCardData(front: 'How to implement a stack using two queues?', back: 'On push: enqueue to Q1, then move all Q2 elements into Q1. Pop: dequeue from Q1.'),
          FlashCardData(front: 'What is a Deque?', back: 'Double-Ended Queue — supports insert and delete at both front and rear. Used in sliding window maximum problems.'),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════
//  11. HEAP
// ══════════════════════════════════════════════
class HeapMaterialPage extends StatelessWidget {
  const HeapMaterialPage({super.key});
  @override
  Widget build(BuildContext context) {
    return const DSAMaterialPage(
      data: MaterialPageData(
        title: 'Heap',
        accentColor: Colors.deepOrange,
        icon: Icons.filter_list_rounded,
        definition:
            'A Heap is a complete binary tree satisfying the heap property. In a Max-Heap, every parent node is greater than or equal to its children. In a Min-Heap, every parent is less than or equal to its children. Heaps are the most efficient implementation of a Priority Queue.',
        howItWorks:
            'Stored as an array — for node at index i, left child is at 2i+1, right child at 2i+2, parent at (i-1)/2. Insertion adds at the end and sifts up. Extraction removes the root, places the last element at root, and sifts down. Building a heap from an array takes O(n) using bottom-up heapify.',
        operations: [
          OperationData(name: 'Insert', definition: 'Add element at end, then sift up to restore heap property.', complexity: 'O(log n)'),
          OperationData(name: 'Extract Min/Max', definition: 'Remove root, place last element at root, sift down.', complexity: 'O(log n)'),
          OperationData(name: 'Peek Min/Max', definition: 'Return root element (min or max) without removal.', complexity: 'O(1)'),
          OperationData(name: 'Heapify', definition: 'Convert an arbitrary array into a valid heap using bottom-up sift-down.', complexity: 'O(n)'),
          OperationData(name: 'Heap Sort', definition: 'Build max-heap, then repeatedly extract max to sort in-place.', complexity: 'O(n log n)'),
          OperationData(name: 'Decrease Key', definition: 'Reduce a key value and sift up. Used in Dijkstra algorithm.', complexity: 'O(log n)'),
        ],
        realWorldApps: [
          'Priority queues in OS schedulers (highest priority runs first)',
          'Dijkstra shortest path algorithm uses a min-heap',
          'Heap Sort for efficient in-place sorting',
          'Median maintenance in streaming data using two heaps',
          'Top K problems — find K largest/smallest elements efficiently',
        ],
        keyTakeaways: [
          FlashCardData(front: 'Min-Heap vs Max-Heap?', back: 'Min-Heap: root is the smallest. Max-Heap: root is the largest. Choose based on whether you need frequent min or max access.'),
          FlashCardData(front: 'Why store heap as array instead of tree nodes?', back: 'Index arithmetic (2i+1, 2i+2) gives O(1) child/parent access with better cache performance and no pointer overhead.'),
          FlashCardData(front: 'How to find median of a data stream?', back: 'Two heaps: max-heap for lower half, min-heap for upper half. Median is root of max-heap or average of both roots.'),
          FlashCardData(front: 'Why is building a heap O(n) not O(n log n)?', back: 'Bottom-up heapify: most nodes near leaves do little work. Total work sums to O(n) mathematically.'),
          FlashCardData(front: 'How to find Kth largest element efficiently?', back: 'Min-heap of size K. For each element: if larger than root, replace root and heapify. Root is the Kth largest.'),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════
//  12. SHORTEST PATH
// ══════════════════════════════════════════════
class ShortestPathMaterialPage extends StatelessWidget {
  const ShortestPathMaterialPage({super.key});
  @override
  Widget build(BuildContext context) {
    return const DSAMaterialPage(
      data: MaterialPageData(
        title: 'Shortest Path',
        accentColor: Colors.lime,
        icon: Icons.route_rounded,
        definition:
            'Shortest Path algorithms find the minimum cost route between vertices in a weighted graph. Different algorithms handle different scenarios: non-negative weights (Dijkstra), negative weights (Bellman-Ford), all-pairs (Floyd-Warshall). These are among the most practically important graph algorithms.',
        howItWorks:
            'Dijkstra uses a greedy min-heap: always expand the closest unvisited node and relax neighbors. Bellman-Ford relaxes all edges V-1 times — slower but handles negative weights and detects negative cycles. Floyd-Warshall uses dynamic programming with a 2D distance matrix updated for each intermediate vertex.',
        operations: [
          OperationData(name: "Dijkstra's", definition: 'Greedy min-heap. Single-source, non-negative weights only.', complexity: 'O((V+E) log V)'),
          OperationData(name: 'Bellman-Ford', definition: 'Relax all edges V-1 times. Handles negative weights, detects negative cycles.', complexity: 'O(V·E)'),
          OperationData(name: 'Floyd-Warshall', definition: 'Dynamic programming for all-pairs shortest paths.', complexity: 'O(V³)'),
          OperationData(name: 'BFS (unweighted)', definition: 'Finds shortest path by hop count in unweighted graphs.', complexity: 'O(V+E)'),
          OperationData(name: 'A* Search', definition: 'Dijkstra with a heuristic to guide search toward the target.', complexity: 'O(E log V)'),
        ],
        realWorldApps: [
          'Google Maps uses Dijkstra/A* for fastest driving routes',
          'Network routing protocols (OSPF) use shortest path algorithms',
          'GPS navigation systems compute optimal paths in real-time',
          'Game AI pathfinding — A* for NPC movement',
          'Currency arbitrage detection uses Bellman-Ford for negative cycles',
        ],
        keyTakeaways: [
          FlashCardData(front: 'Why cannot Dijkstra handle negative weights?', back: 'Once a node is finalized, Dijkstra never revisits it. A negative edge could create a shorter path to an already-finalized node.'),
          FlashCardData(front: 'How does Bellman-Ford detect negative cycles?', back: 'After V-1 relaxations, do one more pass. If any distance still decreases, a negative cycle exists.'),
          FlashCardData(front: 'When to use Floyd-Warshall?', back: 'When you need shortest paths between ALL pairs of vertices and V is small. Otherwise Dijkstra from each source is better.'),
          FlashCardData(front: 'What makes A* faster than Dijkstra?', back: 'A* uses a heuristic (estimated distance to goal) to prioritize promising paths — explores fewer nodes in practice.'),
          FlashCardData(front: 'What is edge relaxation?', back: 'For edge u to v with weight w: if dist[u] + w < dist[v], update dist[v]. Core operation in all shortest path algorithms.'),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════
//  13. MST
// ══════════════════════════════════════════════
class MSTMaterialPage extends StatelessWidget {
  const MSTMaterialPage({super.key});
  @override
  Widget build(BuildContext context) {
    return const DSAMaterialPage(
      data: MaterialPageData(
        title: 'Minimum Spanning Tree',
        accentColor: Colors.greenAccent,
        icon: Icons.park_rounded,
        definition:
            'A Minimum Spanning Tree (MST) is a subset of edges in a connected, undirected, weighted graph that connects all vertices with the minimum possible total edge weight, without forming any cycle. An MST always has exactly V-1 edges for V vertices.',
        howItWorks:
            "Prim's grows the MST greedily from a starting vertex — always picking the minimum weight edge connecting a visited vertex to an unvisited one (uses a min-heap). Kruskal's sorts all edges by weight and adds them one by one, skipping edges that would form a cycle (uses Union-Find). Both always produce an MST.",
        operations: [
          OperationData(name: "Prim's Algorithm", definition: 'Grow MST from a source by always adding the cheapest edge crossing the cut.', complexity: 'O(E log V)'),
          OperationData(name: "Kruskal's Algorithm", definition: 'Sort edges by weight, add edge if it does not form a cycle (Union-Find).', complexity: 'O(E log E)'),
          OperationData(name: 'Union-Find', definition: 'Efficiently check and merge connected components for Kruskal.', complexity: 'O(α(n))'),
          OperationData(name: 'Cut Property', definition: 'Minimum weight edge crossing any cut of the graph is always in some MST.', complexity: 'O(1)'),
          OperationData(name: 'Cycle Detection', definition: 'Used in Kruskal — skip edge if both endpoints are in the same component.', complexity: 'O(α(n))'),
        ],
        realWorldApps: [
          'Network design — laying minimum cable to connect all offices',
          'Road construction — build roads connecting all cities at minimum cost',
          'Water and electricity supply network optimization',
          'Cluster analysis in machine learning (single-linkage clustering)',
          'Approximation for the Traveling Salesman Problem',
        ],
        keyTakeaways: [
          FlashCardData(front: "Prim's vs Kruskal's — when to use which?", back: "Prim's: better for dense graphs. Kruskal's: better for sparse graphs. Both give the same MST."),
          FlashCardData(front: 'How many edges does an MST have?', back: 'Exactly V-1 edges for a graph with V vertices — just enough to connect all without any cycle.'),
          FlashCardData(front: 'What is Union-Find used for in Kruskal?', back: 'To check if two vertices are already connected — if yes, adding the edge creates a cycle, so skip it.'),
          FlashCardData(front: 'Can a graph have multiple MSTs?', back: 'Yes — if multiple edges have the same weight, different MSTs may exist, all with the same minimum total weight.'),
          FlashCardData(front: 'What is the Cut Property?', back: 'For any cut (partition into two sets), the minimum weight edge crossing the cut must belong to some MST.'),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════
//  14. HUFFMAN
// ══════════════════════════════════════════════
class HuffmanMaterialPage extends StatelessWidget {
  const HuffmanMaterialPage({super.key});
  @override
  Widget build(BuildContext context) {
    return const DSAMaterialPage(
      data: MaterialPageData(
        title: 'Huffman Coding',
        accentColor: Colors.red,
        icon: Icons.compress_rounded,
        definition:
            'Huffman Coding is a lossless data compression algorithm that assigns variable-length binary codes to characters based on their frequency — more frequent characters get shorter codes. It builds an optimal prefix-free binary tree (Huffman Tree) using a greedy approach.',
        howItWorks:
            'Count frequency of each character. Create a leaf node for each and insert into a min-heap by frequency. Repeatedly extract the two lowest-frequency nodes, create a new internal node with their sum as frequency, and insert it back. Repeat until one node remains — that is the Huffman Tree root. Traverse left (0) or right (1) to get codes.',
        operations: [
          OperationData(name: 'Build Frequency Table', definition: 'Count how many times each character appears in the input.', complexity: 'O(n)'),
          OperationData(name: 'Build Huffman Tree', definition: 'Use a min-heap to greedily merge the two lowest-frequency nodes.', complexity: 'O(n log n)'),
          OperationData(name: 'Generate Codes', definition: 'Traverse tree assigning 0 for left and 1 for right to get prefix-free codes.', complexity: 'O(n)'),
          OperationData(name: 'Encode', definition: 'Replace each character in input with its Huffman code.', complexity: 'O(n)'),
          OperationData(name: 'Decode', definition: 'Traverse tree bit by bit — left for 0, right for 1 — output character on reaching a leaf.', complexity: 'O(n)'),
        ],
        realWorldApps: [
          'JPEG and PNG image formats use Huffman coding for compression',
          'ZIP and GZIP use Huffman as part of the DEFLATE algorithm',
          'MP3 audio compression uses Huffman for entropy encoding',
          'PDF format uses Huffman coding internally',
          'HTTP/2 header compression (HPACK) uses Huffman coding',
        ],
        keyTakeaways: [
          FlashCardData(front: 'Why is Huffman coding called greedy?', back: 'At each step it makes the locally optimal choice — merging two smallest frequency nodes — leading to a globally optimal encoding.'),
          FlashCardData(front: 'What is a prefix-free code?', back: 'No codeword is a prefix of another. This ensures encoded text can be decoded uniquely without delimiters.'),
          FlashCardData(front: 'What affects Huffman compression ratio?', back: 'Character frequency distribution. High skew (few frequent chars) gives high compression. Uniform distribution gives minimal gains.'),
          FlashCardData(front: 'How is the Huffman tree used for decoding?', back: 'Read bits one at a time: go left for 0, right for 1. When a leaf is reached, output that character and return to root.'),
          FlashCardData(front: 'Huffman vs Run-Length Encoding?', back: 'Huffman: variable-length codes per character, great for varied text. RLE: compresses consecutive repeats, great for solid color image regions.'),
        ],
      ),
    );
  }
}