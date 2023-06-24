import "package:csi_door_logs/utils/styles.dart";
import "package:flutter/material.dart";

class AdaptiveSpinner extends StatelessWidget {
  final Color color;
  final Color? backgroundColor;

  const AdaptiveSpinner({
    this.backgroundColor,
    this.color = Colors.white,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return CircularProgressIndicator.adaptive(
      backgroundColor: backgroundColor ?? lightGray,
      valueColor: AlwaysStoppedAnimation(color),
    );
  }
}
