import 'dart:math';
import 'package:flutter/material.dart';

class ArrayInputSection extends StatefulWidget {
  final String initialValue;
  final void Function(List<int> array) onArrayChanged;

  const ArrayInputSection({
    super.key,
    required this.initialValue,
    required this.onArrayChanged,
  });

  @override
  State<ArrayInputSection> createState() => _ArrayInputSectionState();
}

class _ArrayInputSectionState extends State<ArrayInputSection> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _applyArray() {
    final nums = _controller.text
        .split(',')
        .map((s) => int.tryParse(s.trim()))
        .whereType<int>()
        .toList();
    if (nums.isNotEmpty) {
      widget.onArrayChanged(nums);
    }
  }

  void _randomArray() {
    final rng = Random();
    final len = rng.nextInt(5) + 5;
    final arr = List.generate(len, (_) => rng.nextInt(99) + 1);
    _controller.text = arr.join(',');
    widget.onArrayChanged(arr);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF161B22),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          const Text(
            'Array:',
            style: TextStyle(
              color: Color(0xFF8B949E),
              fontSize: 13,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _controller,
              style: const TextStyle(
                color: Color(0xFFE2E8F0),
                fontSize: 14,
                fontFamily: 'monospace',
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              onSubmitted: (_) => _applyArray(),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _applyArray,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
              decoration: BoxDecoration(
                color: const Color(0xFF2563EB),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Apply',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _randomArray,
            child: const Text(
              'Random',
              style: TextStyle(
                color: Color(0xFFE2E8F0),
                fontSize: 13,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }
}