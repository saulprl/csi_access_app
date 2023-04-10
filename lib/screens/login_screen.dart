import "package:csi_door_logs/widgets/auth/login_form.dart";
import "package:flutter/material.dart";

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 88.0),
              Image.asset("assets/CSI_PRO_Access_Logotipo_inverted.png"),
              const SizedBox(height: 96.0),
              const LoginForm(),
            ],
          ),
        ),
      ),
    );
  }
}
