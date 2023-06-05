import "package:flutter/material.dart";

class CustomSwitcher extends StatelessWidget {
  final Widget child;
  final Duration? duration;
  final Widget Function(Widget, Animation<double>)? transitionBuilder;

  const CustomSwitcher({
    required this.child,
    this.duration,
    this.transitionBuilder,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: duration ?? const Duration(milliseconds: 400),
      transitionBuilder: transitionBuilder ??
          (child, animation) {
            return ScaleTransition(scale: animation, child: child);
          },
      child: child,
    );
  }
}
