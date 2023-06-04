import "package:csi_door_logs/utils/enums.dart";
import "package:csi_door_logs/utils/styles.dart";
import "package:csi_door_logs/widgets/pible/pible_bubble.dart";
import "package:flutter/material.dart";

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
        return deepGray;
    }
  }

  String generateText() {
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

  Widget generateTrailingWidget() {
    switch (state) {
      case BTServiceState.waiting:
      case BTServiceState.discovering:
        return const CircularProgressIndicator.adaptive(
          backgroundColor: lightGray,
          valueColor: AlwaysStoppedAnimation(Colors.white),
        );
      case BTServiceState.done:
        return doneIcon;
      case BTServiceState.failed:
        return failedIcon;
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
