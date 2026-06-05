import 'package:flutter/material.dart';

/// Animates an edge highlight by scaling the indicator in when it becomes active.
class EdgeHighlightAnimation extends StatefulWidget {
  final bool isActive;
  final Widget child;
  const EdgeHighlightAnimation({super.key, required this.isActive, required this.child});
  @override
  State<EdgeHighlightAnimation> createState() => _EdgeHighlightAnimationState();
}

class _EdgeHighlightAnimationState extends State<EdgeHighlightAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);
  }

  @override
  void didUpdateWidget(EdgeHighlightAnimation old) {
    super.didUpdateWidget(old);
    if (widget.isActive && !old.isActive) _ctrl.forward(from: 0);
    else if (!widget.isActive) _ctrl.reset();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    if (!widget.isActive) return widget.child;
    return AnimatedBuilder(
      animation: _scale,
      builder: (_, child) => Transform.scale(scale: 0.8 + _scale.value * 0.2, child: child),
      child: widget.child,
    );
  }
}