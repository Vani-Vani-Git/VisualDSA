import 'dart:math';
import 'package:flutter/material.dart';
// Relative import — adjust the number of '../' to match your folder depth
// bst_input_section.dart lives in:
//   features/bst_visualizer/presentation/widgets/
// tree_draw_canvas.dart lives in:
//   features/binary_tree_visualizer/presentation/widgets/
import '../../../binary_tree_visualizer/presentation/widgets/tree_draw_canvas.dart';

class BSTInputSection extends StatefulWidget {
  final String initialValue;
  final void Function(List<int> values) onArrayChanged;

  const BSTInputSection({
    super.key,
    required this.initialValue,
    required this.onArrayChanged,
  });

  @override
  State<BSTInputSection> createState() => _BSTInputSectionState();
}

class _BSTInputSectionState extends State<BSTInputSection> {
  late TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _apply() {
    final nums = _ctrl.text
        .split(',')
        .map((s) => int.tryParse(s.trim()))
        .whereType<int>()
        .where((n) => n > 0 && n <= 999)
        .toList();
    if (nums.isNotEmpty) widget.onArrayChanged(nums);
  }

  void _random() {
    final rng = Random();
    final len = rng.nextInt(4) + 5;
    final set = <int>{};
    while (set.length < len) set.add(rng.nextInt(90) + 5);
    final list = set.toList();
    _ctrl.text = list.join(',');
    widget.onArrayChanged(list);
  }

  void _openDraw() {

  Navigator.of(context).push(

    MaterialPageRoute(

      fullscreenDialog: true,

      builder: (_) => TreeDrawCanvas(

        onConfirm:
            (root, levelOrder) {

          if (levelOrder.isEmpty) {
            return;
          }

          _ctrl.text =
              levelOrder.join(',');

          widget.onArrayChanged(
              levelOrder);

          ScaffoldMessenger.of(context)
              .showSnackBar(

            SnackBar(

              content: Text(

                '✅ Drawn tree applied as BST! '
                'Nodes: ${levelOrder.join(', ')}',

                style: const TextStyle(

                  fontFamily:
                      'monospace',

                  fontSize: 12,
                ),
              ),

              backgroundColor:
                  const Color(
                      0xFF1C2128),

              duration:
                  const Duration(
                      seconds: 3),
            ),
          );
        },
      ),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF161B22),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ───────────────────────────────────────────────────────
          Row(children: const [
            Icon(Icons.account_tree,
                color: Color(0xFF4CAF50), size: 15),
            SizedBox(width: 6),
            Text('Binary Search Tree',
                style: TextStyle(
                    color: Color(0xFF4CAF50),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'monospace')),
            SizedBox(width: 6),
            Text('(BST — no duplicates)',
                style: TextStyle(
                    color: Color(0xFF4B5563),
                    fontSize: 10,
                    fontFamily: 'monospace')),
          ]),
          const SizedBox(height: 8),

          // ── Input field ───────────────────────────────────────────────────
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF0F1117),
              border: Border.all(color: const Color(0xFF30363D)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(children: [
              const Text('Nodes:',
                  style: TextStyle(
                      color: Color(0xFF8B949E),
                      fontSize: 12,
                      fontFamily: 'monospace')),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _ctrl,
                  style: const TextStyle(
                      color: Color(0xFFE2E8F0),
                      fontSize: 12,
                      fontFamily: 'monospace'),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    hintText: 'e.g. 50,30,70,20,40,60',
                    hintStyle: TextStyle(
                        color: Color(0xFF4B5563),
                        fontSize: 11,
                        fontFamily: 'monospace'),
                  ),
                  onSubmitted: (_) => _apply(),
                ),
              ),
            ]),
          ),
          const SizedBox(height: 8),

          // ── Buttons: Apply | Random | Draw ───────────────────────────────
          Row(children: [
            _solidBtn('Apply', const Color(0xFF2563EB), _apply),
            const SizedBox(width: 8),
            _solidBtn('Random', const Color(0xFF374151), _random),
            const SizedBox(width: 8),

            // Draw button
            GestureDetector(
              onTap: _openDraw,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withOpacity(0.12),
                  border: Border.all(
                      color: const Color(0xFF4CAF50).withOpacity(0.7)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.gesture,
                          color: Color(0xFF4CAF50), size: 14),
                      SizedBox(width: 5),
                      Text('Draw',
                          style: TextStyle(
                              color: Color(0xFF4CAF50),
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'monospace')),
                    ]),
              ),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _solidBtn(String label, Color color, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
          decoration: BoxDecoration(
              color: color, borderRadius: BorderRadius.circular(7)),
          child: Text(label,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'monospace')),
        ),
      );
}