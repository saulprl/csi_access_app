import 'package:flutter/material.dart';

class Bubble extends StatefulWidget {
  final BorderRadius borderRadius;
  final Color color;
  // final Widget child;
  final EdgeInsetsGeometry padding;
  final CrossAxisAlignment crossAlignment;
  final int? data;
  final String label;
  final TextAlign textAlign;
  final bool reversed;
  final Duration duration;

  const Bubble({
    this.data,
    required this.label,
    required this.borderRadius,
    required this.color,
    // required this.child,
    this.crossAlignment = CrossAxisAlignment.start,
    this.padding = const EdgeInsets.all(24.0),
    this.textAlign = TextAlign.start,
    this.reversed = false,
    this.duration = const Duration(milliseconds: 750),
    super.key,
  });

  @override
  State<Bubble> createState() => _BubbleState();
}

class _BubbleState extends State<Bubble> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: duration,
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const style = TextStyle(
      color: Colors.white,
      overflow: TextOverflow.clip,
    );

    final children = <Widget>[
      Text(
        data?.toString().padLeft(2, '0') ?? "--",
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

    return AnimatedBuilder(
      animation: _controller,
      builder: (ctx, _) => AnimatedOpacity(
        opacity: data != null ? 1.0 : _controller.value,
        duration: duration,
        child: Container(
          padding: padding,
          decoration: BoxDecoration(color: color, borderRadius: borderRadius),
          child: Column(
            crossAxisAlignment: crossAlignment,
            children: reversed ? children.reversed.toList() : children,
          ),
        ),
      ),
    );
  }

  BorderRadius get borderRadius => widget.borderRadius;
  Color get color => widget.color;
  EdgeInsetsGeometry get padding => widget.padding;
  CrossAxisAlignment get crossAlignment => widget.crossAlignment;
  int? get data => widget.data;
  String get label => widget.label;
  TextAlign get textAlign => widget.textAlign;
  bool get reversed => widget.reversed;
  Duration get duration => widget.duration;
}
