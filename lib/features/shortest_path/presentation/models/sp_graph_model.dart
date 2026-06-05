import 'dart:math';
import 'package:flutter/material.dart';

// ── Graph Properties ──────────────────────────────────────────────────────────
class SpGraphProperties {
  bool weighted;
  bool directed;
  bool connected;

  SpGraphProperties({
    this.weighted = true,
    this.directed = false,
    this.connected = false,
  });

  SpGraphProperties copyWith({bool? weighted, bool? directed, bool? connected}) =>
      SpGraphProperties(
        weighted: weighted ?? this.weighted,
        directed: directed ?? this.directed,
        connected: connected ?? this.connected,
      );
}

// ── Vertex ────────────────────────────────────────────────────────────────────
class SpVertex {
  final int id;
  final String label;
  Offset position;

  SpVertex({required this.id, required this.label, required this.position});
}

// ── Edge ──────────────────────────────────────────────────────────────────────
class SpEdge {
  final int from;
  final int to;
  final int weight;

  SpEdge({required this.from, required this.to, this.weight = 1});
}

// ── Graph Model ───────────────────────────────────────────────────────────────
class SpGraphModel {
  final List<SpVertex> vertices;
  final List<SpEdge> edges;
  final SpGraphProperties properties;

  SpGraphModel({
    required this.vertices,
    required this.edges,
    required this.properties,
  });

  int get n => vertices.length;

  static SpGraphModel random(SpGraphProperties props, Size canvasSize) {
    final rng = Random();
    final count = rng.nextInt(3) + 4; // 4-6 vertices
    final cx = canvasSize.width / 2;
    final cy = canvasSize.height / 2;
    final r = min(canvasSize.width, canvasSize.height) * 0.33;

    final verts = List.generate(count, (i) {
      final angle = (2 * pi * i / count) - pi / 2;
      return SpVertex(
        id: i,
        label: '$i',
        position: Offset(cx + r * cos(angle), cy + r * sin(angle)),
      );
    });

    final edges = <SpEdge>[];
    final used = <String>{};

    void addEdge(int a, int b) {
      final key = props.directed ? '$a->$b' : (a < b ? '$a-$b' : '$b-$a');
      if (used.contains(key)) return;
      used.add(key);
      edges.add(SpEdge(
        from: a,
        to: b,
        weight: rng.nextInt(9) + 1,
      ));
    }

    // Spanning tree for connectivity (always connected for SP to make sense)
    final perm = List.generate(count, (i) => i)..shuffle(rng);
    for (int i = 0; i < count - 1; i++) addEdge(perm[i], perm[i + 1]);

    // Extra edges
    final extra = rng.nextInt(count) + 1;
    for (int k = 0; k < extra; k++) {
      int a = rng.nextInt(count);
      int b = rng.nextInt(count);
      if (a != b) addEdge(a, b);
    }

    return SpGraphModel(vertices: verts, edges: edges, properties: props);
  }
}

// ── Animation Step ────────────────────────────────────────────────────────────
enum SpStepType {
  init,
  visitNode,
  relaxEdge,
  edgeRelaxed,
  edgeSkipped,
  nodeFinalized,
  pathFound,
  noPath,
  iteration,
}

class SpAnimStep {
  final SpStepType type;
  final int? currentNode;
  final int? fromNode;
  final int? toNode;
  final Map<int, int> dist;
  final Map<int, int?> prev;
  final Set<int> visited;
  final Set<int> inPath;
  final Set<String> pathEdges;
  final String statusMsg;
  final int? iteration;

  const SpAnimStep({
    required this.type,
    this.currentNode,
    this.fromNode,
    this.toNode,
    required this.dist,
    required this.prev,
    required this.visited,
    this.inPath = const {},
    this.pathEdges = const {},
    this.statusMsg = '',
    this.iteration,
  });
}

// ── Dijkstra Generator — runs to ALL nodes from src (no destination) ──────────
class DijkstraGenerator {
  static List<SpAnimStep> generate(SpGraphModel g, int src) {
    final steps = <SpAnimStep>[];
    final nodeIds = g.vertices.map((v) => v.id).toSet();
    final dist = <int, int>{};
    final prev = <int, int?>{};
    final visited = <int>{};

    for (final v in nodeIds) {
      dist[v] = v == src ? 0 : 999999;
      prev[v] = null;
    }

    steps.add(SpAnimStep(
      type: SpStepType.init,
      dist: Map.from(dist),
      prev: Map.from(prev),
      visited: {},
      statusMsg:
          'Initialize: dist[$src] = 0, all others = ∞. Source node: $src',
    ));

    // Build adjacency map
    final adj = <int, List<SpEdge>>{};
    for (final v in nodeIds) adj[v] = [];
    for (final e in g.edges) {
      adj[e.from]!.add(e);
      if (!g.properties.directed) {
        adj[e.to]!.add(SpEdge(from: e.to, to: e.from, weight: e.weight));
      }
    }

    while (visited.length < nodeIds.length) {
      // Pick unvisited node with minimum distance
      int? u;
      int minD = 999999 + 1;
      for (final v in nodeIds) {
        if (!visited.contains(v) && dist[v]! < minD) {
          minD = dist[v]!;
          u = v;
        }
      }
      if (u == null) break; // all remaining are unreachable

      visited.add(u);
      steps.add(SpAnimStep(
        type: SpStepType.visitNode,
        currentNode: u,
        dist: Map.from(dist),
        prev: Map.from(prev),
        visited: Set.from(visited),
        statusMsg:
            'Pick node $u — minimum dist = ${dist[u]}. Mark as visited.',
      ));

      for (final e in adj[u]!) {
        final v = e.to;
        if (visited.contains(v)) continue;
        final newDist = dist[u]! + e.weight;

        steps.add(SpAnimStep(
          type: SpStepType.relaxEdge,
          currentNode: u,
          fromNode: u,
          toNode: v,
          dist: Map.from(dist),
          prev: Map.from(prev),
          visited: Set.from(visited),
          statusMsg:
              'Relax ($u→$v) w=${e.weight}: ${dist[u]} + ${e.weight} = $newDist'
              ' vs dist[$v] = ${dist[v] == 999999 ? "∞" : dist[v]}',
        ));

        if (newDist < dist[v]!) {
          dist[v] = newDist;
          prev[v] = u;
          steps.add(SpAnimStep(
            type: SpStepType.edgeRelaxed,
            currentNode: u,
            fromNode: u,
            toNode: v,
            dist: Map.from(dist),
            prev: Map.from(prev),
            visited: Set.from(visited),
            statusMsg: '✓ Update dist[$v] = $newDist  (via $u)',
          ));
        } else {
          steps.add(SpAnimStep(
            type: SpStepType.edgeSkipped,
            currentNode: u,
            fromNode: u,
            toNode: v,
            dist: Map.from(dist),
            prev: Map.from(prev),
            visited: Set.from(visited),
            statusMsg: '✗ No update: $newDist ≥ dist[$v]=${dist[v]}',
          ));
        }
      }

      steps.add(SpAnimStep(
        type: SpStepType.nodeFinalized,
        currentNode: u,
        dist: Map.from(dist),
        prev: Map.from(prev),
        visited: Set.from(visited),
        statusMsg: 'Node $u finalized. Shortest dist[$u] = ${dist[u]}.',
      ));
    }

    // Final step — show all shortest paths from src
    // Build path edges for all reachable nodes
    final allPathEdges = <String>{};
    for (final v in nodeIds) {
      if (v == src || dist[v] == 999999) continue;
      int? cur = v;
      while (cur != null && cur != src) {
        final p = prev[cur];
        if (p != null) allPathEdges.add('$p-$cur');
        cur = p;
      }
    }

    final reachable = nodeIds.where((v) => dist[v]! < 999999).toSet();

    steps.add(SpAnimStep(
      type: SpStepType.pathFound,
      dist: Map.from(dist),
      prev: Map.from(prev),
      visited: Set.from(visited),
      inPath: reachable,
      pathEdges: allPathEdges,
      statusMsg:
          '🎯 Done! Shortest paths from $src to all reachable nodes computed.',
    ));

    return steps;
  }
}

// ── Bellman-Ford Generator — runs for all nodes from src (no destination) ────
class BellmanFordGenerator {
  static List<SpAnimStep> generate(SpGraphModel g, int src) {
    final steps = <SpAnimStep>[];
    final nodeIds = g.vertices.map((v) => v.id).toSet();
    final dist = <int, int>{};
    final prev = <int, int?>{};

    for (final v in nodeIds) {
      dist[v] = v == src ? 0 : 999999;
      prev[v] = null;
    }

    steps.add(SpAnimStep(
      type: SpStepType.init,
      dist: Map.from(dist),
      prev: Map.from(prev),
      visited: {},
      statusMsg:
          'Initialize: dist[$src]=0, all others=∞. '
          'Will run ${nodeIds.length - 1} iterations over all edges.',
    ));

    // Build edge list (both directions if undirected)
    final allEdges = <SpEdge>[];
    for (final e in g.edges) {
      allEdges.add(e);
      if (!g.properties.directed) {
        allEdges.add(SpEdge(from: e.to, to: e.from, weight: e.weight));
      }
    }

    final V = nodeIds.length;
    bool convergedEarly = false;

    for (int iter = 1; iter <= V - 1; iter++) {
      bool anyUpdate = false;

      steps.add(SpAnimStep(
        type: SpStepType.iteration,
        dist: Map.from(dist),
        prev: Map.from(prev),
        visited: {},
        iteration: iter,
        statusMsg: '━━ Iteration $iter / ${V - 1} — relax all edges ━━',
      ));

      for (final e in allEdges) {
        if (dist[e.from]! == 999999) continue;
        final newDist = dist[e.from]! + e.weight;

        steps.add(SpAnimStep(
          type: SpStepType.relaxEdge,
          fromNode: e.from,
          toNode: e.to,
          dist: Map.from(dist),
          prev: Map.from(prev),
          visited: {},
          iteration: iter,
          statusMsg:
              '[I$iter] Edge (${e.from}→${e.to}) w=${e.weight}: '
              '${dist[e.from]} + ${e.weight} = $newDist '
              'vs dist[${e.to}]=${dist[e.to] == 999999 ? "∞" : dist[e.to]}',
        ));

        if (newDist < dist[e.to]!) {
          dist[e.to] = newDist;
          prev[e.to] = e.from;
          anyUpdate = true;
          steps.add(SpAnimStep(
            type: SpStepType.edgeRelaxed,
            fromNode: e.from,
            toNode: e.to,
            dist: Map.from(dist),
            prev: Map.from(prev),
            visited: {},
            iteration: iter,
            statusMsg: '✓ [I$iter] dist[${e.to}] updated = $newDist',
          ));
        } else {
          steps.add(SpAnimStep(
            type: SpStepType.edgeSkipped,
            fromNode: e.from,
            toNode: e.to,
            dist: Map.from(dist),
            prev: Map.from(prev),
            visited: {},
            iteration: iter,
            statusMsg: '✗ [I$iter] No update for dist[${e.to}]',
          ));
        }
      }

      if (!anyUpdate) {
        convergedEarly = true;
        steps.add(SpAnimStep(
          type: SpStepType.nodeFinalized,
          dist: Map.from(dist),
          prev: Map.from(prev),
          visited: {},
          iteration: iter,
          statusMsg:
              '⚡ No updates in iteration $iter — converged early! Stopping.',
        ));
        break;
      }
    }

    // Build all path edges
    final allPathEdges = <String>{};
    for (final v in nodeIds) {
      if (v == src || dist[v] == 999999) continue;
      int? cur = v;
      while (cur != null && cur != src) {
        final p = prev[cur];
        if (p != null) allPathEdges.add('$p-$cur');
        cur = p;
      }
    }

    final reachable = nodeIds.where((v) => dist[v]! < 999999).toSet();

    steps.add(SpAnimStep(
      type: SpStepType.pathFound,
      dist: Map.from(dist),
      prev: Map.from(prev),
      visited: reachable,
      inPath: reachable,
      pathEdges: allPathEdges,
      statusMsg: convergedEarly
          ? '🎯 Done (early convergence)! Shortest distances from $src computed.'
          : '🎯 Done! All ${V - 1} iterations complete. Shortest paths from $src.',
    ));

    return steps;
  }
}