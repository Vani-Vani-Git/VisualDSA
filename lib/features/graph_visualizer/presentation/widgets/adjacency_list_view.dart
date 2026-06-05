import 'package:flutter/material.dart';
import '../models/graph_model.dart';

class AdjacencyListView extends StatelessWidget {
  final GraphModel graph;
  final int? activeVertex;
  final int? activeNeighbour;
  // How many anim steps have been played
  final int revealedStepIndex;

  const AdjacencyListView({
    super.key,
    required this.graph,
    this.activeVertex,
    this.activeNeighbour,
    this.revealedStepIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    final adjList = graph.adjacencyList;
    final weighted = graph.properties.weighted;

    // Build weighted edge map: from -> List<{to, weight}>
    final weightMap = <int, Map<int, int>>{};
    for (final e in graph.edges) {
      weightMap.putIfAbsent(e.from, () => {})[e.to] = e.weight;
      if (!graph.properties.directed) {
        weightMap.putIfAbsent(e.to, () => {})[e.from] = e.weight;
      }
    }

    // Rows visible: all up to and including activeVertex
    final visibleVertices = activeVertex == null
        ? <GraphVertex>[]
        : graph.vertices
            .where((v) => v.id <= activeVertex!)
            .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Weighted graph: show edge table (u v w) like the video
        if (weighted && graph.edges.isNotEmpty)
          _buildEdgeTable(context),
        if (weighted && graph.edges.isNotEmpty) const SizedBox(height: 10),

        // Vertex rows
        ...visibleVertices.map((v) {
          final isActive = v.id == activeVertex;
          final allNeighbours = adjList[v.id] ?? [];

          List<int> visibleNeighbours;
          if (v.id < (activeVertex ?? -1)) {
            visibleNeighbours = allNeighbours;
          } else if (isActive) {
            if (activeNeighbour == null) {
              visibleNeighbours = [];
            } else {
              final idx = allNeighbours.indexOf(activeNeighbour!);
              visibleNeighbours =
                  idx >= 0 ? allNeighbours.sublist(0, idx + 1) : allNeighbours;
            }
          } else {
            visibleNeighbours = [];
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _indexCell(v.id, isActive),
                if (visibleNeighbours.isNotEmpty || isActive)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    child: Text('→',
                        style: TextStyle(
                            color: Color(0xFF8B949E),
                            fontSize: 14,
                            fontFamily: 'monospace')),
                  ),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: visibleNeighbours.map((nb) {
                        final isNew = isActive && nb == activeNeighbour;
                        final w = weightMap[v.id]?[nb];
                        return _neighbourCell(nb, w, isNew, weighted);
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  // Edge table shown for weighted graphs (u | v | w columns)
  Widget _buildEdgeTable(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        border: Border.all(color: const Color(0xFF30363D)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // Header
          _tableRow('u', 'v', 'w', isHeader: true),
          ...graph.edges.map((e) {
            final isCurrentEdge = activeVertex != null &&
                e.from == activeVertex &&
                (activeNeighbour == null || e.to == activeNeighbour);
            return _tableRow(
              '${e.from}',
              '${e.to}',
              '${e.weight}',
              highlight: isCurrentEdge,
            );
          }),
        ],
      ),
    );
  }

  Widget _tableRow(String u, String v, String w,
      {bool isHeader = false, bool highlight = false}) {
    final textColor = isHeader
        ? const Color(0xFF8B949E)
        : highlight
            ? const Color(0xFF22C55E)
            : const Color(0xFFE2E8F0);
    final bg = highlight
        ? const Color(0xFF22C55E).withOpacity(0.12)
        : Colors.transparent;

    return Container(
      color: bg,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 36,
            child: Text(u,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: textColor,
                    fontSize: 12,
                    fontWeight:
                        isHeader ? FontWeight.w700 : FontWeight.normal,
                    fontFamily: 'monospace')),
          ),
          SizedBox(
            width: 36,
            child: Text(v,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: textColor,
                    fontSize: 12,
                    fontWeight:
                        isHeader ? FontWeight.w700 : FontWeight.normal,
                    fontFamily: 'monospace')),
          ),
          SizedBox(
            width: 36,
            child: Text(w,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: textColor,
                    fontSize: 12,
                    fontWeight:
                        isHeader ? FontWeight.w700 : FontWeight.normal,
                    fontFamily: 'monospace')),
          ),
        ],
      ),
    );
  }

  Widget _indexCell(int id, bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 42,
      height: 34,
      decoration: BoxDecoration(
        color: isActive
            ? const Color(0xFF22C55E).withOpacity(0.2)
            : const Color(0xFF9333EA).withOpacity(0.18),
        border: Border.all(
          color: isActive
              ? const Color(0xFF22C55E)
              : const Color(0xFF9333EA).withOpacity(0.5),
          width: isActive ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Center(
        child: Text(
          '$id',
          style: TextStyle(
            color: isActive
                ? const Color(0xFF22C55E)
                : const Color(0xFFE2E8F0),
            fontSize: 13,
            fontWeight: FontWeight.w700,
            fontFamily: 'monospace',
          ),
        ),
      ),
    );
  }

  // For non-weighted: plain number box
  // For weighted: {neighbour, weight} box matching the video
  Widget _neighbourCell(int nb, int? weight, bool isNew, bool weighted) {
    final label = weighted && weight != null ? '{$nb,$weight}' : '$nb';
    final cellW = weighted ? 60.0 : 42.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.only(right: 4),
      width: cellW,
      height: 34,
      decoration: BoxDecoration(
        color: isNew
            ? const Color(0xFF22C55E).withOpacity(0.22)
            : const Color(0xFF9333EA).withOpacity(0.12),
        border: Border.all(
          color: isNew
              ? const Color(0xFF22C55E)
              : const Color(0xFF9333EA).withOpacity(0.4),
          width: isNew ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            color: isNew
                ? const Color(0xFF22C55E)
                : const Color(0xFFE2E8F0),
            fontSize: weighted ? 10 : 13,
            fontWeight: FontWeight.w600,
            fontFamily: 'monospace',
          ),
        ),
      ),
    );
  }
}