import 'dart:math';
import 'package:flutter/material.dart';

/// Top bar — identical in appearance to the Searching dashboard's ArrayInputSection.
/// Shows:  Array: [comma-separated values]  [Apply]  Random
///
/// On Apply  → parses the text field, clamps each value 1–999, max [maxSize] items,
///             calls [onArrayChanged] with the new list (used as initial stack).
/// On Random → generates [maxSize] random values and calls [onArrayChanged].
class StackArrayInputSection extends StatefulWidget {
  final List<int> initialArray;
  final int maxSize;
  final void Function(List<int> array) onArrayChanged;

  const StackArrayInputSection({
    super.key,
    required this.initialArray,
    required this.maxSize,
    required this.onArrayChanged,
  });

  @override
  State<StackArrayInputSection> createState() =>
      _StackArrayInputSectionState();
}

class _StackArrayInputSectionState extends State<StackArrayInputSection> {
  late TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initialArray.join(','));
  }

  /// Keep the text field in sync when the parent commits a new stack
  /// (e.g. after a push/pop animation finishes).
  @override
  void didUpdateWidget(StackArrayInputSection old) {
    super.didUpdateWidget(old);
    // Only refresh if the field isn't focused (user isn't typing)
    if (!_ctrl.selection.isValid ||
        _ctrl.text != widget.initialArray.join(',')) {
      final hasFocus = FocusManager.instance.primaryFocus?.context
              ?.findAncestorWidgetOfExactType<StackArrayInputSection>() !=
          null;
      if (!hasFocus) {
        _ctrl.text = widget.initialArray.join(',');
      }
    }
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
        .take(widget.maxSize) // never exceed maxSize
        .toList();
    if (nums.isNotEmpty) {
      widget.onArrayChanged(nums);
    }
  }

  void _random() {
    final rng = Random();
    // Generate between 2 and maxSize random values
    final len = rng.nextInt(widget.maxSize - 1) + 2;
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
          // Label
          const Text(
            'Array:',
            style: TextStyle(
              color: Color(0xFF8B949E),
              fontSize: 13,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(width: 8),

          // Text field
          Expanded(
            child: TextField(
              controller: _ctrl,
              style: const TextStyle(
                color: Color(0xFFE2E8F0),
                fontSize: 13,
                fontFamily: 'monospace',
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
                hintText: 'e.g. 10,20,30',
                hintStyle: TextStyle(
                  color: Color(0xFF4B5563),
                  fontSize: 13,
                  fontFamily: 'monospace',
                ),
              ),
              keyboardType: TextInputType.text,
              onSubmitted: (_) => _apply(),
            ),
          ),

          const SizedBox(width: 8),

          // Apply button
          GestureDetector(
            onTap: _apply,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
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

          const SizedBox(width: 10),

          // Random button
          GestureDetector(
            onTap: _random,
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