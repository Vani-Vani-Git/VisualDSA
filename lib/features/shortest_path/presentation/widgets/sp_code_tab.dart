import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SpCodeTabSection extends StatefulWidget {
  final String algorithm; // 'dijkstra' | 'bellman_ford'
  final void Function(String lang)? onLanguageChanged;

  const SpCodeTabSection({
    super.key,
    required this.algorithm,
    this.onLanguageChanged,
  });

  @override
  State<SpCodeTabSection> createState() => _SpCodeTabSectionState();
}

class _SpCodeTabSectionState extends State<SpCodeTabSection> {
  String _lang = 'Python';
  bool _langOpen = false;

  static const _langs = ['Python', 'Java', 'C', 'C++'];

  static const _code = {
    'dijkstra': {
      'Python': '''import heapq

def dijkstra(graph, src, n):
    dist = [float('inf')] * n
    dist[src] = 0
    pq = [(0, src)]  # (dist, node)

    while pq:
        d, u = heapq.heappop(pq)
        if d > dist[u]:
            continue
        for v, w in graph[u]:
            if dist[u] + w < dist[v]:
                dist[v] = dist[u] + w
                heapq.heappush(pq, (dist[v], v))
    return dist

# Example
graph = {0: [(1,4),(2,1)], 1: [(3,1)],
         2: [(1,2),(3,5)], 3: []}
print(dijkstra(graph, 0, 4))''',
      'Java': '''import java.util.*;

class Dijkstra {
  static int[] dijkstra(List<int[]>[] graph,
                         int src, int n) {
    int[] dist = new int[n];
    Arrays.fill(dist, Integer.MAX_VALUE);
    dist[src] = 0;
    PriorityQueue<int[]> pq =
      new PriorityQueue<>((a,b)->a[0]-b[0]);
    pq.add(new int[]{0, src});

    while (!pq.isEmpty()) {
      int[] cur = pq.poll();
      int d = cur[0], u = cur[1];
      if (d > dist[u]) continue;
      for (int[] nb : graph[u]) {
        int v = nb[0], w = nb[1];
        if (dist[u] + w < dist[v]) {
          dist[v] = dist[u] + w;
          pq.add(new int[]{dist[v], v});
        }
      }
    }
    return dist;
  }
}''',
      'C': '''#include <stdio.h>
#include <limits.h>
#define V 9

int minDist(int dist[], int visited[]) {
  int min = INT_MAX, idx;
  for (int v = 0; v < V; v++)
    if (!visited[v] && dist[v] <= min)
      min = dist[v], idx = v;
  return idx;
}

void dijkstra(int graph[V][V], int src) {
  int dist[V], visited[V] = {0};
  for (int i = 0; i < V; i++)
    dist[i] = INT_MAX;
  dist[src] = 0;

  for (int c = 0; c < V-1; c++) {
    int u = minDist(dist, visited);
    visited[u] = 1;
    for (int v = 0; v < V; v++)
      if (!visited[v] && graph[u][v]
          && dist[u] != INT_MAX
          && dist[u]+graph[u][v] < dist[v])
        dist[v] = dist[u] + graph[u][v];
  }
}''',
      'C++': '''#include <bits/stdc++.h>
using namespace std;
typedef pair<int,int> pii;

vector<int> dijkstra(
  vector<vector<pii>>& g, int src, int n) {
  vector<int> dist(n, INT_MAX);
  dist[src] = 0;
  priority_queue<pii, vector<pii>,
    greater<pii>> pq;
  pq.push({0, src});

  while (!pq.empty()) {
    auto [d, u] = pq.top(); pq.pop();
    if (d > dist[u]) continue;
    for (auto [v, w] : g[u]) {
      if (dist[u] + w < dist[v]) {
        dist[v] = dist[u] + w;
        pq.push({dist[v], v});
      }
    }
  }
  return dist;
}''',
    },
    'bellman_ford': {
      'Python': '''def bellman_ford(edges, n, src):
    dist = [float('inf')] * n
    dist[src] = 0

    # Relax all edges n-1 times
    for _ in range(n - 1):
        updated = False
        for u, v, w in edges:
            if (dist[u] != float('inf')
                    and dist[u] + w < dist[v]):
                dist[v] = dist[u] + w
                updated = True
        if not updated:
            break  # early termination

    # Check for negative-weight cycles
    for u, v, w in edges:
        if (dist[u] != float('inf')
                and dist[u] + w < dist[v]):
            return None  # negative cycle

    return dist

# edges = [(u, v, weight), ...]
edges = [(0,1,4),(0,2,1),(2,1,2),(1,3,1)]
print(bellman_ford(edges, 4, 0))''',
      'Java': '''import java.util.Arrays;

class BellmanFord {
  static int[] bellmanFord(
      int[][] edges, int n, int src) {
    int[] dist = new int[n];
    Arrays.fill(dist, Integer.MAX_VALUE);
    dist[src] = 0;

    for (int i = 1; i < n; i++) {
      boolean updated = false;
      for (int[] e : edges) {
        int u=e[0], v=e[1], w=e[2];
        if (dist[u]!=Integer.MAX_VALUE
            && dist[u]+w < dist[v]) {
          dist[v] = dist[u] + w;
          updated = true;
        }
      }
      if (!updated) break;
    }
    // Negative cycle check
    for (int[] e : edges)
      if (dist[e[0]]!=Integer.MAX_VALUE
          && dist[e[0]]+e[2] < dist[e[1]])
        return null;
    return dist;
  }
}''',
      'C': '''#include <stdio.h>
#include <limits.h>

struct Edge { int src, dest, weight; };

void bellmanFord(struct Edge edges[],
    int V, int E, int src) {
  int dist[V];
  for (int i=0;i<V;i++) dist[i]=INT_MAX;
  dist[src] = 0;

  for (int i=1; i<V; i++) {
    for (int j=0; j<E; j++) {
      int u=edges[j].src,
          v=edges[j].dest,
          w=edges[j].weight;
      if (dist[u]!=INT_MAX
          && dist[u]+w < dist[v])
        dist[v] = dist[u] + w;
    }
  }
  // Negative cycle check
  for (int j=0; j<E; j++) {
    int u=edges[j].src,
        v=edges[j].dest,
        w=edges[j].weight;
    if (dist[u]!=INT_MAX
        && dist[u]+w < dist[v])
      printf("Negative cycle!\\n");
  }
}''',
      'C++': '''#include <bits/stdc++.h>
using namespace std;

struct Edge { int u, v, w; };

vector<int> bellmanFord(
    vector<Edge>& edges, int n, int src) {
  vector<int> dist(n, INT_MAX);
  dist[src] = 0;

  for (int i = 1; i < n; i++) {
    bool updated = false;
    for (auto& [u, v, w] : edges) {
      if (dist[u] != INT_MAX
          && dist[u] + w < dist[v]) {
        dist[v] = dist[u] + w;
        updated = true;
      }
    }
    if (!updated) break;
  }
  // Negative cycle check
  for (auto& [u, v, w] : edges)
    if (dist[u] != INT_MAX
        && dist[u] + w < dist[v])
      return {}; // negative cycle
  return dist;
}''',
    },
  };

  static const _keywords = [
    'def', 'class', 'return', 'for', 'if', 'in', 'import', 'from', 'while',
    'not', 'and', 'or', 'break', 'None', 'True', 'False', 'float',
    'void', 'int', 'new', 'else', 'static', 'struct', 'const', 'vector',
    'list', 'using', 'namespace', 'public', 'include', 'auto', 'bool',
    'continue', 'null', 'List', 'Arrays', 'import', 'typedef',
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
      } else if (t.startsWith('"') || t.startsWith("'")) {
        color = const Color(0xFF86EFAC);
      } else if (_keywords.contains(t)) {
        color = const Color(0xFFC084FC);
      } else if (RegExp(r'^\d+$').hasMatch(t)) {
        color = const Color(0xFFFB923C);
      } else {
        color = const Color(0xFFE2E8F0);
      }
      spans.add(TextSpan(text: token, style: TextStyle(color: color)));
    }
    return spans;
  }

  @override
  Widget build(BuildContext context) {
    final code =
        _code[widget.algorithm]?[_lang] ?? '// Not available';
    final lines = code.split('\n');

    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Language dropdown
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => setState(() => _langOpen = !_langOpen),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 9),
                  decoration: BoxDecoration(
                    color: const Color(0xFF161B22),
                    border: Border.all(color: const Color(0xFF30363D)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_lang,
                          style: const TextStyle(
                              color: Color(0xFFE2E8F0),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'monospace')),
                      Icon(
                          _langOpen
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          color: const Color(0xFF8B949E),
                          size: 16),
                    ],
                  ),
                ),
              ),
              if (_langOpen)
                Container(
                  margin: const EdgeInsets.only(top: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1C2128),
                    border: Border.all(color: const Color(0xFF30363D)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: _langs.map((l) {
                      final sel = l == _lang;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _lang = l;
                            _langOpen = false;
                          });
                          widget.onLanguageChanged?.call(l);
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 9),
                          color: sel
                              ? const Color(0xFF21262D)
                              : Colors.transparent,
                          child: Text(l,
                              style: TextStyle(
                                  color: sel
                                      ? const Color(0xFF3B82F6)
                                      : const Color(0xFFE2E8F0),
                                  fontSize: 13,
                                  fontFamily: 'monospace')),
                        ),
                      );
                    }).toList(),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),

          // Code block
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFF161B22),
              border: Border.all(color: const Color(0xFF21262D)),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Copy bar
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6),
                  decoration: const BoxDecoration(
                    border: Border(
                        bottom: BorderSide(color: Color(0xFF21262D))),
                  ),
                  child: Row(
                    children: [
                      Text(
                        '${widget.algorithm == 'dijkstra' ? "Dijkstra" : "Bellman-Ford"} · $_lang',
                        style: const TextStyle(
                            color: Color(0xFF8B949E),
                            fontSize: 10,
                            fontFamily: 'monospace'),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: code));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Copied!'),
                              duration: Duration(seconds: 1),
                              backgroundColor: Color(0xFF1C2128),
                            ),
                          );
                        },
                        child: const Row(
                          children: [
                            Icon(Icons.copy,
                                size: 12, color: Color(0xFF8B949E)),
                            SizedBox(width: 4),
                            Text('Copy',
                                style: TextStyle(
                                    color: Color(0xFF8B949E),
                                    fontSize: 10,
                                    fontFamily: 'monospace')),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(10),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: List.generate(lines.length, (i) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 1),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 22,
                                child: Text('${i + 1}',
                                    style: const TextStyle(
                                        color: Color(0xFFEF4444),
                                        fontSize: 10,
                                        fontFamily: 'monospace')),
                              ),
                              const SizedBox(width: 6),
                              RichText(
                                text: TextSpan(
                                  style: const TextStyle(
                                      fontSize: 11,
                                      fontFamily: 'monospace',
                                      height: 1.5),
                                  children: _colorize(lines[i]),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}