import "package:flutter/material.dart";

import "package:csi_door_logs/widgets/animations/index.dart";
import "package:csi_door_logs/widgets/main/index.dart";
import "package:csi_door_logs/widgets/pible/pible_bubble.dart";

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
        return Theme.of(context).colorScheme.tertiary;
      case EncryptionState.failed:
        return deepGray;
    }
  }

  String get generateText {
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

  Widget get generateTrailingWidget {
    switch (state) {
      case EncryptionState.done:
        return doneIcon;
      case EncryptionState.failed:
        return failedIcon;
      default:
        return const AdaptiveSpinner();
    }
  }

  Widget get generateChild {
    switch (state) {
      case EncryptionState.done:
        return const SingleChildScrollView(
          physics: NeverScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
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
        return Text(
          generateText,
          style: pibleBubbleTextStyle,
          textAlign: TextAlign.center,
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
      children: [
        AnimatedAlign(
          curve: Curves.easeInOut,
          duration: const Duration(milliseconds: 400),
          alignment:
              isEncrypted ? Alignment.bottomCenter : Alignment.centerRight,
          child: generateTrailingWidget,
        ),
        CustomSwitcher(
          transitionBuilder: (child, animation) {
            return FadeTransition(opacity: animation, child: child);
          },
          child: generateChild,
        ),
      ],
    );
  }
}
