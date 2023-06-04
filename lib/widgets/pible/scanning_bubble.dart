import "package:csi_door_logs/utils/styles.dart";
import "package:csi_door_logs/widgets/pible/pible_bubble.dart";
import "package:flutter/material.dart";

class ScanningBubble extends StatelessWidget {
  final bool isScanning;
  final VoidCallback? restartScan;

  const ScanningBubble({required this.isScanning, this.restartScan, super.key});

  @override
  Widget build(BuildContext context) {
    return PibleBubble(
      backgroundColor:
          isScanning ? Theme.of(context).colorScheme.tertiary : deepGray,
      backgroundIcon: !isScanning ? Icons.refresh : null,
      onTap: restartScan,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            isScanning ? "Scanning devices..." : "Scan stopped",
            style: pibleBubbleTextStyle,
          ),
          if (isScanning)
            const CircularProgressIndicator.adaptive(
              backgroundColor: lightGray,
              valueColor: AlwaysStoppedAnimation(Colors.white),
            ),
        ],
      ),
    );
  }
}
