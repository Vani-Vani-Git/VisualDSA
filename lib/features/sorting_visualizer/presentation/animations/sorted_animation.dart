import 'package:flutter/material.dart';

/// Scales a bar up slightly when it lands in its sorted position.
class SortedAnimationWrapper extends StatefulWidget {
  final bool isSorted;
  final Widget child;

  const SortedAnimationWrapper({
    super.key,
    required this.isSorted,
    required this.child,
  });

  @override
  State<SortedAnimationWrapper> createState() => _SortedAnimationWrapperState();
}

class _SortedAnimationWrapperState extends State<SortedAnimationWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  bool _popped = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _scale = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.08), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 1.08, end: 1.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void didUpdateWidget(SortedAnimationWrapper old) {
    super.didUpdateWidget(old);
    if (widget.isSorted && !old.isSorted && !_popped) {
      _popped = true;
      _ctrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scale,
      builder: (_, child) =>
          Transform.scale(scale: _scale.value, child: child),
      child: widget.child,
    );
  }
}