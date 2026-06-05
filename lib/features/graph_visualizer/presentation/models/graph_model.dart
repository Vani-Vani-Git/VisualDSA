import 'dart:math';
import 'package:flutter/material.dart';

// ── Graph properties ──────────────────────────────────────────────────────────
class GraphProperties {
  bool weighted;
  bool connected;
  bool directed;
  bool cyclic;
  bool loop;

  GraphProperties({
    this.weighted = false,
    this.connected = false,
    this.directed = false,
    this.cyclic = false,
    this.loop = false,
  });

  GraphProperties copyWith({
    bool? weighted,
    bool? connected,
    bool? directed,
    bool? cyclic,
    bool? loop,
  }) =>
      GraphProperties(
        weighted: weighted ?? this.weighted,
        connected: connected ?? this.connected,
        directed: directed ?? this.directed,
        cyclic: cyclic ?? this.cyclic,
        loop: loop ?? this.loop,
      );
}

// ── Graph vertex ──────────────────────────────────────────────────────────────
class GraphVertex {
  final int id;
  final String label;
  Offset position;

  GraphVertex({required this.id, required this.label, required this.position});
}

// ── Graph edge ────────────────────────────────────────────────────────────────
class GraphEdge {
  final int from;
  final int to;
  final int weight;
  bool isLoop;

  GraphEdge({
    required this.from,
    required this.to,
    this.weight = 1,
    this.isLoop = false,
  });
}

// ── Graph model ───────────────────────────────────────────────────────────────
class GraphModel {
  final List<GraphVertex> vertices;
  final List<GraphEdge> edges;
  final GraphProperties properties;
  final Map<int, Map<int, int>> weights;
  GraphModel({
    required this.vertices,
    required this.edges,
    required this.properties,
    required this.weights,
  });

  int get n => vertices.length;

  // Adjacency matrix  n×n
  List<List<int>> get adjacencyMatrix {
    final mat = List.generate(n, (_) => List.filled(n, 0));
    for (final e in edges) {
      if (e.isLoop) {
        mat[e.from][e.from] = e.weight;
      } else {
        mat[e.from][e.to] = e.weight;
        if (!properties.directed) mat[e.to][e.from] = e.weight;
      }
    }
    return mat;
  }

  // Adjacency list: vertex id → list of neighbour ids
  Map<int, List<int>> get adjacencyList {
    final map = <int, List<int>>{};
    for (final v in vertices) map[v.id] = [];
    for (final e in edges) {
      if (e.isLoop) {
        map[e.from]!.add(e.from);
      } else {
        map[e.from]!.add(e.to);
        if (!properties.directed) map[e.to]!.add(e.from);
      }
    }
    return map;
  }

  // Build a random graph obeying current properties
  static GraphModel random(GraphProperties props, Size canvasSize) {
    final rng = Random();
    final count = rng.nextInt(4) + 4; // 4-7 vertices
    final labels = List.generate(count, (i) => '$i');

    // Place vertices in a circle
    final cx = canvasSize.width / 2;
    final cy = canvasSize.height / 2;
    final r = min(canvasSize.width, canvasSize.height) * 0.36;

    final verts = List.generate(count, (i) {
      final angle = (2 * pi * i / count) - pi / 2;
      return GraphVertex(
        id: i,
        label: labels[i],
        position: Offset(cx + r * cos(angle), cy + r * sin(angle)),
      );
    });

    final edges = <GraphEdge>[];
    final used = <String>{};

    void addEdge(int a, int b) {
      final key = props.directed ? '$a->$b' : (a < b ? '$a-$b' : '$b-$a');
      if (used.contains(key)) return;
      used.add(key);
      edges.add(GraphEdge(
        from: a,
        to: b,
        weight: props.weighted ? rng.nextInt(8) + 1 : 1,
      ));
    }

    // Ensure connected: span-tree chain
    if (props.connected) {
      final perm = List.generate(count, (i) => i)..shuffle(rng);
      for (int i = 0; i < count - 1; i++) addEdge(perm[i], perm[i + 1]);
    }

    // Add extra random edges
    final extra = rng.nextInt(count) + 1;
    for (int k = 0; k < extra; k++) {
      int a = rng.nextInt(count);
      int b = rng.nextInt(count);
      if (a == b) continue;
      addEdge(a, b);
    }

    // Cyclic: ensure at least one back-edge if directed
    if (props.cyclic && props.directed && edges.isNotEmpty) {
      final last = edges.last;
      addEdge(last.to, last.from);
    }
    // Loop: add self-loop on vertex 0
    if (props.loop) {
      edges.add(GraphEdge(
        from: 0,
        to: 0,
        weight: props.weighted ? rng.nextInt(8) + 1 : 1,
        isLoop: true,
      ));
    }

    return GraphModel(vertices: verts, edges: edges, properties: props, weights: <int,Map<int,int>>{},);
  }

  // Build from user input
  static GraphModel fromInput({
    required List<int> vertexIds,
    required Map<int, List<int>> adjacencies,
    required GraphProperties props,
    required Size canvasSize,
    Map<int, Map<int, int>>? weights,
  }) {
    final rng = Random();
    final count = vertexIds.length;
    final cx = canvasSize.width / 2;
    final cy = canvasSize.height / 2;
    final r = min(canvasSize.width, canvasSize.height) * 0.36;

    final verts = List.generate(count, (i) {
      final angle = (2 * pi * i / count) - pi / 2;
      return GraphVertex(
        id: vertexIds[i],
        label: '${vertexIds[i]}',
        position: Offset(cx + r * cos(angle), cy + r * sin(angle)),
      );
    });

    final edges = <GraphEdge>[];
    final used = <String>{};
    for (final entry in adjacencies.entries) {
      for (final nb in entry.value) {
        final key = props.directed
            ? '${entry.key}->$nb'
            : (entry.key < nb ? '${entry.key}-$nb' : '$nb-${entry.key}');
        if (used.contains(key)) continue;
        used.add(key);
        edges.add(GraphEdge(
          from: entry.key,
          to: nb,
          weight: props.weighted ? rng.nextInt(8) + 1 : 1,
        ));
      }
    }
    return GraphModel(vertices: verts, edges: edges, properties: props, weights: weights ?? <int,Map<int,int>>{},);
  }
}

// ── Animation step for matrix/list ───────────────────────────────────────────
class GraphAnimStep {
  final int? highlightRow;    // matrix: row being processed
  final int? highlightCol;    // matrix: col being set
  final int? activeVertex;    // list: vertex whose row is expanding
  final int? activeNeighbour; // list: neighbour being appended
  final int? highlightEdgeFrom;
  final int? highlightEdgeTo;
  final String statusMsg;

  const GraphAnimStep({
    this.highlightRow,
    this.highlightCol,
    this.activeVertex,
    this.activeNeighbour,
    this.highlightEdgeFrom,
    this.highlightEdgeTo,
    this.statusMsg = '',
  });
}