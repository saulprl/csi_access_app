import "package:csi_door_logs/utils/styles.dart";
import "package:csi_door_logs/widgets/pible/pible_bubble.dart";
import "package:flutter/material.dart";

class BluetoothBubble extends StatelessWidget {
  final bool isBluetoothOn;

  const BluetoothBubble({required this.isBluetoothOn, super.key});

  @override
  Widget build(BuildContext context) {
    return PibleBubble(
      backgroundColor:
          isBluetoothOn ? Theme.of(context).colorScheme.tertiary : deepGray,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            isBluetoothOn ? "Bluetooth on" : "Bluetooth off",
            style: pibleBubbleTextStyle,
          ),
        ],
      ),
    );
  }
}
