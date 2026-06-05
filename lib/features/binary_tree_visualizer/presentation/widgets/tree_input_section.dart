import 'dart:math';
import 'package:flutter/material.dart';

class TreeInputSection extends StatefulWidget {
  final String initialValue;
  final void Function(List<int> values) onArrayChanged;
  final VoidCallback onDrawTap;

  const TreeInputSection({
    super.key,
    required this.initialValue,
    required this.onArrayChanged,
    required this.onDrawTap,
  });

  @override
  State<TreeInputSection> createState() => _TreeInputSectionState();
}

class _TreeInputSectionState extends State<TreeInputSection> {
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
    final len = rng.nextInt(5) + 5;
    final set = <int>{};
    while (set.length < len) set.add(rng.nextInt(90) + 5);
    final list = set.toList();
    _ctrl.text = list.join(',');
    widget.onArrayChanged(list);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF161B22),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: const [
            Icon(Icons.account_tree, color: Color(0xFF3B82F6), size: 15),
            SizedBox(width: 6),
            Text('Binary Tree',
                style: TextStyle(
                    color: Color(0xFF3B82F6),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'monospace')),
            SizedBox(width: 6),
            Text('(level-order input)',
                style: TextStyle(
                    color: Color(0xFF4B5563),
                    fontSize: 11,
                    fontFamily: 'monospace')),
          ]),
          const SizedBox(height: 8),
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
                    hintText: 'e.g. 1,2,3,4,5',
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
          Row(children: [
            _btn('Apply', const Color(0xFF2563EB), _apply),
            const SizedBox(width: 8),
            _btn('Random', const Color(0xFF374151), _random),
            const SizedBox(width: 8),
            // ── DRAW button replacing Upload ──────────────────────────────
            GestureDetector(
              onTap: widget.onDrawTap,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: const Color(0xFF7C3AED),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.draw_outlined,
                        color: Colors.white, size: 13),
                    SizedBox(width: 5),
                    Text('Draw',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'monospace')),
                  ],
                ),
              ),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _btn(String label, Color color, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
              color: color, borderRadius: BorderRadius.circular(8)),
          child: Text(label,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'monospace')),
        ),
      );
}