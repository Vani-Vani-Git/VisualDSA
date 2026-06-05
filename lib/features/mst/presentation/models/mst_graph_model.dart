import 'dart:math';
import 'package:flutter/material.dart';

// ── Graph Properties ──────────────────────────────────────────────────────────
class MstGraphProperties {
  bool weighted;

  MstGraphProperties({this.weighted = true});

  MstGraphProperties copyWith({bool? weighted}) =>
      MstGraphProperties(weighted: weighted ?? this.weighted);
}

// ── Vertex ────────────────────────────────────────────────────────────────────
class MstVertex {
  final int id;
  final String label;
  Offset position;

  MstVertex({required this.id, required this.label, required this.position});
}

// ── Edge ──────────────────────────────────────────────────────────────────────
class MstEdge {
  final int from;
  final int to;
  final int weight;

  MstEdge({required this.from, required this.to, this.weight = 1});
}

// ── Graph Model ───────────────────────────────────────────────────────────────
class MstGraphModel {
  final List<MstVertex> vertices;
  final List<MstEdge> edges;
  final MstGraphProperties properties;

  MstGraphModel({
    required this.vertices,
    required this.edges,
    required this.properties,
  });

  int get n => vertices.length;

  // MST always works on undirected connected graphs
  static MstGraphModel random(MstGraphProperties props, Size canvasSize) {
    final rng = Random();
    final count = rng.nextInt(3) + 4; // 4–6 vertices
    final cx = canvasSize.width / 2;
    final cy = canvasSize.height / 2;
    final r = min(canvasSize.width, canvasSize.height) * 0.33;

    final verts = List.generate(count, (i) {
      final angle = (2 * pi * i / count) - pi / 2;
      return MstVertex(
        id: i,
        label: '$i',
        position: Offset(cx + r * cos(angle), cy + r * sin(angle)),
      );
    });

    final edges = <MstEdge>[];
    final used = <String>{};

    void addEdge(int a, int b) {
      final key = a < b ? '$a-$b' : '$b-$a';
      if (used.contains(key)) return;
      used.add(key);
      edges.add(MstEdge(
        from: a,
        to: b,
        weight: rng.nextInt(9) + 1,
      ));
    }

    // Guaranteed spanning tree (connected)
    final perm = List.generate(count, (i) => i)..shuffle(rng);
    for (int i = 0; i < count - 1; i++) addEdge(perm[i], perm[i + 1]);

    // Extra edges for interesting MST
    final extra = rng.nextInt(count) + count - 1;
    for (int k = 0; k < extra; k++) {
      int a = rng.nextInt(count);
      int b = rng.nextInt(count);
      if (a != b) addEdge(a, b);
    }

    return MstGraphModel(vertices: verts, edges: edges, properties: props);
  }
}

// ── Animation Step ────────────────────────────────────────────────────────────
enum MstStepType {
  init,
  considerEdge,   // looking at an edge
  addEdge,        // edge added to MST
  rejectEdge,     // edge rejected (would form cycle / not min)
  nodeAdded,      // Prim: node added to MST set
  mstComplete,
}

class MstAnimStep {
  final MstStepType type;
  final int? fromNode;
  final int? toNode;
  final int? currentNode;       // Prim: current node being expanded
  final Set<int> mstNodes;      // nodes in MST so far
  final Set<String> mstEdges;   // "from-to" edges in MST so far
  final Set<String> rejEdges;   // rejected edges (greyed out)
  final String? activeEdgeKey;  // edge being currently considered
  final String statusMsg;
  final int totalWeight;        // running MST weight

  const MstAnimStep({
    required this.type,
    this.fromNode,
    this.toNode,
    this.currentNode,
    required this.mstNodes,
    required this.mstEdges,
    this.rejEdges = const {},
    this.activeEdgeKey,
    this.statusMsg = '',
    this.totalWeight = 0,
  });
}

// ── Prim's Generator ──────────────────────────────────────────────────────────
class PrimGenerator {
  static List<MstAnimStep> generate(MstGraphModel g, int src) {
    final steps = <MstAnimStep>[];
    final n = g.vertices.length;
    if (n == 0) return steps;

    // Build adjacency
    final adj = <int, List<MstEdge>>{};
    for (final v in g.vertices) adj[v.id] = [];
    for (final e in g.edges) {
      adj[e.from]!.add(e);
      adj[e.to]!.add(MstEdge(from: e.to, to: e.from, weight: e.weight));
    }

    final inMst = <int>{};
    final mstEdges = <String>{};
    final rejEdges = <String>{};
    int totalWeight = 0;

    inMst.add(src);

    steps.add(MstAnimStep(
      type: MstStepType.init,
      currentNode: src,
      mstNodes: Set.from(inMst),
      mstEdges: Set.from(mstEdges),
      statusMsg: 'Start at node $src. Add it to MST set.',
      totalWeight: 0,
    ));

    while (inMst.length < n) {
      // Find minimum weight edge crossing the cut
      MstEdge? best;
      for (final u in inMst) {
        for (final e in adj[u]!) {
          if (!inMst.contains(e.to)) {
            if (best == null || e.weight < best.weight) {
              best = e;
            }
          }
        }
      }
      if (best == null) break; // disconnected

      // Show all candidate edges being considered from cut
      for (final u in inMst) {
        for (final e in adj[u]!) {
          if (!inMst.contains(e.to)) {
            final key = _edgeKey(e.from, e.to);
            final isBest = e.from == best.from && e.to == best.to ||
                e.from == best.to && e.to == best.from;

            steps.add(MstAnimStep(
              type: MstStepType.considerEdge,
              fromNode: e.from,
              toNode: e.to,
              currentNode: e.from,
              mstNodes: Set.from(inMst),
              mstEdges: Set.from(mstEdges),
              rejEdges: Set.from(rejEdges),
              activeEdgeKey: key,
              statusMsg: isBest
                  ? '⭐ Best cut edge: (${e.from}–${e.to}) w=${e.weight}'
                  : 'Consider cut edge (${e.from}–${e.to}) w=${e.weight}',
              totalWeight: totalWeight,
            ));
          }
        }
      }

      // Add best edge to MST
      totalWeight += best.weight;
      final key = _edgeKey(best.from, best.to);
      mstEdges.add(key);
      inMst.add(best.to);

      steps.add(MstAnimStep(
        type: MstStepType.addEdge,
        fromNode: best.from,
        toNode: best.to,
        currentNode: best.to,
        mstNodes: Set.from(inMst),
        mstEdges: Set.from(mstEdges),
        rejEdges: Set.from(rejEdges),
        activeEdgeKey: key,
        statusMsg:
            '✓ Add edge (${best.from}–${best.to}) w=${best.weight}. '
            'Node ${best.to} joins MST. Total = $totalWeight',
        totalWeight: totalWeight,
      ));

      steps.add(MstAnimStep(
        type: MstStepType.nodeAdded,
        currentNode: best.to,
        mstNodes: Set.from(inMst),
        mstEdges: Set.from(mstEdges),
        rejEdges: Set.from(rejEdges),
        statusMsg:
            'MST now has ${inMst.length} nodes. '
            '${n - inMst.length} remaining.',
        totalWeight: totalWeight,
      ));
    }

    steps.add(MstAnimStep(
      type: MstStepType.mstComplete,
      mstNodes: Set.from(inMst),
      mstEdges: Set.from(mstEdges),
      rejEdges: Set.from(rejEdges),
      statusMsg:
          '🎯 MST complete! Total weight = $totalWeight. '
          '${mstEdges.length} edges spanning ${inMst.length} nodes.',
      totalWeight: totalWeight,
    ));

    return steps;
  }

  static String _edgeKey(int a, int b) => a < b ? '$a-$b' : '$b-$a';
}

// ── Kruskal's Generator ───────────────────────────────────────────────────────
class KruskalGenerator {
  static List<MstAnimStep> generate(MstGraphModel g) {
    final steps = <MstAnimStep>[];
    if (g.vertices.isEmpty) return steps;

    // Sort all edges by weight
    final sortedEdges = List<MstEdge>.from(g.edges)
      ..sort((a, b) => a.weight.compareTo(b.weight));

    // Union-Find
    final parent = <int, int>{};
    final rank = <int, int>{};
    for (final v in g.vertices) {
      parent[v.id] = v.id;
      rank[v.id] = 0;
    }

    int find(int x) {
      if (parent[x] != x) parent[x] = find(parent[x]!);
      return parent[x]!;
    }

    bool union(int x, int y) {
      final px = find(x), py = find(y);
      if (px == py) return false;
      if (rank[px]! < rank[py]!) {
        parent[px] = py;
      } else if (rank[px]! > rank[py]!) {
        parent[py] = px;
      } else {
        parent[py] = px;
        rank[px] = rank[px]! + 1;
      }
      return true;
    }

    final mstEdges = <String>{};
    final rejEdges = <String>{};
    final mstNodes = <int>{};
    int totalWeight = 0;

    steps.add(MstAnimStep(
      type: MstStepType.init,
      mstNodes: {},
      mstEdges: {},
      statusMsg:
          'Sort all ${sortedEdges.length} edges by weight. '
          'Process smallest first.',
      totalWeight: 0,
    ));

    for (final e in sortedEdges) {
      final key = _edgeKey(e.from, e.to);

      steps.add(MstAnimStep(
        type: MstStepType.considerEdge,
        fromNode: e.from,
        toNode: e.to,
        mstNodes: Set.from(mstNodes),
        mstEdges: Set.from(mstEdges),
        rejEdges: Set.from(rejEdges),
        activeEdgeKey: key,
        statusMsg:
            'Consider edge (${e.from}–${e.to}) w=${e.weight}. '
            'Does it form a cycle?',
        totalWeight: totalWeight,
      ));

      if (union(e.from, e.to)) {
        // No cycle — add to MST
        mstEdges.add(key);
        mstNodes.add(e.from);
        mstNodes.add(e.to);
        totalWeight += e.weight;

        steps.add(MstAnimStep(
          type: MstStepType.addEdge,
          fromNode: e.from,
          toNode: e.to,
          mstNodes: Set.from(mstNodes),
          mstEdges: Set.from(mstEdges),
          rejEdges: Set.from(rejEdges),
          activeEdgeKey: key,
          statusMsg:
              '✓ No cycle — add (${e.from}–${e.to}) w=${e.weight}. '
              'Total = $totalWeight',
          totalWeight: totalWeight,
        ));
      } else {
        // Cycle — reject
        rejEdges.add(key);
        steps.add(MstAnimStep(
          type: MstStepType.rejectEdge,
          fromNode: e.from,
          toNode: e.to,
          mstNodes: Set.from(mstNodes),
          mstEdges: Set.from(mstEdges),
          rejEdges: Set.from(rejEdges),
          activeEdgeKey: key,
          statusMsg:
              '✗ Forms cycle — reject (${e.from}–${e.to}) w=${e.weight}',
          totalWeight: totalWeight,
        ));
      }

      // MST has V-1 edges — done
      if (mstEdges.length == g.vertices.length - 1) break;
    }

    // All remaining vertices in MST
    for (final v in g.vertices) {
      mstNodes.add(v.id);
    }

    steps.add(MstAnimStep(
      type: MstStepType.mstComplete,
      mstNodes: Set.from(mstNodes),
      mstEdges: Set.from(mstEdges),
      rejEdges: Set.from(rejEdges),
      statusMsg:
          '🎯 MST complete! Total weight = $totalWeight. '
          '${mstEdges.length} edges selected.',
      totalWeight: totalWeight,
    ));

    return steps;
  }

  static String _edgeKey(int a, int b) => a < b ? '$a-$b' : '$b-$a';
}