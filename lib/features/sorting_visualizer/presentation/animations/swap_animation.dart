import 'package:flutter/material.dart';

/// Wraps a bar widget and shakes it horizontally when [isSwapping] is true.
class SwapAnimationWrapper extends StatefulWidget {
  final bool isSwapping;
  final Widget child;

  const SwapAnimationWrapper({
    super.key,
    required this.isSwapping,
    required this.child,
  });

  @override
  State<SwapAnimationWrapper> createState() => _SwapAnimationWrapperState();
}

class _SwapAnimationWrapperState extends State<SwapAnimationWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _shake;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _shake = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -3.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -3.0, end: 3.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 3.0, end: 0.0), weight: 1),
    ]).animate(_ctrl);
  }

  @override
  void didUpdateWidget(SwapAnimationWrapper old) {
    super.didUpdateWidget(old);
    if (widget.isSwapping && !old.isSwapping) {
      _ctrl.forward(from: 0);
    } else if (!widget.isSwapping) {
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
    if (!widget.isSwapping) return widget.child;
    return AnimatedBuilder(
      animation: _shake,
      builder: (_, child) =>
          Transform.translate(offset: Offset(_shake.value, 0), child: child),
      child: widget.child,
    );
  }
}