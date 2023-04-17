import 'package:flutter/material.dart';

class Bubble extends StatelessWidget {
  final BorderRadius borderRadius;
  final Color color;
  final Widget child;
  final EdgeInsetsGeometry padding;

  const Bubble({
    required this.borderRadius,
    required this.color,
    required this.child,
    this.padding = const EdgeInsets.all(24.0),
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: borderRadius,
      ),
      child: child,
    );
  }
}
