import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TravCodeTab extends StatefulWidget {
  final String algorithm; // 'bfs' | 'dfs'
  final void Function(String lang)? onLanguageChanged;
  const TravCodeTab({super.key, required this.algorithm, this.onLanguageChanged});
  @override
  State<TravCodeTab> createState() => _TravCodeTabState();
}

class _TravCodeTabState extends State<TravCodeTab> {
  String _lang = 'Python';
  bool _langOpen = false;
  static const _langs = ['Python', 'Java', 'C', 'C++'];

  static const _code = {
    'bfs': {
      'Python': '''from collections import deque

def bfs(graph, src):
    visited = set()
    queue   = deque([src])
    visited.add(src)
    order   = []

    while queue:
        node = queue.popleft()
        order.append(node)

        for neighbour in graph[node]:
            if neighbour not in visited:
                visited.add(neighbour)
                queue.append(neighbour)

    return order

# Example — adjacency list
graph = {
    0: [1, 2],
    1: [0, 3, 4],
    2: [0, 5],
    3: [1],
    4: [1],
    5: [2],
}
print("BFS order:", bfs(graph, 0))''',

      'Java': '''import java.util.*;

class BFS {
  static List<Integer> bfs(
      Map<Integer, List<Integer>> graph,
      int src) {
    Set<Integer> visited = new HashSet<>();
    Queue<Integer> queue = new LinkedList<>();
    List<Integer> order = new ArrayList<>();

    queue.add(src);
    visited.add(src);

    while (!queue.isEmpty()) {
      int node = queue.poll();
      order.add(node);

      for (int nb : graph
          .getOrDefault(node,
              Collections.emptyList())) {
        if (!visited.contains(nb)) {
          visited.add(nb);
          queue.add(nb);
        }
      }
    }
    return order;
  }
}''',

      'C': '''#include <stdio.h>
#include <stdlib.h>
#define MAX 100

int adj[MAX][MAX], n;
int visited[MAX];
int queue[MAX], front=0, rear=0;

void bfs(int src) {
  queue[rear++] = src;
  visited[src] = 1;

  while (front < rear) {
    int node = queue[front++];
    printf("%d ", node);

    for (int v=0; v<n; v++) {
      if (adj[node][v] && !visited[v]) {
        visited[v] = 1;
        queue[rear++] = v;
      }
    }
  }
}

int main() {
  n = 6;
  // Build adjacency matrix...
  bfs(0);
}''',

      'C++': '''#include <bits/stdc++.h>
using namespace std;

vector<int> bfs(
    vector<vector<int>>& graph, int src) {
  int n = graph.size();
  vector<bool> visited(n, false);
  queue<int> q;
  vector<int> order;

  q.push(src);
  visited[src] = true;

  while (!q.empty()) {
    int node = q.front(); q.pop();
    order.push_back(node);

    for (int nb : graph[node]) {
      if (!visited[nb]) {
        visited[nb] = true;
        q.push(nb);
      }
    }
  }
  return order;
}

int main() {
  vector<vector<int>> g = {
    {1,2},{0,3,4},{0,5},{1},{1},{2}
  };
  for (int v : bfs(g, 0))
    cout << v << " ";
}''',
    },

    'dfs': {
      'Python': '''def dfs_iterative(graph, src):
    visited = set()
    stack   = [src]
    order   = []

    while stack:
        node = stack.pop()
        if node in visited:
            continue
        visited.add(node)
        order.append(node)

        # Push in reverse for left-to-right
        for nb in reversed(graph[node]):
            if nb not in visited:
                stack.append(nb)

    return order

def dfs_recursive(graph, src,
                  visited=None, order=None):
    if visited is None:
        visited, order = set(), []
    visited.add(src)
    order.append(src)
    for nb in graph[src]:
        if nb not in visited:
            dfs_recursive(graph, nb,
                          visited, order)
    return order

graph = {0:[1,2],1:[0,3,4],
         2:[0,5],3:[1],4:[1],5:[2]}
print("DFS:", dfs_iterative(graph, 0))''',

      'Java': '''import java.util.*;

class DFS {
  // Iterative DFS
  static List<Integer> dfsIter(
      Map<Integer,List<Integer>> g, int src){
    Set<Integer> visited = new HashSet<>();
    Deque<Integer> stack = new ArrayDeque<>();
    List<Integer> order = new ArrayList<>();

    stack.push(src);
    while (!stack.isEmpty()) {
      int node = stack.pop();
      if (visited.contains(node)) continue;
      visited.add(node); order.add(node);
      for (int nb : g.getOrDefault(node,
              Collections.emptyList()))
        if (!visited.contains(nb))
          stack.push(nb);
    }
    return order;
  }

  // Recursive DFS
  static void dfsRec(
      Map<Integer,List<Integer>> g,
      int node, Set<Integer> visited,
      List<Integer> order) {
    visited.add(node); order.add(node);
    for (int nb : g.getOrDefault(node,
            Collections.emptyList()))
      if (!visited.contains(nb))
        dfsRec(g, nb, visited, order);
  }
}''',

      'C': '''#include <stdio.h>
#define MAX 100

int adj[MAX][MAX], n;
int visited[MAX];
int stack[MAX], top=-1;

void dfs_iter(int src) {
  stack[++top] = src;

  while (top >= 0) {
    int node = stack[top--];
    if (visited[node]) continue;
    visited[node] = 1;
    printf("%d ", node);

    for (int v=n-1; v>=0; v--)
      if (adj[node][v] && !visited[v])
        stack[++top] = v;
  }
}

void dfs_rec(int node) {
  visited[node] = 1;
  printf("%d ", node);
  for (int v=0; v<n; v++)
    if (adj[node][v] && !visited[v])
      dfs_rec(v);
}

int main() {
  n = 6;
  dfs_iter(0);
}''',

      'C++': '''#include <bits/stdc++.h>
using namespace std;

// Iterative DFS
vector<int> dfsIter(
    vector<vector<int>>& g, int src) {
  int n = g.size();
  vector<bool> visited(n, false);
  stack<int> st;
  vector<int> order;

  st.push(src);
  while (!st.empty()) {
    int node = st.top(); st.pop();
    if (visited[node]) continue;
    visited[node] = true;
    order.push_back(node);
    for (auto it = g[node].rbegin();
         it != g[node].rend(); ++it)
      if (!visited[*it]) st.push(*it);
  }
  return order;
}

// Recursive DFS
void dfsRec(vector<vector<int>>& g,
    int node, vector<bool>& vis,
    vector<int>& order) {
  vis[node] = true;
  order.push_back(node);
  for (int nb : g[node])
    if (!vis[nb])
      dfsRec(g, nb, vis, order);
}''',
    },
  };

  static const _keywords = [
    'def','class','return','for','if','in','import','from','while',
    'not','and','or','None','True','False','self','void','int',
    'new','else','static','using','namespace','public','include',
    'auto','bool','set','queue','stack','map','vector','deque',
    'continue','reversed','Collections','Set','Queue','List',
  ];

  List<TextSpan> _colorize(String line) {
    final spans = <TextSpan>[];
    final rx = RegExp(r'([A-Za-z_]\w*|\d+|[^\w\s]|\s+)');
    for (final m in rx.allMatches(line)) {
      final token = m.group(0)!;
      final t = token.trim();
      Color color;
      if (t.startsWith('#') || t.startsWith('//')) color = const Color(0xFF6B7280);
      else if (t.startsWith('"') || t.startsWith("'")) color = const Color(0xFF86EFAC);
      else if (_keywords.contains(t)) color = const Color(0xFFC084FC);
      else if (RegExp(r'^\d+$').hasMatch(t)) color = const Color(0xFFFB923C);
      else color = const Color(0xFFE2E8F0);
      spans.add(TextSpan(text: token, style: TextStyle(color: color)));
    }
    return spans;
  }

  @override
  Widget build(BuildContext context) {
    final code = _code[widget.algorithm]?[_lang] ?? '';
    final lines = code.split('\n');

    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Language dropdown
          GestureDetector(
            onTap: () => setState(() => _langOpen = !_langOpen),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              decoration: BoxDecoration(
                color: const Color(0xFF161B22),
                border: Border.all(color: const Color(0xFF30363D)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_lang, style: const TextStyle(color: Color(0xFFE2E8F0),
                      fontSize: 13, fontWeight: FontWeight.w600, fontFamily: 'monospace')),
                  Icon(_langOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                      color: const Color(0xFF8B949E), size: 16),
                ],
              ),
            ),
          ),
          if (_langOpen) Container(
            margin: const EdgeInsets.only(top: 2),
            decoration: BoxDecoration(
              color: const Color(0xFF1C2128),
              border: Border.all(color: const Color(0xFF30363D)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(children: _langs.map((l) {
              final sel = l == _lang;
              return GestureDetector(
                onTap: () { setState(() { _lang = l; _langOpen = false; }); widget.onLanguageChanged?.call(l); },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                  color: sel ? const Color(0xFF21262D) : Colors.transparent,
                  child: Text(l, style: TextStyle(
                      color: sel ? const Color(0xFF3B82F6) : const Color(0xFFE2E8F0),
                      fontSize: 13, fontFamily: 'monospace')),
                ),
              );
            }).toList()),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFF161B22),
              border: Border.all(color: const Color(0xFF21262D)),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: Color(0xFF21262D)))),
                child: Row(children: [
                  Text('${widget.algorithm.toUpperCase()} · $_lang',
                      style: const TextStyle(color: Color(0xFF8B949E), fontSize: 10, fontFamily: 'monospace')),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: code));
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Copied!'), duration: Duration(seconds: 1),
                        backgroundColor: Color(0xFF1C2128),
                      ));
                    },
                    child: const Row(children: [
                      Icon(Icons.copy, size: 12, color: Color(0xFF8B949E)),
                      SizedBox(width: 4),
                      Text('Copy', style: TextStyle(color: Color(0xFF8B949E), fontSize: 10, fontFamily: 'monospace')),
                    ]),
                  ),
                ]),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: List.generate(lines.length, (i) => Padding(
                      padding: const EdgeInsets.only(bottom: 1),
                      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        SizedBox(width: 22,
                            child: Text('${i+1}', style: const TextStyle(
                                color: Color(0xFFEF4444), fontSize: 10, fontFamily: 'monospace'))),
                        const SizedBox(width: 6),
                        RichText(text: TextSpan(
                          style: const TextStyle(fontSize: 11, fontFamily: 'monospace', height: 1.5),
                          children: _colorize(lines[i]),
                        )),
                      ]),
                    )),
                  ),
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}