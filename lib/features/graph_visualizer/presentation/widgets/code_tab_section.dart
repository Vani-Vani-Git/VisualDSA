import 'package:flutter/material.dart';
import 'language_dropdown.dart';

class CodeTabSection extends StatefulWidget {
  final String mode; // 'adjacency_matrix' | 'adjacency_list' | 'create_graph'
  final void Function(String)? onLanguageChanged;

  const CodeTabSection({super.key, required this.mode, this.onLanguageChanged});

  @override
  State<CodeTabSection> createState() => _CodeTabSectionState();
}

class _CodeTabSectionState extends State<CodeTabSection> {
  String _lang = 'Python';

  static const Map<String, Map<String, String>> _snippets = {
    'adjacency_matrix': {
      'Python': '''# Adjacency Matrix representation
V = 5
graph = [[0]*V for _ in range(V)]

def add_edge(u, v, w=1):
    graph[u][v] = w
    graph[v][u] = w  # undirected

def print_matrix():
    for row in graph:
        print(row)

add_edge(0, 1)
add_edge(0, 4)
add_edge(1, 2)
add_edge(1, 4)
add_edge(2, 3)
add_edge(3, 4)
print_matrix()''',
      'Java': '''int V = 5;
int[][] graph = new int[V][V];

void addEdge(int u, int v, int w) {
    graph[u][v] = w;
    graph[v][u] = w; // undirected
}

void printMatrix() {
    for (int[] row : graph) {
        for (int val : row)
            System.out.print(val + " ");
        System.out.println();
    }
}''',
      'C': '''#define V 5
int graph[V][V] = {0};

void addEdge(int u, int v, int w) {
    graph[u][v] = w;
    graph[v][u] = w;
}

void printMatrix() {
    for (int i=0;i<V;i++) {
        for (int j=0;j<V;j++)
            printf("%d ", graph[i][j]);
        printf("\\n");
    }
}''',
      'C++': '''const int V = 5;
int graph[V][V] = {0};

void addEdge(int u, int v, int w=1) {
    graph[u][v] = w;
    graph[v][u] = w;
}

void printMatrix() {
    for (int i=0;i<V;i++) {
        for (int j=0;j<V;j++)
            cout << graph[i][j] << " ";
        cout << "\\n";
    }
}''',
    },
    'adjacency_list': {
      'Python': '''from collections import defaultdict

class Graph:
    def __init__(self):
        self.adj = defaultdict(list)

    def add_edge(self, u, v):
        self.adj[u].append(v)
        self.adj[v].append(u)

    def print_list(self):
        for v, nb in self.adj.items():
            print(f"{v}: {nb}")

g = Graph()
g.add_edge(0, 1)
g.add_edge(0, 4)
g.add_edge(1, 2)
g.add_edge(2, 3)
g.print_list()''',
      'Java': '''import java.util.*;

class Graph {
    int V;
    LinkedList<Integer>[] adj;

    Graph(int v) {
        V = v;
        adj = new LinkedList[v];
        for (int i=0; i<v; i++)
            adj[i] = new LinkedList<>();
    }

    void addEdge(int u, int v) {
        adj[u].add(v);
        adj[v].add(u);
    }

    void printList() {
        for (int i=0; i<V; i++)
            System.out.println(i+": "+adj[i]);
    }
}''',
      'C': '''#include <stdio.h>
#include <stdlib.h>

struct Node {
    int data;
    struct Node* next;
};

struct Node* adj[10];

void addEdge(int u, int v) {
    struct Node* n1 = malloc(sizeof(*n1));
    n1->data = v; n1->next = adj[u];
    adj[u] = n1;
    struct Node* n2 = malloc(sizeof(*n2));
    n2->data = u; n2->next = adj[v];
    adj[v] = n2;
}''',
      'C++': '''#include <bits/stdc++.h>
using namespace std;

class Graph {
    int V;
    vector<list<int>> adj;
public:
    Graph(int v): V(v), adj(v) {}

    void addEdge(int u, int v) {
        adj[u].push_back(v);
        adj[v].push_back(u);
    }

    void printList() {
        for (int i=0; i<V; i++) {
            cout << i << ": ";
            for (auto x: adj[i])
                cout << x << " ";
            cout << "\\n";
        }
    }
};''',
    },
    'create_graph': {
      'Python': '''# Graph creation
class Graph:
    def __init__(self, vertices):
        self.V = vertices
        self.adj = {v: [] for v in range(V)}

    def add_edge(self, u, v):
        self.adj[u].append(v)
        self.adj[v].append(u)

g = Graph(5)
g.add_edge(0, 1)
g.add_edge(0, 4)
g.add_edge(1, 2)''',
      'Java': '''class Graph {
    int V;
    List<List<Integer>> adj;

    Graph(int v) {
        V = v;
        adj = new ArrayList<>();
        for (int i=0;i<v;i++)
            adj.add(new ArrayList<>());
    }
    void addEdge(int u, int v) {
        adj.get(u).add(v);
        adj.get(v).add(u);
    }
}''',
      'C': '''#define V 5
int adj[V][V] = {0};
void addEdge(int u, int v) {
    adj[u][v] = 1;
    adj[v][u] = 1;
}''',
      'C++': '''class Graph {
    int V;
    vector<vector<int>> adj;
public:
    Graph(int v): V(v), adj(v) {}
    void addEdge(int u, int v) {
        adj[u].push_back(v);
        adj[v].push_back(u);
    }
};''',
    },
  };

  static const _keywords = [
    'def', 'class', 'return', 'for', 'if', 'in', 'import', 'from',
    'self', 'void', 'int', 'new', 'while', 'else', 'struct', 'const',
    'vector', 'list', 'using', 'namespace', 'public', 'include',
    'malloc', 'sizeof', 'auto',
  ];

  List<TextSpan> _colorize(String line) {
    final spans = <TextSpan>[];
    final tokenRegex = RegExp(r'([A-Za-z_]\w*|\d+|[^\w\s]|\s+)');
    for (final m in tokenRegex.allMatches(line)) {
      final token = m.group(0)!;
      final t = token.trim();
      Color color;
      if (t.startsWith('#') || t.startsWith('//')) {
        color = const Color(0xFF6B7280);
      } else if (_keywords.contains(t)) {
        color = const Color(0xFFC084FC);
      } else if (RegExp(r'^\d+$').hasMatch(t)) {
        color = const Color(0xFFFB923C);
      } else if (t.startsWith('"') || t.startsWith("'")) {
        color = const Color(0xFF86EFAC);
      } else {
        color = const Color(0xFFE2E8F0);
      }
      spans.add(TextSpan(text: token, style: TextStyle(color: color)));
    }
    return spans;
  }

  @override
  Widget build(BuildContext context) {
    final code = _snippets[widget.mode]?[_lang] ?? '// Not available';
    final lines = code.split('\n');

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LanguageDropdown(
            selected: _lang,
            onChanged: (l) {
              setState(() => _lang = l);
              widget.onLanguageChanged?.call(l);
            },
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(lines.length, (i) => Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 24,
                      child: Text('${i + 1}',
                          style: const TextStyle(
                            color: Color(0xFFEF4444),
                            fontSize: 11,
                            fontFamily: 'monospace',
                          )),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 11,
                            fontFamily: 'monospace',
                            height: 1.55,
                          ),
                          children: _colorize(lines[i]),
                        ),
                      ),
                    ),
                  ],
                ),
              )),
            ),
          ),
        ],
      ),
    );
  }
}