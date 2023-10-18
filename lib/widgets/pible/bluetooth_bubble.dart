import "package:csi_door_logs/utils/styles.dart";
import "package:csi_door_logs/widgets/animations/index.dart";
import "package:csi_door_logs/widgets/pible/pible_bubble.dart";
import "package:flutter/material.dart";

class BluetoothBubble extends StatelessWidget {
  final bool isBluetoothOn;

  const BluetoothBubble({required this.isBluetoothOn, super.key});

  @override
  Widget build(BuildContext context) {
    final statusText = isBluetoothOn ? "Bluetooth: On" : "Bluetooth: Off";

    return PibleBubble(
      backgroundColor:
          isBluetoothOn ? Theme.of(context).colorScheme.tertiary : darkColor,
      children: [
        CustomSwitcher(
          transitionBuilder: (child, animation) {
            return FadeTransition(opacity: animation, child: child);
          },
          child: Text(
            statusText,
            key: ValueKey("Bluetooth $statusText"),
            style: pibleBubbleTextStyle,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
