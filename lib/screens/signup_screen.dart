import "package:flutter/material.dart";

import "package:csi_door_logs/widgets/auth/signup_form.dart";

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        iconTheme: IconThemeData(
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 32.0),
              Image.asset("assets/CSI_PRO_Access_Logotipo_inverted.png"),
              const SignupForm(),
            ],
          ),
        ),
      ),
    );
  }
}
