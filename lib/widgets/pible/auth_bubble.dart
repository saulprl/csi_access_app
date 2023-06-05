import "package:flutter/material.dart";

import "package:csi_door_logs/widgets/animations/index.dart";
import "package:csi_door_logs/widgets/main/index.dart";
import "package:csi_door_logs/widgets/pible/pible_bubble.dart";

import "package:csi_door_logs/utils/enums.dart";
import "package:csi_door_logs/utils/styles.dart";

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

  String get generateText {
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

  Widget get generateTrailingWidget {
    switch (state) {
      case LocalAuthState.done:
        return doneIcon;
      case LocalAuthState.failed:
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
            key: ValueKey("Auth $statusText"),
            style: pibleBubbleTextStyle,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
