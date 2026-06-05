import 'package:flutter/material.dart';

/// Plays a quick scale-up "pop" when the target element is found.
class FoundAnimationWrapper extends StatefulWidget {
  final bool isFound;
  final Widget child;

  const FoundAnimationWrapper({
    super.key,
    required this.isFound,
    required this.child,
  });

  @override
  State<FoundAnimationWrapper> createState() => _FoundAnimationWrapperState();
}

class _FoundAnimationWrapperState extends State<FoundAnimationWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  bool _popped = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _scale = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.18), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 1.18, end: 0.95), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 0.95, end: 1.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void didUpdateWidget(FoundAnimationWrapper old) {
    super.didUpdateWidget(old);
    if (widget.isFound && !old.isFound && !_popped) {
      _popped = true;
      _ctrl.forward(from: 0);
    } else if (!widget.isFound) {
      _popped = false;
      _ctrl.reset();
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