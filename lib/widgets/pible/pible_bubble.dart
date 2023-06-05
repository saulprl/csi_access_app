import "package:flutter/material.dart";

class PibleBubble extends StatefulWidget {
  final IconData? backgroundIcon;
  final Color backgroundColor;
  final double? height;
  final double? width;
  final BorderRadiusGeometry? borderRadius;
  final BoxShape? shape;
  final VoidCallback? onTap;
  final List<Widget> children;

  const PibleBubble({
    required this.children,
    required this.backgroundColor,
    this.backgroundIcon,
    this.onTap,
    this.height = 60.0,
    this.width = double.infinity,
    this.borderRadius = const BorderRadius.all(Radius.circular(16.0)),
    this.shape = BoxShape.rectangle,
    super.key,
  });

  @override
  State<PibleBubble> createState() => _PibleBubbleState();
}

class _PibleBubbleState extends State<PibleBubble> {
  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.of(context).size.height;

    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: AnimatedContainer(
        curve: Curves.easeOut,
        duration: const Duration(seconds: 1),
        clipBehavior: Clip.hardEdge,
        height: widget.height ?? 60.0,
        constraints: BoxConstraints(
          minHeight: 60.0,
          maxHeight: maxHeight * 0.6,
        ),
        decoration: BoxDecoration(
          borderRadius: widget.borderRadius,
          color: widget.backgroundColor,
        ),
        width: widget.width ?? double.infinity,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(
                vertical: 8.0,
                horizontal: 16.0,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: widget.children,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
