import "package:csi_door_logs/widgets/main/adaptive_spinner.dart";
import "package:flutter/material.dart";

class SplashScreen extends StatelessWidget {
  final String? message;
  final bool error;

  const SplashScreen({this.message, this.error = false, super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: SafeArea(
        child: Stack(
          children: [
            message != null
                ? Align(
                    alignment: Alignment.bottomCenter,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!error) const AdaptiveSpinner(),
                        const SizedBox(height: 20.0),
                        Text(
                          message!,
                          style: const TextStyle(color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20.0),
                      ],
                    ),
                  )
                : Container(
                    alignment: Alignment.bottomCenter,
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: const AdaptiveSpinner(),
                  ),
            Center(
              child: Image.asset(
                "assets/access_logo_fg.png",
                width: size.width * 0.8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
