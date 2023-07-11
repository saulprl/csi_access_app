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
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset("assets/Access_splash.png", height: 300.0),
              message != null
                  ? Column(
                      children: [
                        Text(
                          message!,
                          style: const TextStyle(color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20.0),
                        if (!error)
                          const CircularProgressIndicator.adaptive(
                            backgroundColor: Colors.white,
                          ),
                      ],
                    )
                  : const CircularProgressIndicator.adaptive(
                      backgroundColor: Colors.white,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
