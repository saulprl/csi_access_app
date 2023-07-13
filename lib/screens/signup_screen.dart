import "package:flutter/material.dart";

import "package:csi_door_logs/widgets/auth/signup_form.dart";

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  double _transitionValue = 0.0;

  @override
  void initState() {
    super.initState();
    _startTransition();
  }

  void _startTransition() {
    Future.delayed(const Duration(milliseconds: 750), () {
      setState(() {
        _transitionValue = 1.0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                alignment: Alignment.center,
                color: Theme.of(context).colorScheme.primary,
                child: Image.asset("assets/Access_splash.png", height: 300.0),
              ),
            ),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeInOutCubic,
              left: (1 - _transitionValue) * size.width,
              right: -_transitionValue * size.width,
              top: 0,
              bottom: 0,
              child: Container(
                color: Colors.white,
              ),
            ),
            const SignupForm(),
          ],
        ),

        // SingleChildScrollView(
        //   child:
        // ),
      ),
    );
  }
}
