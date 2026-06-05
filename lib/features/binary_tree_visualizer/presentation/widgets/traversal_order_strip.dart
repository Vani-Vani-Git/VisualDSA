import 'package:flutter/material.dart';

class TraversalOrderStrip extends StatelessWidget {
  final List<int> visitedOrder;
  final String operation;

  const TraversalOrderStrip({
    super.key,
    required this.visitedOrder,
    required this.operation,
  });

  static const _opColors = {
    'inorder': Color(0xFF3B82F6),
    'preorder': Color(0xFFA78BFA),
    'postorder': Color(0xFFF59E0B),
    'insert': Color(0xFF22C55E),
    'delete': Color(0xFFEF4444),
  };

  @override
  Widget build(BuildContext context) {
    if (visitedOrder.isEmpty) return const SizedBox.shrink();

    final color = _opColors[operation] ?? const Color(0xFF3B82F6);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        border: Border.all(color: color.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _label(),
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: 6),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: visitedOrder.asMap().entries.map((e) {
                final isLast = e.key == visitedOrder.length - 1;
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isLast
                            ? color.withOpacity(0.25)
                            : color.withOpacity(0.08),
                        border: Border.all(
                            color: isLast
                                ? color
                                : color.withOpacity(0.3),
                            width: isLast ? 1.5 : 1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${e.value}',
                        style: TextStyle(
                          color: isLast ? Colors.white : color,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                    if (!isLast)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Icon(Icons.arrow_forward,
                            color: color.withOpacity(0.5), size: 12),
                      ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  String _label() {
    switch (operation) {
      case 'inorder':
        return 'Inorder (L→Root→R):';
      case 'preorder':
        return 'Preorder (Root→L→R):';
      case 'postorder':
        return 'Postorder (L→R→Root):';
      case 'insert':
        return 'Inserted:';
      case 'delete':
        return 'Path visited:';
      default:
        return 'Order:';
    }
  }
}