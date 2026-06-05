import 'graph_model.dart';

class GraphAnimGenerator {
  // ── Adjacency Matrix steps ─────────────────────────────────────────────────
  // One step per cell: scan row by row, column by column.
  // Matrix starts blank; each step reveals that cell.
  // Simultaneously highlights the corresponding edge on the graph canvas.
  static List<GraphAnimStep> matrixSteps(GraphModel g) {
    final steps = <GraphAnimStep>[];
    final mat = g.adjacencyMatrix;
    final n = g.n;

    for (int i = 0; i < n; i++) {
      for (int j = 0; j < n; j++) {
        final val = mat[i][j];
        int? eFrom, eTo;
        if (val != 0) {
          eFrom = i;
          eTo = j;
        }

        final isEdge = val != 0;
        final weight = g.properties.weighted;
        String msg;
        if (i == j) {
          msg = 'Is vertex $i adjacent to itself? ${isEdge ? "Yes (loop)" : "No"}  →  [$i][$j] = $val';
        } else if (isEdge) {
          msg = weight
              ? 'Edge ($i → $j) exists with weight $val  →  [$i][$j] = $val'
              : 'Edge ($i → $j) exists  →  [$i][$j] = 1';
        } else {
          msg = 'No edge ($i → $j)  →  [$i][$j] = 0';
        }

        steps.add(GraphAnimStep(
          highlightRow: i,
          highlightCol: j,
          highlightEdgeFrom: eFrom,
          highlightEdgeTo: eTo,
          statusMsg: msg,
        ));
      }
    }
    return steps;
  }

  // ── Adjacency List steps ───────────────────────────────────────────────────
  // For each vertex, add each neighbour one by one.
  // For weighted graphs, show {neighbour, weight} notation.
  static List<GraphAnimStep> listSteps(GraphModel g) {
    final steps = <GraphAnimStep>[];
    final list = g.adjacencyList;
    final weighted = g.properties.weighted;

    // Build weight lookup
    final weightMap = <String, int>{};
    for (final e in g.edges) {
      weightMap['${e.from}-${e.to}'] = e.weight;
      if (!g.properties.directed) weightMap['${e.to}-${e.from}'] = e.weight;
    }

    for (final v in g.vertices) {
      final neighbours = list[v.id] ?? [];
      if (neighbours.isEmpty) {
        steps.add(GraphAnimStep(
          activeVertex: v.id,
          statusMsg: 'Vertex ${v.id}: no neighbours → empty list',
        ));
        continue;
      }
      for (final nb in neighbours) {
        final w = weightMap['${v.id}-$nb'] ?? 1;
        final label = weighted ? '{$nb, $w}' : '$nb';
        steps.add(GraphAnimStep(
          activeVertex: v.id,
          activeNeighbour: nb,
          highlightEdgeFrom: v.id,
          highlightEdgeTo: nb,
          statusMsg: weighted
              ? 'Adding (${v.id}, $nb) edge with weight $w to adjacency list → ${v.id}: $label'
              : 'Vertex ${v.id}: add neighbour $nb to adjacency list',
        ));
      }
    }
    return steps;
  }
}