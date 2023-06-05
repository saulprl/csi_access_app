import "package:flutter/material.dart";

import "package:flutter_blue_plus/flutter_blue_plus.dart";

import "package:csi_door_logs/widgets/animations/index.dart";
import "package:csi_door_logs/widgets/main/index.dart";
import "package:csi_door_logs/widgets/pible/pible_bubble.dart";

import "package:csi_door_logs/utils/styles.dart";

class DeviceBubble extends StatelessWidget {
  final BluetoothDeviceState state;
  final VoidCallback? onTap;
  final double iconSize = 30.0;
  final Color iconColor = Colors.white;

  const DeviceBubble({required this.state, this.onTap, super.key});

  Color generateColor(BuildContext context) {
    switch (state) {
      case BluetoothDeviceState.connected:
        return Theme.of(context).colorScheme.tertiary;
      case BluetoothDeviceState.connecting:
        return Theme.of(context).colorScheme.tertiary.withOpacity(0.7);
      case BluetoothDeviceState.disconnected:
        return deepGray;
      case BluetoothDeviceState.disconnecting:
        return deepGray.withOpacity(0.7);
    }
  }

  String get generateText {
    switch (state) {
      case BluetoothDeviceState.connected:
        return "Connected to PiBLE";
      case BluetoothDeviceState.connecting:
        return "Connecting to PiBLE...";
      case BluetoothDeviceState.disconnected:
        return "Disconnected from PiBLE";
      case BluetoothDeviceState.disconnecting:
        return "Disconnecting from PiBLE...";
    }
  }

  Widget get generateTrailingWidget {
    switch (state) {
      case BluetoothDeviceState.connected:
        return doneIcon;
      case BluetoothDeviceState.disconnected:
        return failedIcon;
      case BluetoothDeviceState.connecting:
      case BluetoothDeviceState.disconnecting:
        return const AdaptiveSpinner();
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusText = generateText;

    return PibleBubble(
      backgroundColor: generateColor(context),
      onTap: onTap,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: CustomSwitcher(child: generateTrailingWidget),
        ),
        CustomSwitcher(
          transitionBuilder: (child, animation) {
            return FadeTransition(opacity: animation, child: child);
          },
          child: Text(
            statusText,
            key: ValueKey("Device $statusText"),
            style: pibleBubbleTextStyle,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
