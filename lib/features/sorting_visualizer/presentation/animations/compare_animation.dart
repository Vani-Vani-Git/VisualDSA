import 'package:flutter/material.dart';

/// Pulses a bar with a purple glow when [isComparing] is true.
class CompareAnimationWrapper extends StatefulWidget {
  final bool isComparing;
  final Widget child;

  const CompareAnimationWrapper({
    super.key,
    required this.isComparing,
    required this.child,
  });

  @override
  State<CompareAnimationWrapper> createState() =>
      _CompareAnimationWrapperState();
}

class _CompareAnimationWrapperState extends State<CompareAnimationWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isComparing) return widget.child;
    return AnimatedBuilder(
      animation: _pulse,
      builder: (_, child) => Opacity(opacity: _pulse.value, child: child),
      child: widget.child,
    );
  }
}