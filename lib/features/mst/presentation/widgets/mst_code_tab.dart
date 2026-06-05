import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MstCodeTabSection extends StatefulWidget {
  final String algorithm; // 'prims' | 'kruskals'
  final void Function(String lang)? onLanguageChanged;

  const MstCodeTabSection({
    super.key,
    required this.algorithm,
    this.onLanguageChanged,
  });

  @override
  State<MstCodeTabSection> createState() => _MstCodeTabSectionState();
}

class _MstCodeTabSectionState extends State<MstCodeTabSection> {
  String _lang = 'Python';
  bool _langOpen = false;

  static const _langs = ['Python', 'Java', 'C', 'C++'];

  static const _code = {
    'prims': {
      'Python': '''import heapq

def prims(graph, n, src=0):
    # graph[u] = list of (weight, v)
    visited = [False] * n
    min_heap = [(0, src, -1)]
    mst_cost = 0
    mst_edges = []

    while min_heap and len(mst_edges) < n - 1:
        w, u, parent = heapq.heappop(min_heap)
        if visited[u]:
            continue
        visited[u] = True
        mst_cost += w
        if parent != -1:
            mst_edges.append((parent, u, w))

        for weight, v in graph[u]:
            if not visited[v]:
                heapq.heappush(
                    min_heap, (weight, v, u))

    return mst_cost, mst_edges

# Example: adjacency list (weight, neighbour)
graph = {
    0: [(4,1),(2,2)],
    1: [(4,0),(3,2),(1,3)],
    2: [(2,0),(3,1),(5,3)],
    3: [(1,1),(5,2)]
}
cost, edges = prims(graph, 4)
print(f"MST cost: {cost}")
print(f"MST edges: {edges}")''',

      'Java': '''import java.util.*;

class Prims {
  static int prims(List<int[]>[] graph, int n) {
    boolean[] visited = new boolean[n];
    // PQ: {weight, u, parent}
    PriorityQueue<int[]> pq =
        new PriorityQueue<>((a,b)->a[0]-b[0]);
    pq.add(new int[]{0, 0, -1});
    int mstCost = 0;
    List<int[]> mstEdges = new ArrayList<>();

    while (!pq.isEmpty()
           && mstEdges.size() < n - 1) {
      int[] cur = pq.poll();
      int w = cur[0], u = cur[1], par = cur[2];
      if (visited[u]) continue;
      visited[u] = true;
      mstCost += w;
      if (par != -1)
        mstEdges.add(new int[]{par, u, w});

      for (int[] nb : graph[u]) {
        if (!visited[nb[1]])
          pq.add(new int[]{nb[0], nb[1], u});
      }
    }
    return mstCost;
  }
}''',

      'C': '''#include <stdio.h>
#include <limits.h>
#define V 5

int minKey(int key[], int inMST[]) {
  int min = INT_MAX, idx = 0;
  for (int v = 0; v < V; v++)
    if (!inMST[v] && key[v] < min)
      min = key[v], idx = v;
  return idx;
}

void prims(int graph[V][V]) {
  int parent[V], key[V], inMST[V];
  for (int i = 0; i < V; i++)
    key[i] = INT_MAX, inMST[i] = 0;
  key[0] = 0; parent[0] = -1;

  for (int c = 0; c < V - 1; c++) {
    int u = minKey(key, inMST);
    inMST[u] = 1;
    for (int v = 0; v < V; v++)
      if (graph[u][v] && !inMST[v]
          && graph[u][v] < key[v]) {
        parent[v] = u;
        key[v] = graph[u][v];
      }
  }
  int cost = 0;
  for (int i = 1; i < V; i++) {
    printf("%d - %d w=%d\\n",
        parent[i], i, graph[i][parent[i]]);
    cost += graph[i][parent[i]];
  }
  printf("Total: %d\\n", cost);
}''',

      'C++': '''#include <bits/stdc++.h>
using namespace std;
typedef pair<int,int> pii;

int prims(vector<vector<pii>>& g, int n) {
  vector<bool> inMST(n, false);
  // {weight, node, parent}
  priority_queue<tuple<int,int,int>,
      vector<tuple<int,int,int>>,
      greater<>> pq;
  pq.push({0, 0, -1});
  int mstCost = 0;
  vector<pair<int,int>> mstEdges;

  while (!pq.empty()
      && (int)mstEdges.size() < n-1) {
    auto [w, u, par] = pq.top(); pq.pop();
    if (inMST[u]) continue;
    inMST[u] = true;
    mstCost += w;
    if (par != -1)
      mstEdges.push_back({par, u});
    for (auto [v, wt] : g[u])
      if (!inMST[v])
        pq.push({wt, v, u});
  }
  return mstCost;
}''',
    },

    'kruskals': {
      'Python': '''class UnionFind:
    def __init__(self, n):
        self.parent = list(range(n))
        self.rank = [0] * n

    def find(self, x):
        if self.parent[x] != x:
            self.parent[x] = self.find(
                self.parent[x])  # path compress
        return self.parent[x]

    def union(self, x, y):
        px, py = self.find(x), self.find(y)
        if px == py: return False
        if self.rank[px] < self.rank[py]:
            px, py = py, px
        self.parent[py] = px
        if self.rank[px] == self.rank[py]:
            self.rank[px] += 1
        return True

def kruskals(edges, n):
    # edges = [(weight, u, v), ...]
    edges.sort()  # sort by weight
    uf = UnionFind(n)
    mst_cost = 0
    mst_edges = []

    for w, u, v in edges:
        if uf.union(u, v):
            mst_cost += w
            mst_edges.append((u, v, w))
            if len(mst_edges) == n - 1:
                break  # MST complete

    return mst_cost, mst_edges

edges = [(4,0,1),(2,0,2),(3,1,2),(1,1,3),(5,2,3)]
cost, mst = kruskals(edges, 4)
print(f"MST cost: {cost}")
print(f"MST: {mst}")''',

      'Java': '''import java.util.*;

class Kruskals {
  static int[] parent, rank;

  static int find(int x) {
    if (parent[x] != x)
      parent[x] = find(parent[x]);
    return parent[x];
  }

  static boolean union(int x, int y) {
    int px = find(x), py = find(y);
    if (px == py) return false;
    if (rank[px] < rank[py]) {
      int t = px; px = py; py = t;
    }
    parent[py] = px;
    if (rank[px] == rank[py]) rank[px]++;
    return true;
  }

  static int kruskals(int[][] edges, int n) {
    // edges[i] = {weight, u, v}
    Arrays.sort(edges, (a,b)->a[0]-b[0]);
    parent = new int[n];
    rank = new int[n];
    for (int i = 0; i < n; i++) parent[i] = i;

    int cost = 0, count = 0;
    for (int[] e : edges) {
      if (union(e[1], e[2])) {
        cost += e[0]; count++;
        System.out.printf(
            "%d-%d w=%d%n",e[1],e[2],e[0]);
        if (count == n - 1) break;
      }
    }
    return cost;
  }
}''',

      'C': '''#include <stdio.h>
#include <stdlib.h>

struct Edge {
  int u, v, w;
};

int parent[100], rnk[100];

int find(int x) {
  if (parent[x] != x)
    parent[x] = find(parent[x]);
  return parent[x];
}

int unite(int x, int y) {
  int px=find(x), py=find(y);
  if (px==py) return 0;
  if (rnk[px]<rnk[py]) {
    int t=px; px=py; py=t;
  }
  parent[py]=px;
  if (rnk[px]==rnk[py]) rnk[px]++;
  return 1;
}

int cmp(const void* a, const void* b) {
  return ((struct Edge*)a)->w
       - ((struct Edge*)b)->w;
}

int kruskals(struct Edge* edges,
             int E, int n) {
  for (int i=0;i<n;i++)
    parent[i]=i, rnk[i]=0;
  qsort(edges, E, sizeof(*edges), cmp);
  int cost=0, cnt=0;
  for (int i=0; i<E && cnt<n-1; i++)
    if (unite(edges[i].u, edges[i].v)) {
      cost += edges[i].w; cnt++;
    }
  return cost;
}''',

      'C++': '''#include <bits/stdc++.h>
using namespace std;

struct Edge {
  int u, v, w;
  bool operator<(const Edge& o) const {
    return w < o.w;
  }
};

struct UnionFind {
  vector<int> p, r;
  UnionFind(int n): p(n), r(n,0) {
    iota(p.begin(), p.end(), 0);
  }
  int find(int x) {
    return p[x]==x ? x : p[x]=find(p[x]);
  }
  bool unite(int x, int y) {
    x=find(x); y=find(y);
    if (x==y) return false;
    if (r[x]<r[y]) swap(x,y);
    p[y]=x;
    if (r[x]==r[y]) r[x]++;
    return true;
  }
};

int kruskals(vector<Edge>& edges, int n) {
  sort(edges.begin(), edges.end());
  UnionFind uf(n);
  int cost = 0, cnt = 0;
  for (auto& [u, v, w] : edges) {
    if (uf.unite(u, v)) {
      cost += w;
      if (++cnt == n - 1) break;
    }
  }
  return cost;
}''',
    },
  };

  static const _keywords = [
    'def', 'class', 'return', 'for', 'if', 'in', 'import', 'from',
    'while', 'not', 'and', 'or', 'break', 'None', 'True', 'False',
    'self', 'void', 'int', 'new', 'else', 'static', 'struct', 'const',
    'vector', 'list', 'using', 'namespace', 'public', 'include',
    'auto', 'bool', 'continue', 'iota', 'sort', 'swap', 'true', 'false',
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
    final code = _code[widget.algorithm]?[_lang] ?? '// Not available';
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
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
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
                // Header bar
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6),
                  decoration: const BoxDecoration(
                      border: Border(
                          bottom: BorderSide(color: Color(0xFF21262D)))),
                  child: Row(
                    children: [
                      Text(
                        '${widget.algorithm == 'prims' ? "Prim's" : "Kruskal's"} · $_lang',
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