import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:csi_door_logs/providers/auth_provider.dart';

import 'package:csi_door_logs/widgets/main/adaptive_spinner.dart';
import 'package:csi_door_logs/widgets/auth/auth_button.dart';

import 'package:csi_door_logs/utils/styles.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  var _isLoading = false;

  final String joke = "Nope - wrong option!";
  final String serious = "Sign in with email";
  var _emailProvider = "Sign in with email";

  void showModal(String message) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text("Error"),
          content: Text(message, style: const TextStyle(fontSize: 18.0)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text(
                "OK",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void signInWithGitHub() {
    setState(() => _isLoading = true);
    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      auth.signInWithGitHub();
    } catch (error) {
      showModal(error.toString());
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void signInWithGoogle() {
    setState(() => _isLoading = true);
    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      auth.signInWithGoogle();
    } catch (error) {
      showModal(error.toString());
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 8.0,
            horizontal: 16.0,
          ),
          child: Column(
            children: [
              AuthButton(
                onPressed: signInWithGitHub,
                providerImage:
                    Image.asset("assets/auth_providers/github-mark.png"),
                providerName: "GitHub",
              ),
              const SizedBox(height: 16.0),
              AuthButton(
                onPressed: signInWithGoogle,
                providerImage:
                    Image.asset("assets/auth_providers/google-g.png"),
                providerName: "Google",
              ),
              const SizedBox(height: 16.0),
              AuthButton(
                onPressed: () {
                  if (_emailProvider == joke) return;
                  setState(() => _emailProvider = joke);

                  Future.delayed(
                    const Duration(seconds: 5),
                    () {
                      if (mounted) {
                        setState(() => _emailProvider = serious);
                      }
                    },
                  );
                },
                providerImage: Icon(
                  emailIcon,
                  color: Colors.black38,
                  size: 32.0,
                ),
                providerName: "email",
                label: _emailProvider,
                color: Colors.black38,
              ),
            ],
          ),
        ),
        if (_isLoading)
          Container(
            alignment: Alignment.bottomCenter,
            padding: const EdgeInsets.only(bottom: 20.0),
            child: const AdaptiveSpinner(),
          )
      ],
    );
  }
}
