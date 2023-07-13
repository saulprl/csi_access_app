import "package:flutter/material.dart";

class SplashScreen extends StatelessWidget {
  final String? message;
  final bool error;

  const SplashScreen({this.message, this.error = false, super.key});

  @override
  Widget build(BuildContext context) {
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
                        if (!error)
                          const CircularProgressIndicator.adaptive(
                            backgroundColor: Colors.white,
                          ),
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
                    child: const CircularProgressIndicator.adaptive(
                      backgroundColor: Colors.white,
                    ),
                  ),
            Center(
              child: Image.asset("assets/Access_splash.png", height: 300.0),
            ),
          ],
        ),
      ),
    );
  }
}
