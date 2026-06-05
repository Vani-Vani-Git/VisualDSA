import 'package:flutter/material.dart';

/// Pulses a cell/node when it becomes the active highlight.
class CellHighlightAnimation extends StatefulWidget {
  final bool isActive;
  final Widget child;
  const CellHighlightAnimation({super.key, required this.isActive, required this.child});
  @override
  State<CellHighlightAnimation> createState() => _CellHighlightAnimationState();
}

class _CellHighlightAnimationState extends State<CellHighlightAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _pulse;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600))
      ..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.6, end: 1.0).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }
  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    if (!widget.isActive) return widget.child;
    return AnimatedBuilder(
      animation: _pulse,
      builder: (_, child) => Opacity(opacity: _pulse.value, child: child),
      child: widget.child,
    );
  }
}