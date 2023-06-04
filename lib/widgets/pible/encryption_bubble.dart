import "package:csi_door_logs/widgets/pible/pible_bubble.dart";
import "package:flutter/material.dart";

import "package:csi_door_logs/utils/enums.dart";
import "package:csi_door_logs/utils/styles.dart";

class EncryptionBubble extends StatelessWidget {
  final EncryptionState state;

  const EncryptionBubble({required this.state, super.key});

  Color generateColor(BuildContext context) {
    final orange = Theme.of(context).colorScheme.error;

    switch (state) {
      case EncryptionState.waiting:
        return orange.withOpacity(0.65);
      case EncryptionState.encrypting:
        return orange;
      case EncryptionState.done:
        return Theme.of(context).colorScheme.primary;
      case EncryptionState.failed:
        return deepGray;
    }
  }

  String generateText() {
    switch (state) {
      case EncryptionState.waiting:
        return "Waiting for auth...";
      case EncryptionState.encrypting:
        return "Encrypting data...";
      case EncryptionState.done:
        return "Welcome in!";
      case EncryptionState.failed:
        return "Something went wrong";
    }
  }

  Widget generateTrailingWidget() {
    switch (state) {
      case EncryptionState.waiting:
      case EncryptionState.encrypting:
        return const CircularProgressIndicator.adaptive(
          backgroundColor: lightGray,
          valueColor: AlwaysStoppedAnimation(Colors.white),
        );
      case EncryptionState.done:
        return doneIcon;
      case EncryptionState.failed:
        return failedIcon;
    }
  }

  Widget generateChild(bool isEncrypted) {
    switch (state) {
      case EncryptionState.done:
        return SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text("Welcome in!", style: pibleBubbleTextStyle),
              Text(
                "Don't forget to close the door!",
                style: pibleBubbleTextStyle,
              ),
              Text(
                "Navigating back to the Dashboard",
                style: pibleBubbleTextStyle,
              ),
            ],
          ),
        );
      default:
        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(generateText(), style: pibleBubbleTextStyle),
            if (!isEncrypted) generateTrailingWidget(),
          ],
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEncrypted = state == EncryptionState.done;

    final height = isEncrypted ? double.infinity : 60.0;
    final borderRadius = BorderRadius.circular(16.0);

    return PibleBubble(
      backgroundColor: generateColor(context),
      height: height,
      borderRadius: borderRadius,
      child: generateChild(isEncrypted),
    );
  }
}
