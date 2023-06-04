import "package:csi_door_logs/utils/styles.dart";
import "package:csi_door_logs/widgets/pible/pible_bubble.dart";
import "package:flutter/material.dart";

import "package:flutter_blue_plus/flutter_blue_plus.dart";

class DeviceBubble extends StatelessWidget {
  final BluetoothDeviceState state;
  final double iconSize = 30.0;
  final Color iconColor = Colors.white;

  const DeviceBubble({required this.state, super.key});

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

  String generateText() {
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

  Widget generateTrailingWidget() {
    switch (state) {
      case BluetoothDeviceState.connected:
        return doneIcon;
      case BluetoothDeviceState.disconnected:
        return failedIcon;
      case BluetoothDeviceState.connecting:
      case BluetoothDeviceState.disconnecting:
        return const CircularProgressIndicator.adaptive(
          backgroundColor: lightGray,
          valueColor: AlwaysStoppedAnimation(Colors.white),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PibleBubble(
      backgroundColor: generateColor(context),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(generateText(), style: pibleBubbleTextStyle),
          generateTrailingWidget(),
        ],
      ),
    );
  }
}
