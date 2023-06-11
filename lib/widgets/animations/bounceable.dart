import 'package:flutter/material.dart';

class Bounceable extends StatefulWidget {
  final Widget child;
  final VoidCallback onPressed;
  final double scaleFactor;
  final Duration duration;
  final bool stayOnBottom;

  const Bounceable({
    required this.child,
    required this.onPressed,
    this.scaleFactor = 1,
    this.duration = const Duration(milliseconds: 300),
    this.stayOnBottom = false,
    super.key,
  });

  @override
  State<Bounceable> createState() => _BounceableState();
}

class _BounceableState extends State<Bounceable>
    with SingleTickerProviderStateMixin {
  final _childKey = GlobalKey();

  late AnimationController _controller;
  late double _scale;

  bool _isOutside = false;

  Widget get child => widget.child;
  VoidCallback get onPressed => widget.onPressed;
  double get scaleFactor => widget.scaleFactor;
  Duration get duration => widget.duration;
  bool get stayOnBottom => widget.stayOnBottom;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: duration,
      lowerBound: 0.0,
      upperBound: 0.1,
    )..addListener(() => setState(() {}));
  }

  @override
  void didUpdateWidget(covariant Bounceable oldWidget) {
    if (oldWidget.stayOnBottom != stayOnBottom) {
      if (!stayOnBottom) {
        _reverseAnimation();
      }
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _scale = 1 - (_controller.value * scaleFactor);

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onLongPressEnd: (details) => _onLongPressEnd(details, context),
      onHorizontalDragEnd: _onDragEnd,
      onVerticalDragEnd: _onDragEnd,
      onHorizontalDragUpdate: (details) => _onDragUpdate(details, context),
      onVerticalDragUpdate: (details) => _onDragUpdate(details, context),
      child: Transform.scale(
        key: _childKey,
        scale: _scale,
        child: child,
      ),
    );
  }

  _triggerOnPressed() {
    onPressed();
  }

  _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  _onTapUp(TapUpDetails details) {
    if (!stayOnBottom) {
      Future.delayed(duration, () => _reverseAnimation());
    }

    _triggerOnPressed();
  }

  _onDragUpdate(DragUpdateDetails details, BuildContext ctx) {
    final touchPosition = details.globalPosition;
    _isOutside = _isOutsideChildBox(touchPosition);
  }

  _onLongPressEnd(LongPressEndDetails details, BuildContext ctx) {
    final touchPosition = details.globalPosition;
    if (!_isOutsideChildBox(touchPosition)) {
      _triggerOnPressed();
    }

    _reverseAnimation();
  }

  _onDragEnd(DragEndDetails details) {
    if (!_isOutside) {
      _triggerOnPressed();
    }

    _reverseAnimation();
  }

  _reverseAnimation() {
    if (mounted) {
      _controller.reverse();
    }
  }

  bool _isOutsideChildBox(Offset touchPosition) {
    final childRenderBox =
        _childKey.currentContext?.findRenderObject() as RenderBox?;

    if (childRenderBox == null) return true;

    final childSize = childRenderBox.size;
    final childPosition = childRenderBox.localToGlobal(Offset.zero);

    final isVerticallyOutside = touchPosition.dy < childPosition.dy ||
        touchPosition.dy > childPosition.dy + childSize.height;
    final isHorizontallyOutside = touchPosition.dx < childPosition.dx ||
        touchPosition.dx > childPosition.dx + childSize.width;

    return isVerticallyOutside || isHorizontallyOutside;
  }
}
