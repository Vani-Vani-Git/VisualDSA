import 'dart:math';
import 'package:flutter/material.dart';

class HeapArrayInputSection extends StatefulWidget {
  final List<int> initialArray;
  final int maxSize;
  final void Function(List<int> array) onArrayChanged;

  const HeapArrayInputSection({
    super.key,
    required this.initialArray,
    required this.maxSize,
    required this.onArrayChanged,
  });

  @override
  State<HeapArrayInputSection> createState() =>
      _HeapArrayInputSectionState();
}

class _HeapArrayInputSectionState extends State<HeapArrayInputSection> {
  late TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initialArray.join(','));
  }

  @override
  void didUpdateWidget(HeapArrayInputSection old) {
    super.didUpdateWidget(old);
    final newText = widget.initialArray.join(',');
    if (_ctrl.text != newText) _ctrl.text = newText;
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
        .where((n) => n >= 1 && n <= 999)
        .take(widget.maxSize)
        .toList();
    if (nums.isNotEmpty) widget.onArrayChanged(nums);
  }

  void _random() {
    final rng = Random();
    final len = rng.nextInt(8) + 4; // 4–11 nodes
    final arr = List.generate(len, (_) => rng.nextInt(90) + 10);
    _ctrl.text = arr.join(',');
    widget.onArrayChanged(arr);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF161B22),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          const Text('Array:',
              style: TextStyle(
                  color: Color(0xFF8B949E),
                  fontSize: 13,
                  fontFamily: 'monospace')),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _ctrl,
              style: const TextStyle(
                  color: Color(0xFFE2E8F0),
                  fontSize: 13,
                  fontFamily: 'monospace'),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
                hintText: 'e.g. 35,33,42,10',
                hintStyle: TextStyle(
                    color: Color(0xFF4B5563),
                    fontSize: 13,
                    fontFamily: 'monospace'),
              ),
              keyboardType: TextInputType.text,
              onSubmitted: (_) => _apply(),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _apply,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
              decoration: BoxDecoration(
                color: const Color(0xFF2563EB),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text('Apply',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'monospace')),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: _random,
            child: const Text('Random',
                style: TextStyle(
                    color: Color(0xFFE2E8F0),
                    fontSize: 13,
                    fontFamily: 'monospace')),
          ),
        ],
      ),
    );
  }
}