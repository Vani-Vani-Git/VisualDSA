import 'package:flutter/material.dart';

enum ArrayBoxState { normal, compare, swap, sorted, insert, update, delete }

class ArrayBox extends StatelessWidget {
  final int value;
  final int index;
  final ArrayBoxState boxState;

  const ArrayBox({
    super.key,
    required this.value,
    required this.index,
    this.boxState = ArrayBoxState.normal,
  });

  Color get _borderColor {
    switch (boxState) {
      case ArrayBoxState.compare:
        return const Color(0xFFA78BFA);
      case ArrayBoxState.swap:
        return const Color(0xFFF59E0B);
      case ArrayBoxState.sorted:
        return const Color(0xFF22C55E);
      case ArrayBoxState.insert:
        return const Color(0xFFF59E0B);
      case ArrayBoxState.update:
        return const Color(0xFF22D3EE);
      case ArrayBoxState.delete:
        return const Color(0xFFEF4444);
      case ArrayBoxState.normal:
        return const Color(0xFF3B82F6);
    }
  }

  Color get _bgColor {
    switch (boxState) {
      case ArrayBoxState.compare:
        return const Color(0xFFA78BFA).withOpacity(0.18);
      case ArrayBoxState.swap:
        return const Color(0xFFF59E0B).withOpacity(0.18);
      case ArrayBoxState.sorted:
        return const Color(0xFF22C55E).withOpacity(0.13);
      case ArrayBoxState.insert:
        return const Color(0xFFF59E0B).withOpacity(0.22);
      case ArrayBoxState.update:
        return const Color(0xFF22D3EE).withOpacity(0.22);
      case ArrayBoxState.delete:
        return const Color(0xFFEF4444).withOpacity(0.22);
      case ArrayBoxState.normal:
        return const Color(0xFF3B82F6).withOpacity(0.08);
    }
  }

  List<BoxShadow> get _shadows {
    if (boxState == ArrayBoxState.normal) return [];
    final color = _borderColor;
    return [
      BoxShadow(
        color: color.withOpacity(0.5),
        blurRadius: 12,
        spreadRadius: 2,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: _bgColor,
        border: Border.all(color: _borderColor, width: 2),
        borderRadius: BorderRadius.circular(12),
        boxShadow: _shadows,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$value',
            style: const TextStyle(
              color: Color(0xFFE2E8F0),
              fontSize: 15,
              fontWeight: FontWeight.w700,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}