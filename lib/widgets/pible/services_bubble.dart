import "package:flutter/material.dart";

import "package:csi_door_logs/widgets/animations/index.dart";
import "package:csi_door_logs/widgets/main/index.dart";
import "package:csi_door_logs/widgets/pible/pible_bubble.dart";

import "package:csi_door_logs/utils/enums.dart";
import "package:csi_door_logs/utils/styles.dart";

class ServicesBubble extends StatelessWidget {
  final BTServiceState state;

  const ServicesBubble({required this.state, super.key});

  Color generateColor(BuildContext context) {
    final orange = Theme.of(context).colorScheme.error;

    switch (state) {
      case BTServiceState.waiting:
        return orange.withOpacity(0.65);
      case BTServiceState.discovering:
        return orange;
      case BTServiceState.done:
        return Theme.of(context).colorScheme.tertiary;
      case BTServiceState.failed:
        return darkColor;
    }
  }

  String get generateText {
    switch (state) {
      case BTServiceState.waiting:
        return "Waiting for device...";
      case BTServiceState.discovering:
        return "Reading device services...";
      case BTServiceState.done:
        return "Found Access service";
      case BTServiceState.failed:
        return "Unable to find Access service";
    }
  }

  Widget get generateTrailingWidget {
    switch (state) {
      case BTServiceState.done:
        return doneIcon;
      case BTServiceState.failed:
        return failedIcon;
      default:
        return const AdaptiveSpinner();
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusText = generateText;

    return PibleBubble(
      backgroundColor: generateColor(context),
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
            key: ValueKey("Services: $statusText"),
            style: pibleBubbleTextStyle,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
