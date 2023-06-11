import 'package:csi_door_logs/widgets/animations/index.dart';
import 'package:flutter/material.dart';

class Bubble extends StatelessWidget {
  final BorderRadius borderRadius;
  final Color color;
  // final Widget child;
  final EdgeInsetsGeometry padding;
  final CrossAxisAlignment crossAlignment;
  final int data;
  final String label;
  final TextAlign textAlign;
  final bool reversed;

  const Bubble({
    required this.data,
    required this.label,
    required this.borderRadius,
    required this.color,
    // required this.child,
    this.crossAlignment = CrossAxisAlignment.start,
    this.padding = const EdgeInsets.all(24.0),
    this.textAlign = TextAlign.start,
    this.reversed = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    const style = TextStyle(
      color: Colors.white,
      overflow: TextOverflow.clip,
    );

    final children = <Widget>[
      Text(
        data.toString().padLeft(2, '0'),
        style: style.copyWith(
          fontSize: 52.0,
        ),
      ),
      Text(
        label.toLowerCase(),
        style: style.copyWith(
          fontSize: 20.0,
        ),
        textAlign: textAlign,
      ),
    ];

    return Bounceable(
      onPressed: () {},
      duration: const Duration(milliseconds: 125),
      scaleFactor: 0.35,
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: color,
          borderRadius: borderRadius,
          boxShadow: const [
            BoxShadow(
              color: Colors.black54,
              blurRadius: 4.0,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: crossAlignment,
          children: reversed ? children.reversed.toList() : children,
        ),
      ),
    );
  }
}
