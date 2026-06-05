import 'package:flutter/material.dart';
import '../models/graph_model.dart';

class AdjacencyMatrixView extends StatelessWidget {
  final GraphModel graph;
  final int? highlightRow;
  final int? highlightCol;
  // How many steps have been revealed (controls which cells show values)
  final int revealedUpTo;

  const AdjacencyMatrixView({
    super.key,
    required this.graph,
    this.highlightRow,
    this.highlightCol,
    this.revealedUpTo = 0,
  });

  @override
  Widget build(BuildContext context) {
    final mat = graph.adjacencyMatrix;
    final n = graph.n;
    final cellSize =
        ((MediaQuery.of(context).size.width - 80) / (n + 1)).clamp(30.0, 48.0);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              SizedBox(width: cellSize, height: cellSize),
              ...List.generate(n, (j) => _headerCell(cellSize, '$j')),
            ],
          ),
          // Data rows
          ...List.generate(n, (i) {
            return Row(
              children: [
                _headerCell(cellSize, '$i'),
                ...List.generate(n, (j) {
                  // Linear index in the n×n matrix
                  final linearIdx = i * n + j;
                  // Cell has been reached if revealedUpTo > linearIdx
                  final reached = revealedUpTo > linearIdx;
                  // Currently active (being scanned)
                  final isActive =
                      i == highlightRow && j == highlightCol;
                  final val = mat[i][j];
                  return _dataCell(
                    cellSize,
                    reached || isActive ? val : null, // null = not shown yet
                    isActive,
                    reached && val != 0,
                  );
                }),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _headerCell(double size, String label) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF8B949E),
          fontSize: 12,
          fontWeight: FontWeight.w700,
          fontFamily: 'monospace',
        ),
      ),
    );
  }

  // [displayVal] = null means cell not revealed yet
  Widget _dataCell(double size, int? displayVal, bool isActive, bool isFilled) {
    Color bg;
    Color border;

    if (isActive) {
      // Currently scanned cell → bright green (image 3 style)
      bg = const Color(0xFF22C55E).withOpacity(0.25);
      border = const Color(0xFF22C55E);
    } else if (isFilled && (displayVal ?? 0) != 0) {
      // Already-filled edge cell → blue highlight
      bg = const Color(0xFF1D4ED8).withOpacity(0.25);
      border = const Color(0xFF3B82F6);
    } else if (displayVal != null) {
      // Revealed but zero / no edge
      bg = const Color(0xFF1C2128);
      border = const Color(0xFF30363D);
    } else {
      // Not yet revealed → completely dark
      bg = const Color(0xFF161B22);
      border = const Color(0xFF21262D);
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: border, width: isActive ? 2 : 1),
      ),
      child: Center(
        child: displayVal == null
            ? const SizedBox() // blank until revealed
            : Text(
                '$displayVal',
                style: TextStyle(
                  color: displayVal != 0
                      ? const Color(0xFFE2E8F0)
                      : const Color(0xFF4B5563),
                  fontSize: 12,
                  fontWeight:
                      displayVal != 0 ? FontWeight.w700 : FontWeight.normal,
                  fontFamily: 'monospace',
                ),
              ),
      ),
    );
  }
}