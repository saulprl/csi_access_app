import "package:flutter/material.dart";

import "package:csi_door_logs/widgets/animations/index.dart";
import "package:csi_door_logs/widgets/main/index.dart";
import "package:csi_door_logs/widgets/pible/pible_bubble.dart";

import "package:csi_door_logs/utils/styles.dart";

class ScanningBubble extends StatelessWidget {
  final bool isScanning;
  final VoidCallback? onTap;

  const ScanningBubble({required this.isScanning, this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    final blue = Theme.of(context).colorScheme.tertiary;
    final statusText = isScanning ? "Scanning devices..." : "Scan stopped";

    return PibleBubble(
      backgroundColor: isScanning ? blue.withOpacity(0.7) : blue,
      backgroundIcon: onTap != null ? refreshIcon : null,
      onTap: onTap,
      children: [
        if (onTap != null)
          Align(
            alignment: Alignment.centerRight,
            child: Icon(
              refreshIcon,
              color: Colors.white,
              size: 44.0,
            ),
          ),
        if (isScanning)
          const Align(
            alignment: Alignment.centerRight,
            child: AdaptiveSpinner(),
          ),
        CustomSwitcher(
          transitionBuilder: (child, animation) {
            return FadeTransition(opacity: animation, child: child);
          },
          child: Text(
            statusText,
            key: ValueKey("Scanning $statusText"),
            style: pibleBubbleTextStyle,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
