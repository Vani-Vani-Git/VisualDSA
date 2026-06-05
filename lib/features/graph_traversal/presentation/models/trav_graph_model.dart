import 'dart:math';
import 'package:flutter/material.dart';

// ── Graph Properties ──────────────────────────────────────────────────────────
class TravGraphProperties {
  bool directed;
  bool connected;

  TravGraphProperties({this.directed = false, this.connected = false});

  TravGraphProperties copyWith({bool? directed, bool? connected}) =>
      TravGraphProperties(
        directed: directed ?? this.directed,
        connected: connected ?? this.connected,
      );
}

// ── Vertex / Edge ─────────────────────────────────────────────────────────────
class TravVertex {
  final int id;
  final String label;
  Offset position;
  TravVertex({required this.id, required this.label, required this.position});
}

class TravEdge {
  final int from;
  final int to;
  TravEdge({required this.from, required this.to});
}

// ── Graph Model ───────────────────────────────────────────────────────────────
class TravGraphModel {
  final List<TravVertex> vertices;
  final List<TravEdge> edges;
  final TravGraphProperties properties;

  TravGraphModel({
    required this.vertices,
    required this.edges,
    required this.properties,
  });

  int get n => vertices.length;

  static TravGraphModel random(TravGraphProperties props, Size canvasSize) {
    final rng = Random();
    final count = rng.nextInt(3) + 5;
    final cx = canvasSize.width / 2;
    final cy = canvasSize.height / 2;
    final r = min(canvasSize.width, canvasSize.height) * 0.33;

    final verts = List.generate(count, (i) {
      final angle = (2 * pi * i / count) - pi / 2;
      return TravVertex(
        id: i,
        label: '$i',
        position: Offset(cx + r * cos(angle), cy + r * sin(angle)),
      );
    });

    final edges = <TravEdge>[];
    final used = <String>{};

    void addEdge(int a, int b) {
      final key =
          props.directed ? '$a->$b' : (a < b ? '$a-$b' : '$b-$a');
      if (used.contains(key)) return;
      used.add(key);
      edges.add(TravEdge(from: a, to: b));
    }

    final perm = List.generate(count, (i) => i)..shuffle(rng);
    for (int i = 0; i < count - 1; i++) addEdge(perm[i], perm[i + 1]);

    final extra = rng.nextInt(count);
    for (int k = 0; k < extra; k++) {
      final a = rng.nextInt(count);
      final b = rng.nextInt(count);
      if (a != b) addEdge(a, b);
    }

    return TravGraphModel(vertices: verts, edges: edges, properties: props);
  }
}

// ── Animation Step ────────────────────────────────────────────────────────────
enum TravStepType {
  init,
  enqueue,
  dequeue,
  visitNode,
  exploreEdge,
  edgeTree,
  edgeCross,
  done,
}

class TravAnimStep {
  final TravStepType type;
  final int? currentNode;
  final int? fromNode;
  final int? toNode;
  final List<int> queue;
  final Set<int> visited;
  final Set<int> inQueue;
  final Set<String> treeEdges;
  final Set<String> crossEdges;
  final List<int> visitOrder;
  final String statusMsg;

  const TravAnimStep({
    required this.type,
    this.currentNode,
    this.fromNode,
    this.toNode,
    required this.queue,
    required this.visited,
    required this.inQueue,
    required this.treeEdges,
    this.crossEdges = const {},
    required this.visitOrder,
    this.statusMsg = '',
  });
}

// ── BFS Generator ─────────────────────────────────────────────────────────────
class BfsGenerator {
  static List<TravAnimStep> generate(TravGraphModel g, int src) {
    final steps = <TravAnimStep>[];
    final adj = <int, List<int>>{};
    for (final v in g.vertices) adj[v.id] = [];
    for (final e in g.edges) {
      adj[e.from]!.add(e.to);
      if (!g.properties.directed) adj[e.to]!.add(e.from);
    }
    for (final k in adj.keys) adj[k]!.sort();

    final visited = <int>{};
    final inQueue = <int>{};
    final treeEdges = <String>{};
    final crossEdges = <String>{};
    final visitOrder = <int>[];
    final queue = <int>[];

    queue.add(src);
    inQueue.add(src);

    steps.add(TravAnimStep(
      type: TravStepType.init,
      currentNode: src,
      queue: List.from(queue),
      visited: {},
      inQueue: Set.from(inQueue),
      treeEdges: {},
      visitOrder: [],
      statusMsg: 'BFS: Initialize. Enqueue source node $src. Queue = [$src]',
    ));

    while (queue.isNotEmpty) {
      final u = queue.removeAt(0);
      inQueue.remove(u);
      visited.add(u);
      visitOrder.add(u);

      steps.add(TravAnimStep(
        type: TravStepType.visitNode,
        currentNode: u,
        queue: List.from(queue),
        visited: Set.from(visited),
        inQueue: Set.from(inQueue),
        treeEdges: Set.from(treeEdges),
        crossEdges: Set.from(crossEdges),
        visitOrder: List.from(visitOrder),
        statusMsg:
            'Dequeue $u → mark visited. Order: ${visitOrder.join(' → ')}',
      ));

      for (final v in (adj[u] ?? [])) {
        final key = _ek(u, v, g.properties.directed);
        steps.add(TravAnimStep(
          type: TravStepType.exploreEdge,
          currentNode: u,
          fromNode: u,
          toNode: v,
          queue: List.from(queue),
          visited: Set.from(visited),
          inQueue: Set.from(inQueue),
          treeEdges: Set.from(treeEdges),
          crossEdges: Set.from(crossEdges),
          visitOrder: List.from(visitOrder),
          statusMsg: 'Check edge ($u→$v): '
              '${visited.contains(v) ? "visited — skip." : inQueue.contains(v) ? "in queue — skip." : "new → enqueue!"}',
        ));

        if (!visited.contains(v) && !inQueue.contains(v)) {
          queue.add(v);
          inQueue.add(v);
          treeEdges.add(key);
          steps.add(TravAnimStep(
            type: TravStepType.enqueue,
            currentNode: u,
            fromNode: u,
            toNode: v,
            queue: List.from(queue),
            visited: Set.from(visited),
            inQueue: Set.from(inQueue),
            treeEdges: Set.from(treeEdges),
            crossEdges: Set.from(crossEdges),
            visitOrder: List.from(visitOrder),
            statusMsg:
                '✓ Enqueue $v. Queue = [${queue.join(', ')}]',
          ));
        } else if (visited.contains(v)) {
          crossEdges.add(key);
          steps.add(TravAnimStep(
            type: TravStepType.edgeCross,
            currentNode: u,
            fromNode: u,
            toNode: v,
            queue: List.from(queue),
            visited: Set.from(visited),
            inQueue: Set.from(inQueue),
            treeEdges: Set.from(treeEdges),
            crossEdges: Set.from(crossEdges),
            visitOrder: List.from(visitOrder),
            statusMsg: '✗ Cross edge ($u→$v) — $v already visited.',
          ));
        }
      }
    }

    steps.add(TravAnimStep(
      type: TravStepType.done,
      queue: [],
      visited: Set.from(visited),
      inQueue: {},
      treeEdges: Set.from(treeEdges),
      crossEdges: Set.from(crossEdges),
      visitOrder: List.from(visitOrder),
      statusMsg: '🎯 BFS complete! Order: ${visitOrder.join(' → ')}',
    ));
    return steps;
  }

  static String _ek(int a, int b, bool d) =>
      d ? '$a->$b' : (a < b ? '$a-$b' : '$b-$a');
}

// ── DFS Generator ─────────────────────────────────────────────────────────────
class DfsGenerator {
  static List<TravAnimStep> generate(TravGraphModel g, int src) {
    final steps = <TravAnimStep>[];
    final adj = <int, List<int>>{};
    for (final v in g.vertices) adj[v.id] = [];
    for (final e in g.edges) {
      adj[e.from]!.add(e.to);
      if (!g.properties.directed) adj[e.to]!.add(e.from);
    }
    for (final k in adj.keys) adj[k]!.sort();

    final visited = <int>{};
    final inStack = <int>{};
    final treeEdges = <String>{};
    final crossEdges = <String>{};
    final visitOrder = <int>[];
    final stack = <int>[];

    stack.add(src);
    inStack.add(src);

    steps.add(TravAnimStep(
      type: TravStepType.init,
      currentNode: src,
      queue: List.from(stack),
      visited: {},
      inQueue: Set.from(inStack),
      treeEdges: {},
      visitOrder: [],
      statusMsg: 'DFS: Push source $src to stack. Stack = [$src]',
    ));

    while (stack.isNotEmpty) {
      final u = stack.removeLast();
      inStack.remove(u);
      if (visited.contains(u)) continue;

      visited.add(u);
      visitOrder.add(u);

      steps.add(TravAnimStep(
        type: TravStepType.visitNode,
        currentNode: u,
        queue: List.from(stack),
        visited: Set.from(visited),
        inQueue: Set.from(inStack),
        treeEdges: Set.from(treeEdges),
        crossEdges: Set.from(crossEdges),
        visitOrder: List.from(visitOrder),
        statusMsg:
            'Pop $u from stack → visit. Order: ${visitOrder.join(' → ')}',
      ));

      final neighbours = List<int>.from(adj[u] ?? [])..sort();
      for (final v in neighbours.reversed) {
        final key = _ek(u, v, g.properties.directed);
        steps.add(TravAnimStep(
          type: TravStepType.exploreEdge,
          currentNode: u,
          fromNode: u,
          toNode: v,
          queue: List.from(stack),
          visited: Set.from(visited),
          inQueue: Set.from(inStack),
          treeEdges: Set.from(treeEdges),
          crossEdges: Set.from(crossEdges),
          visitOrder: List.from(visitOrder),
          statusMsg: 'Edge ($u→$v): '
              '${visited.contains(v) ? "visited — back edge." : "unvisited — push to stack."}',
        ));

        if (!visited.contains(v)) {
          stack.add(v);
          inStack.add(v);
          treeEdges.add(key);
          steps.add(TravAnimStep(
            type: TravStepType.enqueue,
            currentNode: u,
            fromNode: u,
            toNode: v,
            queue: List.from(stack),
            visited: Set.from(visited),
            inQueue: Set.from(inStack),
            treeEdges: Set.from(treeEdges),
            crossEdges: Set.from(crossEdges),
            visitOrder: List.from(visitOrder),
            statusMsg:
                '✓ Push $v. Stack top = ${stack.isNotEmpty ? stack.last : "-"}',
          ));
        } else {
          crossEdges.add(key);
          steps.add(TravAnimStep(
            type: TravStepType.edgeCross,
            currentNode: u,
            fromNode: u,
            toNode: v,
            queue: List.from(stack),
            visited: Set.from(visited),
            inQueue: Set.from(inStack),
            treeEdges: Set.from(treeEdges),
            crossEdges: Set.from(crossEdges),
            visitOrder: List.from(visitOrder),
            statusMsg: '✗ Back edge ($u→$v) — $v already visited.',
          ));
        }
      }
    }

    steps.add(TravAnimStep(
      type: TravStepType.done,
      queue: [],
      visited: Set.from(visited),
      inQueue: {},
      treeEdges: Set.from(treeEdges),
      crossEdges: Set.from(crossEdges),
      visitOrder: List.from(visitOrder),
      statusMsg: '🎯 DFS complete! Order: ${visitOrder.join(' → ')}',
    ));
    return steps;
  }

  static String _ek(int a, int b, bool d) =>
      d ? '$a->$b' : (a < b ? '$a-$b' : '$b-$a');
}