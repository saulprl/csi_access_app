import "package:csi_door_logs/utils/styles.dart";
import "package:csi_door_logs/widgets/pible/pible_bubble.dart";
import "package:flutter/material.dart";

import "package:csi_door_logs/utils/enums.dart";

class AuthBubble extends StatelessWidget {
  final LocalAuthState state;

  const AuthBubble({required this.state, super.key});

  Color generateColor(BuildContext context) {
    final orange = Theme.of(context).colorScheme.error;

    switch (state) {
      case LocalAuthState.waiting:
        return orange.withOpacity(0.65);
      case LocalAuthState.authenticating:
        return orange;
      case LocalAuthState.done:
        return Theme.of(context).colorScheme.tertiary;
      case LocalAuthState.failed:
        return deepGray;
    }
  }

  String generateText() {
    switch (state) {
      case LocalAuthState.waiting:
        return "Waiting for service...";
      case LocalAuthState.authenticating:
        return "Authenticating...";
      case LocalAuthState.done:
        return "Authenticated!";
      case LocalAuthState.failed:
        return "Authentication failed";
    }
  }

  Widget generateTrailingWidget() {
    switch (state) {
      case LocalAuthState.waiting:
      case LocalAuthState.authenticating:
        return const CircularProgressIndicator.adaptive(
          backgroundColor: lightGray,
          valueColor: AlwaysStoppedAnimation(Colors.white),
        );
      case LocalAuthState.done:
        return doneIcon;
      case LocalAuthState.failed:
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
