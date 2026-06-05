import 'package:flutter/material.dart';
import '../models/sort_step.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SortBarCanvas
//
// Renders the array exactly like the videos:
//   • White-bordered square boxes (not bars) with index above, value inside
//   • Currently compared pair: bold border highlight (no fill)
//   • Swapped pair: highlighted differently
//   • Sorted bracket: a curly-bracket line below cells + "Sorted" label
//   • Selection sort "min" pointer: yellow speech-bubble below the min cell
//   • Insertion sort key: blank slot in the array, key value shown below slot
//   • Status message shown below the canvas
//   • For merge/quick sort: colored bar chart maintained (original style)
// ─────────────────────────────────────────────────────────────────────────────

class SortBarCanvas extends StatelessWidget {
  final List<int> array;
  final Set<int> comparing;
  final Set<int> swapping;
  final Set<int> sorted;
  final int? pivot;
  final Set<int> merging;
  final String statusMsg;

  // Selection sort
  final int? minIndex;
  final int? scanIndex;

  // Insertion sort
  final int? keyValue;
  final int? keyIndex;
  final int? emptyIndex;

  // Sorted bracket counts
  final int sortedFromRight; // bubble: how many from right
  final int sortedFromLeft;  // selection/insertion: how many from left

  // Which algorithm is active (controls render style)
  final String algorithm;

  const SortBarCanvas({
    super.key,
    required this.array,
    required this.algorithm,
    this.comparing = const {},
    this.swapping = const {},
    this.sorted = const {},
    this.pivot,
    this.merging = const {},
    this.statusMsg = '',
    this.minIndex,
    this.scanIndex,
    this.keyValue,
    this.keyIndex,
    this.emptyIndex,
    this.sortedFromRight = 0,
    this.sortedFromLeft = 0,
  });

  // ── Box-style algorithms ───────────────────────────────────────────────────
  static const _boxAlgos = {'bubble_sort', 'selection_sort', 'insertion_sort'};

  bool get _isBoxStyle => _boxAlgos.contains(algorithm);

  @override
  Widget build(BuildContext context) {
    if (array.isEmpty) return const SizedBox(height: 200);

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _isBoxStyle ? _buildBoxView(context) : _buildBarView(),
          // Status message
          if (statusMsg.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: statusMsg.contains('sorted') || statusMsg.contains('correct')
                      ? const Color(0xFF22C55E).withOpacity(0.1)
                      : const Color(0xFF3B82F6).withOpacity(0.08),
                  border: Border.all(
                    color: statusMsg.contains('sorted') || statusMsg.contains('correct')
                        ? const Color(0xFF22C55E).withOpacity(0.3)
                        : const Color(0xFF3B82F6).withOpacity(0.2),
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  statusMsg,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: statusMsg.contains('sorted') || statusMsg.contains('correct')
                        ? const Color(0xFF22C55E)
                        : const Color(0xFF93C5FD),
                    fontSize: 12,
                    fontFamily: 'monospace',
                    height: 1.4,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── BOX VIEW (bubble / selection / insertion) ──────────────────────────────
  Widget _buildBoxView(BuildContext context) {
    final n = array.length;
    // Compute cell width responsively
    final screenW = MediaQuery.of(context).size.width - 24;
    final cellW = (screenW / n).clamp(30.0, 56.0);

    // Extra height for: index row + cell + bracket area + key below
    const indexH = 20.0;
    const cellH = 52.0;
    const bracketAreaH = 36.0; // bracket + "Sorted" label
    const keyAreaH = 28.0;     // key value shown below slot (insertion)
    const minAreaH = 28.0;     // min pointer (selection)

    final totalH = indexH + cellH +
        (sortedFromLeft > 0 || sortedFromRight > 0 ? bracketAreaH : 0) +
        (keyValue != null ? keyAreaH : 0) +
        (minIndex != null ? minAreaH : 0);

    return SizedBox(
      height: totalH.clamp(90.0, 220.0),
      child: Stack(
        children: [
          Column(
            children: [
              // Index labels row
              Row(
                children: List.generate(n, (i) {
                  return SizedBox(
                    width: cellW,
                    child: Text(
                      '$i',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFF8B949E),
                        fontSize: 11,
                        fontFamily: 'monospace',
                      ),
                    ),
                  );
                }),
              ),

              // Cell row
              Row(
                children: List.generate(n, (i) => _buildCell(i, cellW, cellH)),
              ),

              // Sorted bracket
              if (sortedFromRight > 0 || sortedFromLeft > 0)
                _buildSortedBracket(n, cellW),

              // Key value below empty slot (insertion sort)
              if (keyValue != null && keyIndex != null)
                _buildKeyLabel(n, cellW),

              // Min pointer (selection sort)
              if (minIndex != null)
                _buildMinPointer(n, cellW),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCell(int i, double cellW, double cellH) {
    final isEmpty = emptyIndex == i;
    final isComparing = comparing.contains(i);
    final isSwapping = swapping.contains(i);
    final isMin = minIndex == i && !isSwapping;
    final isSortedCell = sorted.contains(i);
    final inSortedLeft = sortedFromLeft > 0 && i < sortedFromLeft;
    final inSortedRight = sortedFromRight > 0 && i >= array.length - sortedFromRight;

    Color borderColor;
    double borderWidth;
    Color textColor = const Color(0xFFE2E8F0);
    Color bgColor = Colors.transparent;

    if (isEmpty) {
      // Blank slot — thin dashed-style border
      borderColor = const Color(0xFF4B5563);
      borderWidth = 1;
      textColor = Colors.transparent;
    } else if (isSwapping) {
      borderColor = const Color(0xFFF59E0B);
      borderWidth = 2.5;
      bgColor = const Color(0xFFF59E0B).withOpacity(0.12);
    } else if (isComparing) {
      borderColor = const Color(0xFF3B82F6);
      borderWidth = 2.5;
      bgColor = const Color(0xFF3B82F6).withOpacity(0.1);
    } else if (isMin) {
      borderColor = const Color(0xFFF59E0B);
      borderWidth = 2.5;
      bgColor = const Color(0xFFF59E0B).withOpacity(0.1);
    } else if (isSortedCell || inSortedLeft || inSortedRight) {
      borderColor = const Color(0xFF6B7280);
      borderWidth = 1;
      textColor = const Color(0xFF9CA3AF);
    } else {
      borderColor = const Color(0xFFE2E8F0);
      borderWidth = 1.5;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: cellW,
      height: cellH,
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: borderColor, width: borderWidth),
      ),
      child: Center(
        child: isEmpty
            ? const SizedBox()
            : Text(
                '${array[i]}',
                style: TextStyle(
                  color: textColor,
                  fontSize: cellW > 44 ? 15 : 12,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'monospace',
                ),
              ),
      ),
    );
  }

  // Sorted bracket line + "Sorted" label matching the video
  Widget _buildSortedBracket(int n, double cellW) {
    String bracketLabel = 'Sorted';
    int startIdx, endIdx;

    if (sortedFromLeft > 0 && sortedFromLeft <= n) {
      startIdx = 0;
      endIdx = sortedFromLeft - 1;
    } else if (sortedFromRight > 0 && sortedFromRight <= n) {
      startIdx = n - sortedFromRight;
      endIdx = n - 1;
    } else {
      return const SizedBox(height: 36);
    }

    final bracketW = (endIdx - startIdx + 1) * cellW;
    final leftOffset = startIdx * cellW;

    return SizedBox(
      height: 36,
      child: Stack(
        children: [
          Positioned(
            left: leftOffset,
            top: 4,
            width: bracketW,
            child: CustomPaint(
              size: Size(bracketW, 16),
              painter: _BracketPainter(color: const Color(0xFF8B949E)),
            ),
          ),
          Positioned(
            left: leftOffset + bracketW / 2 - 24,
            top: 18,
            child: Text(
              bracketLabel,
              style: const TextStyle(
                color: Color(0xFF8B949E),
                fontSize: 11,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Key value shown below the empty slot (insertion sort)
  Widget _buildKeyLabel(int n, double cellW) {
    if (keyIndex == null) return const SizedBox(height: 28);
    final leftOffset = keyIndex! * cellW + cellW / 2 - 10;

    return SizedBox(
      height: 28,
      child: Stack(
        children: [
          Positioned(
            left: leftOffset.clamp(0.0, double.infinity),
            top: 4,
            child: Text(
              '$keyValue',
              style: const TextStyle(
                color: Color(0xFFE2E8F0),
                fontSize: 14,
                fontWeight: FontWeight.w700,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }

  // "min" speech-bubble pointer below the min cell (selection sort)
  Widget _buildMinPointer(int n, double cellW) {
    if (minIndex == null) return const SizedBox(height: 28);
    final leftOffset = minIndex! * cellW;

    return SizedBox(
      height: 28,
      child: Stack(
        children: [
          Positioned(
            left: leftOffset + cellW / 2 - 16,
            top: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'min',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── BAR VIEW (merge / quick sort — original bar chart style) ──────────────
  Color _barColor(int index) {
    if (swapping.contains(index)) return const Color(0xFFF59E0B);
    if (pivot == index) return const Color(0xFFF97316);
    if (comparing.contains(index)) return const Color(0xFFA78BFA);
    if (merging.contains(index)) return const Color(0xFF22D3EE);
    if (sorted.contains(index)) return const Color(0xFF22C55E);
    return const Color(0xFF60A5FA);
  }

  Widget _buildBarView() {
    final maxVal = array.reduce((a, b) => a > b ? a : b).toDouble();
    const chartH = 160.0;

    return SizedBox(
      height: chartH + 24,
      child: Column(
        children: [
          Expanded(
            child: LayoutBuilder(builder: (_, constraints) {
              final barW = (constraints.maxWidth / array.length) - 4;
              return Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(array.length, (i) {
                  final h = ((array[i] / maxVal) * chartH).clamp(8.0, chartH);
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: barW.clamp(8.0, 60.0),
                      height: h,
                      decoration: BoxDecoration(
                        color: _barColor(i),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(4),
                          topRight: Radius.circular(4),
                        ),
                      ),
                    ),
                  );
                }),
              );
            }),
          ),
          const SizedBox(height: 4),
          LayoutBuilder(builder: (_, constraints) {
            final itemW = constraints.maxWidth / array.length;
            return Row(
              children: List.generate(array.length, (i) {
                return SizedBox(
                  width: itemW,
                  child: Text(
                    '${array[i]}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _barColor(i).withOpacity(0.9),
                      fontSize: array.length > 8 ? 9 : 11,
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }),
            );
          }),
        ],
      ),
    );
  }
}

// ── Custom painter for the "Sorted" bracket ────────────────────────────────
class _BracketPainter extends CustomPainter {
  final Color color;
  _BracketPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    // Left vertical tick
    canvas.drawLine(Offset(0, 0), Offset(0, size.height), paint);
    // Right vertical tick
    canvas.drawLine(
        Offset(size.width, 0), Offset(size.width, size.height), paint);
    // Horizontal line connecting them
    canvas.drawLine(
        Offset(0, size.height), Offset(size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(_BracketPainter old) => old.color != color;
}