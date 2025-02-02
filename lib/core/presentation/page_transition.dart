import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// A widget that handles page transitions for bottom navigation.
class PageTransition extends StatelessWidget {
  final Widget child;
  final bool isActive;
  final Duration duration;

  const PageTransition({
    super.key,
    required this.child,
    required this.isActive,
    this.duration = const Duration(milliseconds: 1000),
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !isActive,
      child: isActive
          ? child
              .animate()
              .blur(
                begin: const Offset(90, 90),
                end: const Offset(0, 0),
                curve: Curves.easeOutExpo,
                duration: duration,
              )
              .fadeIn(
                duration: duration,
                curve: Curves.ease,
              )
              .moveY(begin: 15, end: 0)
          : const SizedBox.shrink(),
    );
  }
}
