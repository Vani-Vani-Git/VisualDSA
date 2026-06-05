import 'package:flutter/material.dart';

/// Plays a pop/bounce when a node becomes active in the list animation.
class NodePopAnimation extends StatefulWidget {
  final bool isActive;
  final Widget child;
  const NodePopAnimation({super.key, required this.isActive, required this.child});
  @override
  State<NodePopAnimation> createState() => _NodePopAnimationState();
}

class _NodePopAnimationState extends State<NodePopAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  bool _popped = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 350));
    _scale = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.2), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 0.92), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 0.92, end: 1.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void didUpdateWidget(NodePopAnimation old) {
    super.didUpdateWidget(old);
    if (widget.isActive && !old.isActive && !_popped) {
      _popped = true;
      _ctrl.forward(from: 0);
    } else if (!widget.isActive) {
      _popped = false;
      _ctrl.reset();
    }
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scale,
      builder: (_, child) => Transform.scale(scale: _scale.value, child: child),
      child: widget.child,
    );
  }
}
